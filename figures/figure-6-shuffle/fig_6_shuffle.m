clearvars; clc; close all
addpath(genpath('../../helpers'))

%% 
load ./params.mat

%%
[vid,period] = walkingBookended(person='lena',action='walk1');
T0 = period;
T_train = 3*T0;
T_test = 2*T0;

%%
esn = esncon(frame=vid(:,:,1),rs=rs,is=is,rl=rl,Nx=50,rc='c',bias=0,v=v);

p = randperm(numel(esn.W));
Wsh = reshape( esn.W(p), 2500, 2500 );
TAUsh = reshape( esn.TAU(p), 2500, 2500 );

esn_sh = esncon(frame=vid(:,:,1),rs=rs,is=is,rl=rl,Nx=50,rc='c',bias=0,v=v,W=Wsh,TAU=TAUsh);

[out_sh,ground_truth,ssimval_sh,amat_sh,~,~,~] = esnsim(esn=esn_sh,in=vid,T0=T0,Ttr=T_train,Tte=T_test);

[out,~,ssimval,amat,~,~,~] = esnsim(esn=esn,in=vid,T0=T0,Ttr=T_train,Tte=T_test);

%%
nrows = 4; 
ncols = 7; 

tl = tiledlayout(nrows,ncols,'TileSpacing','tight');

sk = 13;
frames = (1:ncols)*sk;

for ii = 1 : nrows
    if ii == 1
        data = cos(angle(amat(:,:,T0+T_train+frames)));
    elseif ii==2
        data = out(:,:,frames);
    elseif ii==3
        data = cos(angle(amat_sh(:,:,T0+T_train+frames)));
    elseif ii == 4
        data = out_sh(:,:,frames);
    end

    for jj = 1:length(frames)
        nexttile
        imagesc(data(:,:,jj),[min(data(:)) max(data(:))])
        axis off
        colormap bone
        pbaspect([50 80 1])
    end
end

% exportgraphics(gcf,'./W-shuff.pdf')