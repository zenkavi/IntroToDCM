
% Modifying DEM_demo_induced_fmri.m used in Fraessle et al. (2021) to
% createmy own 3 node network

% DEM Structure: create random inputs
% -------------------------------------------------------------------------
T  = 512;                             % number of observations (scans)
TR = 2;                               % repetition time or timing
t  = (1:T)*TR;                        % observation times
n  = 3;                               % number of regions or nodes
u  = spm_rand_mar(T,n,1/2)/4;         % endogenous fluctuations
% spm_rand_mar creates an AR(1) process with autoregression coefficient set
% at 1/2 and the standard deviation of the fluctuations are scaled to 1/4

% experimental inputs (Cu = 0 to suppress)
% -------------------------------------------------------------------------
% Cu  = [1; 0; 0] * 0;                  % no input for resting state
Cu  = [1; 0; 0] * 1;                  % input at node 1
E   = cos(2*pi*TR*(1:T)/24) * 0;

% priors
% -------------------------------------------------------------------------
options.nonlinear  = 0;
options.two_state  = 0;
options.stochastic = 1;
options.centre     = 1;
options.induced    = 1;

A   = ones(n,n);
B   = zeros(n,n,0);
C   = zeros(n,n);
D   = zeros(n,n,0);
pP  = spm_dcm_fmri_priors(A,B,C,D,options);


% true parameters (reciprocal connectivity)
% -------------------------------------------------------------------------
pP.A = [  0  .2    0;
.4    0  0;
0   .3    0];
pP.C = eye(n,n);
pP.transit = randn(n,1)/16;

% simulate response to endogenous fluctuations
%==========================================================================

% integrate states
% -------------------------------------------------------------------------
M.f  = 'spm_fx_fmri';
% x - state vector has 5 values representating different things as detailed
% in the 'spm_fx_fmri' function
M.x  = sparse(n,5);                       
U.u  = u + (Cu*E)';
U.dt = TR;
% Make hidden states
x    = spm_int_J(pP,M,U);

% haemodynamic observer
% -------------------------------------------------------------------------

% Convert hidden states into fmri timeseries
for i = 1:T
y(i,:) = spm_gx_fmri(spm_unvec(x(i,:),M.x),[],pP)';
end

% observation noise process
% -------------------------------------------------------------------------
e    = spm_rand_mar(T,n,1/2)/4;

% show simulated response
%--------------------------------------------------------------------------
i = 1:T;
spm_figure('Getwin','Figure 1'); clf
subplot(2,2,1)
plot(t(i),u(i,:))
title('Endogenous fluctuations','FontSize',16)
xlabel('Time (seconds)')
ylabel('Amplitude')
axis square

subplot(2,2,2), hold off
plot(t(i),x(i,n + 1:end),'c'), hold on
plot(t(i),x(i,1:n)), hold off
title('Hidden states','FontSize',16)
xlabel('Time (seconds)')
ylabel('Amplitude')
axis square

subplot(2,2,3)
plot(t(i),y(i,:),t(i),e(i,:),':')
title('Hemodynamic response and noise','FontSize',16)
xlabel('Time (seconds)')
ylabel('Amplitude')
axis square


% nonlinear system identification (DCM for CSD)
%==========================================================================
DCM.options = options;

DCM.a    = logical(pP.A);
DCM.b    = zeros(n,n,0);
DCM.c    = logical(Cu);
DCM.d    = zeros(n,n,0);

% response
% -------------------------------------------------------------------------
DCM.Y.y  = y + e;
DCM.Y.dt = TR;
DCM.U.u  = E';
DCM.U.dt = TR;
