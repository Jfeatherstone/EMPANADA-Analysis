
function BrightnessPostprocessing(matFileContainingTrials)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Analysis/BrightnessAnalysis.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

% Load in our trials var
load(matFileContainingTrials, 'trials');

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "averageBrightness", "averageBrightnessDerivative"];
for i=1: length(requiredFields)
   if ~ismember(requiredFields(i), fieldnames(trials(1).results))
      fprintf('Error: required field \"%s\" not found in trials.results variable!\n Are you sure you are using the correct .mat file?', requiredFields(i)); 
      return
   end
end

% Make sure that the startup file has been run
if ~exist('settings', 'var')
   fprintf('Warning: startup program has not been run, correcting now...\n')
   startup;
   fprintf('Startup file run successfully!\n');
end
global settings

% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup;

% Set the colors of our lines
brightnessLineColor = '#0072BD'; % Default blue
brightnessDerivativeLineColor = '#7E2F8E'; % Default purple

downsampleFactor = 1;
noiseThreshhold = .04;

% Also create a sample graph with a trial from each gravity at the same
% speed
figure((length(trials) + 1) * 4);
hold on;

% I've chosen these by just examining the trial list
% They're all 70mms trials
lunarTrial = 1;
martianTrial = 5;
microTrial = 19;

set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
title(['Average Brightness by Gravity (', trials(lunarTrial).speed, ' mm/s)'])
xlabel('Probe position [mm]');
ylabel('Average brightness [a.u.]');
yticks([])

plot(trials(microTrial).results.frameTime * 8.5, trials(microTrial).results.averageBrightness + 15, 'Color', settings.colors(trials(microTrial).gravity), 'DisplayName', trials(microTrial).gravity);
plot(trials(lunarTrial).results.frameTime * 8.5, trials(lunarTrial).results.averageBrightness + 5, 'Color', settings.colors(trials(lunarTrial).gravity), 'DisplayName', trials(lunarTrial).gravity);
plot(trials(martianTrial).results.frameTime * 8.5, trials(martianTrial).results.averageBrightness - 5, 'Color', settings.colors(trials(martianTrial).gravity), 'DisplayName', trials(martianTrial).gravity);

legend('Location', 'southeast')

printfig((length(trials) + 1) * 4, 'SampleBrightnessComparison');
return

for i=1: length(trials)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      AVERAGE BRIGHTNESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Figure number doesn't really matter, so long as it is unique
    figure(4*i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    % Normalize the data by subtracting out the mean (but don't actually
    % change the scale of any of the data)
    brightnessData = trials(i).results.averageBrightness;
    plot(trials(i).results.frameTime, brightnessData, 'Color', brightnessLineColor);
    
    % Create the title
    titleStr = ['Day ', num2str(trials(i).day), ', speed=', trials(i).speed, 'mm/s, gravity=', trials(i).gravity];
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('Average brightness [a.u.]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', num2str(trials(i).day), '-', trials(i).gravity, '-', trials(i).speed, 'mms-Brightness'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(4*i, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    BRIGHTNESS DERIVATIVE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure(4*i + 1);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    brightnessDerivativeData = AverageDownsample(trials(i).results.averageBrightnessDerivative, downsampleFactor);
    plot(AverageDownsample(trials(i).results.frameTime, downsampleFactor), brightnessDerivativeData, 'Color', brightnessDerivativeLineColor);
    
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('d/dt of average brightness [a.u.]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')

    % Now save the figure
    saveFileNameNoExtension = ['Day', num2str(trials(i).day), '-', trials(i).gravity, '-', trials(i).speed, 'mms-BrightnessDerivative'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(4*i + 1, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BRIGHTNESS DERIVATIVE AND BRIGHTNESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    figure(4*i + 2);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    yyaxis right
    plot(AverageDownsample(trials(i).results.frameTime, downsampleFactor), brightnessDerivativeData);
    ylabel('d/dt of average brightness');
    ylim([min(brightnessDerivativeData) - .4, max(brightnessDerivativeData) + .1])
    
    yyaxis left
    plot(trials(i).results.frameTime, brightnessData);
    ylabel('Average brightness');
    ylim([min(brightnessData) - .5, max(brightnessData) + 2.5])
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')

    % Now save the figure
    saveFileNameNoExtension = ['Day', num2str(trials(i).day), '-', trials(i).gravity, '-', trials(i).speed, 'mms-BrightnessDerivativeComparison'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(4*i + 2, saveFileNameNoExtension);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BRIGHTNESS DERIVATIVE ABS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure(4*i + 3);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    brightnessDerivativeAbsData = AverageDownsample(abs(trials(i).results.averageBrightnessDerivative), downsampleFactor);
    brightnessDerivativeAbsData(brightnessDerivativeAbsData < noiseThreshhold) = brightnessDerivativeAbsData(brightnessDerivativeAbsData < noiseThreshhold) / 10.;
    plot(AverageDownsample(trials(i).results.frameTime, downsampleFactor), brightnessDerivativeAbsData, 'Color', settings.colors(trials(i).gravity));
    
    % Create the title
    %title(titleStr);
    
    xlabel('Time [s]');
    ylabel('|d/dt brightness| [a.u.]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', num2str(trials(i).day), '-', trials(i).gravity, '-', trials(i).speed, 'mms-BrightnessDerivativeAbs'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(4*i + 3, saveFileNameNoExtension);
    
    hold off
end


end % Function end