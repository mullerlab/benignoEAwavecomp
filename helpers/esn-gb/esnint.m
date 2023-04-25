function [a_new,ratio,it] = esnint(args)

arguments
    args.esn
    args.x
    args.a
end

W = args.esn.W;
TAU = args.esn.TAU;
x = args.esn.is * ( args.x + args.esn.bias ); x = x(:);
a = args.a; a = reshape(a, args.esn.N, []);
if args.esn.maxDelay == 0
    it = exp( -1i*a ) .* args.esn.W * exp(1i*a);
elseif args.esn.maxDelay > 0
%     it = zeros(args.esn.N,1);
    for ii = 1 : args.esn.N
%         for jj = 1 : args.esn.N
%             it(ii) = it(ii) + W(ii,jj) * exp( 1i*( a( jj , end - TAU(ii,jj) )  -  a(ii,end) )  );
%         end
        tmp = a(args.esn.lagInds{ii});
        it(ii,1) = args.esn.Wval{ii} * exp( 1i*( tmp - a(ii,end) ) );
    end
end
it = -1i*it;

input_term = norm(x);
recurrence_term = norm(it);
ratio = recurrence_term / input_term;

a_new = a(:,end) + ( x + it );

if strcmp(args.esn.rc,'r')
    a_new = angle( exp(1i*a_new) );
elseif strcmp(args.esn.rc,'c')
    if ~isequal(imag(a_new), zeros(args.esn.N,1))
        a_new = a_new ./ abs(a_new);
    end
end

end
