function [outputArg1,outputArg2] = ForceDataPostprocessing(matFileContainingTrials)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Preprocessing/ForceData.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

% Load in our trials var
load(matFileContainingTrials, 'trials');

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "forceData"];
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
end
global settings

% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup;

for i = 1: length(trials)
   
    % Setup the unique figure
    figure(i);
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    % Now crop the data according to start and end times
    % This isn't exact, but works well enough
    % Since the arduino doesn't guarantee equal time steps, we have to
    % manually look through the time series for when the times come up
    startIndex = 0;
    endIndex = 0;
    for j = 1: length(trials(i).results.frameTime)
       if trials(i).results.frameTime(j) > trials(i).cropTimes(1)
           startIndex = j;
           break;
       end
    end
    for j = 0: length(trials(i).results.frameTime) - 1
       if trials(i).results.frameTime(length(trials(i).results.frameTime) - j) < trials(i).cropTimes(2)
           endIndex = length(trials(i).results.frameTime) - j;
           break;
       end
    end
    disp(trials(i).speed);
    disp(startIndex);
    disp(endIndex);
    
    data = trials(i).results.forceData(startIndex:endIndex);
    time = trials(i).results.frameTime(startIndex:endIndex) - trials(i).results.frameTime(startIndex);
    plot(time, data);
    xlabel('Time [s]');
    ylabel('Load Cell Reading [a.u.]');
    % Create the title
    titleStr = ['Day ', num2str(trials(i).day), ', speed=', trials(i).speed, 'mm/s, gravity=', trials(i).gravity];
    title(titleStr);
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', num2str(trials(i).day), '-', trials(i).gravity, '-', trials(i).speed, 'mms-ForceData'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(i, saveFileNameNoExtension);
    %clf

end

end

