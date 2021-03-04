function [DCM, options] = make_DEM_demo_induced_fmri(varargin)

    % DEM Structure: create random inputs
    % -------------------------------------------------------------------------
    def_T  = 512;                             % number of observations (scans)
    def_TR = 2;                               % repetition time or timing
    def_n  = 3;                               % number of regions or nodes
    def_A   = ones(n,n);
    def_C   = zeros(n,n);

    
    p = inputParser;
    validScalarPosNum = @(x) isnumeric(x) && isscalar(x) && (x > 0);
    addOptional(p,'T',def_T,validScalarPosNum);
    addOptional(p,'TR',def_TR,validScalarPosNum);
    addOptional(p,'n',def_n,validScalarPosNum);
    addOptional(p,'A',def_TR,validScalarPosNum);
    addOptional(p,'C',def_n,validScalarPosNum);
     
    
    T = p.Results.T;
    TR = p.Results.TR;
    n = p.Results.n;
    A = p.Results.A;
       
    t  = (1:T)*TR;                        % observation times
    u  = spm_rand_mar(T,n,1/2)/4;         % endogenous fluctuations

    % experimental inputs (Cu = 0 to suppress)
    % -------------------------------------------------------------------------
    Cu  = ones(n, 1) * 0;
    E   = cos(2*pi*TR*(1:T)/24) * 0;

    % priors
    % -------------------------------------------------------------------------
    options.nonlinear  = 0;
    options.two_state  = 0;
    options.stochastic = 1;
    options.centre     = 1;
    options.induced    = 1;

    
    B   = zeros(n,n,0);
    D   = zeros(n,n,0);
    pP  = spm_dcm_fmri_priors(A,B,C,D,options);


    % true parameters (reciprocal connectivity)
    % -------------------------------------------------------------------------
    pP.A = [  0  -.2    0;
             .3    0  -.1;
              0   .2    0];
    pP.C = eye(n,n);
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
    e    = spm_rand_mar(T,n,1/2)/4;

    % priors for inversion
    %==========================================================================
    DCM.options = options;
    DCM.n = n;

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

end