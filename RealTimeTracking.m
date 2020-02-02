% Load in the trial data
load('AnalyzedData.mat');

fig = figure();
axh = axes('Parent', fig);

% The number of the trial that we are looking to analyze
trialNum = 1;

% We want to normalize the data to keep things clean (doesn't really matter
% other than that)
brightnessData = (trials(trialNum).results.averageBrightness - mean(trials(trialNum).results.averageBrightness));
brightnessData = brightnessData / max(brightnessData);

gSquaredData = (trials(trialNum).results.averageGSquared - mean(trials(trialNum).results.averageGSquared));
gSquaredData = gSquaredData / max(gSquaredData);


Xdata = trials(trialNum).results.frameTime;
Y1data = brightnessData;
Y2data = gSquaredData;

% We want to draw a vertical line to follow the current point
verticalLineBounds = [1.2 * max(gSquaredData), 1.2 * min(gSquaredData)];

% This is an arbitrarily chosen value that just accounts for the minute
% amount of time that it takes for a for loop to process things. I used
% this value because I tried a whole bunch and this seemed to work best, no
% other reason
forLoopEvaluationTolerance = .0004;

for i = 1: length(Xdata)
    % We want to keep track of how long it takes to perform the following
    % actions so that we can keep up with real time
    tic    
    
    % Draw all of the data
    linePlot1 = plot(axh, Xdata, Y1data);
    hold on
    linePlot2 = plot(axh, Xdata, Y2data);
    
    legend('Average Brightness', 'Average G Squared');
    
    % Highlight the point with a special character and a vertical
    % line (on the same plot)
    point1 = plot(axh, Xdata(i), Y1data(i), '*', 'MarkerSize', 15);
    point2 = plot(axh, Xdata(i), Y2data(i), '*', 'MarkerSize', 15);

    plot(axh, [Xdata(i), Xdata(i)], verticalLineBounds, 'm--');
    
    % Title and axes
    title('Average Brightness of Image and G Squared vs. Time')
    xlabel('Time [s]')
    ylabel('Average Brightness / G Squared [arb. units]')
    
    if i > 1
        % This is how much time we should wait, which accounts for the time
        % it takes to do the above actions
        waitTime = (trials(trialNum).results.frameTime(i) - trials(trialNum).results.frameTime(i-1)) - toc - forLoopEvaluationTolerance;
        
        % If the wait time is negative, that means we're behind and need to
        % skip ahead to catch up
        if waitTime < 0
            i = i + 1;
            disp(waitTime);
            hold off
            continue;
        end
        
        pause(waitTime);
    end
    
    hold off
end
