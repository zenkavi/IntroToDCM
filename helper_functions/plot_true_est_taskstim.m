function plot_true_est_taskstim(DCM, output)
    cmap = mycmap();   

    f = figure();
    
    % for non-stim inputs make true_C 0
    true_C = DCM.Tp.C;
    for i=1:size(DCM.U.u, 2)
        if unique(DCM.U.u(:, i)) == 0
            true_C(:, i) = true_C(:, i)*0;
    end
    
    subplot(1, 2, 1)
    h = heatmap(true_C);
    h.CellLabelColor = 'none';
    h.Colormap = cmap;
    h.ColorLimits = [-1 1];
    title("True C"); 
    xlabel("Input");
    ylabel("Node");

    subplot(1, 2, 2)
    
    if length(output) == 1
        h = heatmap(output.Ep.C);
        h.CellLabelColor = 'none';
        title("Estimated C"); 
    else
        cur_cs = cellfun(@(c) {c.Ep.C}, output);
        mean_c = mean(cat(3, cur_cs{:}), 3);
        h = heatmap(mean_c);
        h.CellLabelColor = 'none';
        title("Average Estimated C"); 
    end
    
    h.Colormap = cmap;
    h.ColorLimits = [-1 1];
    xlabel("Input");
    ylabel("Node");

    set(f,'Units','normalized','Position',[0 0 1 .5]); 
end