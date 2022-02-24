
%%Test wavelet and spectrogram parameters
%%PICK your PARAMS
start_freq=10;
end_freq=60;
num_secs=5;
sFreq = 500;
frex = linspace(5,100,5);
%% Generate Chirp
interval_s = 1/sFreq;
t = 0:interval_s:num_secs; %time period     
y = chirp(t,start_freq,t(end),end_freq);

%% Plot the chirp
figure
subplot 321
plot(t,y)
xlabel('seconds')
x_msec = (t-t(end)/2)*1000;
raw_lfp = y;
str = sprintf('Chirp: %d Hz to %d Hz over %d s',start_freq, end_freq, num_secs);
title(str)
axis tight
%   set(gca,'fontsize',15)

subplot 322
%         spectrogram(raw_lfp,10,20,frex,sFreq,'yaxis') %spectrogram(x,window(number of samples_),noverlap (number of samples to overlap),f,fs)
spectrogram(raw_lfp,256,200,256,sFreq,'yaxis') %still dont totally get why these are better

spectrogram(raw_lfp,150,70,256,Fs,'yaxis')
title('Spectogram')
ylabel('Frequency')
colorbar
%  set(gca,'fontsize',15)
h=colorbar
ylabel(h,'Power');
xlabel('Time (s)')

subplot 323 %this wasnt acting weird before, now it is -wtf
%     eegpower = MorletWaveletConvolution(raw_lfp,t,sFreq,1,5,f1+500,600,0,0);
 [phase,pow,filtsig] = waveletdecompCOLIN(frex,raw_lfp,sFreq,7); %Colin's
% [pow] = variablewavelet_LC(frex,raw_lfp,500,[3 6 10]); %Colin's
contourf(t,frex,pow,20,'linecolor','none') %whats the 20?
%  set(gca,'clim',[-5 max(max(pow))])%, 'yscale','log','ytick',...
title('Colin''s Wavelet Decomp')
ylabel('Frequency')
h=colorbar
ylabel(h,'Power (/max)');
xlabel('Time (s)')
% set(gca,'fontsize',15)

subplot 324 %error says input arguments must be real but it still works, but the error will make the next things not plot
[powr,fqs,scales]=SPEC_cwt_cowen(raw_lfp,sFreq,frex,32, true); %Cowen's %Q is the 32 value
title('Cowen''s Wavelet Decomp')
contourf(t,fqs,powr,40,'linecolor','none')
% set(gca,'fontsize',15)
ylabel('Frequency')
xlabel('Time (s)')
yticks([0 50 100])
%%
subplot 325
pmtm(raw_lfp,[],frex,sFreq) %[] gives default for "time bandwidth product- ie num slepian sequences, default is 4, num tapers= 2NW-1

subplot 326
pwelch(raw_lfp,length(raw_lfp),0,frex,sFreq);

%% End
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%     sFreq = 1800;
%     interval_s = 1/sFreq;
%     t = 0:interval_s:0.800;
%     fo = 80; f1 = 300;     % Frequency - linear increase from f0 to f1
%     y = chirp(t,fo,t(end),f1);
%
%     figure
% %     [z,f,t,p] =
%     spectrogram(y,256,200,256,sFreq,'yaxis')
%     figure
%     plot(t,y)
%     xlabel('s')
%     x_msec = (t-t(end)/2)*1000;
%     raw_lfp = y;
%
% %     imagesc(t,f,10*log10(abs(p)))
%
%     figure
%     eegpower = MorletWaveletConvolution(raw_lfp,t,sFreq,1,fo,f1,100,[],[]);
% %     imagesc(t,frex,eegpower.eegpower)
%
%     frex = logspace(log10(fo),log10(f1),100);
%
%     contourf(t,frex,eegpower.eegpower,40,'linecolor','none')
%     set(gca,'clim',[-10 20])%, 'yscale','log','ytick',...
%     colorbar

