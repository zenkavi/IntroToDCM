function plot_true_est_connectivity(DCM, output)
    cmap = mycmap();   

    f = figure();

    subplot(1, 2, 1)
    h = heatmap(DCM.Tp.A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;
    h.ColorLimits = [-0.5 0.5];
    title("True A"); 
    xlabel("From");
    ylabel("To");


    subplot(1, 2, 2)
    
    if length(output) == 1
        h = heatmap(output.Ep.A);
        h.CellLabelColor = 'none';
        title("Estimated A"); 
    else
        cur_as = cellfun(@(c) {c.Ep.A}, output);
        mean_a = mean(cat(3, cur_as{:}), 3);
        h = heatmap(mean_a);
        h.CellLabelColor = 'none';
        title("Average Estimated A"); 
    end
    
    h.Colormap = cmap;
    h.ColorLimits = [-0.5 0.5];
    xlabel("From");
    ylabel("To");

    set(f,'Units','normalized','Position',[0 0 1 .5]); 
end