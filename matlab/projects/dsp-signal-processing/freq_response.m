function [h, w] = freq_response(b, a, nfft)
%FREQ_RESPONSE FFT-based frequency response H(e^jw) of B(z)/A(z) (freqz-like).
%   [h, w] = freq_response(b, a) returns the complex frequency response h and
%   the frequency grid w (rad/sample, 0..pi inclusive) computed on the one-sided
%   half of an nfft-point FFT grid (nfft default 1024, even):
%       h = fft(b(:), nfft) ./ fft(a(:), nfft),  w = linspace(0, pi, nfft/2+1).
%   [h, w] = freq_response(b) evaluates an FIR filter (denominator a = 1).
%   Magnitude/phase follow directly as abs(h) and angle(h).
%
%   Equivalent to toolbox freqz(b, a, nfft, 'half') with the grid rebased to
%   include both endpoints; the FFT identity H(e^jw_k) = FFT of the
%   zero-padded coefficients evaluated at DFT bin k does the work.
%
%   Example:
%       [h, w] = freq_response(fir_design_lowpass(0.25, 31, 'hamming'), 1, 512);
%       plot(w/pi, 20*log10(abs(h))); xlabel('f / f_{Nyq}'); ylabel('dB');

narginchk(1, 3);
if nargin < 2 || isempty(a)
    a = 1;
end
if nargin < 3
    nfft = 1024;
end
if ~isnumeric(b) || ~isvector(b) || ~isfinite(b) || ~isreal(b) || isempty(b)
    error('freq_response:badB', 'B must be a nonempty finite real numeric vector.');
end
if ~isnumeric(a) || ~isvector(a) || ~isfinite(a) || ~isreal(a) || isempty(a) || a(1) == 0
    error('freq_response:badA', 'A must be a finite real numeric vector with A(1) ~= 0.');
end
if ~isnumeric(nfft) || ~isscalar(nfft) || ~isfinite(nfft) || nfft < 4 ...
        || nfft ~= fix(nfft) || mod(nfft, 2) ~= 0
    error('freq_response:badNfft', 'NFFT must be an even integer >= 4.');
end

hb = fft(b(:), nfft);
ha = fft(a(:), nfft);
if any(abs(ha) < 1e-12)
    error('freq_response:singularA', 'A has a (near-)zero on the unit circle.');
end

half = floor(nfft/2) + 1;
h = (hb ./ ha);
h = h(1:half);
w = linspace(0, pi, half).';
end
