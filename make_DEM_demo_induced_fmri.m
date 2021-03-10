function [DCM, options] = make_DEM_demo_induced_fmri(stim_options)

    % DEM Structure: create random inputs
    % -------------------------------------------------------------------------
    T  = stim_options.T;                             % number of observations (scans)
    TR = stim_options.TR;                               % repetition time or timing
    n  = stim_options.n;                               % number of regions or nodes
   
    t  = (1:T)*TR;                        % observation times
    ar_coef = stim_options.ar_coef;
    u  = spm_rand_mar(T,n,ar_coef)/4;         % endogenous fluctuations

    % experimental inputs (Cu = 0 to suppress)
    % -------------------------------------------------------------------------
    Cu  = ones(n, 1) * 0;
    E   = cos(2*pi*TR*(1:T)/24) * 0;

    % priors
    % -------------------------------------------------------------------------
    options.nonlinear  = stim_options.nonlinear;
    options.two_state  = stim_options.two_state;
    options.stochastic = stim_options.stochastic;
    options.centre     = stim_options.centre;
    options.induced    = stim_options.induced;

    A  = stim_options.A;
    B   = zeros(n,n,0);
    C  = stim_options.C;
    D   = zeros(n,n,0);
    pP  = spm_dcm_fmri_priors(A,B,C,D,options);


    % true parameters (reciprocal connectivity)
    % -------------------------------------------------------------------------
    
    if ( isfield(stim_options,'Tp') )
        pP.A = stim_options.Tp.A;
    else
        pP.A = [  0  -.2    0;
                 .3    0  -.1;
                 0   .2    0];
    end
    
    pP.C = eye(n,n); %used by spm_int_J to create states
    pP.transit = randn(n,1)/16;

    % simulate response to endogenous fluctuations
    %==========================================================================

    % integrate states
    % -------------------------------------------------------------------------
    M.f  = 'spm_fx_fmri';
    M.x  = sparse(n,5);
    U.u  = u + (Cu*E)';
    U.dt = TR;
    x    = spm_int_J(pP,M,U);

    % haemodynamic observer
    % -------------------------------------------------------------------------
    for i = 1:T
        y(i,:) = spm_gx_fmri(spm_unvec(x(i,:),M.x),[],pP)';
    end

    % observation noise process
    % -------------------------------------------------------------------------
    e    = spm_rand_mar(T,n,ar_coef)/4;

    % priors for inversion
    %==========================================================================
    DCM.options = options;
    DCM.n = n;
    
    if ( isfield(stim_options,'a') )
        DCM.a = stim_options.a;
    else
        DCM.a    = logical(pP.A); %default in DEM_demo_induced_fMRI.m
    end
    
    if ( isfield(stim_options,'c') )
        DCM.c = stim_options.c;
    else
        DCM.c    = logical(Cu); %note this is different than pP.C used for data generation
    end
    
    DCM.b    = zeros(n,n,0);
    DCM.d    = zeros(n,n,0);

    % response
    % -------------------------------------------------------------------------
    DCM.Y.y  = y + e;
    DCM.Y.dt = TR;
    DCM.U.u  = E';
    DCM.U.dt = TR;

    % true parameters (added for rDCM inversion)
    % -------------------------------------------------------------------------
    DCM.U.name = {'null'}; 
%     DCM.Tp.A = pP.A; %This isn't true bc spm_fx_fmri.m resets the diagonals in EE
    SE     = diag(pP.A);
    EE     = pP.A - diag(exp(SE)/2 + SE);
    DCM.Tp.A = EE;
    DCM.Tp.B = pP.B;
    DCM.Tp.C = pP.C;
    DCM.Tp.D = pP.D;
    DCM.Tp.transit = pP.transit;
    DCM.Tp.decay = pP.decay;
    DCM.Tp.epsilon = pP.epsilon;
    
    options.y_dt = DCM.Y.dt;
    
end