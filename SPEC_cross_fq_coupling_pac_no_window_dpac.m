function [pacz,pacraw,dpac,pacdz] = SPEC_cross_fq_coupling_pac_no_window_dpac(LF_phase,HF_power,num_iter)
% [pac] = cfc_pac(LF_phase,HF_power,num_iter)
%  This function calculates Phase Amplitude Coupling
% Cowen modification from Colin who developed from XCohen book

if nargin == 0
    % Validate...
    [L1, INFO] = Artificial_LFP(500, 40, [7], [0], 0.01 );
    [L2, INFO] = Artificial_LFP(500, 40, [40], [0], 0.01 );
    L3 = L1 + abs(L1 > 0).*(L2*.5);
    figure
    plot(L1)
    hold on
    plot(L2)
    plot(L3,'k','LineWidth',4)
    legend('1','2','3')
    
    % Filter
    filter_order = 6;
    filterweightsLF = designfilt('bandpassiir','FilterOrder',filter_order, ...
        'HalfPowerFrequency1',5 ,'HalfPowerFrequency2',10, ...
        'SampleRate',500,'DesignMethod' ,'butter');
    filterweightsHF = designfilt('bandpassiir','FilterOrder',filter_order, ...
        'HalfPowerFrequency1',35 ,'HalfPowerFrequency2',50, ...
        'SampleRate',500,'DesignMethod' ,'butter');
    Lf = filtfilt(filterweightsLF,L3);
    LFph = angle(hilbert(Lf));
    Hf = filtfilt(filterweightsHF,L3);
    HFp = envelope_cowen(Hf);
    figure
    plot(Lf)
    hold on
    plot(Hf)
    
    
    figure
    plot(LFph)
    hold on
    plot(HFp)
    
    LF_phase=angle(hilbert(Lf));
    HF_power=abs(hilbert(Hf));
    
    [pacz,pacraw,dpac,pacdz]  =  SPEC_cross_fq_coupling_pac_no_window_dpac(LFph,HFp,300);
%     [pacz,pacraw,dpac,pacdz] =  SPEC_cross_fq_coupling_pac_no_window_dpac(LFph,HFp(randperm(length(HFp))),300);
    
%     figure
%     bar([pac(:) pacr(:)])
%     figure
%     bar([pacp(:) pacpr(:)])
%     
%     nbins=18;
%     nsurrogates=200;
%     randtype=2; %timesplice
    
    %     out = get_mi(LFph,HFp,nbins,nsurrogates,randtype); this is beyond me
    %     and throws errors
    
    
end

if  length(LF_phase)~=length(HF_power)
    error('LF_phase and HF_power must have the same length')
end
if nargin < 3
    num_iter = 500;
end

if length(LF_phase) < 200
    %     disp('Warning: Very small sample vector passed into SPEC_cross_fq_coupling_pac_no_window');
    pacz = nan; dpac = nan; pacdz = nan; pacraw=nan;
    
    return
end

% % Do PAC without bootstrapping
pacraw = abs(mean(HF_power.*exp(1i*LF_phase)));

%dpac: subtract teh average vector of the modulating phase angles from the
%euler transform of each phase angle before multiplication...c
phi=mean(exp(1i*LF_phase));
dpac = abs(mean(HF_power.*(exp(1i*LF_phase)-phi)));

% Note: this measure is sensitive to the power fluctuations in the HF band.
% An alternative is to bandpass the HF power in the same range as the lf
% band and THEN hilbert transform the signal in order to allow for
% phase-to-phase comparison.
% if ~isempty(num_iter)
%     permutedPAC=zeros(num_iter,1,class(LF_phase));
%     permutedPACd=zeros(num_iter,1,class(LF_phase));

permutedPAC = zeros(1,num_iter);
permutedPACd = zeros(1,num_iter);

