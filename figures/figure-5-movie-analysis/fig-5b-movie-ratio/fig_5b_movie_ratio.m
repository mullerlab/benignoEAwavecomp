% init
clearvars; clc; close all
addpath(genpath('../../../helpers'))

% load data
load ./data.mat
sm = smooth(ssims,30);
err = abs(ssims-sm);

%%
[b,d] = boundedline(ratios,sm,err,'linewidth',2);
set(gca,'FontSize',18,'linewidth',2,'XScale','log')
b.Color = 'k';
d.FaceColor = 'k';
d.FaceAlpha = 0.1;
xlabel('recurrence-to-input ratio')
ylabel('total structural similarity')
ylim([0 1])
pbaspect([1 1 1])

% exportgraphics(gcf,'./ssim-vs-isrs.pdf')
