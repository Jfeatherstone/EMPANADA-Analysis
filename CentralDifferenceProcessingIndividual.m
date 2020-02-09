% Load in our data
load('AnalyzedData.mat')

figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup_laptop;

brightnessLineColor = '#0072BD'; % Default blue
gSquaredLineColor = '#7E2F8E'; % Default purple

for i=1: length(trials)
    % We plot both the derivative and the derivative squared (on separate
    % graphs)
    
    % We use the length of the data - 2 since we don't include the first or
    % last point (since we can't use central difference formula)
    centralDifference = double.empty(length(trials(i).results.averageBrightness) - 2, 0);
    % This is our delta t in the central difference
    frameTimeDifference = trials(trialNum).results.frameTime(2) - trials(trialNum).results.frameTime(1);

    for j=2: length(trials(i).results.averageBrightness) - 1
        centralDifference(j-1) = ((trials(i).results.averageBrightness(j-1) - trials(i).results.averageBrightness(j+1)) / (2 * frameTimeDifference));
    end

    %%%%%%%%%%%%%%%%%%%%%%%
    %       DERIVATIVE
    %%%%%%%%%%%%%%%%%%%%%%%

    % Create the figure and set its size
    figure(2*i)
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    plot(trials(i).results.frameTime(2:end-1), centralDifference);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('d/dt of average brightness [arb. units]');
    % Since we have weird units, we don't need y ticks
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-BrightnessDerivative'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(2*i, saveFileNameNoExtension);

    %%%%%%%%%%%%%%%%%%%%%%%
    % DERIVATIVE SQUARED
    %%%%%%%%%%%%%%%%%%%%%%%
    % Create the figure and set its size
    figure(2*i + 1)
    set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);
    
    plot(trials(i).results.frameTime(2:end-1), centralDifference.^2);
    
    % Create the title
    titleStr = strcat('Day ', char(trials(i).day), ', speed=', char(trials(i).speed), 'mm/s, gravity=', char(trials(i).gravity));
    title(titleStr);
    
    xlabel('Time [s]');
    ylabel('d/dt of average brightness squared [arb. units]');
    % Since we have weird units, we don't need y ticks
    %set(gca,'ytick',[]);
    %set(gca,'yticklabel',[]);
    % Make the graph not pop up (since we'll be saving it to a file)
    set(gcf,'visible','off')
    
    % Now save the figure
    saveFileNameNoExtension = ['Day', char(trials(i).day), '-', char(trials(i).gravity), '-', char(trials(i).speed), 'mms-BrightnessDerivativeSquared'];
    % This is a custom figure saving method, see file for more info
    % (printfig.m)
    printfig(2*i + 1, saveFileNameNoExtension);

end