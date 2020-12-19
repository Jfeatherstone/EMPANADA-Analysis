function MethodComparison(trialDay, trialSpeed, brightnessMatFile, gSquaredMatFile, forceMatFile)

global settings

% Day 10 2mm/s looks quite nice, so that is the default
if ~exist('trialDay', 'var')
    trialDay = 10;
end
if ~exist('trialSpeed', 'var')
    trialSpeed = 2;
end

% In case data is not provided, we default to what is below
if ~exist('brightnessMatFile', 'var')
   brightnessMatFile = 'Analysis/BrightnessAnalysisAllEdited.mat';
   fprintf('Warning: brightness file not provided, defaulting to %s\n', brightnessMatFile);
end

% In case data is not provided, we default to what is below
if ~exist('gSquaredMatFile', 'var')
   gSquaredMatFile = 'Analysis/GSquaredAnalysisAllEdited.mat';
   fprintf('Warning: g squared file not provided, defaulting to %s\n', gSquaredMatFile);
end

% In case data is not provided, we default to what is below
if ~exist('forceMatFile', 'var')
   forceMatFile = 'Preprocessing/ForceData.mat';
   fprintf('Warning: force file not provided, defaulting to %s\n', forceMatFile);
end


% Load in the data
load(brightnessMatFile, 'trials');
bTrials = trials;

load(gSquaredMatFile, 'trials');
gTrials = trials;

load(forceMatFile, 'trials');
fTrials = trials;

