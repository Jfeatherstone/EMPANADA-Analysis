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
figureWidth = 720;
figureHeight = 480;

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         LUNAR
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hold on;
for i=1: length(lunarGravityTrials)
   disp(std(lunarGravityTrials(i).results.averageBrightness));
   disp(lunarGravityTrials(i).speed);
   plot(lunarGravityTrials(i).speed, std(lunarGravityTrials(i).results.averageBrightness), settings.pointSymbols(lunarGravityTrials(i).day), 'Color', settings.colors('Lunar'));
end

xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Lunar)');
%xlim([0, 240]);
legend('Day 1', 'Day 2');

saveFileNameNoExtension = 'Lunar-StandardDeviation';
printfig(1, saveFileNameNoExtension);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%         MARTIAN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2);
hold on;
for i=1: length(martianGravityTrials)
   disp(std(martianGravityTrials(i).results.averageBrightness));
   disp(martianGravityTrials(i).speed);
   plot(martianGravityTrials(i).speed, std(martianGravityTrials(i).results.averageBrightness), settings.pointSymbols(martianGravityTrials(i).day), 'Color', settings.colors('Martian'));
end

xlabel('Probe speed [mm/s]');
ylabel('Standard deviation of brightness');
title('Standard deviation vs. probe speed (Martian)');
%xlim([0, 240]);
legend('Day 1', 'Day 2');

saveFileNameNoExtension = 'Martian-StandardDeviation';
printfig(2, saveFileNameNoExtension);

end

