function esn = esncon(args)
    
    arguments
        args.frame % frame of same size as input frames
        args.rs % recurrent strength
        args.rl % recurrent length
        args.is % input strength
        args.Nx % # of nodes on a side of square grid
        args.v = 1e6 % speed
        args.bias = 0
        args.periodicBoundaries = false
        args.rc = 'r' % real or complex
        args.W
        args.TAU
    end
    
    esn.v = args.v;
    esn.rc = args.rc;
    esn.rs = args.rs;
    esn.rl = args.rl;
    esn.is = args.is;
    esn.bias = args.bias;
    [ esn.Mrow , esn.Mcol ] = size(args.frame);
    esn.M = esn.Mrow * esn.Mcol;
    esn.Nx = args.Nx;
    esn.N = esn.Nx^2;
    if args.periodicBoundaries
        pos = assignSpacePeriodic( esn.Nx , esn.Nx );
    else
        pos = assignSpace( esn.Nx , esn.Nx );
    end
    D = pdist2(pos, pos, 'euclidean');
    if isfield(args,'W')
        esn.W = args.W;
    else
        esn.W = args.rs * exp( -D.^2 / 2 / args.rl.^2 );
    end
    if isfield(args,'TAU')
        esn.TAU = args.TAU;
    else
        esn.TAU = round( D ./ args.v );
    end
    esn.maxDelay = max(esn.TAU(:));

    esn.Wcol=cell(esn.N,1);
    esn.Wval=esn.Wcol;
    for ii = 1 : esn.N
        [~,esn.Wcol{ii},esn.Wval{ii}] = find(esn.W(ii,:));
        rows = esn.Wcol{ii};
        cols = (esn.maxDelay+1) - esn.TAU(ii,rows);
        esn.lagInds{ii} = sub2ind([esn.N esn.maxDelay+1],rows',cols');
    end

end