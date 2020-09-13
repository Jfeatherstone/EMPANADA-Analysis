function MaxLoadVideoGen(singleTrial)
%MAXLOADVIDEOGEN Summary of this function goes here

% Make sure that the trials struct has the fields we need
requiredFields = ["frameTime", "averageBrightness"];
for i=1: length(requiredFields)
   if ~ismember(requiredFields(i), fieldnames(singleTrial.results))
      fprintf('Error: required field \"%s\" not found in singleTrial.results variable!\n Are you sure you are using the correct input file?', requiredFields(i)); 
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

videoReader = VideoReader([settings.datapath, singleTrial.fileName]);

frameTimeDifference = 1 / videoReader.FrameRate;

% We want to start at the proper time specified by cropTimes in the
% array, so we find the closest multiple of our frame rate
croppedStartTime = singleTrial.cropTimes(1) - mod(singleTrial.cropTimes(1), frameTimeDifference);
videoReader.CurrentTime = croppedStartTime;
% Same process for the end time
croppedEndTime = singleTrial.cropTimes(2) - mod(singleTrial.cropTimes(2), frameTimeDifference);
% Now we find the total number of frames between
% We shouldn't have any issues since this value that is being casted to
% an int should always be exact eg. 1320.000000 since these values
% should be complementary
numFrames = int32((croppedEndTime - videoReader.CurrentTime) / frameTimeDifference);

% Now we iterate over every frame to populate the above matrices
% Since this is done with a while loop, we also want to keep track of
% the current frame number (changed since read() is depracated)
currentFrameNumber = 1;
%open(videoWriter); % Open our writer

allFramesMean = mean(singleTrial.results.averageBrightness);
allFramesInverseMean = 255 - allFramesMean;

% Previous code for this analysis used depracated methods that involved
% iterating over each frame based on a function read(video, frameNum)
% which no longer exists.
while hasFrame(videoReader)
    % Previous code saved each frame as a separate image, but that
    % doesn't seem necessary yet, so I will leave that out here
    currentFrame = readFrame(videoReader);
    figure(1);
    imshow(currentFrame, 'Border', 'tight');
    originalFrames(currentFrameNumber) = getframe(gcf);
    %waitforbuttonpress;
    
    % Converting the frame to gray-scale yields better results
    currentFrameGrayScale = rgb2gray(currentFrame);
    
    inverseFrameGrayScale = uint8(255) - currentFrameGrayScale;
    %inverseFrameGrayScale(inverseFrameGrayScale < mean(currentFrameGrayScale)) = 0;
        
    % Subtract out the average brightness
%     brightChains = abs(currentFrameGrayScale - uint8(mean(currentFrameGrayScale)));
%     brightChains(brightChains < mean(brightChains)) = 0;
%     %brightChains = uint8((double(brightChains) - mean(brightChains)).^2 + mean(brightChains));
%     brightChains = brightChains * 2;
%     %brightChains = brightChains / max(brightChains) * 255

    brightDiscardThreshhold = 1.35;
    brightChains = exp(-double(inverseFrameGrayScale)/127.) * 255;
    brightChains(brightChains < brightDiscardThreshhold*mean(brightChains)) = 0;
    %brightChains = brightChains > brightDiscardThreshhold*mean(brightChains);
    brightChains = uint8(double(currentFrameGrayScale) .* brightChains / 255);
    
    wienerKernelSize = 12;
    darkOffset = 15;
    darkDiscardThreshhold = 1.25;
    darkChains = exp(-double(wiener2(currentFrameGrayScale, [wienerKernelSize,wienerKernelSize]))/127.) * 255;
    darkChains(darkChains < darkDiscardThreshhold*mean(darkChains)) = 0;
    %darkChains = darkChains > darkDiscardThreshhold*mean(darkChains);
    darkChains = uint8(double(max(inverseFrameGrayScale - darkOffset, 0)) .* darkChains / 255);
    
    %disp(darkChains)
    %darkChains = (darkChains - mean(darkChains)) * 2;
    %darkChains = abs(currentFrameGrayScale - uint8(mean(currentFrameGrayScale)));
    
    figure(2);
    %imshow(darkChains);
    imshow(darkChains, 'Border', 'tight');
    %break;
    %waitforbuttonpress;
    recordingFrames(currentFrameNumber) = getframe(gcf);
    waitforbuttonpress;
    
    %imshow(editedFrame);
%     frame = getframe(gcf);
%     writeVideo(videoWriter, frame);
%     clf;
%     
    currentFrameNumber = currentFrameNumber + 1;
    
    % Little debug message since it may take a while to run
    if mod(currentFrameNumber, 50) == 0
       fprintf('Wrote frame %i...\n', currentFrameNumber); 
    end
    
    if currentFrameNumber > numFrames
        break
    end
end

videoWriter = VideoWriter([settings.avi_savepath, singleTrial.fileName(1:end-4)]); % Indexing is to get rid of .mov extension
videoWriter.FrameRate = 30;
open(videoWriter);
writeVideo(videoWriter, recordingFrames);
close(videoWriter);

videoWriterOriginal = VideoWriter([settings.avi_savepath, singleTrial.fileName(1:end-4), '-Original']); % Indexing is to get rid of .mov extension
videoWriterOriginal.FrameRate = 30;
open(videoWriterOriginal);
writeVideo(videoWriterOriginal, originalFrames);
close(videoWriterOriginal);


% Make sure to clear this so that past values don't get held onto
clear recordingFrames
clear originalFrames
end

