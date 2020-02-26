
function trials = LocalizedBrightnessAnalysis(startupFile, matFileContainingTrials)
% This file finds the average derivative of brightness for each column and
% each row of the image file, so we can determine an area of effect of the
% probe

% In case data is not provided, we default to the output of LoadFiles.m
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Preprocessing/LoadFiles.mat';
   fprintf('Warning: file list not provided, defaulting to %s!\n', matFileContainingTrials);
end

% In case the startup file is not provided, default to my laptop
if ~exist('startupFile', 'var')
    fprintf('Warning: startup file not specified, defaulting to laptop (StartupLaptop.m)!\n')
    StartupLaptop()
else
   	run(startupFile)
end
% And allow the variable settings to be accessed
global settings

% Make sure that the startup file has been run
% This shouldn't ever error since we just checked, but I have it here just
% in case something wack happens
if ~exist('settings', 'var')
   fprintf('Error: startup program has not been run, datapath not defined!\n') 
   return
end

% We also want to make sure that the output file is always saved inside the
% Analysis folder, so if we are running the function from elsewhere, we
% need to account for that
outputPath = 'LocalizedBrightnessAnalysis.mat';
if ~strcmp(pwd, strcat(settings.matlabpath, 'Analysis'))
   fprintf('Warning: analysis script not run from Analysis directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Analysis/LocalizedBrightnessAnalysis.mat'];
end

% Load the video files and trial information from another file
load(matFileContainingTrials, 'trials');

% What our results struct will look like
%results = struct('frameTime', {}, 'averageColumnBrightness', {}, 'averageRowBrightness', {});

% We first want to load in the brightness average by row and column, and
% we'll take derivatives after

for i=1: length(trials)
    fprintf('Currently processing trial %i of %i:\n', i, length(trials));

    % Load in our video
    video = VideoReader([settings.datapath, trials(i).fileName]);
    frameTimeDifference = 1 / video.FrameRate;
    
    % We shouldn't have any issues since this value that is being casted to
    % an int should always be exact eg. 1320.0000000000 since these values
    % should be complementary
    numFrames = int32(video.Duration / frameTimeDifference);
    frameTime = zeros(1, numFrames);
    
    dim = [video.Width, video.Height];
    
    % Setup arrays
    averageRowBrightness = zeros(dim(2), numFrames);
    averageColumnBrightness = zeros(dim(1), numFrames);
    
    % This is because we want to record values in the above arrays, so we
    % need an index
    currentFrameNum = 1;
    
    while hasFrame(video)
        % Grab the current frame
       currentFrame = readFrame(video);
       
       % Grab current time
       frameTime(i) = video.CurrentTime;
       
       % Converting the frame to gray-scale yields better results
       currentFrameGrayScale = rgb2gray(currentFrame);
       
       % Average the rows
       for j=1: dim(2)
           averageRowBrightness(currentFrameNum, j) = mean(currentFrameGrayScale(j, 1:end));
       end
       
       % Average the columns
       for j=1: dim(1)
          averageColumnBrightness(currentFrameNum, j) = mean(currentFrameGrayScale(1:end, j)); 
       end
       
       % Increment the frame number
       currentFrameNum = currentFrameNum + 1;
       
    end
    
    
    % Now that we have all of the brightness values, we take the centered
    % difference stencil
    % For obvious reasons, we throw away the first and last point
    averageRowBrightnessDerivative = zeros(dim(2), numFrames - 2);
    averageColumnBrightnessDerivative = zeros(dim(1), numFrames - 2);
    
    % This differentiation code is copied (more or less) from
    % BrightnessDerivativeAnalysis.m
    
    % Rows
    for j=2: numFrames - 1
        for k=1: dim(2)
            averageRowBrightnessDerivative(j-1, k) = ((averageRowBrightness(j-1, k) - averageRowBrightness(j+1, k)) / (2 * frameTimeDifference));
        end
    end
    
    % Columns
    for j=2: numFrames - 1
        for k=1: dim(1)
            averageColumnBrightnessDerivative(j-1, k) = ((averageColumnBrightness(j-1, k) - averageColumnBrightness(j+1, k)) / (2 * frameTimeDifference));
        end
    end
    
    results = struct('frameTime', frameTime, 'averageRowBrightness', averageRowBrightness, 'averageRowBrightnessDerivative', averageRowBrightnessDerivative, 'averageColumnBrightness', averageColumnBrightness, 'averageColumnBrightnessDerivative', averageColumnBrightnessDerivative);
    trials(i).results = results;
    
    save(outputPath, 'trials');
    
    fprintf('...Processing complete!\n')
end

end % Function end
