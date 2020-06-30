function trials = LoadForceData()

% Make sure that the startup file has been run
if ~exist('settings', 'var')
   fprintf('Warning: startup program has not been run, correcting now...\n')
   startup;
end
global settings

% We also want to make sure that the output file is always saved inside the
% Analysis folder, so if we are running the function from elsewhere, we
% need to account for that
outputPath = 'ForceData.mat';
if ~strcmp(pwd, strcat(settings.matlabpath, 'Preprocessing'))
   fprintf('Warning: preprocessing script not run from Preprocessing directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Preprocessing/ForceData.mat'];
end

% We also want to make sure that our excel file specifying the crop times
% for each video is there
if ~exist('Force-data', 'dir')
    fprintf('Error: Force-data folder is not present in MATLAB directory!\n');
    return
end
% Which file we want to start at
% This is useful if we only want to look at a single trial for testing
start = 1;

% To keep our struct array looking nice (and not having blank spots in
% between actual entries) we will use this offset index to adjust when we
% find bad files
offset = start - 1;

% An empty array of the type of struct we will be using later
trials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});

fileList = dir('Force-data');

% Load in the excel file to read crop times
dataKeyExcel = readtable('EMPANADA Data Files Key.xlsx');
startTimes = containers.Map(table2array(dataKeyExcel(:,2)), table2array(dataKeyExcel(:,6)));
endTimes = containers.Map(table2array(dataKeyExcel(:,2)), table2array(dataKeyExcel(:,7)));
questionable = containers.Map(table2array(dataKeyExcel(:,2)), table2array(dataKeyExcel(:,8)));

for i = start: length(fileList)
    % First we want to do some checks to make sure that invalid files don't
    % get processed
    
    % Check if it is a directory
    if fileList(i).isdir == 1
        fprintf('Invalid file: "%s": is a directory (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset);
        offset = offset + 1;
        continue
    end
    
    % Make sure the size of the file is non-zero
    % This eliminates '.' and '..' which always show up
    if fileList(i).bytes == 0
        fprintf('Invalid file: "%s": has size of 0 bytes (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset);
        offset = offset + 1;
        continue
    end
    
    % Make sure we have a .csv extension
    if ~strcmp(fileList(i).name(end-3:end), '.csv')
        fprintf('Invalid file: "%s": has incorrect extension (correct=.csv) (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset);
        offset = offset + 1;
        continue
    end
    
    fileName = fileList(i).name;
    % Even throw a debug message in there
    fprintf('Loading file "%s"... (%i of %i)\n', fileName, i - offset, length(fileList) - offset);
    
    % First we remove the file extension
    splitExt = strsplit(fileList(i).name, '.');
    % We have to cast to char here because otherwise strsplit won't take this
    % as an input
    removedExt = char(splitExt(1));
    
    % Split the name into day, gravity, and speed
    nameFields = strsplit(removedExt, '-');

    % Grab the day and take only the last character
    day = char(nameFields(1));
    day = str2double(day(end:end));
    
    % Don't need to do any editing here
    gravity = nameFields(2);

    % Grab the speed and take everything but the last 3 characters (mms)
    speed = char(nameFields(3));
    speed = speed(1:end-3);
    % The old speeds are all scaled wrong, so we have to adjust if the day
    % is 1 or 2
    % I determined this value experimentally, see LabBlog for more info
    % specifically the post on June 1, 2020
    speedRescale = .0407;
    
    if day == 1 || day == 2
       speed = num2str(str2double(speed) * speedRescale); 
    end
    
    % Now read the data from the csv file
    data = readtable(['Force-data/', fileName]);
    frameTime = table2array(data(:,1));
    forceData = table2array(data(:,2));
    results = struct('frameTime', frameTime, 'forceData', forceData);
    
    % Now we grab the start and end times
    % These cells are formatted as numbers in the sheet, so we don't have
    % to do any conversions
    % We do have to switch out the csv extension for mov though, since the
    % sheet contains the file names of the videos
    fileNameWithMOV = [removedExt, '.mov'];
    
    % If the data has been marked as questionable, we ignore it
    if strcmp(questionable(fileNameWithMOV), 'Yes')
        fprintf('Invalid file: "%s": has been marked as questionable (%i of %i)\n', fileList(i).name, i - offset, length(fileList) - offset);
        offset = offset + 1;
        continue
    end    

    cropTimes = [startTimes(fileNameWithMOV), endTimes(fileNameWithMOV)];
    
    trials(i - offset) = struct('day', day, 'gravity', gravity, 'speed', speed, 'fileName', fileName, 'cropTimes', cropTimes, 'results', results);

end

save(outputPath, 'trials');

end

