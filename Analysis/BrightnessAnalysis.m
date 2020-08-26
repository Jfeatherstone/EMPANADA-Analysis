
function trials = BrightnessAnalysis(matFileContainingTrials)
% Most of the code here is taken from BrightnessGSquaredAnalysis.m and the
% purpose is just to separate the two methods, since G Squared takes much
% longer to run

% In case data is not provided, we default to the output of LoadFiles.m
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Preprocessing/LoadFiles.mat';
   fprintf('Warning: file list not provided, defaulting to %s!\n', matFileContainingTrials);
end

% Make sure that the startup file has been run
if ~exist('settings', 'var')
   fprintf('Warning: startup program has not been run, correcting now...\n')
   startup;
   fprintf('Startup file run successfully!\n');
end
global settings

% We also want to make sure that the output file is always saved inside the
% Analysis folder, so if we are running the function from elsewhere, we
% need to account for that
outputPath = 'BrightnessAnalysis.mat';
if ~strcmp(pwd, strcat(settings.matlabpath, 'Analysis'))
   fprintf('Warning: analysis script not run from Analysis directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Analysis/BrightnessAnalysis.mat'];
end

% Load the video files and trial information from another file
load(matFileContainingTrials, 'trials')

% Empty array of structs that we will store results to
% We don't actually need this array anymore, but we will create structs
% that have the same form below
%results = struct('frameTime', frameTime, 'averageBrightness', averageBrightness, 'averageBrightnessDerivative', brightnessDerivative);

% The first thing we need to do is determine the size of the videos we will
% be sampling. Since they may be taken with different cameras/FoV, we want
% to make sure that the same number of pixels is sampled regardless

% Initialize as an arbitrarily high number
minWidth = 10000;
minHeight = 10000;

% I don't believe there's a faster way to do this, unfortunately
for i=1: length(trials)
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
    minWidth = min(minWidth, currentVideo.Width);
    minHeight = min(minHeight, currentVideo.Height);
end

fprintf('Found minimum video dimensions %i x %i, videos will be cropped to this size.\n', minWidth, minHeight);

for i=1: length(trials)
    
    fprintf('Currently processing trial %i of %i:\n', i, length(trials));
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
    
    frameTimeDifference = 1 / currentVideo.FrameRate;
    
    % We want to start at the proper time specified by cropTimes in the
    % array, so we find the closest multiple of our frame rate
    croppedStartTime = trials(i).cropTimes(1) - mod(trials(i).cropTimes(1), frameTimeDifference);
    currentVideo.CurrentTime = croppedStartTime;
    % Same process for the end time
    croppedEndTime = trials(i).cropTimes(2) - mod(trials(i).cropTimes(2), frameTimeDifference);
    % Now we find the total number of frames between
    % We shouldn't have any issues since this value that is being casted to
    % an int should always be exact eg. 1320.000000 since these values
    % should be complementary
    numFrames = int32((croppedEndTime - currentVideo.CurrentTime) / frameTimeDifference);
    
    frameTime = zeros(1, numFrames);
    averageBrightness = zeros(1, numFrames);

    % We want to establish what portion of the video we will be looking at,
    % since most will end up cropped
    croppedStartPixelHorizontal = 0;
    croppedStartPixelVertical = 0;
    if (currentVideo.Width > minWidth)
        % Hopefully we don't have an odd width or height, but if so, we
        % will round up (7.5 -> 8)
        croppedStartPixelHorizontal = round((currentVideo.Width - minWidth) / 2);
    end
    if (currentVideo.Height > minHeight)
        % Hopefully we don't have an odd width or height, but if so, we
        % will round up (7.5 -> 8)
        croppedStartPixelVertical = round((currentVideo.Height - minHeight) / 2);
    end
    
    % Now we iterate over every frame to populate the above matrices
    % Since this is done with a while loop, we also want to keep track of
    % the current frame number (changed since read() is depracated)
    currentFrameNumber = 1;
    
    % Previous code for this analysis used depracated methods that involved
    % iterating over each frame based on a function read(video, frameNum)
    % which no longer exists.
    while hasFrame(currentVideo)
        % Previous code saved each frame as a separate image, but that
        % doesn't seem necessary yet, so I will leave that out here
        currentFrame = readFrame(currentVideo);
        
        % And make sure to subtract out the start time
        frameTime(currentFrameNumber) = currentVideo.CurrentTime - croppedStartTime;
        
        % Converting the frame to gray-scale yields better results
        currentFrameGrayScale = rgb2gray(currentFrame);
        
        % The indexing is to account for the spatial cropping as defined by
        % minWidth and minHeight
        % +1 in the first index since matlab is 1-indexed (arrays start at
        % 1)
        croppedFrameGrayScale = currentFrameGrayScale(croppedStartPixelVertical+1:croppedStartPixelVertical+minHeight,croppedStartPixelHorizontal+1:croppedStartPixelHorizontal+minWidth);
        
        % Record the average brightness in our matrix
        averageBrightness(currentFrameNumber) = mean2(croppedFrameGrayScale);
 
        currentFrameNumber = currentFrameNumber + 1;
        if currentFrameNumber > numFrames
            break
        end
    end
    
    % Now calculate the derivative of the brightness
    
    % We normalize the trial to do this
    normalizedAverageBrightness = averageBrightness / max(averageBrightness);
    
    brightnessDerivative = zeros(1, numFrames);
    % This is our delta t in the central difference

    % Use central difference for every point except first and last
    for j=2: numFrames - 1
        brightnessDerivative(j) = (normalizedAverageBrightness(j-1) - normalizedAverageBrightness(j+1)) / (2 * frameTimeDifference);
    end
    
    % Now use the proper stencil for the first and last points
    brightnessDerivative(1) = (normalizedAverageBrightness(1) - normalizedAverageBrightness(2)) / frameTimeDifference;
    brightnessDerivative(end) = (normalizedAverageBrightness(end-1) - normalizedAverageBrightness(end)) / frameTimeDifference;
    
    % Now save all of the data
    
    % Now we save all of the results we just found into our original trials
    % struct, which has an empty spot for exactly this purpose
    results = struct('frameTime', frameTime, 'averageBrightness', averageBrightness, 'averageBrightnessDerivative', brightnessDerivative);
    trials(i).results = results;
    
    % Save in between each trial, so if it crashes we at least get some
    % data
    save(outputPath, 'trials');
    
    fprintf('...Processing complete!\n')

end

!curl -X POST $SMS_ENDPOINT -d "Analysis done"
end % Function end