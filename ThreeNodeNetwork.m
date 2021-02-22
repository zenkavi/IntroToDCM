% What is the effect of the Fast Fourier transform used in rDCM?

% Based on matlab documentation here: https://www.mathworks.com/help/matlab/ref/fft.html
T = options.y_dt;     % Sampling period       
L = 2714;             % Length of signal
t = (0:L-1)*T;        % Time vector

Y = y_fft;            %from tapas_rdcm_create_regressor.m

% Compute the two-sided spectrum P2. 
% Then compute the single-sided spectrum P1 based on P2 and the even-valued signal length L.
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

% Define the frequency domain f and plot the single-sided amplitude spectrum P1
f = (1/T)*(0:(L/2))/L;
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of fft(y)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

% What does y look like in the time domain?
plot(t, y)


% Make DCM structure with .Tp (true parameters) and true input (.U) using
% the rDCM/test/DCM_LargeScale_Smith_model1.mat as a template

for k = 1:nr
    idx_y = ~isnan(Y(:,k));
    fprintf('\n')
    fprintf('%d',sum(idx_y))
end