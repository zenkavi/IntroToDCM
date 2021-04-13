function stim_options = get_default_stim_options()
    
    n = 3;
    stim_options.T  = 512;                             % number of observations (scans)
    stim_options.TR = 2;                               % repetition time or timing
    stim_options.n  = n;                               % number of regions or nodes
    
    stim_options.ar_coef = 1/2;
     
    stim_options.nonlinear  = 0;
    stim_options.two_state  = 0;
    stim_options.stochastic = 1;
    stim_options.centre     = 1;
    stim_options.induced    = 1;
        
    stim_options.SNR = 3;
    
    %True parameters
    stim_options.Tp.A = [  0  .2    0; .4    0  0; 0   .3    0];
    stim_options.Tp.C = eye(n);
    
    %Used by tapas_rdcm_sparse.m and tapas_rdcm_ridge.m
    %Priors for inversion - which parameters to estimate
    stim_options.a = ones(n,n);
    stim_options.c = zeros(n,n);
    
    stim_options.avoid_edge_effects = 0;

end
