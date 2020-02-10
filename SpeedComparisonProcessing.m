% Load in our data
load('AnalyzedData.mat')

figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup_laptop;

% We want to sort each trial into it's gravity
% These are the same structs from LoadFiles.m
microGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fullPath', {}, 'results', {});
martianGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fullPath', {}, 'results', {});
lunarGravityTrials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fullPath', {}, 'results', {});

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
%       LUNAR CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% We first have to convert the speeds to numbers
for i=1: length(lunarGravityTrials)
   lunarGravityTrials(i).speed = str2double(lunarGravityTrials(i).speed);
end

[~, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);

allLunarBrightnessData = [];
allLunarGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allLunarBrightnessData = [allLunarBrightnessData, lunarGravityTrials(i).results.averageBrightness - mean(lunarGravityTrials(i).results.averageBrightness)]; 
   allLunarGSquaredData = [allLunarGSquaredData, lunarGravityTrials(i).results.averageGSquared - mean(lunarGravityTrials(i).results.averageGSquared)]; 
end

lunarBrightnessNormalization = max(allLunarBrightnessData);
lunarGSquaredNormalization = max(allLunarGSquaredData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MARTIAN CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1: length(martianGravityTrials)
   martianGravityTrials(i).speed = str2double(martianGravityTrials(i).speed);
end

[~, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

allMartianBrightnessData = [];
allMartianGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allMartianBrightnessData = [allMartianBrightnessData, martianGravityTrials(i).results.averageBrightness - mean(martianGravityTrials(i).results.averageBrightness)]; 
   allMartianGSquaredData = [allMartianGSquaredData, martianGravityTrials(i).results.averageGSquared - mean(martianGravityTrials(i).results.averageGSquared)]; 
end

martianBrightnessNormalization = max(allMartianBrightnessData);
martianGSquaredNormalization = max(allMartianGSquaredData);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MICRO CLEANUP
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for i=1: length(microGravityTrials)
   microGravityTrials(i).speed = str2double(microGravityTrials(i).speed);
end

[~, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

allMicroBrightnessData = [];
allMicroGSquaredData = [];
for i=1: length(lunarGravityTrials)
   allMicroBrightnessData = [allMicroBrightnessData, microGravityTrials(i).results.averageBrightness - mean(microGravityTrials(i).results.averageBrightness)]; 
   allMicroGSquaredData = [allMicroGSquaredData, microGravityTrials(i).results.averageGSquared - mean(microGravityTrials(i).results.averageGSquared)]; 
end

microBrightnessNormalization = max(allMicroBrightnessData);
microGSquaredNormalization = max(allMicroGSquaredData);
% Now that we have them separated and sorted, we can graph all of them

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
title('Speed Comparison of Probe in Lunar Gravity (Brightness)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(lunarGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    brightnessData = (lunarGravityTrials(i).results.averageBrightness - mean(lunarGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (lunarBrightnessNormalization * length(lunarGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(lunarGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(lunarGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', lunarGravityTrials(1).day, '-Lunar-SpeedComparisonBrightness'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(1, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       LUNAR G SQUARED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(2);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average G squared [arb. units]');
title('Speed Comparison of Probe in Lunar Gravity (G Squared)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(lunarGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    gSquaredData = (lunarGravityTrials(i).results.averageGSquared - mean(lunarGravityTrials(i).results.averageGSquared));
    gSquaredData = gSquaredData / (lunarBrightnessNormalization * length(lunarGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
    plot(lunarGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(lunarGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', lunarGravityTrials(1).day, '-Lunar-SpeedComparisonGSquared'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(2, saveFileNameNoExtension);
hold off


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
title('Speed Comparison of Probe in Martian Gravity (Brightness)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(martianGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    brightnessData = (martianGravityTrials(i).results.averageBrightness - mean(martianGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (martianBrightnessNormalization * length(martianGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(martianGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(martianGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', martianGravityTrials(1).day, '-Martian-SpeedComparisonBrightness'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(3, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%       MARTIAN G SQUARED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

figure(4);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average G squared [arb. units]');
title('Speed Comparison of Probe in Martian Gravity (G Squared)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(martianGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    gSquaredData = (martianGravityTrials(i).results.averageGSquared - mean(martianGravityTrials(i).results.averageGSquared));
    gSquaredData = gSquaredData / (martianGSquaredNormalization * length(martianGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
    plot(martianGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(martianGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', martianGravityTrials(1).day, '-Martian-SpeedComparisonGSquared'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(4, saveFileNameNoExtension);
hold off


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
title('Speed Comparison of Probe in Micro Gravity (Brightness)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(microGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    brightnessData = (microGravityTrials(i).results.averageBrightness - mean(microGravityTrials(i).results.averageBrightness));
    brightnessData = brightnessData / (microBrightnessNormalization * length(microGravityTrials) * .5);
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(microGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(microGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', microGravityTrials(1).day, '-Micro-SpeedComparisonBrightness'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(5, saveFileNameNoExtension);
hold off

figure(6);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
xlabel('Time [s]');
ylabel('Average G squared [arb. units]');
title('Speed Comparison of Probe in Micro Gravity (G Squared)')
% Since we have weird units, we don't need y ticks
set(gca,'ytick',[]);
set(gca,'yticklabel',[]);
% We don't want to auto adjust our axis limits since we want to not
% have any of the graphs be on top of each other
ylim([-1, 1]);
legend();

for i=1: length(microGravityTrials)
    % This is the same normalization that is done in BasicPostProcessing
    gSquaredData = (microGravityTrials(i).results.averageGSquared - mean(microGravityTrials(i).results.averageGSquared));
    gSquaredData = gSquaredData / (microBrightnessNormalization * length(microGravityTrials) * .5);
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    gSquaredData = gSquaredData - 1 + (2*i - 1) * offsetFactor;
    plot(microGravityTrials(i).results.frameTime, gSquaredData, 'DisplayName', [num2str(microGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', microGravityTrials(1).day, '-Micro-SpeedComparisonGSquared'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(6, saveFileNameNoExtension);
hold off