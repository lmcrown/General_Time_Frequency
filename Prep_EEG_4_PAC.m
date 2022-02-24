function [pwr,phase]=Prep_EEG_4_PAC(sFreq,freq4power,freq4phase,EEG)

% sFreq = 1000;
time = -1:1/sFreq:1;
half_of_wavelet_size = (length(time)-1)/2;
n_wavelet     = length(time);
n_data        = length(EEG);
n_convolution = n_wavelet+n_data-1;
fft_data = fft(EEG,n_convolution);
% freq4phase=8;
% freq4power=30;
% wavelet for phase and its FFT
wavelet4phase = exp(2*1i*pi*freq4phase.*time) .* exp(-time.^2./(2*(4/(2*pi*freq4phase))^2));
fft_wavelet4phase = fft(wavelet4phase,n_convolution);

% wavelet for power and its FFT
wavelet4power = exp(2*1i*pi*freq4power.*time) .* exp(-time.^2./(2*(4/(2*pi*freq4power))^2));
fft_wavelet4power = fft(wavelet4power,n_convolution);

% get phase values
convolution_result_fft = ifft(fft_wavelet4phase.*fft_data,n_convolution);
phase = angle(convolution_result_fft(half_of_wavelet_size+1:end-half_of_wavelet_size));

% get power values (note: 'power' is a built-in function so we'll name this variable 'amp')
convolution_result_fft = ifft(fft_wavelet4power.*fft_data,n_convolution);
pwr = abs(convolution_result_fft(half_of_wavelet_size+1:end-half_of_wavelet_size)).^2;