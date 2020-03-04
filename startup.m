% This auto starts on opening Matlab, though most startup things are in two
% files in the Misc folder, since there should be different settings for my
% laptop vs. the lab machines

global settings;

% This file decides which machine you are on based on the host name
myLaptopHostName = "ArchMSI";

if strcmp(getenv('HOST'), myLaptopHostName)
    fprintf('Detected system: personal laptop. Adjusting settings appropriately...\n');
    % set up where to read/save data
    username = 'jack';
    settings.png_savepath = ['/home/', username, '/workspaces/matlab-workspace/EMPANADA-Analysis/Output-png/'];
    settings.fig_savepath = ['/home/', username, '/workspaces/matlab-workspace/EMPANADA-Analysis/Output-fig/'];
    settings.avi_savepath = ['/home/', username, '/workspaces/matlab-workspace/EMPANADA-Analysis/Output-avi/'];

    settings.datapath = ['/home/', username, '/workspaces/matlab-workspace/EMPANADA-Proper/'];
    settings.matlabpath = ['/home/', username, '/workspaces/matlab-workspace/EMPANADA-Analysis/'];
else
    fprintf('Detected system: lab computer. Adjusting settings appropriately...\n');
    % set up where to read/save data
    username = 'jdfeathe';
    settings.png_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-png/'];
    settings.fig_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-fig/'];
    settings.avi_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-avi/'];

    settings.datapath = ['/eno/', username, '/DATA/EMPANADA-Proper/'];
    settings.matlabpath = ['/eno/', username, '/EMPANADA-Analysis/'];
end

% And setup some variables that are the same for both machines

addpath(genpath(settings.matlabpath))

% set up graphics defaults to have a nice, large font
% to change this later, type "settings.charfrac = 0.5 ; startup" to
% get a smaller font or "settings.charfrac = 1.2 ; startup" to get a 
% larger font, where the # is any decimal number not too far from 1.0
% (the default size)
if ~ismember('charfrac', fieldnames(settings))
    settings.charfrac=1.0;
end

settings.fontsize=24*settings.charfrac;
settings.smallfontsize=18*settings.charfrac;
settings.largefontsize=28*settings.charfrac;
settings.linewidth = 1.5;
set(0,'DefaultTextFontSize',settings.fontsize)
set(0,'DefaultAxesFontSize',settings.fontsize)
set(0,'DefaultUIControlFontSize',settings.fontsize)
set(0,'DefaultLineLineWidth', settings.linewidth)
set(0,'DefaultAxesLineWidth', settings.linewidth)

% work in your matlab directory by default
cd(settings.matlabpath)

clear c hostname result username