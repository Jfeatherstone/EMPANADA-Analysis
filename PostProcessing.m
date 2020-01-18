% Load in the final data that was analyzed
load('AnalyzedData.mat')

% Instead of manually creating each type of graph in this file, we can just
% have a standardized way of defining what we want to be on a graph and it
% will do it automatically for us
%analysisOptions('Brightness Analysis By Gravity') = true;

%newData = trials(1).results.averageBrightness - trials(1).results.averageBrightness(1);

%scatter(trials(1).results.frameTime, trials(1).results.averageGSquared);
%plot(trials(1).results.frameTime, newData);

fig = figure();
axh = axes('Parent', fig);

normalizedData = trials(1).results.averageBrightness - trials(1).results.averageBrightness(1);
normalizedData = normalizedData / max(abs(normalizedData));

Xdata = trials(1).results.frameTime;
Ydata = normalizedData;

verticalLineBounds = [1.2 * max(normalizedData), 1.2 * min(normalizedData)];

for i = 1: length(Xdata)
    linePlot = plot(axh, Xdata, Ydata);
    hold on
    point = plot(axh, Xdata(i), Ydata(i), '*', 'MarkerSize', 15);
    plot(axh, [Xdata(i), Xdata(i)], verticalLineBounds, 'm--');
    
    title('Average Brightness of Image vs. Time')
    xlabel('Time [s]')
    ylabel('Average Brightness [arb. units]')

    pause(.01)
    hold off
end



% for i = 1: length(trials(1).results.frameTime)
%    plot(trials(1).results.frameTime(i), trials(1).results.averageGSquared(i), 'c*')
%    pause(trials(1).results.frameTime(i));
% end

