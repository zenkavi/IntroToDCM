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
    DCM.Y.dt = stim_options.TR;
    
    %Specify hemodynamic parameters
    DCM.Tp.transit = randn(n,1)/16;
    DCM.Tp.decay = normrnd(0,1/256, [n,1]);
    DCM.Tp.epsilon = -0.0504;
    
    %Enforce inhibitory self connections
    SE     = diag(stim_options.Tp.A);
    EE     = stim_options.Tp.A - diag(exp(SE)/2 + SE);
    DCM.Tp.A = EE;
    
%     DCM.Tp.B = zeros(n,n,0);
    DCM.Tp.B = zeros(n,n,size(stim_options.u, 2)); %fixed for tapas_dcm_euler_gen.m
    DCM.Tp.C = stim_options.c;
    DCM.Tp.D = zeros(n,n,0);
        
    DCM.a = stim_options.a;
    DCM.c = stim_options.c;
    DCM.b = zeros(n, n, size(stim_options.u, 2));
    DCM.d    = zeros(n,n,0);
        
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
    
    % Using TAPAS to generate task data
    DCM = tapas_rdcm_generate(DCM, options, stim_options.SNR);
end
