% Unlike the other analysis script, this doesn't deal with the raw data,
% but instead works with the output of the previous analysis
load('Brightness_GSquared_Analysis.mat', 'trials');

% We use the central difference stenctil to calculate the derivative of the
% average brightness
for i=1: length(trials)
    
    % We use the length of the data - 2 since we don't include the first or
    % last point (since we can't use central difference formula)
    centralDifference = double.empty(length(trials(i).results.averageBrightness) - 2, 0);
    % This is our delta t in the central difference
    frameTimeDifference = trials(trialNum).results.frameTime(2) - trials(trialNum).results.frameTime(1);

    for j=2: length(trials(i).results.averageBrightness) - 1
        centralDifference(j-1) = ((trials(i).results.averageBrightness(j-1) - trials(i).results.averageBrightness(j+1)) / (2 * frameTimeDifference));
    end
    
    % And we want to adjust the frame times as well, since we have 2 less
    % points
    newFrameTime = trials(i).results.frameTime;
    % Delete first and last element
    newFrameTime(1) = [];
    newFrameTime(end) = [];
 
    % And now create a new struct and overwrite the old data
    newResults = struct('frameTime', newFrameTime, 'brightnessDerivative', centralDifference);
    trials(i).results = newResults;
end

% Save to a new mat file
save('BrightnessDerivativeAnalysis.mat', 'trials');