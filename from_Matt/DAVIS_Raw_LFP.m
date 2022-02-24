function[LFP] = DAVISRaw_LFP(LFP,times)
% function[LFP] = DAVISRaw_LFP(LFP,times)
% For viewing the raw LFP trace, with bd intervals plotted in red
% LFP - the LFP structure to view. Leave blank to use GUI to select
% times - the times to look at.
% Can be run with no input, defaulting to using GUI to view and looking at
% the whole trace
if nargin < 1 | isempty(LFP);
    [LFP,path] = uigetfile('Select LFP');
else
    path = pwd;
end
if ischar(LFP)
     LFP = load(fullfile(path,LFP));
end
if nargin < 2
    times = [1,length(LFP.values)];
end
values = LFP.values;
badvals = nan(size(LFP.values));
if ~isfield(LFP,'timestamps')
     LFP.timestamps = (1/LFP.sFreq):(1/LFP.sFreq):(length(LFP.values)/LFP.sFreq);
end
if ~isfield(LFP,'Channel')
    LFP.Channel = 'No Channel'
end
try LFP.bad_intervals;
catch
    LFP.bad_intervals = [1 2];
end
    for i_interval = 1:size(LFP.bad_intervals,1)
        values(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)))...
            = NaN();
        badvals(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)))...
            = LFP.values(...
            floor(LFP.bad_intervals(i_interval,1))...
            :ceil(LFP.bad_intervals(i_interval,2)));
    end
    ts = LFP.timestamps-LFP.timestamps(1);
    figure
plot(ts(times(1):times(2)),values (times(1):times(2)),'b')
hold on
plot(ts(times(1):times(2)),badvals(times(1):times(2)),'r')
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
        chan_title = ['Ch ' num2str(LFP.Channel)];
    end
% End Translation Table Section
title(['LFP Trace ' chan_title])
ylabel('mV')
xlabel('Time (s)')
