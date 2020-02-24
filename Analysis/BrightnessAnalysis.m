% Most of the code here is taken from BrightnessGSquaredAnalysis.m and the
% purpose is just to separate the two methods, since G Squared takes much
% longer to run

% Load the video files and trial information from another file
% This yields the following variable(s): trials
load('Preprocessing/LoadFiles.mat')

% Empty array of structs that we will store results to
% We don't actually need this array anymore, but we will create structs
% that have the same form below
%results = struct('averageBrightness', {}, 'frameTime', {}, 'averageGSquared', {});

for i=1: length(trials)
    
    fprintf('Currently processing trial %i of %i:\n', i, length(trials));
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
        
    frameTimeDifference = 1 / currentVideo.FrameRate;
    
    % We shouldn't have any issues since this value that is being casted to
    % an int should always be exact eg. 1320.0000000000 since these values
    % should be complementary
    numFrames = int32(currentVideo.Duration / frameTimeDifference);
    frameTime = zeros(1, numFrames);
    averageBrightness = zeros(1, numFrames);

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
        
        frameTime(currentFrameNumber) = currentVideo.CurrentTime;
                
        % Converting the frame to gray-scale yields better results
        currentFrameGrayScale = rgb2gray(currentFrame);
        
        % Record the average brightness in our matrix
        averageBrightness(currentFrameNumber) = mean2(currentFrameGrayScale);
 
        currentFrameNumber = currentFrameNumber + 1;
    end
        
    % Now calculate the derivative of the brightness
    
    brightnessDerivative = zeros(1, numFrames);
    % This is our delta t in the central difference

    % Use central difference for every point except first and last
    for j=2: numFrames - 1
        brightnessDerivative(j) = (averageBrightness(j-1) - averageBrightness(j+1)) / (2 * frameTimeDifference);
    end
    
    % Now use the proper stencil for the first and last points
    brightnessDerivative(1) = (averageBrightness(1) - averageBrightness(2)) / frameTimeDifference;
    brightnessDerivative(end) = (averageBrightness(end-1) - averageBrightness(end)) / frameTimeDifference;
    
    % Now save all of the data
    
    % Now we save all of the results we just found into our original trials
    % struct, which has an empty spot for exactly this purpose
    results = struct('frameTime', frameTime, 'averageBrightness', averageBrightness, 'averageBrightnessDerivative', brightnessDerivative);
    trials(i).results = results;
    
    % Save in between each trial, so if it crashes we at least get some
    % data
    save('BrightnessAnalysis.mat', 'trials');
    
    fprintf('...Processing complete!\n')

end