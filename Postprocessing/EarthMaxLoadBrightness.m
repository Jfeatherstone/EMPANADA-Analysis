function EarthMaxLoadBrightness(matFileContainingTrials, saveFigs)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Analysis/BrightnessAnalysis.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

if ~exist('saveFigs', 'var')
   saveFigs = false; 
end

% Load in our trials var
load(matFileContainingTrials, 'trials');

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "averageBrightness"];
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
settings.charfrac = .55;
startup;

% First, convert speed to numbers instead of strings
% We first have to convert the speeds to numbers
for i=1: length(trials)
   trials(i).speed = str2double(trials(i).speed);
end

% We want to sort each trial into it's gravity
% These are the same structs from LoadFiles.m
% But we only need Earth here
earthFlexibleGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
earthStiffGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});

for i=1: length(trials)
    switch trials(i).gravity
        case 'Earth'
            if trials(i).day == 8 || trials(i).day == 9
                    earthFlexibleGravityTrials(length(earthFlexibleGravityTrials) + 1) = trials(i);
            elseif trials(i).day == 10 || trials(i).day == 11
                    earthStiffGravityTrials(length(earthStiffGravityTrials) + 1) = trials(i);
            end
    end

end

% We also want to sort our trials by speed, so that way they are graphed in
% an order that actually makes sense
[~, index] = sort([earthFlexibleGravityTrials.speed], 'ascend');
earthFlexibleGravityTrials = earthFlexibleGravityTrials(index);

[~, index] = sort([earthStiffGravityTrials.speed], 'ascend');
earthStiffGravityTrials = earthStiffGravityTrials(index);

% We create all of these separate arrays so that we can plot much easier
% later. In python this is could be replaced by doing something like:
% array[:,0] but I don't think this is quite possible in Matlab
% Again only for Earth
earthFlexibleMaxima = zeros(1, length(earthFlexibleGravityTrials));
earthFlexibleSpeeds = zeros(1, length(earthFlexibleGravityTrials));
earthFlexibleDays = zeros(1, length(earthFlexibleGravityTrials));

earthStiffMaxima = zeros(1, length(earthStiffGravityTrials));
earthStiffSpeeds = zeros(1, length(earthStiffGravityTrials));
earthStiffDays = zeros(1, length(earthStiffGravityTrials));



for i=1: length(earthFlexibleGravityTrials)
   earthFlexibleMaxima(i) = max(earthFlexibleGravityTrials(i).results.averageBrightness);
   earthFlexibleSpeeds(i) = earthFlexibleGravityTrials(i).speed;
   earthFlexibleDays(i) = earthFlexibleGravityTrials(i).day;
end

for i=1: length(earthStiffGravityTrials)
   earthStiffMaxima(i) = max(earthStiffGravityTrials(i).results.averageBrightness);
   earthStiffSpeeds(i) = earthStiffGravityTrials(i).speed;
   earthStiffDays(i) = earthStiffGravityTrials(i).day;
end


% Now we sort points into their respective speed categories so that we can
% take averages

% I am using maps for this part because Matlab really doesn't like it when
% you try and assign an array as an element of an array
% ie. doing arr(1) = [1, 2, 3] won't work because Matlab tries to assign
% each element on the right to a *single* position on the left, but we only
% provided one index, so it freaks out
% Using these means we have to convert to arrays later using cell2mat, but
% it works...

earthFlexibleAverageMaximaBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
earthFlexibleErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');

earthStiffAverageMaximaBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
earthStiffErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');


for i=1: length(earthFlexibleGravityTrials)
    earthFlexibleAverageMaximaBySpeed(earthFlexibleGravityTrials(i).speed) = mean(earthFlexibleMaxima(earthFlexibleSpeeds == earthFlexibleGravityTrials(i).speed));
    earthFlexibleErrorBarsBySpeed(earthFlexibleGravityTrials(i).speed) = std(earthFlexibleMaxima(earthFlexibleSpeeds == earthFlexibleGravityTrials(i).speed));
end

for i=1: length(earthStiffGravityTrials)
    earthStiffAverageMaximaBySpeed(earthStiffGravityTrials(i).speed) = mean(earthStiffMaxima(earthStiffSpeeds == earthStiffGravityTrials(i).speed));
    earthStiffErrorBarsBySpeed(earthStiffGravityTrials(i).speed) = std(earthStiffMaxima(earthStiffSpeeds == earthStiffGravityTrials(i).speed));
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        PLOTTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         EARTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;

dayColors = containers.Map('KeyType', 'double', 'ValueType', 'char');
dayColors(8) = "#29f665";
dayColors(9) = "#199850";
dayColors(10) = "#33a6cc";
dayColors(11) = "#345bcb";

% for i=min(earthFlexibleDays): max(earthFlexibleDays)
%     plot(earthFlexibleSpeeds(earthFlexibleDays == i), earthFlexibleMaxima(earthFlexibleDays == i), ['-.', settings.pointSymbols(i)], 'Color', dayColors(i));
% end
% 
% for i=min(earthStiffDays): max(earthStiffDays)
%     plot(earthStiffSpeeds(earthStiffDays == i), earthStiffMaxima(earthStiffDays == i), ['-.', settings.pointSymbols(i)], 'Color', dayColors(i))
% end

% Now plot the averages with error bars
errorbar(cell2mat(earthFlexibleAverageMaximaBySpeed.keys), cell2mat(earthFlexibleAverageMaximaBySpeed.values), cell2mat(earthFlexibleErrorBarsBySpeed.values), 'Color', dayColors(9), 'LineWidth', 1.5, 'DisplayName', 'Flexible probe');
errorbar(cell2mat(earthStiffAverageMaximaBySpeed.keys), cell2mat(earthStiffAverageMaximaBySpeed.values), cell2mat(earthStiffErrorBarsBySpeed.values), 'Color', dayColors(11), 'LineWidth', 1.5, 'DisplayName', 'Stiff probe');

xlim([1, 13]);
xlabel('Probe speed [mm/s]');
ylabel('Maximum Brightness [a.u.]');
title('Maximum Load via Brightness (Earth)');
%legend(["Day " + (min(earthDays):max(earthDays)), 'Average']);
legend()

if saveFigs
    saveFileNameNoExtension = 'Earth-MaxLoad';
    printfig(4, saveFileNameNoExtension);
end

end