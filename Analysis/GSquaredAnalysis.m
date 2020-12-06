
function trials = GSquaredAnalysis(matFileContainingTrials, outputPath, highlightForceChains)

% In case data is not provided, we default to the output of LoadFiles.m
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Preprocessing/LoadFiles.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
end

% In case whether or not to preprocess the images is not specified, we
% default to no
if ~exist('highlightForceChains', 'var')
   highlightForceChains = false; 
   fprintf("Defaulting to analyzing raw images; not apply force chain identification algorithm");
end

% Make sure that the startup file has been run
% This might run it twice (if we change anything later) but whatever
if ~exist('settings', 'var')
   fprintf('Warning: startup program has not been run, correcting now...\n')
   startup;
   fprintf('Startup file run successfully!\n');
end
global settings

% We also want to make sure that the output file is always saved inside the
% Analysis folder, so if we are running the function from elsewhere, we
% need to account for that
% If no path is specified, just name it the same as the m file
if ~exist('outputPath', 'var')
    outputPath = 'GSquaredAnalysis.mat';
end

if ~strcmp(pwd, strcat(settings.matlabpath, 'Analysis'))
   fprintf('Warning: analysis script not run from Analysis directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Analysis/', outputPath];
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

%minWidth = 640;
%minHeight = 480;

fprintf('Found minimum video dimensions %i x %i, videos will be cropped to this size.\n', minWidth, minHeight);

% Now we actually go through each trial
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
    averageGSquared = zeros(1, numFrames);
    
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
    
    % This is used for our progress bar in the while loop
    progressString = '0%% complete';
    progress = '0';
    fprintf(progressString);
    
    % Now we iterate over every frame to populate the above matrices
    % Since this is done with a while loop, we also want to keep track of
    % the current frame number (changed since read() is depracated)
    currentFrameNumber = 1;
    
    while hasFrame(currentVideo)
        % The following code is adapted principally from the DaNL
        % Github repo below:
        % https://github.com/DanielsNonlinearLab/Gsquared

        % These guys take quite a while to run, so I put in a progress bar
        % here to track what's going on
        % The string '\b' represents a backspace character, to clear the
        % previous output      
        
        % Clear the line using backspace character '\b'
        % This is kinda hacky: 10 is the number of characters in '%
        % complete' (with a space) and the other part is the percent's
        % length (could be 1, 2, or 3)
        fprintf(repmat('\b', 1, 10 + strlength(string(progress))));
        
        % Now print the new stuff
        progress = round(currentFrameNumber * 100 / numFrames);
        fprintf('%i%% complete', progress);
        
        % Previous code saved each frame as a separate image, but that
        % doesn't seem necessary yet, so I will leave that out here
        currentFrame = readFrame(currentVideo);
        
        % And make sure to subtract out the start time
        frameTime(currentFrameNumber) = currentVideo.CurrentTime - croppedStartTime;
        
        % Although the original repo didn't convert to gray scale, I will
        % here since I doubt the highlightForceChains process will work
        % very well on a color image. The original code does:
        % double(currentFrame)
        % which I assume is nearly equivalent to gray scaling, since it yielded an
        % array of shape (height, width)
        currentFrameGrayScale = rgb2gray(currentFrame);
        
        % If it was specified, pass the image through the force chain
        % highlighting algorithm (see IdentifyForceChains for more info)
        if highlightForceChains
            % Only apply the corrective gradient to the parabolic trials, since the
            % lighting wasn't uniform
            if trials(i).gravity ~= "Earth"
                currentFrameGrayScale = IdentifyForceChains(currentFrameGrayScale, ["CorrectLightGradient", -45]);
            else
                currentFrameGrayScale = IdentifyForceChains(currentFrameGrayScale);
            end
        end
        
        % The indexing is to account for the spatial cropping as defined by
        % minWidth and minHeight
        % +1 in the first index since matlab is 1-indexed (arrays start at
        % 1)
        croppedFrameGrayScale = currentFrameGrayScale(croppedStartPixelVertical+1:croppedStartPixelVertical+minHeight,croppedStartPixelHorizontal+1:croppedStartPixelHorizontal+minWidth);
        
        % Now cast to doubles
        croppedFrameGrayScale = double(croppedFrameGrayScale);
        
        % We take our x and y limits as starting from the second pixel
        % from each side
        L = size(croppedFrameGrayScale);
        xlim = [2, L(2) - 1];
        ylim = [2, L(1) - 1];
        
        % Initialize our G^2 value as zero since we'll be adding to it over
        % each pixel of the image
        % I know my naming scheme is terrible here, but we already have a
        % matrix named 'averageGSquared' which this value will eventually
        % be stored in, so this is the best I have for this variable
        currentAverageGSquared = 0.0;
        
        % And we also need to store the G^2 at each pixel throughout the
        % image
        %GSquaredMatrix = zeros(L(2)-2, L(1)-2);
        
        % Now we take the brightness values around our pixel, which is
        % essentially the gradient of the brightness
        for y = ylim(1): ylim(2)
           for x = xlim(1): xlim(2)
               % I've put a little picture of which pixels we are comparing
               % for each calculation (O is the current pixel, X are the
               % ones we are calculating)
               
               % - - -
               % X O X
               % - - -
               g1 = croppedFrameGrayScale(y, x-1) - croppedFrameGrayScale(y, x+1);
               
               % - X -
               % - O -
               % - X -
               g2 = croppedFrameGrayScale(y-1, x) - croppedFrameGrayScale(y+1, x);
               
               % - - X
               % - O -
               % X - -
               g3 = croppedFrameGrayScale(y-1, x+1) - croppedFrameGrayScale(y+1, x-1);
               
               % X - -
               % - O -
               % - - X
               g4 = croppedFrameGrayScale(y-1, x-1) - croppedFrameGrayScale(y+1, x+1);
               
               % Not sure why the weighting is set up like this, but that's
               % how I found it :/
               % The diagonal gradients are weighted less than the
               % horizontal and vertical ones (by a factor of 1/2)
               GSquared = (g1*g1/4.0 + g2*g2/4.0 + g3*g3/8.0 + g4*g4/8.0);
               
               % Now we add the weighted G^2 we just calculated to the
               % average, which we will divide by the dimensions later
               currentAverageGSquared = currentAverageGSquared + GSquared / 4.0;
           end
        end
        
        % Now we divide out the dimensions for the average, as promised :)
        currentAverageGSquared = currentAverageGSquared / (diff(xlim) * diff(ylim));
        
        % And store it into our matrix
        averageGSquared(currentFrameNumber) = currentAverageGSquared;
        
        % Increment the frame number
        % We can't just let the while loop go until we run out of frames
        % because we crop the video to cut out some of the end of the
        % process (unimportant stuff)
        currentFrameNumber = currentFrameNumber + 1;
        if currentFrameNumber > numFrames
            break
        end
    end
    
    % Now we save all of the results we just found into our original trials
    % struct, which has an empty spot for exactly this purpose
    results = struct('frameTime', frameTime, 'averageGSquared', averageGSquared);
    trials(i).results = results;
    
    % Save in between each trial, so if it crashes we at least get some
    % data
    save(outputPath, 'trials');
    fprintf('...Processing complete!\n')
    
end

end % Function end

