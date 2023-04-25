function [counts,x_edges,y_edges,z_edges,ind] = histcounts3GB(x,y,z,nbins,x_edges,y_edges,z_edges)
% x,y,z -- column vectors that make up (x',y',z') coordinates
% nbins -- [nx ny nz]
% counts -- nx-by-ny-by-nz matrix of counts
% linear indices of counts

nx = nbins(1);
ny = nbins(2);
nz = nbins(3);

x1 = min(x); x2 = max(x);
dx = (x2-x1)/nx;
if isempty(x_edges)
    x_edges = x1 : dx : x2;
end

y1 = min(y); y2 = max(y);
dy = (y2-y1)/ny;
if isempty(y_edges)
    y_edges = y1 : dy : y2;
end

z1 = min(z); z2 = max(z);
dz = (z2-z1)/nz;
if isempty(z_edges)
    z_edges = z1 : dz : z2;
end

counts = nan(nbins);
ind = cell(nbins);

for ii = 1 : nx
    cdn_x = x >= x_edges(ii) & x < x_edges(ii+1);
    for jj = 1 : ny
        cdn_y = y >= y_edges(jj) & y < y_edges(jj+1);
        for kk = 1 : nz
            cdn_z = z >= z_edges(kk) & z < z_edges(kk+1);
            counts(ii,jj,kk) = nnz(cdn_x & cdn_y & cdn_z);
            ind{ii,jj,kk} = find(cdn_x & cdn_y & cdn_z);
        end
    end
end

end