% This files loads in all of the videos, as well as parses some info from their file names.
% I have renamed files so that they looks as follows:
% Day<1|2>-<Martian|Lunar|Micro>-<Speed>mms.mov

% A sheet that connects these new names to the raw names can be found
% in the Google Drive can be found in the same drive under:
% "Project EMPANADA/DATA/EMPANADA Data Files Key"

% This lists all of the files in the following path
% If the video files are later moved, but sure to update this
% NOTE: Be sure that this ends in a '/' character, as it is used
% as a prefix later on

% Use this path when working on a lab machine
%fileDirectory = '/eno/jdfeathe/DATA/EMPANADA_Proper/';

% Use this path when working on my personal machine
fileDirectory = '~/workspaces/matlab-workspace/EMPANADA-Proper/';

fileList = dir(fileDirectory);

% An empty array of the type of struct we will be using later
%trials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fullPath', {});
trials = struct('day', {}, 'gravity', {}, 'speed', {}, 'video', {}, 'results', {});

% Which file we want to start at
% This is useful if we only want to look at a single trial for testing
start = length(fileList) - 1;

% To keep our struct array looking nice (and not having blank spots in
% between actual entries) we will use this offset index to adjust when we
% find bad files
offset = start - 1;

%for i = 1: length(fileList);
for i = start: length(fileList) % For now we only want to look at a one trial to test the code
    
    % First we want to do some checks to make sure that invalid files don't
    % get processed
    
    % Check if it is a directory
    if fileList(i).isdir == 1
        fprintf('Invalid file: "%s": is a directory (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset)
        offset = offset + 1;
        continue
    end
    
    % Make sure the size of the file is non-zero
    % This eliminates '.' and '..' which always show up
    if fileList(i).bytes == 0
        fprintf('Invalid file: "%s": has size of 0 bytes (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset)
        offset = offset + 1;
        continue
    end
    
    % Make sure we have a .mov extension
    if ~strcmp(fileList(i).name(end-3:end), '.mov')
        fprintf('Invalid file: "%s": has incorrect extension (correct=.mov) (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset)
        offset = offset + 1;
        continue
    end
    
    % First we remove the file extension
    splitExt = strsplit(fileList(i).name, '.');
    % We have to cast to char here because otherwise strsplit won't take this
    % as an input
    removedExt = char(splitExt(1));
    
    % Split the name into day, gravity, and speed
    nameFields = strsplit(removedExt, '-');

    % Grab the day and take only the last character
    day = char(nameFields(1));
    day = day(end:end);
    
    % Don't need to do any editing here
    gravity = nameFields(2);

    % Grab the speed and take everything but the last 3 characters (mms)
    speed = char(nameFields(3));
    speed = speed(1:end-3);
    
    % We can't just use the name (since it would be a relative path) so we
    % add the foler defined above as a prefix
    % Going to leave this to output since it takes a hot minute and its
    % nice to see where it is
    fullFilePath = strcat(fileDirectory, fileList(i).name);
    % Even throw a debug message in there
    fprintf('Loading file "%s"... (%i of %i)\n', fullFilePath, i - offset, length(fileList) - offset)
    
    video = VideoReader(fullFilePath);
    
    % Add this trial into our array
    %trials(i - offset) = struct('day', day, 'gravity', gravity, 'speed', speed, 'fullPath', fullFilePath);
    trials(i - offset) = struct('day', day, 'gravity', gravity, 'speed', speed, 'video', video, 'results', 'N/A');
end

save('LoadFiles.mat', 'trials');



