clearvars; clc; close all
addpath(genpath('../../../helpers'))

%%
frames_per_period=100;
vid = dancingBump(sigma=.2,frames_per_period=frames_per_period);
T0 = frames_per_period;
Ttr = 3*T0;
Tte = 2*T0;

%%
rs=100*.1468;
rl=.0169;
is=0.00003*.0766;
b=0;
v=.0840;

esn = esncon(frame=vid(:,:,1),...
             rs=rs,...
             is=is,...
             rl=rl,...
             Nx=50,...
             rc='c',...
             bias=b,...
             v=v);

[out,ground_truth,ssimval,amat,V,ssimts,ratio] = esnsim(esn=esn,in=vid,T0=T0,Ttr=Ttr,Tte=Tte);

esn0 = esncon(frame=vid(:,:,1),...
             rs=0,...
             is=is,...
             rl=rl,...
             Nx=50,...
             rc='c',...
             bias=b,...
             v=v);

[out0,ground_truth0,ssimval0,amat0,V0,ssimts0,ratio0] = esnsim(esn=esn0,in=vid,T0=T0,Ttr=Ttr,Tte=Tte);

%% 
nrows = 4; % gt, kmnorec, kmrec
ncols = 7; % time steps

tl = tiledlayout(nrows,ncols,'TileSpacing','tight');

sk = 9;
frames = (1:ncols)*sk;

for ii = 1 : nrows
    if ii == 1
        data = ground_truth(:,:,frames);
    elseif ii==2
        data = out(:,:,frames);
    elseif ii==3
        data = cos(angle(amat(:,:,T0+Ttr+frames)));
    elseif ii == 4
        data = out0(:,:,frames);
    end
    minn = min(data(:));
    maxx = max(data(:));

    for jj = 1 : ncols
        nexttile
        imagesc(data(:,:,jj),[minn maxx])
        axis off
%         set(gca,'xtick',[],'ytick',[])

        colormap bone

        pbaspect([1 1 1])
    end
end

% exportgraphics(gcf,'dancing-bump-montage.pdf')

