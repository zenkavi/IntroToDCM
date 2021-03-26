function plot_sim_data(DCM)

    names = cell(1,size(DCM.Tp.A,1));
    for i=1:size(DCM.Tp.A)
        names{i} = sprintf("%.0f", i);
    end
    names = cellstr(names);
    tmp = digraph(DCM.Tp.A', names);
    
    if length(unique(DCM.U.u))>1 %if there is input plot that too
        num_plots = 3;
    else
        num_plots = 2;
    end

    clf
    subplot(1, num_plots, 1)
    p = plot(tmp,'Layout','force','EdgeLabel',tmp.Edges.Weight);
    title("True connectivity matrix")
    axis square
    ax = gca;
    ax.FontSize = 24;
    p.LineWidth = 2;
    p.NodeFontSize = 34;
    p.EdgeFontSize = 24;
    p.ArrowSize = 26;
    highlight(p,[1 2 3]);

    subplot(1,num_plots,2)
    plot(DCM.Y.y);
    axis([0 size(DCM.Y.y,1) min(min(DCM.Y.y))-0.1 max(max(DCM.Y.y))+0.1])
    title("Stimulated BOLD data");
    legend("Node 1", "Node 2", "Node 3");
    axis square
    ax = gca;
    ax.FontSize = 24;
    
    if num_plots == 3
        subplot(1, num_plots, 3)
        r_dt = DCM.Y.dt/DCM.U.dt;
        plot(DCM.U.u(1:r_dt:end,:));
        axis([0 size(DCM.Y.y,1) min(min(DCM.U.u))-0.1 max(max(DCM.U.u))+0.1])
        title("Input to each node");
        legend("Node 1", "Node 2", "Node 3");
        axis square
        ax = gca;
        ax.FontSize = 24;
    end
        
    set(gcf,'position',[0,0,400,250]);
    set(gcf,'Units','normalized','Position',[0 0 1 .5]);


end