function MaxLoadBrightness(matFileContainingTrials)

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
[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

% We create all of these separate arrays so that we can plot much easier
% later. In python this is could be replaced by doing something like:
% array[:,0] but I don't think this is quite possible in Matlab
lunarMaxima = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

martianMaxima = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

microMaxima = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));
microDays = zeros(1, length(microGravityTrials));

% Now we populate all of the arrays we just created
for i=1: length(lunarGravityTrials)
   lunarMaxima(i) = max(lunarGravityTrials(i).results.averageBrightness);
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
   lunarDays(i) = lunarGravityTrials(i).day;
end

for i=1: length(martianGravityTrials)
   martianMaxima(i) = max(martianGravityTrials(i).results.averageBrightness);
   martianSpeeds(i) = martianGravityTrials(i).speed;
   martianDays(i) = martianGravityTrials(i).day;
end

for i=1: length(microGravityTrials)
   microMaxima(i) = max(microGravityTrials(i).results.averageBrightness);
   microSpeeds(i) = microGravityTrials(i).speed;
   microDays(i) = microGravityTrials(i).day;
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

lunarAverageMaximaBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
lunarErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(lunarGravityTrials)
    lunarAverageMaximaBySpeed(lunarGravityTrials(i).speed) = mean(lunarMaxima(lunarSpeeds == lunarGravityTrials(i).speed));
    lunarErrorBarsBySpeed(lunarGravityTrials(i).speed) = std(lunarMaxima(lunarSpeeds == lunarGravityTrials(i).speed));
end

martianAverageMaximaBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
martianErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(martianGravityTrials)
    martianAverageMaximaBySpeed(martianGravityTrials(i).speed) = mean(martianMaxima(martianSpeeds == martianGravityTrials(i).speed));
    martianErrorBarsBySpeed(martianGravityTrials(i).speed) = std(martianMaxima(martianSpeeds == martianGravityTrials(i).speed));
end

microAverageMaximaBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
microErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(microGravityTrials)
    microAverageMaximaBySpeed(microGravityTrials(i).speed) = mean(microMaxima(microSpeeds == microGravityTrials(i).speed));
    microErrorBarsBySpeed(microGravityTrials(i).speed) = std(microMaxima(microSpeeds == microGravityTrials(i).speed));
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
    plot(lunarSpeeds(lunarDays == i), lunarMaxima(lunarDays == i), ['-.', settings.pointSymbols(i)], 'Color', settings.colors('Lunar'), 'DisplayName', ['Day', num2str(i)])
end
% Now plot the average with error bars
errorbar(cell2mat(lunarAverageMaximaBySpeed.keys), cell2mat(lunarAverageMaximaBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar-alt'), 'LineWidth', 1.5);
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Maximum Brightness [a.u.]');
title('Maximum Load via Brightness (Lunar)');
% A string plus an array gives a string array with each element the string
% plus the original element appended at the end
% ie. "Day " + [1, 2, 3] = ["Day 1", "Day 2", "Day 3"]
legend(["Day " + (min(lunarDays):max(lunarDays)), "Average"]);

saveFileNameNoExtension = 'Lunar-MaxLoad';
printfig(1, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MARTIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(2);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=min(martianDays): max(martianDays)
    plot(martianSpeeds(martianDays == i), martianMaxima(martianDays == i), ['-.', settings.pointSymbols(i)], 'Color', settings.colors('Martian'), 'DisplayName', ['Day', num2str(i)])
end
% Now plot the average with error bars
errorbar(cell2mat(martianAverageMaximaBySpeed.keys), cell2mat(martianAverageMaximaBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian-alt'), 'LineWidth', 1.5);
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Maximum Brightness [a.u.]');
title('Maximum Load via Brightness (Martian)');
% A string plus an array gives a string array with each element the string
% plus the original element appended at the end
% ie. "Day " + [1, 2, 3] = ["Day 1", "Day 2", "Day 3"]
legend(["Day " + (min(martianDays):max(martianDays)), "Average"]);

saveFileNameNoExtension = 'Martian-MaxLoad';
printfig(2, saveFileNameNoExtension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MICRO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(3);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
%plot(microSpeeds, microNumPeaks, '*');
errorbar(cell2mat(microAverageMaximaBySpeed.keys), cell2mat(microAverageMaximaBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Day 1');
xlim([0, 12]);
xlabel('Probe speed [mm/s]');
ylabel('Maximum Brightness [a.u.]');
title('Maximum Load via Brightness (Micro)');
legend("Day " + (min(microDays):max(microDays)));

saveFileNameNoExtension = 'Micro-MaxLoad';
printfig(3, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ALL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure(4);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

errorbar(cell2mat(lunarAverageMaximaBySpeed.keys), cell2mat(lunarAverageMaximaBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar'), 'LineWidth', 1.5, 'DisplayName', 'Lunar');
errorbar(cell2mat(martianAverageMaximaBySpeed.keys), cell2mat(martianAverageMaximaBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian'), 'LineWidth', 1.5, 'DisplayName', 'Martian');
errorbar(cell2mat(microAverageMaximaBySpeed.keys), cell2mat(microAverageMaximaBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Micro');

xlabel('Probe speed [mm/s]');
ylabel('Maximum Brightness [a.u.]');
title('Maximum Load By Gravity via Brightness');
xlim([0, 12]);
legend()
saveFileNameNoExtension = 'All-MaxLoad';
printfig(4, saveFileNameNoExtension);

end
