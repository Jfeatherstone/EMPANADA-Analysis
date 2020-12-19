
brightnessMatFile = 'Analysis/BrightnessAnalysisAllEdited.mat';
gSquaredMatFile = 'Analysis/GSquaredAnalysisAllEdited.mat';
forceMatFile = 'Preprocessing/ForceData.mat';

% Load in the data
load(brightnessMatFile, 'trials');
bTrials = trials;

load(gSquaredMatFile, 'trials');
gTrials = trials;

load(forceMatFile, 'trials');
fTrials = trials;

% Set our figure sizes
figureWidth = 1080;
figureHeight = 720;

% Adjust the font to be a little smaller, and rerun our startup
settings.charfrac = .7;
startup;

% Loop over all possible days and speeds
possibleDays = [3, 4, 6, 7, 8, 9, 10, 11];
possibleSpeeds = [2, 3, 4, 5, 6, 7, 8, 9, 10];

for i = 1: length(possibleDays)
    trialDay = possibleDays(i);
    for j = 1: length(possibleSpeeds)
        trialSpeed = possibleSpeeds(j);
        fileName = ['MethodComparison-Day-', num2str(trialDay), '-', num2str(trialSpeed), 'mms'];
        
        [brightnessIndex, ] = intersect(find([bTrials(:).day] == trialDay), find([convertCharsToStrings({bTrials.speed})] == num2str(trialSpeed)));
        [gSquaredIndex, ] = intersect(find([gTrials(:).day] == trialDay), find([convertCharsToStrings({gTrials.speed})] == num2str(trialSpeed)));
        [forceIndex, ] = intersect(find([fTrials(:).day] == trialDay), find([convertCharsToStrings({fTrials.speed})] == num2str(trialSpeed)));

        if isempty(forceIndex) || isempty(brightnessIndex) || isempty(gSquaredIndex)
            fprintf("Invalid day and/or speed (Day %i, %i mm/s)!\n", trialDay, trialSpeed);
            continue
        end
        
        figure(i*(length(possibleSpeeds)+1) + j);
        hold on;

        set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

        plot(bTrials(brightnessIndex).results.frameTime, abs(bTrials(brightnessIndex).results.averageBrightnessDerivative) / max(abs(bTrials(brightnessIndex).results.averageBrightnessDerivative)), 'Color', settings.colors("Earth"), 'DisplayName', 'd/dt \langle Brightness \rangle');
        plot(gTrials(gSquaredIndex).results.frameTime, gTrials(gSquaredIndex).results.averageGSquared / max(gTrials(gSquaredIndex).results.averageGSquared), 'Color', settings.colors("Earth-alt"), 'DisplayName', '\langle G^2 \rangle');
        plot(fTrials(forceIndex).results.frameTime, fTrials(forceIndex).results.forceData / max(fTrials(forceIndex).results.forceData), 'Color', settings.colors("Micro-alt"), 'DisplayName', 'Load Cell');

        xlabel('Time [s]');
        legend()
        title(fileName);
        
        set(gcf,'visible','off')
        fprintf(fileName)
        printfig(i*(length(possibleSpeeds)+1) + j, fileName);
        savePDF(fileName);

    end
    
end