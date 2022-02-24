function [phase,pow,filtsig] = wavelet(frex,LFP,Fs,cycles)
%[phase,pow,filtsig] = waveletdecomp(f,S,srate,width)
%   returns phase, power (scaled to amplitude of input), and
%   the original signal filtered at each frequency
%   f = frequencies to analyze
%   S = signal
%   srate = sampling rate (hz)
%   width = wavelet width

if size(LFP,1)>1 %make sure its in the right direction
    LFP = LFP';
end
LFP = single(LFP);
%preallocate
pow = zeros(numel(frex),numel(LFP),'single');
phase = zeros(numel(frex),numel(LFP),'single');
filtsig = zeros(numel(frex),numel(LFP),'single');
%time for wavelet
wavetime = single(-2:(1/Fs):2);
Lconv = length(wavetime) + length(LFP) -1;
Lconv2 = pow2(nextpow2(Lconv));
%signal fft
Sfft=fft(LFP,Lconv2,2);
for i = 1:numel(frex)
    wavef=frex(i); % wavelet frequency
    % create wavelet
    w = 2*( cycles/(2*pi*wavef) )^2;
    mwave =  exp(1i*2*pi*wavef.*wavetime) .* exp( (-wavetime.^2)/w );
    %wavelet fft
    mwavefft = fft(mwave,Lconv2);
    %inverse wavelet fft
    convrespow = ifft((mwavefft./max(mwavefft)) .* Sfft ,Lconv2);
    convrespow = convrespow(1:Lconv);
    
    startIndex=ceil(length(wavetime)/2);
    endIndex=length(convrespow)-floor(length(wavetime)/2);
    
    convrespow = 2*convrespow(startIndex:endIndex);
   
    % create power and phase
    pow(i,:) = abs(convrespow).^2;
%     pow(i,:) = abs(convrespow);
    phase(i,:)= atan2(imag(convrespow),real(convrespow));
    filtsig(i,:)= real(convrespow);
end
end

