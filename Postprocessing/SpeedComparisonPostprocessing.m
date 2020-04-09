function SpeedComparisonPostprocessing(matFileContainingTrials)

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
settings.charfrac = .7;
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

% We also want to group our data together by the insertion speed, so that
% we can graph the similar data at the same offset

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       LUNAR CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We first have to convert the speeds to numbers
for i=1: length(lunarGravityTrials)
   lunarGravityTrials(i).speed = str2double(lunarGravityTrials(i).speed);
end

[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

allLunarBrightnessData = [];
%allLunarGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allLunarBrightnessData = [allLunarBrightnessData, lunarGravityTrials(i).results.averageBrightness - mean(lunarGravityTrials(i).results.averageBrightness)]; 
   %allLunarGSquaredData = [allLunarGSquaredData, lunarGravityTrials(i).results.averageGSquared - mean(lunarGravityTrials(i).results.averageGSquared)]; 
end

lunarBrightnessNormalization = max(allLunarBrightnessData);
%lunarGSquaredNormalization = max(allLunarGSquaredData);

lunarSpeeds = zeros(1, length(lunarGravityTrials));
lunarDays = zeros(1, length(lunarGravityTrials));

for i=1: length(lunarGravityTrials)
   lunarSpeeds(i) = lunarGravityTrials(i).speed;
   lunarDays(i) = lunarGravityTrials(i).day;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MARTIAN CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1: length(martianGravityTrials)
   martianGravityTrials(i).speed = str2double(martianGravityTrials(i).speed);
end

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

allMartianBrightnessData = [];
%allMartianGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allMartianBrightnessData = [allMartianBrightnessData, martianGravityTrials(i).results.averageBrightness - mean(martianGravityTrials(i).results.averageBrightness)]; 
   %allMartianGSquaredData = [allMartianGSquaredData, martianGravityTrials(i).results.averageGSquared - mean(martianGravityTrials(i).results.averageGSquared)]; 
end

martianBrightnessNormalization = max(allMartianBrightnessData);
%martianGSquaredNormalization = max(allMartianGSquaredData);

martianSpeeds = zeros(1, length(martianGravityTrials));
martianDays = zeros(1, length(martianGravityTrials));

for i=1: length(martianGravityTrials)
   martianSpeeds(i) = martianGravityTrials(i).speed;
   martianDays(i) = martianGravityTrials(i).day;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MICRO CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1: length(microGravityTrials)
   microGravityTrials(i).speed = str2double(microGravityTrials(i).speed);
end

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

allMicroBrightnessData = [];
%allMicroGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allMicroBrightnessData = [allMicroBrightnessData, microGravityTrials(i).results.averageBrightness - mean(microGravityTrials(i).results.averageBrightness)]; 
   %allMicroGSquaredData = [allMicroGSquaredData, microGravityTrials(i).results.averageGSquared - mean(microGravityTrials(i).results.averageGSquared)]; 
end

microBrightnessNormalization = max(allMicroBrightnessData);
%microGSquaredNormalization = max(allMicroGSquaredData);
% Now that we have them separated and sorted, we can graph all of them

% We don't need to record the days for micro as they are all from day 1
microSpeeds = zeros(1, length(microGravityTrials));

for i=1: length(microGravityTrials)
   microSpeeds(i) = microGravityTrials(i).speed;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       LUNAR BRIGTHNESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We don't want graphs to overlap, so we put an offset in here
offsetFactor = 1 / length(lunarGravityTrials);
figure(1);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average brightness [arb. units]');
title('Speed Comparison of Probe in Lunar Gravity')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
%ylim([-1, 1]);
legend();


for i=1: length(lunarGravityTrials)
    brightnessData = (lunarGravityTrials(i).results.averageBrightness - mean(lunarGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (lunarBrightnessNormalization * length(lunarGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*(lunarSpeeds(i)/max(lunarSpeeds) - 1)) * offsetFactor;
    plot(lunarGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(lunarGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = 'Lunar-SpeedComparisonBrightness';
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(1, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       LUNAR G SQUARED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure(2);
% hold on;
% set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
% xlabel('Time [s]');
% ylabel('Average G squared [arb. units]');
% title('Speed Comparison of Probe in Lunar Gravity (G Squared)')
% % Since we have weird units, we don't need y ticks
% set(gca,'ytick',[]);
% set(gca,'yticklabel',[]);
% % We don't want to auto adjust our axis limits since we want to not
% % have any of the graphs be on top of each other
% ylim([-1, 1]);
% legend();
% 
% for i=1: length(lunarGravityTrials)
%     % This is the same normalization that is done in BasicPostProcessing
%     gSquaredData = (lunarGravityTrials(i).results.averageGSquared - mean(lunarGravityTrials(i).results.averageGSquared));
%     gSquaredData = gSquaredData / (lunarBrightnessNormalization * length(lunarGravityTrials));
%     % Now account for our offset
%     % I kinda just messed around with this formula until it looked good, so
%     % there's no real reason why it looks like this :/
%     gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
%     plot(lunarGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(lunarGravityTrials(i).speed), ' mm/s']);
% 
% end
% % Now save the figure
% saveFileNameNoExtension = ['Day', lunarGravityTrials(1).day, '-Lunar-SpeedComparisonGSquared'];
% % This is a custom figure saving method, see file for more info
% % (printfig.m)
% printfig(2, saveFileNameNoExtension);
% hold off


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     MARTIAN BRIGHTNESS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% We don't want graphs to overlap, so we put an offset in here
offsetFactor = 1 / length(martianGravityTrials);

figure(3);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average brightness [arb. units]');
title('Speed Comparison of Probe in Martian Gravity')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(martianGravityTrials)
    brightnessData = (martianGravityTrials(i).results.averageBrightness - mean(martianGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (martianBrightnessNormalization * length(martianGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(martianGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(martianGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = 'Martian-SpeedComparisonBrightness';
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(3, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MARTIAN G SQUARED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% figure(4);
% hold on;
% set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
% xlabel('Time [s]');
% ylabel('Average G squared [arb. units]');
% title('Speed Comparison of Probe in Martian Gravity (G Squared)')
% % Since we have weird units, we don't need y ticks
% set(gca,'ytick',[]);
% set(gca,'yticklabel',[]);
% % We don't want to auto adjust our axis limits since we want to not
% % have any of the graphs be on top of each other
% ylim([-1, 1]);
% legend();
% 
% for i=1: length(martianGravityTrials)
%     % This is the same normalization that is done in BasicPostProcessing
%     gSquaredData = (martianGravityTrials(i).results.averageGSquared - mean(martianGravityTrials(i).results.averageGSquared));
%     gSquaredData = gSquaredData / (martianGSquaredNormalization * length(martianGravityTrials));
%     % Now account for our offset
%     % I kinda just messed around with this formula until it looked good, so
%     % there's no real reason why it looks like this :/
%     gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
%     plot(martianGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(martianGravityTrials(i).speed), ' mm/s']);
% 
% end
% % Now save the figure
% saveFileNameNoExtension = ['Day', martianGravityTrials(1).day, '-Martian-SpeedComparisonGSquared'];
% % This is a custom figure saving method, see file for more info
% % (printfig.m)
% printfig(4, saveFileNameNoExtension);
% hold off


%%%%%%%%%%%%%%%%%%%%%%%%%
%    MICRO BRIGHTNESS
%%%%%%%%%%%%%%%%%%%%%%%%%

% We don't want graphs to overlap, so we put an offset in here
offsetFactor = 1 / length(microGravityTrials);

figure(5);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average brightness [arb. units]');
title('Speed Comparison of Probe in Micro Gravity')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(microGravityTrials)
    brightnessData = (microGravityTrials(i).results.averageBrightness - mean(microGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (microBrightnessNormalization * length(microGravityTrials) * .5);
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(microGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(microGravityTrials(i).speed), ' mm/s']);
end
% Now save the figure
saveFileNameNoExtension = 'Micro-SpeedComparisonBrightness';
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(5, saveFileNameNoExtension);
hold off

% figure(6);
% hold on;
% set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
% xlabel('Time [s]');
% ylabel('Average G squared [arb. units]');
% title('Speed Comparison of Probe in Micro Gravity (G Squared)')
% % Since we have weird units, we don't need y ticks
% set(gca,'ytick',[]);
% set(gca,'yticklabel',[]);
% % We don't want to auto adjust our axis limits since we want to not
% % have any of the graphs be on top of each other
% ylim([-1, 1]);
% legend();
% 
% for i=1: length(microGravityTrials)
%     % This is the same normalization that is done in BasicPostProcessing
%     gSquaredData = (microGravityTrials(i).results.averageGSquared - mean(microGravityTrials(i).results.averageGSquared));
%     gSquaredData = gSquaredData / (microBrightnessNormalization * length(microGravityTrials) * .5);
%     % Now account for our offset
%     % I kinda just messed around with this formula until it looked good, so
%     % there's no real reason why it looks like this :/
%     gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
%     plot(microGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(microGravityTrials(i).speed), ' mm/s']);
% 
% end
% % Now save the figure
% saveFileNameNoExtension = ['Day', microGravityTrials(1).day, '-Micro-SpeedComparisonGSquared'];
% % This is a custom figure saving method, see file for more info
% % (printfig.m)
% printfig(6, saveFileNameNoExtension);
% hold off

end % Function end