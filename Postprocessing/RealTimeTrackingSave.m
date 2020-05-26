
function recordingFrames = RealTimeTrackingSave(matFileContainingTrials)

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

% 1 is arbitrary here, just some integer, since we only have one figure
% here (I guess I could technically not use any, but...)
figure(1);

% The number of the trial that we are looking to analyze
% This can later be changed to iterate over trialNum very easily
trialNum = 4;
video = VideoReader([settings.datapath, trials(trialNum).fileName]);

% Set the size of our figure (note that this is a tall figure)
figureWidth = 720;
figureHeight = 950;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

% Adjust the font to be a little smaller, and rerun our startup
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .65;
startup;

% We want to normalize the data to keep things clean (doesn't really matter
% other than that)
brightnessData = trials(trialNum).results.averageBrightness;
%brightnessData = brightnessData / max(brightnessData);

% gSquaredData = (trials(trialNum).results.averageGSquared - mean(trials(trialNum).results.averageGSquared));
% gSquaredData = gSquaredData / max(gSquaredData);

Xdata = trials(trialNum).results.frameTime;
Y1data = brightnessData;
% Y2data = gSquaredData;

% We want to draw a vertical line to follow the current point
verticalLineBounds = [1.03 * max(brightnessData), .97 * min(brightnessData)];

% This is so that we can find the current data point by dividing the
% current video time by this variable
frameTimeDifference = trials(trialNum).results.frameTime(2) - trials(trialNum).results.frameTime(1);

% Start our index at the beginning as marked by the crop time, this will inevitably skip over a lot of numbers
% though
i = 200;

% Time offset because of the cropping
% We have to cast to an int to round the number and then back to double
croppedStartTime = trials(trialNum).cropTimes(1) - mod(trials(trialNum).cropTimes(1), frameTimeDifference);

% Set the video to start at the cropped time
video.CurrentTime = croppedStartTime;

% Calculate how long the cropped video is
croppedEndTime = trials(trialNum).cropTimes(2) - mod(trials(trialNum).cropTimes(2), frameTimeDifference);

croppedDuration = croppedEndTime - croppedStartTime - 6;

saveFileName = [settings.avi_savepath, 'Day', num2str(trials(trialNum).day), '-', trials(trialNum).gravity, '-', trials(trialNum).speed, 'mms-RealTime'];


while hasFrame(video)
    currentFrame = readFrame(video);
    
    % We want to keep track of how long it takes to perform the following
    % actions so that we can keep up with real time
    
    % Switch to the first (upper) plot
    s1 = subplot(2, 1, 1);
    % Set the position so that the overall result looks nice
    % See help on 'Position' to specifically see what the values mean
    set(s1, 'Position', [.11, .5, .84, .45]);
    
    % Draw all of the data
    linePlot1 = plot(Xdata, Y1data, 'Color', settings.colors(trials(trialNum).gravity));
    hold on
    %linePlot2 = plot(Xdata, Y2data, 'Color', gSquaredLineColor);
    
    % Create the legend (we have set all of the following curves to not
    % show up here using 'HandleVisibility')
    %legend('Average Brightness', 'Average G Squared');
    
    % Highlight the point with a special character and a vertical
    % line (on the same plot)
    point1 = plot(Xdata(i), Y1data(i), 'b*', 'MarkerSize', 15, 'HandleVisibility', 'off');
    %point2 = plot(Xdata(i), Y2data(i), 'm*', 'MarkerSize', 15, 'HandleVisibility', 'off');
    plot([Xdata(i), Xdata(i)], verticalLineBounds, 'b--', 'HandleVisibility', 'off');

    % Title and axes
    title(['Brightness Profile of a ', trials(trialNum).gravity, ' Trial'])
    xlabel('Time [s]')
    ylabel('Average Brightness [arb. units]')
    
    % Now switch back to our second (lower) plot
    s2 = subplot(2, 1, 2);
    % Set the position that our overall result looks nice
    set(s2, 'Position', [.11, .02, .84, .45]);
    hold on
    % Show the current frame
    imshow(currentFrame);
    
    % Draw a scale bar on the image
    % These values are chosen arbitrarily to look nice
    scaleBarPosition = [170, 240];
    scaleBarWidth = 40;
    scaleBarColor = '#ffffff';
    scaleBarEndLineHeight = 30;
    plot(scaleBarPosition(1) + [0, scaleBarWidth], scaleBarPosition(2) + [0, 0], '-', 'Color', scaleBarColor)
    plot(scaleBarPosition(1) + [0, 0], scaleBarPosition(2) + [-scaleBarEndLineHeight * .5, scaleBarEndLineHeight * .5], 'Color', scaleBarColor)
    plot(scaleBarPosition(1) + scaleBarWidth + [0, 0], scaleBarPosition(2) + [-scaleBarEndLineHeight * .5, scaleBarEndLineHeight * .5], 'Color', scaleBarColor)
    annotation('textbox', [.15, .25, .1, .1], 'String', '1 cm', 'Color', scaleBarColor, 'LineStyle', 'none');
    
    if i * frameTimeDifference >= croppedDuration
        break;
    end
    video.CurrentTime = i * frameTimeDifference + croppedStartTime;
    
    recordingFrames(i) = getframe(gcf);
    
    % Clear the graphs
    hold off
    i = i + 1;
    
end

return

% Save the file as both a gif and video
for n=1: length(recordingFrames)
    im = frame2im(recordingFrames(n));
    [imind,cm] = rgb2ind(im,256);
    if n == 1
        imwrite(imind, cm, [saveFileName, '.gif'], 'gif', 'Loopcount', inf, 'DelayTime', .05);
    else
        imwrite(imind,cm, [saveFileName, '.gif'], 'gif', 'WriteMode','append', 'DelayTime', .05);
    end
    % Skip every other
    n = n + 1;
end

writer = VideoWriter([saveFileName, '.avi']);
open(writer);
writeVideo(writer, recordingFrames);
close(writer);

% Make sure to clear this so that past values don't get held onto
clear recordingFrames
end
