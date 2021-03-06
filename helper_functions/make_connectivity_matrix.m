function stim_options = make_connectivity_matrix(stim_options)

    %Fields that must be added to stim_options
    num_comms = stim_options.num_comms;
    num_nodes_per_comm = stim_options.num_nodes_per_comm;
    in_dsity = stim_options.in_dsity;
    out_dsity  = stim_options.out_dsity;
    hub_dsity = stim_options.hub_dsity;
    
    if isfield(stim_options, 'weights_mean')
        weights_mean = stim_options.weights_mean;
    else
        weights_mean = 0;
    end
    
    if isfield(stim_options, 'weights_sd')
        weights_sd = stim_options.weights_sd;
    else
        weights_sd = 0.2;
    end
    
    if isfield(stim_options, 'self_weight')
        self_weight = stim_options.self_weight;
    else
        self_weight = -.5;
    end
    
    %Make new connectivity matrix
    num_nodes = num_comms * num_nodes_per_comm;
    
    %Generate binary connectivity
    W = zeros(num_nodes);
    for i= 1:num_comms
        for j=1:num_comms
            %Within community connections
            if i==j
                tmp_a = rand(num_nodes_per_comm)<in_dsity;
                indstart = 1+(i-1)*num_nodes_per_comm;
                indend = i*num_nodes_per_comm;
                W(indstart:indend,indstart:indend) = tmp_a;
            else
                %Between community connections
                tmp_b = rand(num_nodes_per_comm)<out_dsity;
                indstart_i = 1+(i-1)*num_nodes_per_comm;
                indend_i = i*num_nodes_per_comm;
                indstart_j = 1+(j-1)*num_nodes_per_comm;
                indend_j = j*num_nodes_per_comm;
                W(indstart_i:indend_i, indstart_j:indend_j) = tmp_b;
            end
        end
    end
    
    hubnetwork = 1;
    if hub_dsity>0
        for i=1:num_comms
            for j=1:num_comms
                %Hub connections
                if (i==hubnetwork || j==hubnetwork) && i~=j
                    tmp_b = rand(num_nodes_per_comm)<hub_dsity;
                    indstart_i = 1+(i-1)*num_nodes_per_comm;
                    indend_i = i*num_nodes_per_comm;
                    indstart_j = 1+(j-1)*num_nodes_per_comm;
                    indend_j = j*num_nodes_per_comm;
                    W(indstart_i:indend_i, indstart_j:indend_j) = tmp_b;
                end
            end
        end
    end

    %Make weighted adjacency matrix based on binary matrix
    G = zeros(num_nodes);
    connect_ind = W~=0;
    nconnects = sum(sum(connect_ind));
    
    weights = normrnd(weights_mean, weights_sd, [nconnects,1]);
    
    G(connect_ind) = weights;
    
    %Find num incoming connections per node
    nodeDeg = sum(W, 2);
    
    %Synaptic scaling according to number of incoming connections
    for col=1:size(G,1)
        if nodeDeg > 0
            G(:,col) = G(:,col)./sqrt(nodeDeg);
        end
    end
    
    %Ensure inhibitory self-connections
    G(1:num_nodes+1:end) = self_weight;

    %Default options to update in stim_options
    stim_options.Tp.A = G;
    stim_options.Tp.C = [];
    
    stim_options.n  = num_nodes;
    
    stim_options.a = ones(num_nodes,num_nodes);
    stim_options.c = [];

end