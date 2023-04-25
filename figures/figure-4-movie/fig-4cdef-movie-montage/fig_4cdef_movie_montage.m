clearvars; clc; close all
addpath(genpath('../../../helpers'))

%% 
load ./data.mat

%%
[vid,period] = walkingBookended(person='lena',action='walk1');
T0 = period;
T_train = 3*T0;
T_test = 2*T0;

%%
esn = esncon(frame=vid(:,:,1),rs=3*best.rs,is=best.is,rl=best.rl,Nx=50,rc='c',bias=best.b,v=best.v);
[out,ground_truth,ssimval,rmat,V,ssim_ts,ratio] = esnsim(esn=esn,in=vid,T0=T0,Ttr=T_train,Tte=T_test);

%%
esn0 = esncon(frame=vid(:,:,1),rs=0,is=best.is,rl=best.rl,Nx=50,rc='c',bias=best.b,v=best.v);
[out0,ground_truth0,ssim0,rmat0,V0,ssim_ts0,ratio0] = esnsim(esn=esn0,in=vid,T0=T0,Ttr=T_train,Tte=T_test);

%%
nrows = 4; % 
ncols = 7; % time steps

tl = tiledlayout(nrows,ncols,'TileSpacing','tight');

sk = 3;
frames = (1:ncols)*sk;

for ii = 1 : nrows
    if ii == 1
        data = ground_truth(:,:,frames);
    elseif ii==2
        data = out(:,:,frames);
    elseif ii==3
        data = cos(angle(rmat(:,:,T0+T_train+frames)));
    elseif ii == 4
        data = out0(:,:,frames);
    end

    for jj = 1:length(frames)
        nexttile
        imagesc(data(:,:,jj),[min(data(:)) max(data(:))])
        axis off
        colormap bone
        pbaspect([50 80 1])
    end
end

% exportgraphics(gcf,'natvid-montage.pdf')