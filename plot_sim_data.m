function plot_sim_data(DCM)

    names = cell(1,size(DCM.Tp.A,1));
    for i=1:size(DCM.Tp.A)
        names{i} = sprintf("%.0f", i);
    end
    names = cellstr(names);
    tmp = digraph(DCM.Tp.A', names);

    clf
    subplot(1, 2, 1)
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

    subplot(1,2,2)
    plot(DCM.Y.y);
    axis([0 512 -3 3])
    title("Stimulated BOLD data");
    legend("Node 1", "Node 2", "Node 3")
    axis square
    ax = gca;
    ax.FontSize = 24;

    set(gcf,'position',[0,0,400,250]);
    set(gcf,'Units','normalized','Position',[0 0 1 .5]);


end