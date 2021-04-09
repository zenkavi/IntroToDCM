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
    
    %Now that I know what was breaking tapas_dcm_euler_gen.m can I use
    %tapas_rdcm_generate.m to generate task data?
    DCM = tapas_rdcm_generate(DCM, options, stim_options.SNR);
    
%     % generate neural states 
%     % -------------------------------------------------------------------------
%     A  = stim_options.A;
%     B   = zeros(n,n,0);
%     C  = stim_options.C;
%     D   = zeros(n,n,0);
%     pP  = spm_dcm_fmri_priors(A,B,C,D,options);
%     pP.A = stim_options.Tp.A;    
%     pP.C = stim_options.c;
%     pP.transit = randn(n,1)/16;
%     
%     %Would it break the SPM integrator to add the bug fixes for TAPAS? Yes.
% %     pP.decay = normrnd(0,1/256, [n,1]);
% %     pP.epsilon = -0.0504;
%     
%     DCM.Tp.transit = pP.transit;
%     DCM.Tp.decay = pP.decay;
%     DCM.Tp.epsilon = pP.epsilon;
%     
%     M.f  = 'spm_fx_fmri';
%     M.x  = sparse(n,5);
%     
%     if stim_options.avoid_edge_effects
%         U.u  = repmat(stim_options.u, 3, 1);
%     else
%         U.u = stim_options.u;
%     end
%     U.dt = stim_options.u_dt;
%     x    = spm_int_J(pP,M,U);
%         
%     % extract neural states only
%     x = full(x(:, 1:n));
%     
%     % convolve neural states 
%     % -------------------------------------------------------------------------
%     % generate fixed hemodynamic response function (HRF)
%     if ( ~isfield(options,'h') || numel(options.h) ~= size(DCM.U.u,1) )
%         options.DCM         = DCM;
%         options.conv_dt     = DCM.U.dt;
%         options.conv_length = size(DCM.U.u,1);
%         options.conv_full   = 'true';
%         options.h           = tapas_rdcm_get_convolution_bm(options);
%     end
% 
%     % get the hemodynamic response function (HRF)
%     h = options.h;
%     
%     if stim_options.avoid_edge_effects
%         [N, ~] = size(full(DCM.U.u));
%         nr     = size(DCM.a,1);
%         y = zeros(N, nr);
%         for i = 1:nr
%             tmp = ifft(fft(x(:,i)).*fft([h; zeros(N*3-length(h),1)]));
%             y(:,i) = tmp(N+1:2*N);
%         end
%         DCM.x = x(N+1:2*N);
%     else
%         y = zeros(size(x));
%         for i = 1:n
%             y(:,i) = ifft(fft(x(:,i)).*fft(h));
%         end
%         DCM.x = x;
%     end
%     
%     % Sampling
%     r_dt = stim_options.TR/stim_options.u_dt;
%     y = y(1:r_dt:end,:);
% 
%     % Adding noise
%     eps = randn(size(y))*diag(std(y)/stim_options.SNR);
%     y_noise = y + eps;
% 
%     % Saving the generated data
%     DCM.Y.y = y_noise;
%     DCM.Y.dt = stim_options.TR;
%     DCM.y = y;
end
