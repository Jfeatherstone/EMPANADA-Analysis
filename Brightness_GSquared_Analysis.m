% Load the video files and trial information from another file
% This yields the following variable(s): trials, fps
load('LoadFiles.mat')

% Empty array of structs that we will store results to
results = struct('averageBrightness', {}, 'frameTime', {}, 'GSquared', {});

for i=1: length(trials);
    fprintf('Currently processing trial %i of %i...', i, length(trials));
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  BEGIN BRIGHTNESS ANALYSIS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %disp(trials(i).video.NumberofFrames)
    % Create a 1xN matrix for each frame of the video
    currentVideo = VideoReader(trials(i).fullPath);
    
    %averageBrightness = zeros(1, currentVideo.NumFrames);
    
    % We also want to keep track of what time each frame takes place at
    %frameTime = zeros(1, currentVideo.NumberofFrames);
    
    % Now we iterate over every frame to populate the above matrices
    % Since this is done with a while loop, we also want to keep track of
    % the current frame number (changed since read() is depracated)
    
    while hasFrame(currentVideo);

        % Previous code saved each frame as a separate image, but that
        % doesn't seem necessary yet, so I will leave that out here
        currentFrame = readframe(currentVideo);
        imshow(currentFrame)
        % Time is just a simple calculation
        %frameTime(n) = n / fps;
        
        % Converting the frame to gray-scale yields better results
        %currentFrameGrayScale = rgb2gray(currentFrame);
        
        %averageBrightness(n) = mean2(currentFrameGrayScale);
        
        %fprintf('%f vs. %f', n / fps, currentVideo.CurrentTime)
        break
        % Increment n
        %n = n + 1;
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  END BRIGHTNESS ANALYSIS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  BEGIN G SQUARED ANALYSIS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  END G SQUARED ANALYSIS
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Processing complete!\n')
    
    results(i) = struct('averageBrightness', averageBrightness, 'frameTime', frameTime, 'GSquared', 'N/A');
end