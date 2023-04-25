clearvars; clc; close all
addpath(genpath('../../../helpers'))

%%
load ./scan_results.mat

%%
n_rl = 50;
n_is = 1;
n_rs = 1;
rl_edges = linspace(0, .2, n_rl+1)';
is_edges = linspace(0, .2, n_is+1)';
rs_edges = linspace(0, .2, n_rs+1)';
[counts,~,~,~,ind] = ...
    histcounts3GB(rl_vec,is_vec,rs_vec,[n_rl,n_is,n_rs],rl_edges,is_edges,rs_edges);

M = min(counts);

%%
tmp = [];
max_vec = [];
min_vec = [];
std_vec = [];
for ii = 1 : 50
    tmp(ii) = mean( ssim_vec(ind{ii}(1:M)) );
    max_vec(ii) = max( ssim_vec(ind{ii}(1:M)) );
    min_vec(ii) = min( ssim_vec(ind{ii}(1:M)) );
    std_vec(ii) = std( ssim_vec(ind{ii}(1:M)) );
end

%%
[hl,hp] = boundedline(rl_edges(2:end),tmp,std_vec.^2);
hold on
plot(rl_edges(2:end), max_vec,':k', 'LineWidth',2)
hl.Color = 'black';
hp.FaceColor = 'black';
hp.FaceAlpha = 0.05;
ylim([0 1.05])
xline(.05,'--','LineWidth',2)
xlabel('recurrent length')
ylabel('total structural similarity')
hold off
set(gca,'FontSize',18,'linewidth',2)
pbaspect([1 1 1])

% exportgraphics(gcf,'./ssim-vs-rl.pdf')
