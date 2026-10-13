function b = fir_design_lowpass(fc, N, window_name)
%FIR_DESIGN_LOWPASS Windowed-sinc lowpass FIR design (symmetric, linear phase).
%   b = fir_design_lowpass(fc, N, window_name) returns the N-tap FIR lowpass
%   coefficient vector for normalized cutoff fc in (0, 1], where fc = 1 means
%   half the sample rate (w_c = pi*fc rad/sample). window_name is 'hann' or
%   'hamming' (default 'hamming').
%
%   Method, from scratch: sample the ideal lowpass impulse response
%       h[n] = fc*sinc(fc*(n - (N-1)/2)),  n = 0..N-1,   sinc(x) = sin(pi*x)/(pi*x),
%   (normalized cutoff fc, 1 = half the sample rate => w_c = pi*fc, and the
%   ideal DC gain 1 is restored exactly by the final normalization),
%   window it with the project's window_hann/window_hamming (symmetric, so it
%   preserves the symmetry of h and the filter stays exactly linear phase with
%   delay (N-1)/2 samples), then normalize so the DC gain H(0) = sum(b) = 1.
%   Odd N gives a Type-I filter; even N gives Type-II (H(Nyquist) = 0).
%
%   Example:
%       b = fir_design_lowpass(0.25, 63, 'hamming');

narginchk(1, 3);
if nargin < 1
    fc = 0.25;
end
if nargin < 2
    N = 63;
end
if nargin < 3
    window_name = 'hamming';
end
if ~isnumeric(fc) || ~isscalar(fc) || ~isfinite(fc) || fc <= 0 || fc > 1
    error('fir_design_lowpass:badFc', 'FC must be a scalar in (0, 1].');
end
if ~isnumeric(N) || ~isscalar(N) || ~isfinite(N) || N < 3 || N ~= fix(N)
    error('fir_design_lowpass:badN', 'N must be an integer >= 3.');
end
window_name = validatestring(window_name, {'hann', 'hamming'});

center = (N-1)/2;                   % symmetry center => group delay (N-1)/2 samples
n = 0:N-1;
x = fc*(n - center);
h = ones(1, N);                     % normalized sinc: sinc(0) = 1 exactly
nz = (x ~= 0);
h(nz) = sin(pi*x(nz)) ./ (pi*x(nz));

switch window_name
    case 'hann'
        wn = window_hann(N);
    case 'hamming'
        wn = window_hamming(N);
    otherwise
        error('fir_design_lowpass:badWindow', 'Unsupported window %s.', window_name);
end

b = h .* wn;
b = b / sum(b);                     % normalize: unity DC gain for the lowpass
end
