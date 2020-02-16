% defines some useful default parameters in a variable called settings
% to use these settings in a function include the same line "global
% settings" in functions you write
global settings

% set up where to read/save data
username = 'jdfeathe';
settings.png_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-png/'];
settings.fig_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-fig/'];
settings.avi_savepath = ['/eno/', username, '/EMPANADA-Analysis/Output-avi/'];

settings.datapath = ['/eno/', username, '/DATA/EMPANADA-Proper/'];
settings.matlabpath = ['/eno/', username, '/EMPANADA-Analysis/'];

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

% And initialize some constants I've made
initialize_constants;

%opengl software
% Ted says that this produces as error message about openGL not working on Unix, but that it fixes crashes that were happening previousl
