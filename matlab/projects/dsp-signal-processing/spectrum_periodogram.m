function [f, psd] = spectrum_periodogram(x, fs)
%SPECTRUM_PERIODOGRAM One-sided Hann-windowed FFT periodogram PSD estimate.
%   [f, psd] = spectrum_periodogram(x, fs) estimates the power spectral
%   density of the real signal x (sampled at fs Hz) and returns the one-sided
%   frequency axis f from 0 to fs/2 (length floor(numel(x)/2)+1) and psd in
%   x-units^2/Hz. fs defaults to 1 (normalized frequency axis).
%
%   A symmetric Hann window w is applied to suppress spectral leakage.
%   % Scaling: psd = 2*|X(k)|^2 / (fs*sum(w.^2)) — sum(w.^2) is the
%   % window's noise-power-preserving correction (the tone-amplitude-correct
%   % analog is div-by-mean(w); sum(w.^2) is what integrates to the variance).
%
%   Example:
%       rng(0); x = randn(1, 1024);
%       [f, psd] = spectrum_periodogram(x, 1000);
%       plot(f, 10*log10(psd)); xlabel('Hz'); ylabel('PSD (dB/Hz)');

narginchk(1, 2);
if nargin < 2
    fs = 1;
end
if ~isnumeric(x) || ~isvector(x) || ~isfinite(x) || ~isreal(x) || numel(x) < 4
    error('spectrum_periodogram:badX', 'X must be a finite real numeric vector of length >= 4.');
end
if ~isnumeric(fs) || ~isscalar(fs) || ~isfinite(fs) || ~isreal(fs) || fs <= 0
    error('spectrum_periodogram:badFs', 'FS must be a finite real scalar > 0.');
end

x = x(:).';                         % force row orientation
N = numel(x);
w = window_hann(N);                 % leakage suppression, reuse project window
X = fft(x .* w);
sumw2 = sum(w.^2);                  % window power correction factor

L = floor(N/2) + 1;                 % one-sided bin count
psd = abs(X(1:L)).^2;               % one-sided windowed periodogram
if mod(N, 2) == 0
    psd(2:L-1) = 2*psd(2:L-1);      % pair up ± frequency bins (DC and Nyquist stay single)
else
    psd(2:L) = 2*psd(2:L);          % odd N: no Nyquist bin, all k >= 1 are paired
end
psd = psd / (fs*sumw2);             % Hz-scaled, window-power-corrected

f = (0:L-1) * fs / N;
end
