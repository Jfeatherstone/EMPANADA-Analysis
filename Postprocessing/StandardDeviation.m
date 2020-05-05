function trials = StandardDeviation(matFileContainingTrials)

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


lunarSTDs = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

martianSTDs = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

% We don't need to record the days for micro as they are all from day 1
microSTDs = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));

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
end
% Now we sort points into their respective speed categories so that we can
% take averages

% I am using maps for this pSTDart because Matlab really doesn't like it when
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         LUNAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Now plot stuff
figure(1);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=1: 2
    plot(lunarSpeeds(lunarDays == i), lunarSTDs(lunarDays == i), ['-', settings.pointSymbols(i)], 'Color', settings.colors('Lunar'), 'DisplayName', ['Day', num2str(i)])
end

xlim([50, 240]);
%ylim([max(min(lunarSTD-1), 0), max(lunarNumPeaks)+1]);
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Lunar)');
legend('Day 1', 'Day 2');

saveFileNameNoExtension = 'Lunar-StandardDeviation';
printfig(1, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MARTIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=1: 2
    plot(martianSpeeds(martianDays == i), martianSTDs(martianDays == i), ['-', settings.pointSymbols(i)], 'Color', settings.colors('Martian'), 'DisplayName', ['Day', num2str(i)])
end

xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Martian)');
%xlim([0, 240]);
legend('Day 1', 'Day 2');

saveFileNameNoExtension = 'Martian-StandardDeviation';
printfig(2, saveFileNameNoExtension);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MICRO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


figure(3);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
%hold on;
%plot(microSpeeds, microNumPeaks, '*');
errorbar(cell2mat(microAverageSTDBySpeed.keys), cell2mat(microAverageSTDBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Day 1');

xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Martian)');
%xlim([0, 240]);
legend('Day 1');

saveFileNameNoExtension = 'Micro-StandardDeviation';
printfig(3, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         ALL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Now lets plot everything on the same figure.
figure(4);
hold on;

%yyaxis left
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
errorbar(cell2mat(lunarAverageSTDBySpeed.keys), cell2mat(lunarAverageSTDBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar'), 'LineWidth', 1.5, 'DisplayName', 'Lunar');
errorbar(cell2mat(martianAverageSTDBySpeed.keys), cell2mat(martianAverageSTDBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian'), 'LineWidth', 1.5, 'DisplayName', 'Martian');
%yyaxis right
errorbar(cell2mat(microAverageSTDBySpeed.keys), cell2mat(microAverageSTDBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Micro');
xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
%title(['Slipping events vs. probe speed (micro) (', num2str(microMinPeakHeight), ')']);
title('Standard Dev. Comparison of Gravities');
xlim([50, 240]);
%ylim([max(min(microNumPeaks-1), 0), max(microNumPeaks)+1]);
legend()
saveFileNameNoExtension = 'All-StandardDeviation';
printfig(4, saveFileNameNoExtension);

end