% Find the proper trial indices
% Since the trial structs are organized in an arbitrary order, we have to
% grab the trial that corresponds to the provided trialDay and trialSpeed
% (and Earth gravity, since that's the only one we have force data for)
% We do this by searching through the list, and expect that only a single
% trial is taken for each day/speed pair
% There is probably a better way to do this, but this method works
% The reason the second part is so complicated is because the speeds are
% stored in '', which makes them chars (idk why I did that, I should
% probably reword the code to have them as numbers)
[brightnessIndex, ] = intersect(find([bTrials(:).day] == trialDay), find([convertCharsToStrings({bTrials.speed})] == num2str(trialSpeed)));
[gSquaredIndex, ] = intersect(find([gTrials(:).day] == trialDay), find([convertCharsToStrings({gTrials.speed})] == num2str(trialSpeed)));
[forceIndex, ] = intersect(find([fTrials(:).day] == trialDay), find([convertCharsToStrings({fTrials.speed})] == num2str(trialSpeed)));

if isempty(forceIndex) || isempty(brightnessIndex) || isempty(gSquaredIndex)
    fprintf("Invalid day and/or speed provided!\n")
    return
end

%return

% Set up for Day10 2mm/s trial
arrowColors = ["#f40a0a", "#f4710a", "#f8cc59", "#33ae06", "#6796f3", "#3392ab", "#8126d0"];
brightnessArrowXPositions = [7, 11, 18, 31.5, 41.5, 50.5, 55];
brightnessArrowYPositions = [.4, .58, .72, 1.05, .40, .39, 1.0]*max(abs(bTrials(brightnessIndex).results.averageBrightnessDerivative));

gSquaredArrowXPositions = [5.5, 10, 17.5, 30, 41, 49, 55];
gSquaredArrowYPositions = [.81, .85, .86, .93, .89, .88, 1.01]*max(gTrials(gSquaredIndex).results.averageGSquared);

forceArrowXPositions = [4, 9, 16.5, 29.5, 39.5, 49, 54];
forceArrowYPositions = [.235, .26, .30, .45, .40, .65, 1.01]*max(fTrials(forceIndex).results.forceData);

% Just a small number to make sure the arrow doesn't turn horizontally
% We really only draw the arrow head, so this doesn't matter
arrowLength = 0.001;

% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
settings.charfrac = .7;
startup;

figure(1);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

plot(bTrials(brightnessIndex).results.frameTime, abs(bTrials(brightnessIndex).results.averageBrightnessDerivative), 'Color', settings.colors("Earth"));

for i=1: length(brightnessArrowXPositions)
    drawArrow([brightnessArrowXPositions(i), brightnessArrowXPositions(i)], [brightnessArrowYPositions(i) + arrowLength/2., brightnessArrowYPositions(i) - arrowLength/2.], {'Color', arrowColors(i)})
end

% No xlabel since this graph goes on top of the other
xlabel('Time [s]');
ylabel('|d/dt \langle Brightness \rangle|');
%xlim([0, 12])
ylim([0, 2.5])
yticks([]);
% Make the graph not pop up (since we'll be saving it to a file)
set(gcf,'visible','off')

% Now save the figure
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(1, 'MethodComparison-Brightness');
savePDF('MethodComparison-Brightness')

figure(2);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

plot(gTrials(gSquaredIndex).results.frameTime, gTrials(gSquaredIndex).results.averageGSquared, 'Color', settings.colors("Earth-alt"));

for i=1: length(gSquaredArrowXPositions)
    drawArrow([gSquaredArrowXPositions(i), gSquaredArrowXPositions(i)], [gSquaredArrowYPositions(i) + arrowLength/2., gSquaredArrowYPositions(i) - arrowLength/2.], {'Color', arrowColors(i)})
end

xlabel('Time [s]');
ylabel('\langle G^2 \rangle');
%xlim([0, 12])
ylim([33, 62])
yticks([]);

% Make the graph not pop up (since we'll be saving it to a file)
set(gcf,'visible','off')

% Now save the figure
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(2, 'MethodComparison-GSquared');
savePDF('MethodComparison-GSquared');

figure(3);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

plot(fTrials(forceIndex).results.frameTime, fTrials(forceIndex).results.forceData, 'Color', settings.colors("Martian-alt"));

for i=1: length(forceArrowXPositions)
    drawArrow([forceArrowXPositions(i), forceArrowXPositions(i)], [forceArrowYPositions(i) + arrowLength/2., forceArrowYPositions(i) - arrowLength/2.], {'Color', arrowColors(i)})
end


xlabel('Time [s]');
ylabel('Load Cell Reading');
%xlim([0, 12])
ylim([200, 1900])
yticks([]);

% Make the graph not pop up (since we'll be saving it to a file)
set(gcf,'visible','off')

% Now save the figure
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(3, 'MethodComparison-Force');
savePDF('MethodComparison-Force');

figure(4);
hold on;

set(gcf, 'Position', [0, 0, 2*figureWidth, 2*figureHeight]);

plot(bTrials(brightnessIndex).results.frameTime, abs(bTrials(brightnessIndex).results.averageBrightnessDerivative) / max(abs(bTrials(brightnessIndex).results.averageBrightnessDerivative)), 'Color', settings.colors("Earth"), 'DisplayName', '|d/dt \langle Brightness \rangle|');
plot(gTrials(gSquaredIndex).results.frameTime, gTrials(gSquaredIndex).results.averageGSquared / max(gTrials(gSquaredIndex).results.averageGSquared), 'Color', settings.colors("Earth-alt"), 'DisplayName', '\langle G^2 \rangle');
plot(fTrials(forceIndex).results.frameTime, fTrials(forceIndex).results.forceData / max(fTrials(forceIndex).results.forceData), 'Color', settings.colors("Martian-alt"), 'DisplayName', 'Load Cell');

xlabel('Time [s]');
legend()

set(gcf,'visible','off')
printfig(4, 'MethodComparison-All');
savePDF('MethodComparison-All');

% From: https://stackoverflow.com/questions/25729784/how-to-draw-an-arrow-in-matlab
function drawArrow(x, y, props)

h = annotation('arrow');
set(h,'parent', gca, ...
    'position', [x(1),y(1),x(2)-x(1),y(2)-y(1)], ...
    'HeadLength', 45, 'HeadWidth', 40, props{:}, 'LineStyle', 'none');

end

end