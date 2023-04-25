function [vid,period] = walkingBookended(args)

arguments
    args.action
    args.person
    args.dims = [80 50]
end

fwd = preprocessWeizmann(args.action,args.person,dims=args.dims);
bwd = flip(fwd,3);
rep = cat(3, fwd, bwd(:,:,2:end));
period = size(rep,3)-1;
rep2 = rep(:,:,2:(end-1));
rep3 = cat(3,rep,rep2);
vid = repmat(rep3,1,1,4);

end