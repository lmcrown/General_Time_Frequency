function OUT = DAVIS_Spectrogram(LFP,window_sec, fq_range, PLOT_IT)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function OUT = DAVIS_Spectrogram(LFP,window_sec, fq_range)
% Create a spectrogram of the data in LFP
% LFP        - filename or LFP structure from DAVIS_Pre_Process
% window_sec - Bins over which to calculate power
% fq_range   - Frequency range to display
% Cowen & Mattenator 2016.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if  nargin < 1 | isempty(LFP);
    
    [LFP_name,path] = uigetfile('','Select LFP');
    LFP = fullfile(path,LFP_name);
else
    path = pwd;
end
if ischar(LFP)
    LFP = load(LFP);
end
if nargin < 3 | isempty(fq_range)
    fq_range = [1 160];
end
if nargin < 2 | isempty(window_sec)
    window_sec = 1;
end
if nargin < 4 | isempty(PLOT_IT)
    PLOT_IT = true;
end
% Cleaning section NAN out bad sections.
try LFP.bad_intervals;
catch
    LFP.bad_intervals = [1 2];
end
for i_interval = 1:size(LFP.bad_intervals,1)
LFP.values(...
        floor(LFP.bad_intervals(i_interval,1))...
        :ceil(LFP.bad_intervals(i_interval,2)))...
        = NaN();
end
blanked_Fq_range = [58.5 61.5]; % get rid of 60 hz.
% window_sec = 10;
% fNotch = 120;
window = round(LFP.sFreq*window_sec);
noverlap = round(window/2);
nfft = 4096;
if LFP.sFreq > 10000
    nfft = nfft*5
end
% L2 = Notch_filter(LFP.values,fNotch,round(LFP.sFreq));
[~, fq, ~, SPEC] = spectrogram(double(LFP.values),window,noverlap,nfft,round(LFP.sFreq));
BADIX = fq >= blanked_Fq_range(1) & fq <= blanked_Fq_range(2);
SPEC(BADIX,:) = [];
fq(BADIX) = [];
S = 10*log10(real(SPEC)); % From the matlab docs.
if ~isfield(LFP,'timestamps')
     LFP.timestamps = (1/LFP.sFreq):(1/LFP.sFreq):(length(LFP.values)/LFP.sFreq);
end
if ~isfield(LFP,'Channel')
    LFP.Channel = 'No Channel'
end
end_time_sec = LFP.timestamps(end)-LFP.timestamps(1);
S_time_sec = linspace(0,end_time_sec,size(S,2));
fq_IX = fq >= fq_range(1) & fq <= fq_range(2);
fq = fq(fq_IX);
S = S(fq_IX,:);
S = medfilt1(S,5); % The median filter that slides 1 window over and takes the median. Snew = converted power, 20 = window size
S = medfilt1(S',5)'; % Transposes it
OUT.S = S;
OUT.S_time_sec = S_time_sec;
OUT.fq = fq;
OUT.nfft = nfft;
OUT.window = window;
OUT.blanked_Fq_range = blanked_Fq_range;

%OUT.Smx = Smx; % controlled for inter-animal changes in peak frequency. Might be more reliable between animals.
%OUT.ranged_fq = ranged_fq;
%OUT.ranged_fq_labs = ranged_fq_labs;

if PLOT_IT
    OUT.hand = figure;
    clf
    imagesc(S_time_sec,fq,S);
    cax = prctile(S(:),[1 99]); % To improve the visualzation - removes outliers below 1% and above 99%
    caxis(cax)
    colorbar
    axis xy;
    hold on
    %     plot_markers_simple(bad_intervals_sec(:,1)/60)
    %     plot_markers_simple(bad_intervals_sec(:,2)/60)
    
    colorbar
    colormap(jet)
    ylabel('Hz')
    xlabel('Time (s)')
    % Channel Translation Label
    if exist(fullfile(path,'channel look up.xlsx'),'file') % Check if channel translation table exists
        % Read in the section of channel translation table we need
        [num text raw] = xlsread(fullfile(path,'channel look up.xlsx'),1,'A5:B20');
        % Find the indecies that match our channel number
        chan_title = cell2mat(raw(LFP.Channel == num,2));
        if isempty(chan_title) | isnan(chan_title) %If no label
            chan_title = ['Ch ' num2str(LFP.Channel)];
        else
            %Otherwise use the label
            chan_title = char(chan_title);
        end
    else
        % Mattenator 11/18/2016
        % Some LFPs have their channel number stored as cells, this will
        % check for that and use a method that works. 
        if iscell(LFP.Channel)
        chan_title = ['Ch ' num2str(cell2mat(LFP.Channel))];
        else
        chan_title = ['Ch ' num2str(LFP.Channel)];
        end
    end
    
    title(['Spectrogram ' chan_title])
    c = colorbar;
    c.Label.String = 'dB';
    % Plot the epochs
    if exist(fullfile(pwd,'Input to Analyze.xlsx'),'file')
        try
            [num text raw] = xlsread('Input to Analyze.xlsx',1);
            ispresent = cellfun(@(s) ~isempty(strfind(s, 'Epoch')), raw);
            [r_Epoch c_Epoch] = find(ispresent);
            for i = 1:length(c_Epoch)
                t(i,1) = cell2mat(raw(4,c_Epoch(i)  ));
                t(i,2) = cell2mat(raw(4,c_Epoch(i)+1));
            end
            t = t(~isnan(t(:,1)),:)/60; % Conver to minutes
            for i = 1:size(t,1)
                line([t(i,1) t(i,1)],fq_range,'Color',[1 1 1],'LineWidth',2)
                line([t(i,1) t(i,1)],fq_range,'Color',[0 1 0],'LineWidth',2,'LineStyle','--')
                line([t(i,2) t(i,2)],fq_range,'Color',[1 1 1],'LineWidth',2)
                line([t(i,2) t(i,2)],fq_range,'Color',[1 0 0],'LineWidth',2,'LineStyle','--')
            end
        catch
            display('Something went wrong getting epochs from the .xlsx.')
            display('Ignoring it.')
        end
    end
    %savefig(['Spectrogram_Ch' num2str(LFP.Channel)]);
    % Mattenator 7/27/2016 because causes strange errors and causes matlab
    % to crash. Prety hardcore.
    print(['Spectrogram_Zscore_Ch' num2str(LFP.Channel)],'-dpng');
end



