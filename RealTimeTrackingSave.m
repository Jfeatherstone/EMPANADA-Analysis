% Load in the trial data
load('AnalyzedData.mat');

figure(1);

% The number of the trial that we are looking to analyze
trialNum = 1;
video = VideoReader('/home/jack/workspaces/matlab-workspace/EMPANADA-Proper/Day1-Lunar-210mms.mov');

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

% We want to draw a vertical line to follow the current point, and we don't
% want it to zoom the data way out, so we set bounds here
verticalLineBounds = [1.2 * max(gSquaredData), 1.2 * min(gSquaredData)];

% Since we can't use a for loop, we have to define this here
i = 1;

% This is so that we can find the current data point by dividing the
% current video time by this variable
frameTimeDifference = trials(trialNum).results.frameTime(2) - trials(trialNum).results.frameTime(1);

while hasFrame(video)
    currentFrame = readFrame(video);
    
    % We want to keep track of how long it takes to perform the following
    % actions so that we can keep up with real time
    
    s1 = subplot(2, 1, 1);
    set(s1, 'Position', [.1, .5, .85, .45]);
    
    % Draw all of the data
    linePlot1 = plot(Xdata, Y1data, 'Color', brightnessLineColor);
    hold on
    linePlot2 = plot(Xdata, Y2data, 'Color', gSquaredLineColor);
    
    legend('Average Brightness', 'Average G Squared');
    
    plot([Xdata(i), Xdata(i)], verticalLineBounds, 'b--', 'HandleVisibility', 'off');

    % Highlight the point with a special character and a vertical
    % line (on the same plot)
    point1 = plot(Xdata(i), Y1data(i), 'b*', 'MarkerSize', 15, 'HandleVisibility', 'off');
    point2 = plot(Xdata(i), Y2data(i), 'm*', 'MarkerSize', 15, 'HandleVisibility', 'off');

    % Title and axes
    title('Average Brightness of Image and G Squared vs. Time')
    xlabel('Time [s]')
    ylabel('Average Brightness / G Squared [arb. units]')
    
    % Now show the video
    s2 = subplot(2, 1, 2);
    set(s2, 'Position', [.1, .02, .85, .45]);
    imshow(currentFrame);
        
    video.CurrentTime = i * frameTimeDifference;

    recordingFrames(i) = getframe(gcf);
    
    subplot(2, 1, 1);
    hold off
    subplot(2, 1, 2);
    hold off
    %i = int32(video.CurrentTime / frameTimeDifference);
    i = i + 1;
    
end

saveFileName = ['Day', char(trials(trialNum).day), '-', char(trials(trialNum).gravity), '-', char(trials(trialNum).speed), 'mms-RealTime.avi'];

writer = VideoWriter(saveFileName);
open(writer);
writeVideo(writer, recordingFrames);
close(writer);
