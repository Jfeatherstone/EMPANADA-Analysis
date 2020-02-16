% Load the video files and trial information from another file
% This yields the following variable(s): trials
load('LoadFiles.mat')

diary(['outputlog-', datestr(now,'yyyy-mm-dd') ,'.txt']);

% Empty array of structs that we will store results to
% We don't actually need this array anymore, but we will create structs
% that have the same form below
%results = struct('averageBrightness', {}, 'frameTime', {}, 'averageGSquared', {});

for i=1: length(trials)
    
    fprintf('Currently processing trial %i of %i:\n', i, length(trials));
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
    
    numFrames = currentVideo.NumberofFrames;
    % We have to reset the current time after calling NumberOfFrames
    currentVideo = VideoReader([settings.datapath, trials(i).fileName]);
    
    % Create a 1xN matrix for each frame of the video
    averageBrightness = zeros(1, numFrames);
    averageGSquared = zeros(1, numFrames);
    % We also want to keep track of what time each frame takes place at
    frameTime = zeros(1, numFrames);
    
    % This is used for our progress bar in the while loop
    progressString = '0%% complete';
    progress = '0';
    fprintf(progressString);
    
    % Now we iterate over every frame to populate the above matrices
    % Since this is done with a while loop, we also want to keep track of
    % the current frame number (changed since read() is depracated)
    n = 1;
    
    % Previous code for this analysis used depracated methods that involved
    % iterating over each frame based on a function read(video, frameNum)
    % which no longer exists.
    
    while hasFrame(currentVideo)
        % These guys take quite a while to run, so I put in a progress bar
        % here to track what's going on
        % The string 'a\012b' represents a carriage return, which is
        % similar to '\n' except that it returns to the beginning of the
        % current line instead of going to a new one, which allows us to
        % overwrite text
        
        
        % Clear the line using backspace character '\b'
        % This is kinda hacky: 10 is the number of characters in '%
        % complete' (with a space) and the other part is the percent's
        % length (could be 1, 2, or 3)
        % Ironically, this whole process probably slows down the
        % calculation lol...
        fprintf(repmat('\b', 1, 10 + strlength(string(progress))));
        
        % Now print the new stuff
        progress = round(n * 100 / numFrames);
        progressString = fprintf('%i%% complete', progress);
        
        % Previous code saved each frame as a separate image, but that
        % doesn't seem necessary yet, so I will leave that out here
        currentFrame = readFrame(currentVideo);
        
        frameTime(n) = currentVideo.CurrentTime;

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  BEGIN BRIGHTNESS ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
        % Converting the frame to gray-scale yields better results
        currentFrameGrayScale = rgb2gray(currentFrame);
        
        % Record the average brightness in our matrix
        averageBrightness(n) = mean2(currentFrameGrayScale);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  END BRIGHTNESS ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  BEGIN G SQUARED ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % The following code is adapted principally from the Dr. Daniels'
        % Github repo below:
        % https://github.com/DanielsNonlinearLab/Gsquared
        
        % Not sure if we use the gray scale image or not here, so I'll use
        % it for now
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
        averageGSquared(n) = currentAverageGSquared;
                
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %  END G SQUARED ANALYSIS
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        
        % Increment n
        n = n + 1;
    end
    
    % Now we save all of the results we just found into our original trials
    % struct, which has an empty spot for exactly this purpose
    results = struct('averageBrightness', averageBrightness, 'frameTime', frameTime, 'averageGSquared', averageGSquared);
    trials(i).results = results;
    
    % Save in between each trial, so if it crashes we at least get some
    % data
    save('Brightness_GSquared_Analysis.mat', 'trials');
    
    fprintf('...Processing complete!\n')
    
end

% And save at the end just in case
save('Brightness_GSquared_Analysis.mat', 'trials');