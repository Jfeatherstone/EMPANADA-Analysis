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

% We first have to convert the speeds to numbers
for i=1: length(lunarGravityTrials)
   lunarGravityTrials(i).speed = str2double(lunarGravityTrials(i).speed);
end

[values, index] = sort([lunarGravityTrials.speed], 'ascend');
lunarGravityTrials = lunarGravityTrials(index);
%lunarBrightnessNormalization = max(lunarGravityTrials.results.averageBrightness);
%lunarGSquaredNormalization = max(lunarGravityTrials.results.averageGSquared);

for i=1: length(martianGravityTrials)
   martianGravityTrials(i).speed = str2double(martianGravityTrials(i).speed);
end

[values, index] = sort([martianGravityTrials.speed], 'ascend');
martianGravityTrials = martianGravityTrials(index);

for i=1: length(microGravityTrials)
   microGravityTrials(i).speed = str2double(microGravityTrials(i).speed);
end

[values, index] = sort([microGravityTrials.speed], 'ascend');
microGravityTrials = microGravityTrials(index);

% Now that we have them separated and sorted, we can graph all of them

%%%%%%%%%%%%%%%%%%%%%%%
%       LUNAR
%%%%%%%%%%%%%%%%%%%%%%%

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
    brightnessData = brightnessData / (max(brightnessData) * length(lunarGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(lunarGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(lunarGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', lunarGravityTrials(1).day, '-Lunar-SpeedComparison'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(1, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%
%       MARTIAN
%%%%%%%%%%%%%%%%%%%%%%%

% We don't want graphs to overlap, so we put an offset in here
% We use 2 here since our y limits and -1 to 1, which has a height of 2
offsetFactor = 1 / length(martianGravityTrials);

figure(2);
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
    brightnessData = brightnessData / (max(brightnessData) * length(martianGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(martianGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(martianGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', martianGravityTrials(1).day, '-Martian-SpeedComparison'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(2, saveFileNameNoExtension);
hold off

%%%%%%%%%%%%%%%%%%%%%%%
%       MICRO
%%%%%%%%%%%%%%%%%%%%%%%

% We don't want graphs to overlap, so we put an offset in here
% We use 2 here since our y limits and -1 to 1, which has a height of 2
offsetFactor = 1 / length(microGravityTrials);

figure(3);
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
    brightnessData = brightnessData / (max(brightnessData) * length(microGravityTrials));
    % Now account for our offset
    % I kinda just messed around with this formula until it looked good, so
    % there's no real reason why it looks like this :/
    brightnessData = brightnessData - 1 + (2*i - 1) * offsetFactor;
    plot(microGravityTrials(i).results.frameTime, brightnessData, 'DisplayName', [num2str(microGravityTrials(i).speed), ' mm/s']);

end
% Now save the figure
saveFileNameNoExtension = ['Day', microGravityTrials(1).day, '-Micro-SpeedComparison'];
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(3, saveFileNameNoExtension);
hold off