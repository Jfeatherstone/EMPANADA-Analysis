
function trials = GSquaredAnalysis(matFileContainingTrials)

% In case data is not provided, we default to the output of LoadFiles.m
if ~exist('matFileContainingTrials', 'var')
   matFileContainingTrials = 'Preprocessing/LoadFiles.mat';
   fprintf('Warning: file list not provided, defaulting to %s\n', matFileContainingTrials);
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
outputPath = 'GSquaredAnalysis.mat';
if ~strcmp(pwd, strcat(settings.matlabpath, 'Analysis'))
   fprintf('Warning: analysis script not run from Analysis directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Analysis/GSquaredAnalysis.mat'];
end

% Load the video files and trial information from another file
load(matFileContainingTrials, 'trials')

% Empty array of structs that we will store results to
% We don't actually need this array anymore, but we will create structs
% that have the same form below
%results = struct('frameTime', {}, 'averageGSquared', {});

for i=1: length(trials)
    
    fprintf('Currently processing trial %i of %i:\n', i, length(trials));
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
    
    frameTimeDifference = 1 / currentVideo.FrameRate;
    
    % We shouldn't have any issues since this value that is being casted to
    % an int should always be exact eg. 1320.0000000000 since these values
    % should be complementary
    numFrames = int32(currentVideo.Duration / frameTimeDifference);
    frameTime = zeros(1, numFrames);
    averageGSquared = zeros(1, numFrames);
    
    % This is used for our progress bar in the while loop
    progressString = '0%% complete';
    progress = '0';
    fprintf(progressString);
    
    % Now we iterate over every frame to populate the above matrices
    % Since this is done with a while loop, we also want to keep track of
    % the current frame number (changed since read() is depracated)
    currentFrameNumber = 1;
    
    while hasFrame(currentVideo)
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
        
        % Read the current frame of the video
        currentFrame = readFrame(currentVideo);
        
        frameTime(currentFrameNumber) = currentVideo.CurrentTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  BEGIN G SQUARED ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The following code is adapted principally from the DaNL
        % Github repo below:
        % https://github.com/DanielsNonlinearLab/Gsquared
        
        % Not sure if we use the gray scale image or not here, so I'll use
        % the original for now
        picture = double(currentFrame);
        
        % We take our x and y limits as starting from the second pixel
        % from each side
        L = size(picture);
        xlim = [2, L(2) - 1];
        ylim = [2, L(1) - 1];
        
        % Initialize our G^2 value as zero since we'll be adding to it over
        % each pixel of the image
        % I know my naming scheme is terrible here, but we already have a
        % matrix named 'averageGSquared' which this value will eventually
        % be stored in, so this is the best I have for this variable
        currentAverageGSquared = 0;
        
        % And we also need to store the G^2 at each pixel throughout the
        % image
        GSquaredMatrix = zeros(L(2)-2, L(1)-2);
        
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
               g1 = picture(y, x-1) - picture(y, x+1);
               
               % - X -
               % - O -
               % - X -
               g2 = picture(y-1, x) - picture(y+1, x);
               
               % - - X
               % - O -
               % X - -
               g3 = picture(y-1, x+1) - picture(y+1, x-1);
               
               % X - -
               % - O -
               % - - X
               g4 = picture(y-1, x-1) - picture(y+1, x+1);
               
               % Not sure why the weighting is set up like this, but that's
               % how I found it :/
               
               % The diagonal gradients are weighted less than the
               % horizontal and vertical ones (by a factor of 1/2)
               GSquaredMatrix(y, x) = (g1*g1/4.0 + g2*g2/4.0 + g3*g3/8.0 + g4*g4/8.0);
               
               % Now we add the weighted G^2 we just calculated to the
               % average, which we will divide by the dimensions later
               currentAverageGSquared = currentAverageGSquared + GSquaredMatrix(y, x) / 4.0;
           end
        end
        
        % Now we divide out the dimensions for the average, as promised :)
        currentAverageGSquared = currentAverageGSquared / (diff(xlim) * diff(ylim));
        
        % And store it into our matrix
        averageGSquared(currentFrameNumber) = currentAverageGSquared;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  END G SQUARED ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Increment n
        currentFrameNumber = currentFrameNumber + 1;
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