for i=1:num_iter
    
    % select random time point
    random_timepoint = randsample(round(length(LF_phase)*.8),1)+round(length(LF_phase)*.1); %this is a weird way to get an index but ok
    %     random_timepoint_bias = randsample(round(length(HF_power)*.8),1)+round(length(HF_power)*.1);
    
    % shuffle power
    timeshiftedpwr      = [ HF_power(random_timepoint:end); HF_power(1:random_timepoint-1) ];
    %     timeshiftedpwr_bias = [ power_bias(random_timepoint_bias:end) power_bias(1:random_timepoint_bias-1) ];
    
    % compute PAC
    permutedPAC(1,i) = abs(mean(timeshiftedpwr.*exp(1i*LF_phase)));
    permutedPACd(1,i)= abs(mean(timeshiftedpwr.*(exp(1i*LF_phase)-phi)));
    %     permutedPAC(2,i) = abs(mean(timeshiftedpwr_bias.*exp(1i*phase_bias)));
end

% compute PACz
pacz(1) = (pacraw-mean(permutedPAC(1,:)))/std(permutedPAC(1,:));
pacdz(1) = (dpac-mean(permutedPACd(1,:)))/std(permutedPACd(1,:));




% Do bootstrapping
%     % For method 1.
%     %     random_timepoints = randsample(round(window*.8),num_iter)+round(window*.1);
%     ix = (1:length(LF_phase))';
%     %     random_timepoints = randsample(round(length(LF_phase)*.8),num_iter)+round(length(LF_phase)*.1);
%     random_timepoints = randperm(length(LF_phase));
%     %     random_timepoint = randsample(round(length(eeg)*.8),1)+round(length(eeg)*.1);
%     random_timepoints(random_timepoints < length(LF_phase)/10) = [];
%
%     while length(random_timepoints) < num_iter
%         random_timepoints = [random_timepoints randperm(length(LF_phase))];
%         random_timepoints(random_timepoints < length(LF_phase)/10) = [];
%     end
%     random_timepoints = random_timepoints(1:num_iter);
% %
% %     for i=1:num_iter
%         switch bootstrap_method
%             case 1
%                 % Method 1 from Cohen
%                 ix2 = circshift(ix,[random_timepoints(i) 0]);
%                 permutedPAC(i) = abs(mean(HF_power.*exp(1i*LF_phase(ix2,:))));
%
% %                  phi=mean(exp(1i*LF_phase(ix2,:)));
%                 permutedPACd(i)= abs(mean(HF_power.*(exp(1i*LF_phase(ix2,:))-phi)));
%
%             case 2
%                 % Method 2 from Cohen - very slow. Does not preserve time series
%                 % info.
%                 % NOTE: Colin rand tests using artificial data and this
%                 % method performed better than method 1 at detecting CFC
%                 % events. Method 1 just missed CFC events. BUT this method
%                 % is less conservative and can give you false positives as
%                 % it creates a straw man randomness that is white-like
%                 % noise and does note have the original frequency
%                 % components in the original signal. Better than nothing
%                 % but not recommended by Cohen.
%                 %         lfph2 = LF_phase(randperm(window),:);
%                 %         lfph2 = lfph(RandPermFast(window),:);
%                 permutedPAC(i) = abs(mean(HF_power.*exp(1i*LF_phase(randperm(length(LF_phase)),:))));
%         end
%     end
%     pac = pacraw-mean(permutedPAC,1);
%     pacdz1=dpac-mean(permutedPACd,1);
%     % I am getting significant negative values following subtraction of mean when run on some datasets. This is strange. Should rarely be negative as CFC should be zero in randomness correct? Running on random data confirms this.
%     pacz = pac./std(permutedPAC);
%     pacdz=pacdz1./std(permutedPACd);
%     % I found a BIG BUG (corrected) I was subtracting hte mean twice. Pnly for pacz
%     % Pac is in units of std above the permutations.
% if nargout > 1
%     packl = pac*log(pac/mean(permutedPAC,1)); % another measure of divergence.
%     m = pac-permutedPAC; %of course the more permutastions the more this will likely be true
%     pacp = signtest(m,0,'tail','right'); % Only values ABOVE the permuted values are really valid (the right side)
%     %         pp = repmat(pac,1,length(permutedPAC));
%     %         packl = sum(pp.*log(pp./permutedPAC)) ;
% end
end


