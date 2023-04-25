% init
clearvars; clc; close all
addpath(genpath('../../../helpers'))

% load
load ./data.mat

%% smooth
for ii = 1 : size(data,2)
    data_sm(:,ii) = smooth( data(:,ii) , 30 );
    err(:,ii) = abs( data_sm(:,ii) - data(:,ii) );
end

%% plot
C0 = colorcet('D11');
C = colorcet('D11','N', size(data_sm,2));
hold on
for ii = 1 : size(data_sm,2)
%     errorbar(1:200,data_sm(:,ii),err(:,ii))
    [hl,hp] = boundedline(1:200, data_sm(:,ii), err(:,ii));
    hl.Color = C(ii,:);
    hl.LineWidth = 2;
    hp.FaceColor = C(ii,:);
    hp.FaceAlpha = 0.1;
end
hold off
ylim([0 1])
colormap(C0)
cb = colorbar;
cb.Label.String = 'recurrence-to-input ratio';
caxis([min(ratios) max(ratios)])
pbaspect([1 1 1])
set( gca, 'fontname', 'arial', 'fontsize', 18, 'linewidth', 2 )
xlabel('video frame')
ylabel('structural similarity')

% exportgraphics(gcf,'./ssim-ts.pdf')

