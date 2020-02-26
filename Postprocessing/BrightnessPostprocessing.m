
function BrightnessPostprocessing(startupFile, matFileContainingTrials)

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

% In case the startup file is not provided, default to my laptop
if ~exist('startupFile', 'var')
    fprintf('Warning: startup file not specified, defaulting to laptop (StartupLaptop)!\n')
    startupFile = 'StartupLaptop';
end
run(startupFile)

% And allow the variable settings to be accessed
global settings

% Make sure that the startup file has been run
% This shouldn't ever error since we just checked, but I have it here just
% in case something wack happens
if ~exist('settings', 'var')
   fprintf('Error: startup program has not been run, datapath not defined!\n') 
   return
end

% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
run(startupFile);

% Set the colors of our lines
brightnessLineColor = '#0072BD'; % Default blue
brightnessDerivativeLineColor = '#7E2F8E'; % Default purple

for i=1: length(trials)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %      AVERAGE BRIGHTNESS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Figure number doesn't really matter, so long as it is unique
    figure(3*i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    % Normalize the data by subtracting out the mean (but don't actually
    % change the scale of any of the data)
    brightnessData = trials(i).results.averageBrightness;
    plot(trials(i).results.frameTime, brightnessData, 'Color', brightnessLineColor);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('Average brightness [arb. units]');
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-Brightness'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %    BRIGHTNESS DERIVATIVE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure(3*i + 1);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    brightnessDerivativeData = trials(i).results.averageBrightnessDerivative;
    plot(trials(i).results.frameTime, brightnessDerivativeData, 'Color', brightnessDerivativeLineColor);
    
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel({'d/dt of average brightness', '[arb. units]'});
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    set(gcf,'visible','off')

    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-BrightnessDerivative'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i + 1, saveFileNameNoExtension);
    %clf
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % BRIGHTNESS DERIVATIVE SQUARED
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    figure(3*i + 2);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    % Normalize; see note about normalization above with brightness
    brightnessDerivativeSquaredData = trials(i).results.averageBrightnessDerivative.^2;
    plot(trials(i).results.frameTime, brightnessDerivativeSquaredData, 'Color', brightnessDerivativeLineColor);
    
    % Create the title
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel({'(d/dt of average brightness)^2', '[arb. units]'});
    % Since we have weird units, we don't need y ticks, but we'll leave
    % them in
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file
    %set(gcf,'visible','off')

    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-BrightnessDerivativeSquared'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(3*i + 2, saveFileNameNoExtension);
        
    hold off
end

end % Function end