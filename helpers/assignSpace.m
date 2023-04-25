function pos = assignSpace( Nrow , Ncol )
    drow = single(1 / Nrow);
    row = drow : drow : 1;
    dcol = 1 / Ncol;
    col = dcol : dcol : 1;
    [ROW,COL] = meshgrid(row,col);
    pos = [ROW(:) COL(:)];
end