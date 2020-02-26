function printfig(figureNum, fileNameNoExtension)

    global settings

    figure(figureNum);
    
    % We don't want the figure to show up again
    set(gcf, 'visible', 'off');
    
    saveas(gcf, [settings.fig_savepath, fileNameNoExtension, '.fig'], 'fig')
    saveas(gcf, [settings.png_savepath, fileNameNoExtension, '.png'], 'png')

    %set(gcf, 'visible', 'on');
    return;
