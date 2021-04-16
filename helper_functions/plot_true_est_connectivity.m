function plot_true_est_connectivity(DCM, output, auto_scale)
    cmap = mycmap();   
    
    if length(output) == 1
        col_lims = [abs(min(min(DCM.Tp.A))) abs(max(max(DCM.Tp.A))) abs(min(min(output.Ep.A))) abs(max(max(output.Ep.A)))];
    else
        cur_as = cellfun(@(c) {c.Ep.A}, output);
        mean_a = mean(cat(3, cur_as{:}), 3);
        col_lims = [abs(min(min(DCM.Tp.A))) abs(max(max(DCM.Tp.A))) abs(min(min(mean_a))) abs(max(max(mean_a)))];
    end
    
    if auto_scale == 1
        col_lim = max(col_lims);
    else
        col_lim = 0.5;
    end
    
    f = figure();

    subplot(1, 2, 1)
    h = heatmap(DCM.Tp.A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;
    h.ColorLimits = [-1*col_lim col_lim];   
    title("True A"); 
    xlabel("From");
    ylabel("To");
    
    if size(DCM.Tp.A, 1)>5
        grid(h, 'off')
        h.XDisplayLabels = repmat(" ", size(DCM.Tp.A, 1), 1);
        h.YDisplayLabels = repmat(" ", size(DCM.Tp.A, 1), 1);
    end
    ax = gca;
    ax.FontSize = 24;

    subplot(1, 2, 2)
    
    if length(output) == 1
        h = heatmap(output.Ep.A);
        h.CellLabelColor = 'none';
        title("Estimated A"); 
    else
        h = heatmap(mean_a);
        h.CellLabelColor = 'none';
        title("Average Estimated A"); 
    end
    
    h.Colormap = cmap;
    h.ColorLimits = [-1*col_lim col_lim];
    xlabel("From");
    ylabel("To");
    
    if size(DCM.Tp.A, 1)>5
        grid(h, 'off')
        h.XDisplayLabels = repmat(" ", size(DCM.Tp.A, 1), 1);
        h.YDisplayLabels = repmat(" ", size(DCM.Tp.A, 1), 1);
    end
    ax = gca;
    ax.FontSize = 24;

    set(f,'Units','normalized','Position',[0 0 1 .5]); 
end