function stim_options = get_default_stim_options()
    
    n = 3;
    stim_options.T  = 512;                             % number of observations (scans)
    stim_options.TR = 2;                               % repetition time or timing
    stim_options.n  = n;                               % number of regions or nodes
    stim_options.A   = ones(n,n);
    stim_options.C   = zeros(n,n);
    stim_options.nonlinear  = 0;
    stim_options.two_state  = 0;
    stim_options.stochastic = 1;
    stim_options.centre     = 1;
    stim_options.induced    = 1;
    stim_options.Tp.A = [  0  .2    0; .4    0  0; 0   .4    0];
    
    %Priors for inversion
    a = ones(n,n);
%     a = a.*~eye(size(a)); % set diagonals to 0
    stim_options.a = a;
    stim_options.c = zeros(n,1);

end