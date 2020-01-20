% Load in the trial data
load('AnalyzedData.mat');

fig = figure();
axh = axes('Parent', fig);

% The number of the trial that we are looking to analyze
trialNum = 1;

% We want to normalize the data to keep things clean (doesn't really matter
% other than that)
normalizedData = trials(trialNum).results.averageBrightness - trials(trialNum).results.averageBrightness(1);
normalizedData = normalizedData / max(abs(normalizedData));

Xdata = trials(trialNum).results.frameTime;
Ydata = normalizedData;

% We want to draw a vertical line to follow the current point
verticalLineBounds = [1.2 * max(normalizedData), 1.2 * min(normalizedData)];

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
    linePlot = plot(axh, Xdata, Ydata);
    
    % Highlight the current point with a special character and a vertical
    % line (on the same plot)
    hold on
    point = plot(axh, Xdata(i), Ydata(i), '*', 'MarkerSize', 15);
    plot(axh, [Xdata(i), Xdata(i)], verticalLineBounds, 'm--');
    
    % Title and axes
    title('Average Brightness of Image vs. Time')
    xlabel('Time [s]')
    ylabel('Average Brightness [arb. units]')
    
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
