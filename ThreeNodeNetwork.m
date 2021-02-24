%% Make your own DCM

% Make DCM structure with .Tp (true parameters) and true input (.U) using
% the rDCM/test/DCM_LargeScale_Smith_model1.mat as a template

% Read Smith et al. (2011) to understand why this has 2714 samples
org_DCM = load('tapas-master/rDCM/test/DCM_LargeScaleSmith_model1.mat')
org_DCM = org_DCM.DCM;

% specify the options for the rDCM analysis
options.SNR             = 3;
options.y_dt            = 0.5;
options.p0_all          = 0.15;  % single p0 value (for computational efficiency)
options.iter            = 100;
options.filter_str      = 5;
options.restrictInputs  = 1;

% run a simulation (synthetic) analysis
type = 's';

% create DCM structure based on the fields in the org_DCM
% add fields needed by tapas_rdcm_generate.m

% Input
my_DCM.U.name =
my_DCM.U.u =
my_DCM.U.dt =

% True parameters
my_DCM.Tp.A = 
my_DCM.Tp.B = 
my_DCM.Tp.C = 
my_DCM.Tp.D = []
my_DCM.Tp.transit = 
my_DCM.Tp.decay = 
my_DCM.Tp.epsilon = 

% A priori connectivity matrix (set to full connectivity to see if it can
% correctly prune it to the true matrix)
nr = 3
my_DCM.a = ones(nr, nr)

DCM = tapas_rdcm_generate(my_DCM, options, options.SNR);

%% Effect of the FFT

% What is the effect of the Fast Fourier transform used in rDCM?

% What does y look like in the time domain?
subplot(1,2,1)
plot(t, y)

% Visualizing the signal in the frequency domains based on matlab documentation on FFT: 
% https://www.mathworks.com/help/matlab/ref/fft.html
Fs = ...              % Sampling frequency
T = ...;              % Sampling period       
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
subplot(1,2,1)
plot(f,P1) 
title('Single-Sided Amplitude Spectrum of fft(y)')
xlabel('f (Hz)')
ylabel('|P1(f)|')

%% Effects of filtering

% What is the effect of the filtering?


