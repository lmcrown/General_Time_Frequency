%[phase,pow,filtsig] = waveletdecomp(f,S,srate,width)
%Wavelet
colormap(jet)

minfreq = 2;
maxfreq = 100;
numfreq = 50;
totalLFP=LFP_files{1};
time=Times{1};
trial_idx=time>start_times(1)& time<end_times(1);
frex = logspace(log10(minfreq),log10(maxfreq),numfreq);
    [phase,pow,filtsig] = waveletdecomp(frex,totalLFP(trial_idx),500,8);
    contourf(time(trial_idx),frex,pow,numfreq,'linecolor','none');
    
     
