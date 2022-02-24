function [OUT] = SPEC_cross_fq_coupling_comod_dupre2017_LC(signal,sFreq,low_range, method)
%% function [OUT] = SPEC_cross_fq_coupling_comod_dupre2017(signal,sFreq,low_range, method)
% Requires python and the pactools library installed and tested.
%  Requires that you have a C:\Temp directory on your computer.
%  Requires that the path to python is 'C:\ProgramData\Anaconda3\'
%
% Use Anaconda python and then follow the instructions on the pactools
% github website for install. You will need to figure out where the path is
% to the pythonw.exe. If the pactools install fails, you can also download
% the whole pactools project and subdirs from github and then, using the
% Anaconda command window, go to the root directory and run this...
%   >> python setup.py install
%
% See the pactools on github for more details. here are the methods.
% 'ozkurt', 'canolty', 'tort', 'penny', 'vanwijk', 'duprelatour', 'colgin', 
% 'sigl', 'bispectrum' 
%
% Cowen 2018 wrote this wrapper function.
%
% For testing...
% signal = randn(10000,1); sFreq = 200; low_range = 1:.2:10;

if nargin < 4
    %     ozkurt', 'canolty', 'tort', 'penny', 'vanwijk', 'duprelatour', 'colgin', 'sigl', 'bispectrum'
    method = 'duprelatour';
end
%%
ppath = 'E:\Anaconda';
tmppath = 'C:\Temp\';
signal = signal(:)'; % ensure it's a horizontal vector.
save(fullfile(tmppath,'cm_signal.mat'),'signal','sFreq','low_range','method','-v6');

pth = which('SPEC_cross_fq_coupling_comod_dupre2017_LC');
pth(end-1:end+1) = '.py'; % there is python code of the same name in this dir.
cmd = ['"' ppath 'pythonw.exe" "' pth '"'];
% system (cmd, '-echo') % run the python code.
[a,b] = system(cmd); % run the python code.
OUT = load('C:\Temp\cm_out.mat'); % load the result and spit them out
OUT.CM = OUT.CM'; % like most comodulograms.

if nargout == 0
    imagesc(OUT.low_fq_range,OUT.high_fq_range,OUT.CM)
    xlabel('Low Frequency (Hz)')
    ylabel('High Frequency (Hz)')
    title (method)
    axis xy
    colorbar
    colormap(viridis) % viridis is the same color map as in the python code.
end