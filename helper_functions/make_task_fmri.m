function [DCM, options] = make_tapas_rdcm_generate(stim_options)

    % options structure
    % -------------------------------------------------------------------------
    
    options.nonlinear  = stim_options.nonlinear;
    options.two_state  = stim_options.two_state;
    options.stochastic = stim_options.stochastic;
    options.centre     = stim_options.centre;
    options.induced    = stim_options.induced;
    options.y_dt       = stim_options.TR;

    % DCM structure
    % -------------------------------------------------------------------------
    n = stim_options.n;
    DCM.options = options;
    DCM.n = n;
    
    %Enforce inhibitory self connections
    SE     = diag(stim_options.Tp.A);
    EE     = stim_options.Tp.A - diag(exp(SE)/2 + SE);
    DCM.Tp.A = EE;
    
    DCM.Tp.B = zeros(n,n,0);
    DCM.Tp.C = stim_options.c;
    DCM.Tp.D = zeros(n,n,0);
        
    DCM.a = stim_options.a;
    DCM.c = stim_options.c;
    if isfield(stim_options, 'u')
        DCM.b = zeros(n, n, size(stim_options.u, 2));
    else
        DCM.b    = zeros(n,n,0);
    end
    
    DCM.U.u = stim_options.u;
    DCM.U.dt = stim_options.u_dt;
    input_counter = 0;
    DCM.U.name = cell(1);
    for i=1:size(stim_options.u, 2)
        if length(unique(stim_options.u(:, i)))>1
            input_counter = input_counter+1;
            DCM.U.name{input_counter} = ['u', num2str(input_counter,'%01d')];
        end
    end
    
    % generate neural states 
    % -------------------------------------------------------------------------
    A  = stim_options.A;
    B   = zeros(n,n,0);
    C  = stim_options.C;
    D   = zeros(n,n,0);
    pP  = spm_dcm_fmri_priors(A,B,C,D,options);
    pP.A = stim_options.Tp.A;    
    pP.C = eye(n,n);
    pP.transit = randn(n,1)/16;
    
    M.f  = 'spm_fx_fmri';
    M.x  = sparse(n,5);
    U.u  = stim_options.u;
    U.dt = stim_options.u_dt;
    x    = spm_int_J(pP,M,U);
    
    
    % extract neural states only
    x_ind = zeros(1,n);
    for i = 1:n
        x_ind(i) = (i-1)*5+1;
    end
    x = full(x(:, x_ind));
    
    % convolve neural states 
    % -------------------------------------------------------------------------
    % generate fixed hemodynamic response function (HRF)
    if ( ~isfield(options,'h') || numel(options.h) ~= size(DCM.U.u,1) )
        options.DCM         = DCM;
        options.conv_dt     = DCM.U.dt;
        options.conv_length = size(DCM.U.u,1);
        options.conv_full   = 'true';
        options.h           = tapas_rdcm_get_convolution_bm(options);
    end

    % get the hemodynamic response function (HRF)
    h = options.h;
    
    y = zeros(size(x));
    for i = 1:n
        y(:,i) = ifft(fft(x(:,i)).*fft(h));
    end
    
    
   
end
