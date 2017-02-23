% plot the tangent function
projectName = 'motStudy02';
plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ]; %should be all

ev = -1:.01:1;
Scale = 100;
opt = 0.1;
maxI = 1.25;

for i = 1:length(ev)
ds(i) = tancubed(ev(i),Scale,opt,maxI);
end

h1 = figure;
plot(ev,ds)
xlim([-.4 .4])
title(sprintf('Transfer Function'))
hold on
line([.1 .1], [-1.5 1.5], 'color', [140 136 141]/255, 'LineWidth', 2.5,'LineStyle', '--');
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('\Delta Dot Speed')
xlabel('Retrieval - Control Evidence')
%legend('function', 'optimal evidence')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
print(h1, sprintf('%stanEX.pdf', plotDir), '-dpdf')