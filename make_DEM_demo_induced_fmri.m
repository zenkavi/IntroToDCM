function [DCM, options] = make_DEM_demo_induced_fmri(stim_options)

    % DEM Structure: create random inputs
    % -------------------------------------------------------------------------
    T  = stim_options.T;                      % number of observations (scans)
    TR = stim_options.TR;                     % repetition time or timing
    n  = stim_options.n;                      % number of regions or nodes
   
    t  = (1:T)*TR;                            % observation times
    
    ar_coef = stim_options.ar_coef;

    if isfield(stim_options, 'u')
        u = stim_options.u;
    else
        u  = spm_rand_mar(T,n,ar_coef)/4;     % endogenous fluctuations
    end

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
    
    %used by spm_int_J to create states
    pP.C = eye(n,n);
    pP.transit = randn(n,1)/16;
    
    %replace specified hemodynamic parameters
    if (isfield(stim_options, 'transit'))
        pP.transit = stim_options.transit;
    end
    
    if (isfield(stim_options, 'decay'))
        pP.decay = stim_options.decay;
    end
    
    if (isfield(stim_options, 'epsilon'))
        pP.epsilon = stim_options.epsilon;
    end
    

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
        %default in DEM_demo_induced_fMRI.m
        %using this specifies what parameters should be estimated in tapas_rdcm_ridge.m
        DCM.a    = logical(pP.A); 
    end
    
    if ( isfield(stim_options,'c') )
        DCM.c = stim_options.c;
    else
        %note this is different than pP.C used for data generation
        %for data generation identity matrix ensures endogenous activity
        %propagation
        %for DCM.c no input is assumed since it is endogenous
        DCM.c    = logical(Cu); 
    end
    
    if isfield(stim_options, 'u')
        DCM.b = zeros(n, n, size(stim_options.u, 2));
    else
        DCM.b    = zeros(n,n,0);
    end
    
    DCM.d    = zeros(n,n,0);

    % response
    % -------------------------------------------------------------------------
    
    % compute multiplicative factor (if SNR is specified)
    if ( isfield(stim_options, 'SNR'))
        SNR = stim_options.SNR;
        r = diag(std(y)/SNR);
    else
        r = eye(n);
    end

    % noisy BOLD signal time series
    DCM.Y.y  = y + e*r;
    DCM.Y.dt = TR;
    
    if isfield(stim_options, 'u')
        DCM.U.u = U.u;
    else
        DCM.U.u  = E';
    end
    
    
    DCM.U.dt = TR;

    % true parameters (added for rDCM inversion)
    % -------------------------------------------------------------------------
    if isfield(stim_options, 'u')
        input_counter = 0;
        DCM.U.name = cell(1);
        for i=1:size(stim_options.u, 2)
            if length(unique(stim_options.u(:, i)))>1
                input_counter = input_counter+1;
                DCM.U.name{input_counter} = ['u', num2str(input_counter,'%01d')];
            end
        end
    else
        DCM.U.name = {'null'};
    end
    
    %This isn't true bc spm_fx_fmri.m resets the diagonals in EE
%     DCM.Tp.A = pP.A; 
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