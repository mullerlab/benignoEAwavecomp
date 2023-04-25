clearvars; clc; close all
addpath(genpath('../../../helpers'))

%% init
Nx=50;
N=Nx^2;
nt = 50;
skips = 1:9:50;
ntrials = 1000;
nreps = 100;

%% generate vid
x0 = randi(Nx);
y0 = randi(Nx);
frm = getStimFrame(Nx, 0, 0 );
vid = zeros(Nx,Nx,nt,'single');
vid(:,:,1) = frm;

%% our esn (with recurrence)
esn = esncon(frame=frm, rs=2e-3, is=2e-3, rl=0.2, v=0.01, Nx=Nx, rc='c');
[~,~,~,rmat,~,~] = esnsim(esn=esn,in=vid,T0=nt,Ttr=0,Tte=0,zscore=false);
rmat_arg = cos(angle(rmat));
rmat_arg(rmat_arg > .001*max(rmat_arg(:))) = .001*max(rmat_arg(:));
rmat_arg = rmat_arg / max(rmat_arg(:));
rmat_arg_flat = reshape(rmat_arg,N,[]);
rmat_arg_flat_skip = rmat_arg_flat(:,skips);

%% our esn (without recurrence)
esn0 = esncon(frame=frm, rs=0, is=2e-3, rl=0.2, v=0.01, Nx=Nx, rc='c');
[~,~,~,rmat0,~,~] = esnsim(esn=esn0,in=vid,T0=nt,Ttr=0,Tte=0,zscore=false);
rmat0_flat = reshape(rmat0, N, []);
rmat0_flat_skip = rmat0_flat(:,skips);

%% random rnn
rng(0);
in = double(reshape(vid,N,[]));
R = rnn(N, in, nt);
R_skip = R(:,skips);

%%
acc = nan(nreps,1);
acc0 = nan(nreps,1);
acc_esn = nan(nreps,1);
for jj = 1 : nreps
    tos = randi(5,ntrials,1);
    los = randi(4,ntrials,1);
    d = sub2ind([5 4],tos,los);
    X = nan(N,ntrials);
    X0 = nan(N,ntrials);
    X_esn = nan(N,ntrials);
    for ii = 1 : ntrials
        % shift in time
        X(:,ii) = rmat_arg_flat_skip( : , (6-tos(ii)+1) );
        X0(:,ii) = rmat0_flat_skip( : , (6-tos(ii)+1) );
        X_esn(:,ii) = R_skip( randperm(N) , (6-tos(ii)+1) ); % the shuffle here (randperm) is a proxy for generating a new random rnn each trial 

        % shift in space
        X(:,ii) = shift_in_space(X(:,ii),los(ii),Nx);
        X0(:,ii) = shift_in_space(X0(:,ii),los(ii),Nx);
        X_esn(:,ii) = shift_in_space(X_esn(:,ii),los(ii),Nx);
    end

    classes = (1:20)';
    [~,acc(jj)] = perceptronGB(X,d,classes);
    [~,acc0(jj)] = perceptronGB(X0,d,classes);
    [~,acc_esn(jj)] = perceptronGB(X_esn,d,classes);
end

%% PLOT
skips = 1:13:50;

frm = getStimFrame(Nx, -12, -12 );
vid = zeros(Nx,Nx,nt,'single');
vid(:,:,1) = frm;

esn = esncon(frame=frm, rs=2e-3, is=2e-3, rl=0.2, v=0.01, Nx=Nx, rc='c');
[~,~,~,rmat,~,~] = esnsim(esn=esn,in=vid,T0=nt,Ttr=0,Tte=0,zscore=false);
rmat_arg = cos(angle(rmat));
rmat_arg(rmat_arg > .001*max(rmat_arg(:))) = .001*max(rmat_arg(:));
rmat_arg = rmat_arg / max(rmat_arg(:));
rmat_arg_skip = rmat_arg(:,:,skips);
rmat_arg_skip_shift = zeros(Nx,Nx,6);
rmat_arg_skip_shift(:,:,3:end) = rmat_arg_skip( : , : , 1:(6-3+1) );

