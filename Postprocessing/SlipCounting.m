function SlipCounting(matFileContainingTrials)

% In case data is not provided, we default to the output of BrightnessAnalysis
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Analysis/BrightnessAnalysis.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

% Load in our trials var
load(matFileContainingTrials, 'trials');

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "averageBrightnessDerivative"];
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

% Lets sort our structs as well, while we're at it
[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

[~, index] = sort([earthGravityTrials.speed], 'ascend');
earthGravityTrials = earthGravityTrials(index);

figureWidth = 540;
figureHeight = 400;

% Adjust the font to be a little smaller, and rerun our startup
settings.charfrac = .55;
startup;

% These values are chosen by just looking at the data, a more precise way
% to find similar values should be looked into
lunarMinPeakHeight = .02;
martianMinPeakHeight = .02;
microMinPeakHeight = .02;
earthMinPeakHeight = .02;

minPeakDistance = .25;

lunarNumPeaks = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

martianNumPeaks = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

% We don't need to record the days for micro as they are all from day 1
microNumPeaks = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));

earthNumPeaks = zeros(1, length(earthGravityTrials));
earthSpeeds = zeros(1, length(earthGravityTrials));
earthDays = zeros(1, length(earthGravityTrials));


for i=1: length(lunarGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = abs(lunarGravityTrials(i).results.averageBrightnessDerivative);
   lunarNumPeaks(i) = length(findpeaks(data, lunarGravityTrials(i).results.frameTime, 'MinPeakHeight', lunarMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
   lunarDays(i) = lunarGravityTrials(i).day;
end

for i=1: length(martianGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = abs(martianGravityTrials(i).results.averageBrightnessDerivative);
   martianNumPeaks(i) = length(findpeaks(data, martianGravityTrials(i).results.frameTime, 'MinPeakHeight', martianMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   martianSpeeds(i) = martianGravityTrials(i).speed;
   martianDays(i) = martianGravityTrials(i).day;
end

for i=1: length(microGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = abs(microGravityTrials(i).results.averageBrightnessDerivative);
   microNumPeaks(i) = length(findpeaks(data, microGravityTrials(i).results.frameTime, 'MinPeakHeight', microMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   microSpeeds(i) = microGravityTrials(i).speed;
end

for i=1: length(earthGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = abs(earthGravityTrials(i).results.averageBrightnessDerivative);
   earthNumPeaks(i) = length(findpeaks(data, earthGravityTrials(i).results.frameTime, 'MinPeakHeight', earthMinPeakHeight, 'MinPeakDistance', minPeakDistance));
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

earthAveragePeaksBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
earthErrorBarsBySpeed = containers.Map('KeyType', 'double', 'ValueType', 'any');
for i=1: length(earthGravityTrials)
    earthAveragePeaksBySpeed(earthGravityTrials(i).speed) = mean(earthNumPeaks(earthSpeeds == earthGravityTrials(i).speed));
    earthErrorBarsBySpeed(earthGravityTrials(i).speed) = std(earthNumPeaks(earthSpeeds == earthGravityTrials(i).speed));
end

% Now plot stuff
figure(1);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=1: 2
    plot(lunarSpeeds(lunarDays == i), lunarNumPeaks(lunarDays == i), ['-', settings.pointSymbols(i)], 'Color', settings.colors('Lunar'), 'DisplayName', ['Day', num2str(i)])
end
%plot(lunarSpeeds, lunarNumPeaks, '*');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (Lunar)');
xlim([0, 12]);
ylim([max(min(lunarNumPeaks-1), 0), max(lunarNumPeaks)+1]);
legend()
saveFileNameNoExtension = 'Lunar-SlipCounting';
printfig(1, saveFileNameNoExtension);

figure(2);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=1: 2
    plot(martianSpeeds(martianDays == i), martianNumPeaks(martianDays == i), ['-', settings.pointSymbols(i)], 'Color', settings.colors('Martian'), 'DisplayName', ['Day', num2str(i)])
end
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (Martian)');
xlim([0, 12]);
ylim([0, max(martianNumPeaks)+1]);
legend()
saveFileNameNoExtension = 'Martian-SlipCounting';
printfig(2, saveFileNameNoExtension);

figure(3);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
%hold on;
%plot(microSpeeds, microNumPeaks, '*');
errorbar(cell2mat(microAveragePeaksBySpeed.keys), cell2mat(microAveragePeaksBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'DisplayName', 'Day 1');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
%title(['Slipping events vs. probe speed (micro) (', num2str(microMinPeakHeight), ')']);
title('Slipping events vs. probe speed (micro)');
xlim([0, 12]);
ylim([0, max(microNumPeaks)+1]);
legend()
%saveFileNameNoExtension = ['Micro-SlipCounting-', num2str(microMinPeakHeight)];
saveFileNameNoExtension = 'Micro-SlipCounting';
printfig(3, saveFileNameNoExtension);

figure(4);
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
hold on;
for i=1: 4
    plot(earthSpeeds(earthDays == i), earthNumPeaks(earthDays == i), ['-', settings.pointSymbols(i)], 'Color', settings.colors('Earth'), 'DisplayName', ['Day', num2str(i)])
end
%plot(lunarSpeeds, lunarNumPeaks, '*');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (Earth)');
xlim([0, 12]);
ylim([0, max(earthNumPeaks)+1]);
legend()
saveFileNameNoExtension = 'Earth-SlipCounting';
printfig(4, saveFileNameNoExtension);

% Now lets plot everything on the same figure.
figure(5);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
errorbar(cell2mat(lunarAveragePeaksBySpeed.keys), cell2mat(lunarAveragePeaksBySpeed.values), cell2mat(lunarErrorBarsBySpeed.values), 'Color', settings.colors('Lunar'), 'LineWidth', 1.5, 'DisplayName', 'Lunar');
errorbar(cell2mat(martianAveragePeaksBySpeed.keys), cell2mat(martianAveragePeaksBySpeed.values), cell2mat(martianErrorBarsBySpeed.values), 'Color', settings.colors('Martian'), 'LineWidth', 1.5, 'DisplayName', 'Martian');
errorbar(cell2mat(microAveragePeaksBySpeed.keys), cell2mat(microAveragePeaksBySpeed.values), cell2mat(microErrorBarsBySpeed.values), 'Color', settings.colors('Micro'), 'LineWidth', 1.5, 'DisplayName', 'Micro');
errorbar(cell2mat(earthAveragePeaksBySpeed.keys), cell2mat(earthAveragePeaksBySpeed.values), cell2mat(earthErrorBarsBySpeed.values), 'Color', settings.colors('Earth'), 'LineWidth', 1.5, 'DisplayName', 'Earth');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
%title(['Slipping events vs. probe speed (micro) (', num2str(microMinPeakHeight), ')']);
%title('Slipping events vs. Probe speed for Various Gravities');
xlim([0, 12]);
%ylim([0, max(microNumPeaks)+1]);

% Instead of showing a legend, annotate the values of each one
legend()
%text(75, 20, 'Martian, $g \approx \frac{2}{5} g_{Earth}$', 'Interpreter', 'latex', 'Color', settings.colors('Martian'));
%text(140, 14, 'Lunar, $g \approx \frac{1}{6} g_{Earth}$', 'Interpreter', 'latex', 'Color', settings.colors('Lunar'));
%text(110, 7, 'Micro, $g \approx .001 g_{Earth}$', 'Interpreter', 'latex', 'Color', settings.colors('Micro'));

saveFileNameNoExtension = 'All-SlipCounting';
printfig(5, saveFileNameNoExtension);

end

