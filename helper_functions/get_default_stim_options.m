function stim_options = get_default_stim_options(stim_type)
    
    stim_options.type = stim_type;
    n = 3;
    stim_options.T  = 512;                             
    stim_options.TR = 2;                               
    stim_options.n  = n;                              
     
    stim_options.nonlinear  = 0;
    stim_options.two_state  = 0;
    stim_options.stochastic = 1;
    stim_options.centre     = 1;
    stim_options.induced    = 1;
        
    stim_options.SNR = 3;
    
    %True parameters
    stim_options.Tp.A = [  0  .2    0; .4    0  0; 0   .3    0];

    if stim_options.type == "resting"
        stim_options.ar_coef = 1/2;
        stim_options.Tp.C = eye(n);
        stim_options.c = zeros(n,n);
    else
        stim_options.stim_node = 1;
        stim_options.Tp.C = zeros(n,length(stim_options.stim_node));
        for i=1:length(stim_options.stim_node)
            stim_options.Tp.C(stim_options.stim_node(i),i) = 1;
        end
        stim_options.c = stim_options.Tp.C;
    end
    
    %Used by tapas_rdcm_sparse.m and tapas_rdcm_ridge.m
    %Priors for inversion - which parameters to estimate
    stim_options.a = ones(n,n);
    
  
end
