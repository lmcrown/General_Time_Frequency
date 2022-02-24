function [pac] = cfc_pac(LF_phase,HF_power,window,overlap,do_bootstrap,num_iter)
% [pac] = cfc_pac(LF_phase,HF_power,window,overlap,do_bootstrap,num_iter)
%  This function calculates Phase Amplitude Coupling.  It takes timeseries
%  for low freq phase and high freq power.  It returns a continuous vector
%  of pac values based on a window size and overlap size (both in samples).
%  do_bootstrap = true does bootstrapping to give a z scored pac value
%  which is less biased by input power and variability
if  numel(LF_phase)~=numel(HF_power)
    error('LF_phase and HF_power must have the same length')
end

ncol = fix((numel(LF_phase)-overlap)/(window-overlap));
colindex = 1 + (0:(ncol-1))*(window-overlap);
rowindex = (1:window)';
lfph = NaN(window,ncol);
hfpo = NaN(window,ncol);
lfph(:) = LF_phase(rowindex(:,ones(1,ncol))+colindex(ones(window,1),:)-1);
hfpo(:) = HF_power(rowindex(:,ones(1,ncol))+colindex(ones(window,1),:)-1);
% Do PAC without bootstrapping
pac = abs(mean(hfpo.*exp(1i*lfph),1));
if do_bootstrap
    permutedPAC=zeros(num_iter,numel(pac));
    % Do bootstrapping
    for i=1:num_iter
        lfph2 = lfph(randperm(window),:);
        permutedPAC(i,:) = abs(mean(hfpo.*exp(1i*lfph2)));
    end
    pac = (pac-mean(permutedPAC,1))./std(permutedPAC);
end


end

