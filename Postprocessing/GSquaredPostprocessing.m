
function GSquaredPostprocessing(matFileContainingTrials)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Analysis/GSquaredAnalysis.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

% Load in our trials var
load(matFileContainingTrials, 'trials');

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "averageGSquared"];
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
gSquaredLineColor = '#0072BD'; % Default blue

% Also create a sample graph with a trial from each gravity at the same
% speed

figure((length(trials) + 1) * 4);
hold on;

% I've chosen these by just examining the trial list
% They're all 8.5 mm/s trials (which is what used to be called 210 mm/s)
lunarTrial = 1;
martianTrial = 5;
microTrial = 19;

set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
title([trials(lunarTrial).speed, ' mm/s Probe Velocity'])
xlabel('Probe position [mm]');
ylabel('\langle G^2 \rangle - G_i^2');
yticks([])

% Multiply by the correct speed (8.5) to convert time to position
plot(trials(microTrial).results.frameTime * 8.5, trials(microTrial).results.averageGSquared - mean(trials(microTrial).results.averageGSquared(1:10)), 'Color', settings.colors(trials(microTrial).gravity), 'DisplayName', trials(microTrial).gravity);
plot(trials(lunarTrial).results.frameTime * 8.5, trials(lunarTrial).results.averageGSquared - mean(trials(lunarTrial).results.averageGSquared(1:10)), 'Color', settings.colors(trials(lunarTrial).gravity), 'DisplayName', trials(lunarTrial).gravity);
plot(trials(martianTrial).results.frameTime * 8.5, trials(martianTrial).results.averageGSquared  - mean(trials(martianTrial).results.averageGSquared(1:10)), 'Color', settings.colors(trials(martianTrial).gravity), 'DisplayName', trials(martianTrial).gravity);

legend('Location', 'northeast')

printfig((length(trials) + 1) * 4, 'SampleGSquaredComparison');
savePDF('SampleGSquaredComparison');
return


for i=1: length(trials)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      AVERAGE BRIGHTNESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Figure number doesn't really matter, so long as it is unique
    figure(3*i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    % Normalize the data by subtracting out the mean (but don't actually
    % change the scale of any of the data)
    gSquaredData = trials(i).results.averageGSquared;
    plot(trials(i).results.frameTime, gSquaredData, 'Color', gSquaredLineColor);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('Average G^2 [arb. units]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-GSquared'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i, saveFileNameNoExtension);
    %clf
    
%     figure(3*i + 2);
%     set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
%     hold on
%     plot(trials(i).results.frameTime, brightnessData, 'Color', brightnessLineColor, 'DisplayName', ['Average Brightness', num2str(i)]);
%     plot(trials(i).results.frameTime, brightnessDerivativeData, 'Color', gSquaredLineColor, 'DisplayName', ['Average G Squared', num2str(i)]);
%     
%     % Create the title
%     title(titleStr);
%         
%     xlabel('Time [s]');
%     ylabel(' Average G-squared / brightness [arb. units]');
%     % Since we have weird units, we don't need y ticks
%     set(gca,'ytick',[]);
%     set(gca,'yticklabel',[]);
%     % Make the graph not pop up (since we'll be saving it to a file
%     set(gcf,'visible','off')
% 
%     % Make sure we have a legend
%     % I think there's currently a bug that will sometimes show like 8
%     % entries for each legend, but I have no idea what's causing it and I
%     % can't consistently recreate it, so :/
%     legend();
%     
%     % Now save the figure
%     saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Comparison'];
%     % This is a custom figure saving method, see file for more info
%     % (printfig.m)
%     printfig(3*i + 2, saveFileNameNoExtension);
%     %clf
    
    hold off
end

end % Function end