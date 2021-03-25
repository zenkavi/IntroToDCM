function [DCM, options] = make_tapas_rdcm_generate(stim_options)

    T  = stim_options.T;                      % number of observations (scans)
    TR = stim_options.TR;                     % repetition time or timing
    n  = stim_options.n;                      % number of regions or nodes
    u = stim_options.u;                       % input
    
    
    % options structure
    % -------------------------------------------------------------------------
    
    options.nonlinear  = stim_options.nonlinear;
    options.two_state  = stim_options.two_state;
    options.stochastic = stim_options.stochastic;
    options.centre     = stim_options.centre;
    options.induced    = stim_options.induced;
    

    % DCM structure
    % -------------------------------------------------------------------------
    
    DCM.options = options;
    DCM.n = n;
    
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
    
    % generate timeseries 
    % -------------------------------------------------------------------------
    DCM  = tapas_rdcm_generate(DCM, options, stim_options.SNR)

end
