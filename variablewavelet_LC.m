function [pow] = variablewavelet_LC(frex,LFP,Fs,num_cycles)
%[phase,pow,filtsig] = waveletdecomp(f,S,srate,width)
%   returns phase, power (scaled to amplitude of input), and
%   the original signal filtered at each frequency
%   f = frequencies to analyze
%   LFP=signal
%   Fs = sampling rate (hz)
%   num_cycles= variable S parameter but you need 3 values, its really
%   hardcoded and crappy honestly

if size(LFP,1)>1
    LFP = LFP';
end
LFP = single(LFP);
%preallocate
pow = zeros(numel(frex),numel(LFP),'single');

%time for wavelet
wavetime = single(-2:(1/Fs):2);
Lconv = length(wavetime) + length(LFP) -1;
Lconv2 = pow2(nextpow2(Lconv));
   
%signal fft
Sfft=fft(LFP,Lconv2,2);

for i = 1:numel(frex)
    if frex(i)<=5
        s=num_cycles(1);
    elseif frex(i)>5 && frex(i)<=20
        s=num_cycles(2);
    elseif frex(i)>20
        s=num_cycles(3);
    end
        
        % wavelet frequency
        % create wavelet
%         s = num_cycles(icycle)/(2*pi*frex(i));
        cmw  = exp(2*1i*pi*frex(i).*wavetime) .* exp(-wavetime.^2./(2*s^2));
        
        %wavelet fft
        mwavefft = fft(cmw,Lconv2);
        %inverse wavelet fft
        convrespow = ifft((mwavefft./max(mwavefft)) .* Sfft ,Lconv2);
        convrespow = convrespow(1:Lconv);
        
        startIndex=ceil(length(wavetime)/2);
        endIndex=length(convrespow)-floor(length(wavetime)/2);
        
        convrespow = 2*convrespow(startIndex:endIndex);
        
        % create power and phase
        pow(i,:) = abs(convrespow).^2;
        %     pow(i,:) = abs(convrespow);
   
end
