clearvars;clc

%%
load ./data.mat out ground_truth

%%
k = [1:3:12 36:3:58];
nrows = 2;
ncols = length(k);
set( gcf, 'position', [422 596 1085 388] )
tl = tiledlayout(nrows,ncols,'TileSpacing','tight');
for row = 1 : nrows

    if row == 1
        data = ground_truth;
    elseif row == 2
        data = out;
    end

    for col = 1 : ncols
        nexttile
        imagesc(data(:,:,k(col)),[-2.5 2])
        axis off
        pbaspect([50 80 1])
        colormap bone
    end
end

% exportgraphics(gcf,'switching-montage.pdf')