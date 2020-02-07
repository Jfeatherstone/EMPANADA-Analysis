% Load in the trial data
load('AnalyzedData.mat');

% 1 is arbitrary here, just some integer, since we only have one figure
% here (I guess I could technically not use any, but...)
figure(1);

% The number of the trial that we are looking to analyze
% This can later be changed to iterate over trialNum very easily
trialNum = 1;
video = VideoReader('/home/jack/workspaces/matlab-workspace/EMPANADA-Proper/Day1-Lunar-210mms.mov');

% Set the size of our figure (note that this is a tall figure)
figureWidth = 720;
figureHeight = 950;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .8;
startup_laptop;

brightnessLineColor = '#0072BD'; % Default blue
gSquaredLineColor = '#7E2F8E'; % Default purple

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

% Start our index at one, this will inevitably skip over a lot of numbers
% though
i = 1;

% This is so that we can find the current data point by dividing the
% current video time by this variable
frameTimeDifference = trials(trialNum).results.frameTime(2) - trials(trialNum).results.frameTime(1);

% We use this to time how long it has been since we started the loop, so
% that we can skip along in the video as necessary
% Unless we have a literal supercomputer I don't think we will get every
% frame here, so if that is what you're looking for, check out
% RealTimeTrackingSave.m, which exports a nice, smooth video of the
% comparison
tic

while hasFrame(video)
    currentFrame = readFrame(video);
    
    % We want to keep track of how long it takes to perform the following
    % actions so that we can keep up with real time
    
    % Switch to the first (upper) plot
    s1 = subplot(2, 1, 1);
    % Set the position so that the overall result looks nice
    % See help on 'Position' to specifically see what the values mean
    set(s1, 'Position', [.1, .5, .85, .45]);
    
    % Draw all of the data
    linePlot1 = plot(Xdata, Y1data, 'Color', brightnessLineColor);
    hold on
    linePlot2 = plot(Xdata, Y2data, 'Color', gSquaredLineColor);
    
    % Create the legend (we have set all of the following curves to not
    % show up here using 'HandleVisibility')
    legend('Average Brightness', 'Average G Squared');
    
    % Highlight the point with a special character and a vertical
    % line (on the same plot)
    point1 = plot(Xdata(i), Y1data(i), 'b*', 'MarkerSize', 15, 'HandleVisibility', 'off');
    point2 = plot(Xdata(i), Y2data(i), 'm*', 'MarkerSize', 15, 'HandleVisibility', 'off');
    plot([Xdata(i), Xdata(i)], verticalLineBounds, 'b--', 'HandleVisibility', 'off');

    % Title and axes
    title('Average Brightness of Image and G Squared vs. Time')
    xlabel('Time [s]')
    ylabel('Average Brightness / G Squared [arb. units]')
    
    % Now switch back to our second (lower) plot
    s2 = subplot(2, 1, 2);
    % Set the position that our overall result looks nice
    set(s2, 'Position', [.1, .02, .85, .45]);
    % Show the current frame
    imshow(currentFrame);
    
    % We want to keep the video moving along, even if it means we skip
    % frames
    % For a smoother version of this, see RealTimeTrackingSave.m
    if toc > video.Duration
        break;
    end
    video.CurrentTime = toc;
    
    % Now skip however many frames in the graph
    % Note that we cast to int32 here; I used int32 instead of any other
    % int just in case we have some *really* long videos
    i = int32(video.CurrentTime / frameTimeDifference);
    
    % Clear the graphs
    hold off
    
end
