function [b, a] = butter_lowpass_design(fc, order)
%BUTTER_LOWPASS_DESIGN Digital Butterworth lowpass via analog poles + bilinear transform.
%   [b, a] = butter_lowpass_design(fc, order) designs an order-th digital
%   Butterworth lowpass with normalized cutoff fc in (0, 1) (1 = half the
%   sample rate) and returns transfer-function coefficients such that
%       H(z) = B(z)/A(z) = sum(b(k+1) z^-k) / sum(a(k+1) z^-k),  a(1) = 1.
%
%   Math, fully self-contained (classic analog-to-digital showcase):
%     1. Analog prototype: the N-pole Butterworth has poles on the left half
%        of the unit circle, s_k = exp(1j*pi*(2k + N - 1)/(2*N)), k = 1..N,
%        giving |H(jOmega)|^2 = 1/(1 + (Omega/Omega_c)^(2N)), hence exactly
%        -3.0103 dB at Omega_c.
%     2. Pre-warp: the bilinear transform maps s = (1 - z^-1)/(1 + z^-1)
%        (sampling time T = 2, so Omega = tan(w/2)); choosing the s-plane
%        cutoff Omega_c = tan(w_c/2) with w_c = pi*fc lands the -3.01 dB
%        point exactly on the requested digital cutoff.
%     3. Analog lowpass poles: p_k = Omega_c * s_k.
%     4. Each pole maps to a first-order factor of A(z):
%        (s - p_k) * (1 + z^-1)/(1 - z^-1)^(...) => ((1-p_k) - (1+p_k) z^-1),
%        while the numerator Omega_c^N / prod(s - p_k) becomes
%        Omega_c^N * (1 + z^-1)^N (binomial coefficients).
%     5. Conjugate-pole symmetry makes A(z), B(z) real, so the imaginary
%        roundoff parts are discarded, and both are scaled by prod(1-p_k)
%        so that a(1) = 1.
%
%   Example:
%       [b, a] = butter_lowpass_design(0.25, 4);

narginchk(1, 2);
if nargin < 1
    fc = 0.25;
end
if nargin < 2
    order = 4;
end
if ~isnumeric(fc) || ~isscalar(fc) || ~isfinite(fc) || fc <= 0 || fc >= 1
    error('butter_lowpass_design:badFc', 'FC must be a scalar in (0, 1).');
end
if ~isnumeric(order) || ~isscalar(order) || ~isfinite(order) || order < 1 || order ~= fix(order)
    error('butter_lowpass_design:badOrder', 'ORDER must be a positive integer.');
end

omega_c = tan(pi*fc/2);             % pre-warped analog cutoff (bilinear, T = 2)

num = omega_c^order;                % numerator scale Omega_c^N
numpoly = 1;
for k = 1:order
    numpoly = conv(numpoly, [1 1]); % (1 + z^-1)^N: binomial coefficients
end

den = 1;
for k = 1:order
    sk = exp(1j*pi*(2*k + order - 1)/(2*order));  % unit-circle prototype pole
    pk = omega_c * sk;                            % pre-warped analog pole
    den = conv(den, [(1 - pk), -(1 + pk)]);       % (1-p) - (1+p) z^-1
end

g = den(1);                         % prod(1-p_k): makes a(1) = 1
b = real(num * numpoly / g);
a = real(den / g);
end
