function StandardDeviation(matFileContainingTrials)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Analysis/BrightnessAnalysis.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
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
figureWidth = 540;
figureHeight = 400;

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
microGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
martianGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
lunarGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});
earthGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});

for i=1: length(trials)
    switch trials(i).gravity
        case 'Lunar'
            lunarGravityTrials(length(lunarGravityTrials) + 1) = trials(i);
        case 'Martian'
            martianGravityTrials(length(martianGravityTrials) + 1) = trials(i);
        case 'Micro'
            microGravityTrials(length(microGravityTrials) + 1) = trials(i);
        case 'Earth'
            earthGravityTrials(length(earthGravityTrials) + 1) = trials(i);
    end

end

% We also want to sort our trials by speed, so that way they are graphed in
% an order that actually makes sense
[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

[~, index] = sort([earthGravityTrials.speed], 'ascend');
earthGravityTrials = earthGravityTrials(index);

% We create all of these separate arrays so that we can plot much easier
% later. In python this is could be replaced by doing something like:
% array[:,0] but I don't think this is quite possible in Matlab
lunarSTDs = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

martianSTDs = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

microSTDs = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));
microDays = zeros(1, length(microGravityTrials));


earthSTDs = zeros(1, length(earthGravityTrials));
earthSpeeds = zeros(1, length(earthGravityTrials));
earthDays = zeros(1, length(earthGravityTrials));

% Now we populate all of the arrays we just created
for i=1: length(lunarGravityTrials)
   lunarSTDs(i) = std(lunarGravityTrials(i).results.averageBrightness);
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
   lunarDays(i) = lunarGravityTrials(i).day;
end

for i=1: length(martianGravityTrials)
   martianSTDs(i) = std(martianGravityTrials(i).results.averageBrightness);
   martianSpeeds(i) = martianGravityTrials(i).speed;
   martianDays(i) = martianGravityTrials(i).day;
end

for i=1: length(microGravityTrials)
   microSTDs(i) = std(microGravityTrials(i).results.averageBrightness);
   microSpeeds(i) = microGravityTrials(i).speed;
   microDays(i) = microGravityTrials(i).day;
end

for i=1: length(earthGravityTrials)
   earthSTDs(i) = std(earthGravityTrials(i).results.averageBrightness);
   earthSpeeds(i) = earthGravityTrials(i).speed;
   earthDays(i) = earthGravityTrials(i).day;
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

lunarAverageSTDBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
lunarErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(lunarGravityTrials)
    lunarAverageSTDBySpeed(lunarGravityTrials(i).speed) = mean(lunarSTDs(lunarSpeeds == lunarGravityTrials(i).speed));
    lunarErrorBarsBySpeed(lunarGravityTrials(i).speed) = std(lunarSTDs(lunarSpeeds == lunarGravityTrials(i).speed));
end

martianAverageSTDBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
martianErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(martianGravityTrials)
    martianAverageSTDBySpeed(martianGravityTrials(i).speed) = mean(martianSTDs(martianSpeeds == martianGravityTrials(i).speed));
    martianErrorBarsBySpeed(martianGravityTrials(i).speed) = std(martianSTDs(martianSpeeds == martianGravityTrials(i).speed));
end

microAverageSTDBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
microErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(microGravityTrials)
    microAverageSTDBySpeed(microGravityTrials(i).speed) = mean(microSTDs(microSpeeds == microGravityTrials(i).speed));
    microErrorBarsBySpeed(microGravityTrials(i).speed) = std(microSTDs(microSpeeds == microGravityTrials(i).speed));
end

earthAverageSTDBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
earthErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(earthGravityTrials)
    earthAverageSTDBySpeed(earthGravityTrials(i).speed) = mean(earthSTDs(earthSpeeds == earthGravityTrials(i).speed));
    earthErrorBarsBySpeed(earthGravityTrials(i).speed) = std(earthSTDs(earthSpeeds == earthGravityTrials(i).speed));
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%        PLOTTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         LUNAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(1);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
% Plot each day as a separate line, with appropriate labels, colors, and
% shapes
for i=min(lunarDays): max(lunarDays)
    plot(lunarSpeeds(lunarDays == i), lunarSTDs(lunarDays == i), ['-.', settings.pointSymbols(i)], 'Color', settings.colors('Lunar'), 'DisplayName', ['Day', num2str(i)])
