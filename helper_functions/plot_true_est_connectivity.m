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
    h = heatmap(output.Ep.A);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;
    h.ColorLimits = [-0.5 0.5];
    title("Estimated A"); 

    set(f,'Units','normalized','Position',[0 0 1 .5]); 
end