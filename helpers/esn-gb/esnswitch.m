function [out, ground_truth] = esnswitch(args)

arguments
    args.vids % cell array of vids
    args.esn
    args.VV % cell array of V matrices
    args.T
end

a = zeros( args.esn.N, args.esn.maxDelay+1 );
nn=0;
c = .5;
V = c*args.VV{1} + (1-c)*args.VV{2};
eta=.1;
pm=1;

for kk = 1 : length(args.vids)
    in = args.vids{kk};
    in = zscore( in , [] , [1 2] );
    
    X = imresize3( in , [args.esn.Nx args.esn.Nx size(in,3)] , 'linear' );
    X = zscore(X,[],[1 2]);
    
    for tt = 1 : size(in,3)
        
        nn = nn + 1;
        
        % calculate new activation
        a_new = esnint( esn = args.esn , x = X(:,:,tt) , a = a );
        a = [a(:,end-args.esn.maxDelay+1:end), a_new];
        amat(:,nn) = a_new;

        % calculate output
        y = V * zscore( a_new );
        out(:,:,nn) = reshape(real(y), 80, 50);
        ground_truth(:,:,nn) = single(in(:,:,tt+1));
        ssimval(nn,1) = immse( out(:,:,nn) , single(in(:,:,tt)) );

        % update weight
        if nn == 1, dssim = ssimval;
        else, dssim = ssimval(nn) - ssimval(nn-1); end
        if dssim > 0, pm = -pm; end
        dc = pm * eta ;

        if round(c+dc, 3) > 1 || round(c+dc, 3) < 0, break; end

        c = c + dc;
        V = c*args.VV{1} + (1-c)*args.VV{2};
       
    end

    t1 = tt+1;
    x = X(:,:,t1);
    for tt = t1 : t1+args.T
        nn = nn + 1;

        a_new = esnint( esn = args.esn , x = X(:,:,tt) , a = a );
        a = [a(:,end-args.esn.maxDelay+1:end), a_new];
        amat(:,nn) = a_new;
        
        y = reshape(V * zscore( a_new ), args.esn.Mrow, args.esn.Mcol);
        out(:,:,nn) = real(y);
    
        gt = in(:,:,tt+1);
        ground_truth(:,:,nn) = gt;
        xx = real(single(zscore(imresize(x, [80 50], "bilinear"),[],[1 2])));
        ssimval(nn,1) = immse( out(:,:,nn) , xx );
    
        x = zscore( imresize(y, [args.esn.Nx args.esn.Nx], 'bilinear'), [], [1 2] );

    end

end

end
