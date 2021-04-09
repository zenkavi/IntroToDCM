function plot_true_est_connectivity(DCM, output)
    cmap = mycmap();   

    f = figure();

    subplot(1, 2, 1)
    h = heatmap(DCM.Tp.A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;
    h.ColorLimits = [-0.5 0.5];
    title("True A"); 

    subplot(1, 2, 2)
    
    if length(output == 1)
        h = heatmap(output.Ep.A);
        h.CellLabelColor = 'none';
        title("Estimated A"); 
    else
        cur_as = cellfun(@(c) {c.Ep.A}, output_all(:,i));
        mean_a = mean(cat(3, cur_as{:}), 3);
        h = heatmap(mean_a);
        title("Average Estimated A"); 
    end
    
    h.Colormap = cmap;
    h.ColorLimits = [-0.5 0.5];

    set(f,'Units','normalized','Position',[0 0 1 .5]); 
end