end
% Now plot the average with error bars
errorbar(cell2mat(lunarAverageSTDBySpeed.keys), cell2mat(lunarAverageSTDBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar-alt'), 'LineWidth', 1.5);
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Lunar)');
% A string plus an array gives a string array with each element the string
% plus the original element appended at the end
% ie. "Day " + [1, 2, 3] = ["Day 1", "Day 2", "Day 3"]
legend(["Day " + (min(lunarDays):max(lunarDays)), "Average"]);

saveFileNameNoExtension = 'Lunar-StandardDeviation';
printfig(1, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MARTIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=min(martianDays): max(martianDays)
    plot(martianSpeeds(martianDays == i), martianSTDs(martianDays == i), ['-.', settings.pointSymbols(i)], 'Color', settings.colors('Martian'), 'DisplayName', ['Day', num2str(i)])
end
% Now plot the average with error bars
errorbar(cell2mat(martianAverageSTDBySpeed.keys), cell2mat(martianAverageSTDBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian-alt'), 'LineWidth', 1.5);
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Martian)');
% A string plus an array gives a string array with each element the string
% plus the original element appended at the end
% ie. "Day " + [1, 2, 3] = ["Day 1", "Day 2", "Day 3"]
legend(["Day " + (min(martianDays):max(martianDays)), "Average"]);

saveFileNameNoExtension = 'Martian-StandardDeviation';
printfig(2, saveFileNameNoExtension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MICRO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
%plot(microSpeeds, microNumPeaks, '*');
errorbar(cell2mat(microAverageSTDBySpeed.keys), cell2mat(microAverageSTDBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Day 1');
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Micro)');
legend("Day " + (min(microDays):max(microDays)));

saveFileNameNoExtension = 'Micro-StandardDeviation';
printfig(3, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         EARTH
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=min(earthDays): max(earthDays)
    plot(earthSpeeds(earthDays == i), earthSTDs(earthDays == i), ['-.', settings.pointSymbols(i)], 'Color', settings.colors('Earth'), 'DisplayName', ['Day', num2str(i)])
end
% Now plot the average with error bars
errorbar(cell2mat(earthAverageSTDBySpeed.keys), cell2mat(earthAverageSTDBySpeed.values), cell2mat(earthErrorBarsBySpeed.values), 'Color', settings.colors('Earth-alt'), 'LineWidth', 1.5);
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Earth)');
% A string plus an array gives a string array with each element the string
% plus the original element appended at the end
% ie. "Day " + [1, 2, 3] = ["Day 1", "Day 2", "Day 3"]
legend(["Day " + (min(earthDays):max(earthDays)), "Average"]);

saveFileNameNoExtension = 'Earth-StandardDeviation';
printfig(4, saveFileNameNoExtension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ALL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(5);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

errorbar(cell2mat(lunarAverageSTDBySpeed.keys), cell2mat(lunarAverageSTDBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar'), 'LineWidth', 1.5, 'DisplayName', 'Lunar');
errorbar(cell2mat(martianAverageSTDBySpeed.keys), cell2mat(martianAverageSTDBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian'), 'LineWidth', 1.5, 'DisplayName', 'Martian');
errorbar(cell2mat(microAverageSTDBySpeed.keys), cell2mat(microAverageSTDBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Micro');
errorbar(cell2mat(earthAverageSTDBySpeed.keys), cell2mat(earthAverageSTDBySpeed.values), cell2mat(earthErrorBarsBySpeed.values), 'Color', settings.colors('Earth'), 'LineWidth', 1.5, 'DisplayName', 'Earth');

xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard Dev. Comparison of Gravities');
xlim([0, 12]);
legend()
saveFileNameNoExtension = 'All-StandardDeviation';
printfig(5, saveFileNameNoExtension);

end

