function plot_connectivity(A)
    cmap = mycmap();   

    f = figure();

    h = heatmap(A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;

    if (abs(min(min(A))) > abs(max(max(A))))
        col_lim = abs(min(min(A)));
    else
        col_lim = abs(max(max(A)));
    end

    h.ColorLimits = [-1*col_lim col_lim];
    title("True A"); 
    xlabel("From");
    ylabel("To");

    grid(h, 'off');
    h.XDisplayLabels = repmat(" ", size(A, 1), 1);
    h.YDisplayLabels = repmat(" ", size(A, 1), 1);

end