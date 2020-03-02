function trials = LoadFiles(startupFile, cropData)

% In case the startup file is not provided, default to my laptop
if ~exist('startupFile', 'var')
    fprintf('Warning: startup file not specified, defaulting to laptop (StartupLaptop.m)!\n')
    StartupLaptop()
else
   	run(startupFile)
end
% And allow the variable settings to be accessed
global settings

% Make sure that the startup file has been run
% This shouldn't ever error since we just checked, but I have it here just
% in case something wack happens
if ~exist('settings', 'var')
   fprintf('Error: startup program has not been run, datapath not defined!\n') 
   return
end

% We also want to make sure that the output file is always saved inside the
% Analysis folder, so if we are running the function from elsewhere, we
% need to account for that
outputPath = 'LoadFiles.mat';
if ~strcmp(pwd, strcat(settings.matlabpath, 'Preprocessing'))
   fprintf('Warning: preprocessing script not run from Preprocessing directory, accouting for this in output path!\n')
   outputPath = [settings.matlabpath, 'Preprocessing/LoadFiles.mat'];
end

% We also want to make sure that our excel file specifying the crop times
% for each video is there
if ~isfile('EMPANADA Data Files Key.xlsx') && cropData
    fprintf('Error: data key file is not present in MATLAB directory!\n')
    return
end

% This files loads in all of the videos, as well as parses some info from their file names.
% I have renamed files so that they looks as follows:
% Day<1|2>-<Martian|Lunar|Micro>-<Speed>mms[-<repetition #>].mov

% A sheet that connects these new names to the raw names can be found
% in the Google Drive can be found in the same drive under:
% "Project EMPANADA/DATA/EMPANADA Data Files Key"

% This lists all of the files in the following path
% Be sure to run the proper startup file, so that settings.datapath is
% defined
fileList = dir(settings.datapath);

% An empty array of the type of struct we will be using later
trials = struct('day', {}, 'gravity', {}, 'speed', {}, 'fileName', {}, 'cropTimes', {}, 'results', {});

% Which file we want to start at
% This is useful if we only want to look at a single trial for testing
start = 1;

% To keep our struct array looking nice (and not having blank spots in
% between actual entries) we will use this offset index to adjust when we
% find bad files
offset = start - 1;

% Load in the excel file to read crop times
dataKeyExcel = readtable('EMPANADA Data Files Key.xlsx');
startTimes = containers.Map(table2array(dataKeyExcel(:,2)), table2array(dataKeyExcel(:,6)));
endTimes = containers.Map(table2array(dataKeyExcel(:,2)), table2array(dataKeyExcel(:,7)));

%for i = 1: length(fileList);
for i = start: length(fileList)
    
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
        
    % Now we grab the start and end times
    cropTimes = [str2num(startTimes(fileList(i).name)), str2num(endTimes(fileList(i).name))];
    
    % There may or may not be a fourth entry in name fields, if we have
    % multiple trials that have the same parameters, but this doesn't
    % actually matter to us, so we ignore it (but obviously keep it in the
    % name)
    
    fileName = fileList(i).name;
    % Even throw a debug message in there
    fprintf('Loading file "%s"... (%i of %i)\n', fileName, i - offset, length(fileList) - offset)
        
    % Add this trial into our array
    trials(i - offset) = struct('day', day, 'gravity', gravity, 'speed', speed, 'fileName', fileName, 'cropTimes', cropTimes, 'results', 'N/A');
end

save(outputPath, 'trials');

end % Function end



