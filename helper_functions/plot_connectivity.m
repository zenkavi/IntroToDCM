function plot_connectivity(A)
    cmap = mycmap();   

    h = heatmap(A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;

    col_lims = [abs(min(min(A))) abs(max(max(A)))];
    col_lim = max(col_lims);

    h.ColorLimits = [-1*col_lim col_lim];
    title("True A"); 
    xlabel("From");
    ylabel("To");

    grid(h, 'off');
    h.XDisplayLabels = repmat(" ", size(A, 2), 1);
    h.YDisplayLabels = repmat(" ", size(A, 1), 1);
    
    ax = gca;
    ax.FontSize = 24;

end