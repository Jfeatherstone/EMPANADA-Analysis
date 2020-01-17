% Load in the final data that was analyzed
load('AnalyzedData.mat')

%for i = 1: length(trials)
%   scatter(trials(i).results.frameTime, trials(i).results.averageBrightness) 
%end

scatter(trials(2).results.frameTime, trials(2).results.averageBrightness);