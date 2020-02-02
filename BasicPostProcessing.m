% Load in the final data that was analyzed
% Loads in the following variable(s): trials
load('AnalyzedData.mat')


figureWidth = 500;
figureHeight = 400;
fontSize = 20;

% These options are for export_fig; for more info, see the github repo
% below:
% https://github.com/altmany/export_fig/
exportOptions = '-nocrop -painters';

for i=1: length(trials)
    % Create brightness graph
    % Figure number doesn't really matter, so long as it is unique
    figure(3*i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize the data, so we can later compare it to the gsquared values
    % This normalization may mess with the data and we may not want to do
    % it, not entirely sure though
    brightnessData = (trials(i).results.averageBrightness - mean(trials(i).results.averageBrightness));
    brightnessData = brightnessData / max(brightnessData);
    plot(trials(i).results.frameTime, brightnessData);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('Average brightness [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    %set(gcf,'visible','off')
    % Set the font size
    set(gca, 'FontSize', fontSize);
    
    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness');
    savefig(saveFilePath);
    % We use the export fig function from: https://github.com/altmany/export_fig/
    % To add it to your path, run 'pathtool' in the command line and choose
    % the folder where you have downloaded the files from the repo
    % We define out options above so that everything can be uniform and
    % easily changed
    export_fig(saveFilePathPNG);
    %clf
    
    % Create gsquared graph
    figure(3*i + 1);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    gsquaredData = (trials(i).results.averageGSquared - mean(trials(i).results.averageGSquared));
    gsquaredData = gsquaredData / max(gsquaredData);
    plot(trials(i).results.frameTime, gsquaredData);
    
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel(' Average G-squared [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')
    % Set the font size
    set(gca, 'FontSize', fontSize);

    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared');
    savefig(saveFilePath);
    export_fig(saveFilePathPNG);
    %clf
    
    % Create comparison graph
    figure(3*i + 2);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    hold on
    plot(trials(i).results.frameTime, brightnessData);
    plot(trials(i).results.frameTime, gsquaredData);
    
    % Create the title
    title(titleStr);
        
    xlabel('Time [s]');
    ylabel(' Average G-squared / Average brightness [arb. units]');
    % Since we have weird units, we don't need y ticks
    set(gca,'ytick',[]);
    set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')
    % Set the font size
    set(gca, 'FontSize', fontSize);

    % Make sure we have a legend
    legend('Average brightness', 'Average G-Squared');
    
    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison');
    savefig(saveFilePath);
    export_fig(saveFilePathPNG);
    %clf
end