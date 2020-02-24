% This file takes some trial information and finds when the probe actually
% begins descending and when it stops, since we are only interested in this
% regime

%load('Analysis/BrightnessGSquaredAnalysis.mat', 'trials')

% The new data hasn't finished running yet, so I am still using the old
% naming/file location
%load('AnalyzedData.mat')

minimumLineLength = 35;

trials = struct('day', '1', 'gravity', 'Lunar', 'speed', '70', 'fileName', 'Day1-Lunar-70mms.mov');

for i=1: length(trials)
    % We are going to load the video, so that we can track the probe
    video = VideoReader([settings.datapath, trials.fileName]);
    
    while hasFrame(video)
       currentFrame = readFrame(video);
       
       grayScale = rgb2gray(currentFrame);
       
       % Create a binary image
       binaryFrame = edge(grayScale, 'canny');
       
       % Take the hough transform
       [H, T, R] = hough(binaryFrame);
       
       % Identify a single peak in our hough transform, since we are
       % looking for our probe
       P  = houghpeaks(H, 1);
       
       x = T(P(:,2)); y = R(P(:,1));
       
       lines = houghlines(binaryFrame,T,R,P,'FillGap', 1, 'MinLength', minimumLineLength);
       disp(length(lines));
       imshow(binaryFrame);
       hold on
       
       maxLength = 0;
       
       for k = 1:length(lines)
           xy = [lines(k).point1; lines(k).point2];
           %plot(xy(:,1),xy(:,2),'LineWidth',5,'Color','green');

           % Plot beginnings and ends of lines
           %plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
           %plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
           
           len = norm(lines(k).point1 - lines(k).point2);
           if len > maxLength
              maxLength = len;
              longestLine = xy;
           end
       end
       
       plot(longestLine(:,1), longestLine(:,2), 'LineWidth', 5, 'Color','green');

       pause(.01)
       %break;
    end
    break;
end