% Load in the final data that was analyzed
% Loads in the following variable(s): trials
load('AnalyzedData.mat')


for i=1: length(trials)
    % Create brightness graph
    % Figure number doesn't really matter, so long as it is unique
    figure(3*i);
    set(gcf, 'Position', [500, 400, 0, 0]);
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
    
    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness.png');
    savefig(saveFilePath);
    saveas(gcf, saveFilePathPNG);
    
    % Create gsquared graph
    figure(3*i + 1);
    set(gcf, 'Position', [500, 400, 0, 0]);
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
    
    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared.png');
    savefig(saveFilePath);
    saveas(gcf, saveFilePathPNG);
    
    % Create comparison graph
    figure(3*i + 2);
    set(gcf, 'Position', [500, 400, 0, 0]);
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
    legend('Average brightness', 'Average G-Squared');
    
    % Now save the figure
    saveFilePath = strcat('Output/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison.fig');
    saveFilePathPNG = strcat('Output-PNG/', 'Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison.png');
    savefig(saveFilePath);
    saveas(gcf, saveFilePathPNG);
end