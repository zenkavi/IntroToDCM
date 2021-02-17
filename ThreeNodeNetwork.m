
% Modifying DEM_demo_induced_fmri.m used in Fraessle et al. (2021) to
% createmy own 3 node network

% DEM Structure: create random inputs
% -------------------------------------------------------------------------
T  = 100;                             % number of observations (scans)
TR = 2;                               % repetition time or timing
t  = (1:T)*TR;                        % observation times
n  = 3;                               % number of regions or nodes
u  = spm_rand_mar(T,n,1/2)/4;         % endogenous fluctuations
% spm_rand_mar creates an AR(1) process with autoregression coefficient set
% at 1/2 and the standard deviation of the fluctuations are scaled to 1/4.
% This is supposed to represent resting state activity

% Plot endogenous fluctuations
subplot(2,2,1)
plot(t, u)
ylim([-1 1.5])
xlim([0 T*TR])
title('Endogenous fluctuations')


% experimental inputs (Cu = 0 to suppress)
% -------------------------------------------------------------------------
% Cu  = [1; 0; 0] * 0;                  % no input for resting state
Cu  = [1; 0; 0] * 1;                  % input at node 1
% E   = cos(2*pi*TR*(1:T)/24) * 0;
on_len = 10;
off_len = 5;
num_blocks = T/(on_len + 2*off_len);
E   = repmat([repelem(0, off_len) repelem(1, on_len) repelem(0, off_len)], 1, num_blocks);

% Plot experimental input
subplot(2,2,2)
plot(t, E)
ylim([-1 1.5])
xlim([0 T*TR])
title('Experimental input')

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

% simulate response to endogenous fluctuations + experimental input
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

% Neuronal activity
for i = 1:T
    tmp = spm_unvec(x(i,:),M.x);
    neur_act(i,:) = reshape(full(tmp(:,1)),1,3);
end

% Why is the amplitude here so much lower than both the endogenous activity
% and task input?
% What is the "true" task parameter in this integration scheme?
subplot(2,2,3)
plot(t, neur_act)
ylim([-1 1.5])
xlim([0 T*TR])
title('Integrated neural states')
