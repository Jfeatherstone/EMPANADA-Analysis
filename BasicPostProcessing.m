% Load in the final data that was analyzed
% Loads in the following variable(s): trials
load('AnalyzedData.mat')


figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup_laptop;

brightnessLineColor = '#0072BD'; % Default blue
gSquaredLineColor = '#7E2F8E'; % Default purple

for i=1: length(trials)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           BRIGHTNESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Figure number doesn't really matter, so long as it is unique
    figure(3*i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize the data, so we can later compare it to the gsquared values
    % This normalization may mess with the data and we may not want to do
    % it, not entirely sure though
    brightnessData = (trials(i).results.averageBrightness - mean(trials(i).results.averageBrightness));
    brightnessData = brightnessData / max(brightnessData);
    plot(trials(i).results.frameTime, brightnessData, 'Color', brightnessLineColor);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('Average brightness [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           G SQUARED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(3*i + 1);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    gsquaredData = (trials(i).results.averageGSquared - mean(trials(i).results.averageGSquared));
    gsquaredData = gsquaredData / max(gsquaredData);
    plot(trials(i).results.frameTime, gsquaredData, 'Color', gSquaredLineColor);
    
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel(' Average G-squared [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')

    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i + 1, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %           COMPARISON
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(3*i + 2);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    hold on
    plot(trials(i).results.frameTime, brightnessData, 'Color', brightnessLineColor, 'DisplayName', 'Average Brightness');
    plot(trials(i).results.frameTime, gsquaredData, 'Color', gSquaredLineColor, 'DisplayName', 'Average G Squared');
    
    % Create the title
    title(titleStr);
        
    xlabel('Time [s]');
    ylabel(' Average G-squared / brightness [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')

    % Make sure we have a legend
    legend();
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i + 2, saveFileNameNoExtension);
    %clf
end