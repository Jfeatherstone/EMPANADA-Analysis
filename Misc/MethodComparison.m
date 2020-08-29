load("Misc/MethodComparison.mat")

%drawArrow = @(x,y,varargin) quiver( x(1),y(1),x(2)-x(1),y(2)-y(1),0, varargin{:} );



arrowColors = ["#f40a0a", "#f4710a", "#33ae06", "#6796f3", "#8126d0"];
brightnessArrowXPositions = [2.1, 3.5, 4.9, 6.66, 7.96];
brightnessArrowYPositions = [.02, .02, .045, .055, .03];

forceArrowXPositions = [2.25, 3.5, 5.1, 6.8, 8.1];
forceArrowYPositions = [380, 400, 450, 500, 525];

% Just a small number to make sure the arrow doesn't turn horizontally
% We really only draw the arrow head, so this doesn't matter
arrowLength = 0.001;
forceArrowPositions = [];

% Set our figure sizes
figureWidth = 720;
figureHeight = 480;

% Adjust the font to be a little smaller, and rerun our startuparrowLength
% NOTE: If working on lab machines, change startup_laptop to startup_eno
settings.charfrac = .7;
startup;

figure(1);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

plot(brightnessX, brightnessY, 'Color', settings.colors("Earth"));

for i=1: length(brightnessArrowXPositions)
    drawArrow([brightnessArrowXPositions(i), brightnessArrowXPositions(i)], [brightnessArrowYPositions(i) + arrowLength/2., brightnessArrowYPositions(i) - arrowLength/2.], {'Color', arrowColors(i)})
end

% No xlabel since this graph goes on top of the other
%xlabel('Time [s]');
ylabel('|d/dt brightness| [a.u.]');
xlim([0, 12])
ylim([0, .07])
% Make the graph not pop up (since we'll be saving it to a file)
set(gcf,'visible','off')

% Now save the figure
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(1, 'BrightnessMethodComparison');

figure(2);
hold on;
set(gcf, 'Position', [0, 0, figureWidth, figureHeight]);

plot(forceX, forceY, 'Color', settings.colors("Earth-alt"));

for i=1: length(forceArrowXPositions)
    drawArrow([forceArrowXPositions(i), forceArrowXPositions(i)], [forceArrowYPositions(i) + arrowLength/2., forceArrowYPositions(i) - arrowLength/2.], {'Color', arrowColors(i)})
end


xlabel('Time [s]');
ylabel('Load cell reading [a.u.]');
xlim([0, 12])
ylim([250, 600])
% Make the graph not pop up (since we'll be saving it to a file)
set(gcf,'visible','off')

% Now save the figure
% This is a custom figure saving method, see file for more info
% (printfig.m)
printfig(2, 'ForceMethodComparison');

% From: https://stackoverflow.com/questions/25729784/how-to-draw-an-arrow-in-matlab
function drawArrow(x, y, props)

h = annotation('arrow');
set(h,'parent', gca, ...
    'position', [x(1),y(1),x(2)-x(1),y(2)-y(1)], ...
    'HeadLength', 45, 'HeadWidth', 40, props{:}, 'LineStyle', 'none');

end