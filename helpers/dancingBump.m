function [g,xc,yc] = dancingBump(options)

    arguments
        options.sigma
        options.frames_per_period
        options.phase = 0
        options.xIsZero = false
        options.n = 7
    end

    x = linspace(-2,2,30);
    y = x;
    [X,Y] = meshgrid(x,y);
    Tx = 6*pi; % period of xc
    Ty = 2*pi; % period of yc

    dt = max(Tx,Ty) / options.frames_per_period; % 3600
    t = (0 : dt : options.n*max(Tx,Ty) )'; %(0:0.02*pi:200*pi)';
    if options.xIsZero
        xc = zeros(size(t));
    else
        xc = sin( ((2*pi)/Tx) * t + options.phase ); % period 6pi
    end
    yc = cos( ((2*pi)/Ty) * t ); % period 2pi

    g=[];
    for ii = 1 : length(xc)
        xx = X-xc(ii);
        yy = Y-yc(ii);
        tmp=( xx.^2 + yy.^2 ) ./ (2*options.sigma^2);
        g(:,:,ii) = exp(-tmp);
    end
    
end