esn0 = esncon(frame=frm, rs=0, is=2e-3, rl=0.2, v=0.01, Nx=Nx, rc='c');
[~,~,~,rmat0,~,~] = esnsim(esn=esn0,in=vid,T0=nt,Ttr=0,Tte=0,zscore=false);
rmat0_skip = rmat0(:,:,skips);
rmat0_skip_shift = zeros(Nx,Nx,6);
rmat0_skip_shift(:,:,3:end) = rmat0_skip( : , : , 1:(6-3+1) );

in = double(reshape(vid,N,[]));
rng(0);
R = rnn(N, in, nt);
R_mats = reshape(R,Nx,Nx,[]);
R_skip = R_mats(:,:,skips);
R_skip_shift = zeros(Nx,Nx,6);
R_skip_shift(:,:,3:end) = R_skip(:,:,1:(6-3+1));

nrows=4;
ncols=6;
for row = 1:nrows
    if row==1
        data = zeros(Nx,Nx,6);
        data(:,:,3) = frm;
    elseif row==2
        data = rmat0_skip_shift;
    elseif row==3
        data = rmat_arg_skip_shift;
    elseif row==4
        data = R_skip_shift;
    end
    maxx = max(data(:));
    minn = min(data(:));

    for col = 1:ncols
        ind = sub2ind([ncols nrows],col,row);
        subplot(nrows,ncols,ind)
        imagesc(data(:,:,col),[minn maxx])
        pbaspect([1 1 1])
        axis off
        colormap bone
    end
end

%% plot
figure(2)
xx = [2 4 6];
b=bar(xx,mean(100*[acc0 acc acc_esn]),.4,'LineStyle','none');
b.FaceAlpha = 0.5;
xticks(xx)
xticklabels({'cv-NN without recurrence','cv-NN with recurrence','random RNN'})
ylabel('accuracy (%)')

hold on
plot(2*ones(100,1),100*acc0,'ob')
plot(4*ones(100,1),100*acc,'ob')
plot(6*ones(100,1),100*acc_esn,'ob')
hold off

box off
ylim([0 105])
yline(5,'--','LineWidth',1,'FontSize',18,'Alpha',0.3)
yline(25,'--','LineWidth',1,'FontSize',18,'Alpha',0.3)
yticks([0 5 20 25 40 60 80 100])
yticklabels({'0','5','20','25','40','60','80','100'})
yline(100,'--','LineWidth',1,'FontSize',18,'Alpha',0.3)
xlim([xx(1)-2 xx(end)+2])
pbaspect([1 1 1])

set(gcf,'Position',[2060 30 691 571])
set(gca,'FontSize',22,'LineWidth',2)


%% FUNCTIONS
function frm = getStimFrame(Nx, x0, y0)
    x = linspace(-2,2,Nx);
    [X,Y] = meshgrid(x);
    tmp = ( X.^2 + Y.^2 ) ./ (2*0.05^2);
    frm = exp(-tmp);
    frm = circshift(frm,[x0,y0]);
    frm = single(frm);
end

function R = rnn(N, in, nt)
    U = randn(N); % readin matrix
    W = sprandn(N, N, 0.05); % recurrent matrix
    sr = abs(eigs(W,1)); % spectral radius
    W = W / sr;
    r = zeros(N,1);
    R = nan(N,nt);
    for tt = 1 : nt
        r = tanh( U*in(:,tt) + W*r );
        R(:,tt) = r;
    end
end

function tmp5 = shift_in_space(v,los,Nx)
    tmp = reshape(v, Nx, Nx, []);
    tmp2 = padarray(tmp, [12 12], min(tmp(:)));
    if los==1
        padsize = [-12 -12];
    elseif los==2
        padsize = [12 -12];
    elseif los==3
        padsize = [-12 12];
    elseif los==4
        padsize = [12 12];
    end
    tmp3 = circshift(tmp2,padsize);
    tmp4 = tmp3(12+1:74-12,12+1:74-12);
    tmp5 = tmp4(:);
end

