%% Crop and save MatLAB figure as PDF
% From https://www.mathworks.com/matlabcentral/fileexchange/70349-crop-and-save-matlab-figure-as-pdf-savepdf
% Slightly modified
function savePDF(plot_name)
plot_path = 'Output-pdf/';
% check if directory exists, if not create one
if ~exist(plot_path, 'dir')
    mkdir(plot_path)
end
fig = gcf;
fig.PaperPositionMode = 'auto';
fig_pos = fig.PaperPosition;
fig.PaperSize = [fig_pos(3) fig_pos(4)];
print(fig,'-dpdf','-painters','-r600','-loose',strcat(plot_path,plot_name));
end
