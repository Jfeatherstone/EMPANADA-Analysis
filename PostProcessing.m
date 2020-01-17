% Load in the final data that was analyzed
%load('AnalyzedData.mat')

% Instead of manually creating each type of graph in this file, we can just
% have a standardized way of defining what we want to be on a graph and it
% will do it automatically for us
analysisOptions = containers.Map('KeyType', 'char', 'ValueType', 'any');

% Here is a template struct that the analysis should define
template = struct('enabled', {}, {}, 'xlabel', {}, 'ylabel', {}, 'legend', {});

analysisOptions('Brightness Analysis By Speed') = struct('enabled', true,...
                                                         'xlabel', 'Time [s]',...
                                                         'ylabel', 'Average Brightness [arb. units]',...
                                                         'legend', true...
                                                         );
analysisOptions('Brightness Analysis By Gravity') = true;
