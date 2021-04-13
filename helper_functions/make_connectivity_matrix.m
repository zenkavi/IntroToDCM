function stim_options = make_connectivity_matrix(stim_options)

    %Fields that must be added to stim_options
    num_comms = stim_options.num_comms;
    num_nodes_per_comm = stim_options.num_nodes_per_comm;
    in_dsity = stim_options.in_dsity;
    out_dsity  = stim_options.out_dsity;
    hub_dsity = stim_options.hub_dsity;
    
    %Make new connectivity matrix
    num_nodes = num_comms * num_nodes_per_comm;
    
    %Generate binary connectivity
    W = zeros(num_nodes);
    for i= 1:ncommunities
        for j=1:ncommunities
            for node=1:nodespercommunity
                %Set within network community connections
                if i==j
                    tmp_a = rand(nodespercommunity)<in_dsity;
                    indstart = i*nodespercommunity;
                    indend = i*nodespercommunity+nodespercommunity;
                    W(indstart:indend,indstart:indend) = tmp_a;
                else
                    tmp_b = rand(nodespercommunity,nodespercommunity)<out_dsity;
                    indstart_i = i*nodespercommunity;
                    indend_i = i*nodespercommunity + nodespercommunity;
                    indstart_j = j*nodespercommunity;
                    indend_j = j*nodespercommunity + nodespercommunity;
                    W(indstart_i:indend_i, indstart_j:indend_j) = tmp_b;
                end
            end
        end
    end
    
    hubnetwork = 1;
    if hubnetwork_dsity>0
        for i=1:ncommunities
            for j=1:ncommunities
                if (i==hubnetwork || j==hubnetwork) && i~=j
                    tmp_b = np.random.rand(nodespercommunity,nodespercommunity)<hubnetwork_dsity;
                    indstart_i = i*nodespercommunity;
                    indend_i = i*nodespercommunity + nodespercommunity;
                    indstart_j = j*nodespercommunity;
                    indend_j = j*nodespercommunity + nodespercommunity;
                    W(indstart_i:indend_i, indstart_j:indend_j) = tmp_b;
                end
            end
        end
    end

    %Make sure self-connections exist
    diag(W) = 1;
        
    %Synaptic scaling 
    
    %Default options to update
    stim_options.Tp.A = ...;
    
    stim_options.n  = num_nodes;

    stim_options.A   = ones(n,n);
    stim_options.C   = zeros(n,n);
    
    stim_options.a = ones(n,n);
    stim_options.c = zeros(n,1);

end