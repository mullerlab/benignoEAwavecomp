function [out,ground_truth,ssimval,amat,V,ssim_ts,ratio,train_time] = esnsim(args)

arguments
    args.esn
    args.in single
    args.T0
    args.Ttr
    args.Tte
    args.zscore = true % only false for classn example
    args.gpu = false
    args.V
    args.regularization = false
    args.enlargedReadoutScale = 1
    args.regParam = 1e-9
    args.a0
    args.mldivide = false
end

% init
T = args.T0 + args.Ttr + args.Tte; 
flatten = @(x) x(:);
A = nan( args.esn.N , args.Ttr );
D = nan( args.esn.M , args.Ttr );
if isfield(args,'a0'), a = args.a0; else, a = zeros( args.esn.N, args.esn.maxDelay+1 ); end

% zscore input ("in") framewise; since "in" provides the ground truth frames, it
% is useful to remove framewise means and make variances manageable
in = args.in;
if args.zscore, in = zscore( in , [] , [1 2] ); end

% readin
X = imresize3( in , [args.esn.Nx args.esn.Nx size(in,3)] , 'linear' );
if args.zscore, X = zscore(X,[],[1 2]); end
if args.gpu, X = gpuArray(X); end

% washout
for tt = 1 : args.T0
    a_new = esnint( esn = args.esn , x = X(:,:,tt) , a = a );
    a = [a(:,end-args.esn.maxDelay+1:end), a_new];
    amat(:,:,tt) = reshape(a_new,args.esn.Nx,args.esn.Nx);
end

% training
tic
for tt = (args.T0+1) : (args.T0+args.Ttr)
    a_new = esnint( esn = args.esn , x = X(:,:,tt) , a = a );
    a = [a(:,end-args.esn.maxDelay+1:end), a_new];
    amat(:,:,tt) = reshape(a_new,args.esn.Nx,args.esn.Nx);

    if strcmp(args.esn.rc,'r')
        A(:,tt-args.T0) = zscore(cos(a_new)); % zscoring to remove mean
    elseif strcmp(args.esn.rc,'c')
        A(:,tt-args.T0) = zscore(a_new); % zscoring to remove mean
    end
    if args.enlargedReadoutScale == 1
        D(:,tt-args.T0) = flatten( in(:,:,tt+1) );
    else
        D(:,tt-args.T0) = zscore( flatten( imresize( in(:,:,tt+1) , args.enlargedReadoutScale , 'bilinear' ) ) ); % "in" already zscored framewise
    end
end
if ~isfield(args,'V')
    if args.mldivide
        V = (A'\D')';
    else
        if args.regularization
            V = D * A' * pinv( A*A' + args.regParam*eye(args.esn.N) );
        else
            V = lsqminnorm(A',D')'; % ssim(V*R,D)
        end
    end
else
    V = args.V;
end
train_time = toc;

% forecasting
x = X(:,:,tt+1);
xx=x(:);
out=[];
ground_truth=[];
% ratio=[];
ssim_ts=[];
r = [];
for tt = (args.T0+args.Ttr+1) : T
    % integrate
    [ a_new , ~ , tmp ] = esnint( esn = args.esn , x = x , a = a );
    r=[r;tmp];
    a = [a(:,end-args.esn.maxDelay+1:end), a_new];
    amat(:,:,tt) = reshape(a_new,args.esn.Nx,args.esn.Nx);
    
    % readout
    if strcmp(args.esn.rc,'r')
        y = V * zscore( cos(a_new) ) ;
    elseif strcmp(args.esn.rc,'c')
        y = V * zscore( a_new ) ;
    end
    if args.enlargedReadoutScale == 1
        y = reshape( y , args.esn.Mrow , args.esn.Mcol );
    else
        y = reshape( y , args.enlargedReadoutScale * args.esn.Mrow , args.enlargedReadoutScale * args.esn.Mcol );
        y = zscore( imresize( y , [args.esn.Mrow args.esn.Mcol] , 'bilinear' ) , [] , [1 2] );
    end
    out(:,:,tt-args.T0-args.Ttr) = y;
    
    % ground truth
    gt = in(:,:,tt+1);
    ground_truth(:,:,tt-args.T0-args.Ttr) = gt;

    % calculate performance
    ssim_ts(tt-args.T0-args.Ttr) = ssim(real(y),gt);

    % readin
    x = zscore( imresize(y,[args.esn.Nx args.esn.Nx],'bilinear'), [], [1 2] );
    if tt ~= T, xx = [xx; x(:)]; end
end
ssimval = ssim(real(out),ground_truth);
ratio = norm(r) / norm(xx);
out = real(out);

end
