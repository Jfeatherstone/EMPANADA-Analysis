function StandardDeviationSlipCountingComparison(matFileContainingTrials)

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


% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .62;
startup;

% We want to sort each trial into it's gravity
% These are the same structs from LoadFiles.m
microGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
martianGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
lunarGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});

for i=1: length(trials)
    switch trials(i).gravity
        case 'Lunar'
            lunarGravityTrials(length(lunarGravityTrials) + 1) = trials(i);
    
        case 'Martian'
            martianGravityTrials(length(martianGravityTrials) + 1) = trials(i);
    
        case 'Micro'
            microGravityTrials(length(microGravityTrials) + 1) = trials(i);
    end

end

% We also want to sort our trials by speed, so that way they are graphed in
% an order that actually makes sense

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We first have to convert the speeds to numbers
for i=1: length(lunarGravityTrials)
   lunarGravityTrials(i).speed = str2double(lunarGravityTrials(i).speed);
end

% And now we sort
[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

% Repeat the process for martian
for i=1: length(martianGravityTrials)
   martianGravityTrials(i).speed = str2double(martianGravityTrials(i).speed);
end

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

% Repeat the process for micro
for i=1: length(microGravityTrials)
   microGravityTrials(i).speed = str2double(microGravityTrials(i).speed);
end

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

% These values are chosen by just looking at the data, a more precise way
% to find similar values should be looked into
lunarMinPeakHeight = 100;
martianMinPeakHeight = 100;
microMinPeakHeight = 5;
minPeakDistance = 1;

lunarNumPeaks = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

martianNumPeaks = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

% We don't need to record the days for micro as they are all from day 1
microNumPeaks = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));

for i=1: length(lunarGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = lunarGravityTrials(i).results.averageBrightnessDerivative.^2;
   lunarNumPeaks(i) = length(findpeaks(data, lunarGravityTrials(i).results.frameTime, 'MinPeakHeight', lunarMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
   lunarDays(i) = lunarGravityTrials(i).day;
end

for i=1: length(martianGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = martianGravityTrials(i).results.averageBrightnessDerivative.^2;
   martianNumPeaks(i) = length(findpeaks(data, martianGravityTrials(i).results.frameTime, 'MinPeakHeight', martianMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   martianSpeeds(i) = martianGravityTrials(i).speed;
   martianDays(i) = martianGravityTrials(i).day;
end

for i=1: length(microGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = microGravityTrials(i).results.averageBrightnessDerivative.^2;
   microNumPeaks(i) = length(findpeaks(data, microGravityTrials(i).results.frameTime, 'MinPeakHeight', microMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   microSpeeds(i) = microGravityTrials(i).speed;
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

lunarAveragePeaksBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
lunarErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(lunarGravityTrials)
    lunarAveragePeaksBySpeed(lunarGravityTrials(i).speed) = mean(lunarNumPeaks(lunarSpeeds == lunarGravityTrials(i).speed));
    lunarErrorBarsBySpeed(lunarGravityTrials(i).speed) = std(lunarNumPeaks(lunarSpeeds == lunarGravityTrials(i).speed));
end

martianAveragePeaksBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
martianErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(martianGravityTrials)
    martianAveragePeaksBySpeed(martianGravityTrials(i).speed) = mean(martianNumPeaks(martianSpeeds == martianGravityTrials(i).speed));
    martianErrorBarsBySpeed(martianGravityTrials(i).speed) = std(martianNumPeaks(martianSpeeds == martianGravityTrials(i).speed));
end

microAveragePeaksBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
microErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(microGravityTrials)
    microAveragePeaksBySpeed(microGravityTrials(i).speed) = mean(microNumPeaks(microSpeeds == microGravityTrials(i).speed));
    microErrorBarsBySpeed(microGravityTrials(i).speed) = std(microNumPeaks(microSpeeds == microGravityTrials(i).speed));
end


microSTDs = [];
for i=1: length(microGravityTrials)
    microSTDs(i) = std(microGravityTrials(i).results.averageBrightness);
end

microAverageSTDBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(microGravityTrials)
    microAverageSTDBySpeed(microGravityTrials(i).speed) = mean(microSTDs(microSpeeds == microGravityTrials(i).speed));
end


% Just plot micro gravity for now
figure(1);
hold on;

% Not sure why I have to adjust the line width here, might be an errorbar
% function thing
yyaxis left;
set(gca, 'YColor', settings.colors('Micro'));
ylabel('Slip events', 'Color', settings.colors('Micro'));
errorbar(cell2mat(microAveragePeaksBySpeed.keys), cell2mat(microAveragePeaksBySpeed.values), cell2mat(microErrorBarsBySpeed.values), '-o', 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Slip counting');
% This is scaled by 15 just to make the two lines similar size, but doesn't
% represent any actual data points. This should only be used to look pretty
% in my grant proposal
yyaxis right;
set(gca, 'YColor', settings.colors('Lunar'));
ylabel('Standard deviation', 'Color', settings.colors('Lunar'));
plot(cell2mat(microAverageSTDBySpeed.keys), cell2mat(microAverageSTDBySpeed.values), '-^', 'Color', settings.colors('Lunar'), 'DisplayName', 'Standard dev.');

xlabel('Probe insertion speed [mm/s]');
title('Measures of Granular Activity in Micro Gravity');
legend();

printfig(1, 'StandardDeviationSlipCountingComparison-Micro');