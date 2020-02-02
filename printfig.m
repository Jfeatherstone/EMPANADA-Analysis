function printfig(num, prename, where)

global settings

if ~exist('where')
    where = settings.savepath;
end;

if where(end) ~= '/'
    where(end+1) = '/';
end;

figure(num)
saveas(gcf, [where, prename, '.eps'], 'epsc2')
saveas(gcf, [where, prename, '.fig'], 'fig')
saveas(gcf, [where, prename, '.png'], 'png')

return;
