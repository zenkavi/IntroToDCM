function plot_pred_vs_actual(DCM, output, num_nodes, freq)
    
    fig = figure();

    if freq
        Fs = DCM.Y.dt;            % Sampling frequency
        L = size(DCM.Y.y, 1);     % Length of signal
        f = Fs*(0:(L/2))/L;       % Frequency bins

        yd_source_fft = reshape(output.signal.yd_source_fft, size(DCM.Y.y, 1), size(DCM.Y.y, 2));
        yd_pred_rdcm_fft = reshape(output.signal.yd_pred_rdcm_fft, size(DCM.Y.y, 1), size(DCM.Y.y, 2));

        clf
        for i=1:num_nodes
            subplot(num_nodes, 1, i)

            Y = yd_source_fft(:,i);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);

            plot(f,P1)
            title(sprintf('Single-Sided Amplitude Spectrum of Y(t) for node %d', i))
            xlabel('f (Hz)')
            ylabel('|P1(f)|')

            Y = yd_pred_rdcm_fft(:, i);
            P2 = abs(Y/L);
            P1 = P2(1:L/2+1);
            P1(2:end-1) = 2*P1(2:end-1);

            hold on
            plot(f, P1)
            legend("True", "Predicted")
        end
        
    else
        y_source = reshape(output.signal.y_source, size(DCM.Y.y, 1), size(DCM.Y.y, 2));
        y_pred_rdcm = reshape(output.signal.y_pred_rdcm, size(DCM.Y.y, 1), size(DCM.Y.y, 2));

        clf
        for i=1:num_nodes
            subplot(num_nodes, 1, i)

            plot(y_source(:,i))

            title(sprintf('Time series y(t) for node %d', i))
            xlabel('t (sec)')
            ylabel('y(t)')

            hold on
            plot(y_pred_rdcm(:, i))
            legend("True", "Predicted")
        end
    end
    
    set(fig,'Units','normalized','Position',[0 0 1 .5]); 
end