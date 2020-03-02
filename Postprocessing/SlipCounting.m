function SlipCounting(startupFile, matFileContainingTrials)

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

% First, convert speed to numbers instead of strings
% We first have to convert the speeds to numbers
for i=1: length(trials)
   trials(i).speed = str2double(trials(i).speed);
end


% We want to sort each trial into it's gravity
% These are the same structs from LoadFiles.m
microGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'results', {});
martianGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'results', {});
lunarGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'results', {});

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

% Lets sort our structs as well, while we're at it
[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);


% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
run(startupFile);

% These values are chosen by just looking at the data, a more precise way
% to find similar values should be looked into
lunarMinPeakHeight = 100;
martianMinPeakHeight = 100;
microMinPeakHeight = 10;
minPeakDistance = 1;

lunarNumPeaks = zeros(1, length(lunarGravityTrials));
lunarSpeeds = zeros(1, length(lunarGravityTrials));

martianNumPeaks = zeros(1, length(martianGravityTrials));
martianSpeeds = zeros(1, length(martianGravityTrials));

microNumPeaks = zeros(1, length(microGravityTrials));
microSpeeds = zeros(1, length(microGravityTrials));

for i=1: length(lunarGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = lunarGravityTrials(i).results.averageBrightnessDerivative.^2;
   lunarNumPeaks(i) = length(findpeaks(data, lunarGravityTrials(i).results.frameTime, 'MinPeakHeight', lunarMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
end

for i=1: length(martianGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = martianGravityTrials(i).results.averageBrightnessDerivative.^2;
   martianNumPeaks(i) = length(findpeaks(data, martianGravityTrials(i).results.frameTime, 'MinPeakHeight', martianMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   martianSpeeds(i) = martianGravityTrials(i).speed;
end

for i=1: length(microGravityTrials)
   % We count trials by using the localmax function on the brightness derivative
   data = microGravityTrials(i).results.averageBrightnessDerivative.^2;
   microNumPeaks(i) = length(findpeaks(data, microGravityTrials(i).results.frameTime, 'MinPeakHeight', microMinPeakHeight, 'MinPeakDistance', minPeakDistance));
   microSpeeds(i) = microGravityTrials(i).speed;
end

% Now plot stuff
figure(1);
plot(lunarSpeeds, lunarNumPeaks, '*');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (Lunar)');
xlim([0, 240]);
ylim([max(min(lunarNumPeaks-1), 0), max(lunarNumPeaks)+1]);
saveFileNameNoExtension = 'Lunar-SlipCounting';
printfig(1, saveFileNameNoExtension);

figure(2);
plot(martianSpeeds, martianNumPeaks, '*');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (Martian)');
xlim([0, 240]);
ylim([max(min(martianNumPeaks-1), 0), max(martianNumPeaks)+1]);
saveFileNameNoExtension = 'Martian-SlipCounting';
printfig(2, saveFileNameNoExtension);

figure(3);
plot(microSpeeds, microNumPeaks, '*');
xlabel('Probe speed [mm/s]');
ylabel('# of slipping events');
title('Slipping events vs. probe speed (micro)');
xlim([0, 240]);
ylim([max(min(microNumPeaks-1), 0), max(microNumPeaks)+1]);
saveFileNameNoExtension = 'Micro-SlipCounting';
printfig(3, saveFileNameNoExtension);


end
