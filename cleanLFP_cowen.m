function [bad_start_end, good_start_end, BADIX, LFP, thresh_spec, thresh_LFP] = cleanLFP_cowen(LFP,percentThresh,srate,thresh_spec,thresh_LFP)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[LFP,T,invalid_seconds] = cleanLFP(LFP,percentThresh,srate)
%LFP is PRESUMED to be in millivolts!!!
%   returns detrended and demeaned LFP and invalid seconds
%   Three data checks:
%       less than percentThresh broadband power
%       less than percentThresh raw value
%       less than percentThresh change in "jumps"
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 4
    thresh_spec = [];
end
if nargin < 5
    thresh_LFP = [];
end
despike_it = false;
window = round(srate); % move in 1 s chunks
overlap = 0;
nfft = 1024;
LFP = detrend(LFP);
BADIX = false(size(LFP));
% LFP.values = LFP.values-mean(LFP.values);
[~,~,bin_ctr_ix,SPEC] = spectrogram(LFP,window,overlap,nfft,1);
LSPEC = 10*log10(SPEC);
% SPECm = SPEC - repmat(mean(SPEC,2),1,size(SPEC,2));
bin_start_end_ix = [bin_ctr_ix(:) - window/2+1 (bin_ctr_ix(:) + window/2)];
BADIX(bin_start_end_ix(end):length(BADIX)) = true;
BADIX = BADIX(1:length(LFP));
% broadband = mean(LSPEC);
broadband = mean(abs(zscore(LSPEC')),2);
% FUTURE: DESPIKE TEH DATA
if despike_it
    error('Not implemented yet. - on the to-do list - future version will require spike times - this cannot be done with the final files.')
   
    [b,a] = ellip(2,0.1,40,[450 (srate-10)/2]*2/srate);
    LFPspk = filtfilt(b,a,LFP);
    LFPspk = envelope(LFPspk);
    BADIX(LFPspk > .6) = true; % high-frequency. if the filtered trace is > 60 uV it could be a spike - but is that a bad thing?
    sum(BADIX)/numel(BADIX)
   
end
       
 
if isempty(thresh_spec)
    %     thresh_spec = iqr(broadband) * 1.9;
    %     thresh_spec  = prctile(broadband,percentThresh);
    thresh_spec  = max([1.8 prctile(broadband,percentThresh)*1.1]);
    thresh_spec = min([thresh_spec 4]); % somtimes it can get very large and for some reason it does not catch it..
end
invalid_ix = find(broadband>thresh_spec);
for ii = 1:length(invalid_ix)
    ix = bin_start_end_ix(invalid_ix(ii),1):bin_start_end_ix(invalid_ix(ii),2);
    BADIX(ix) = true;
end
%cut data if raw value exceeds the percent Thresh.
if isempty(thresh_LFP)
    %      thresh_LFP  = prctile(abs(LFP),percentThresh)*1.6;
    %     thresh_LFP  = prctile(abs(LFP),percentThresh)*1.5;
    thresh_LFP = max([1.3 prctile(abs(LFP(1:10:end)),percentThresh)*1.1]);
    thresh_LFP = min([thresh_LFP 4]); % somtimes it can get very large and for some reason it does not catch it..
end
v = abs(LFP) > thresh_LFP;
v = convn(v,ones(round(srate)*2,1),'same');
BADIX = BADIX | v > 0;
% v = abs(diff(LFP));
% v(end+1) = 0;
% th  = prctile(v,percentThresh);
% v = v > th;
% v = convn(v,ones(round(srate),1),'same');
% BADIX = BADIX | v;
BADIX = convn(BADIX,ones(round(srate)*2),'same'); % This may be overkill - seems like I am smearing twice - effectively making the smear 4 seconds on either side
BADIX = BADIX >0;
% function [above_times, below_times] = find_intervals(TX, thresh, lower_thresh, minimum_duration, minimum_inter_interval_period)
[bad_start_end, good_start_end] = find_intervals(double(BADIX(:)),.5,[],[],fix(srate)*2);
bad_start_end = round(bad_start_end);
good_start_end = round(good_start_end);
if nargout == 0
    figure
    subplot(2,1,1)
    imagesc(LSPEC)
    axis xy
    subplot(2,1,2)
    plot(LFP);
    hold on
    plot(    bad_start_end(:,1),zeros(size(bad_start_end(:,1))),'g>')
    plot(    bad_start_end(:,2),zeros(size(bad_start_end(:,1))),'r*')
    plot(    good_start_end(:,1),zeros(size(bad_start_end(:,1))),'c>')
    plot(    good_start_end(:,2),zeros(size(bad_start_end(:,1))),'c<')
end
if nargout ==3
    LFP(BADIX) = nan;
end