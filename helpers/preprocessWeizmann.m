function [walk_aligned,walk_unaligned] = preprocessWeizmann(action,person,args)

arguments
    action
    person
    args.dims = [80 50]
end

if endsWith(action,'1') 
    action2 = extractBefore(action,'1');
elseif endsWith(action,'2')
    action2 = extractBefore(action,'2');
else
    action2 = action;
end

%% masks
wd = fullfile(fileparts(mfilename('fullpath')),'weizmann');
load(fullfile(wd,'classification_masks.mat'))

% aligned mask
str = sprintf('mask_aligned = aligned_masks.%s_%s;',person,action);
eval(str);

% unaligned mask
str = sprintf('mask_unaligned = original_masks.%s_%s;',person,action);
eval(str);

%% pad
vidObj = VideoReader(sprintf('%s/%s/%s_%s.avi',wd,action2,person,action));
nrows_frame=vidObj.Height;
ncols_frame=vidObj.Width;
nframes=vidObj.NumFrames;
mask_aligned = padMask(mask_aligned, nrows_frame, ncols_frame, nframes);

%% load walk
vidObj = VideoReader(sprintf('%s/%s/%s_%s.avi',wd,action2,person,action));
walk_unaligned=[];
while hasFrame(vidObj)
    frame = rgb2gray(readFrame(vidObj)); %double(rgb2gray(readFrame(vidObj)));
    walk_unaligned = cat(3,walk_unaligned,frame);
end

%% align walk
walk_aligned = [];
for ii = 1 : size(mask_unaligned,3)
    walk_aligned = cat(3, walk_aligned, alignWalks(mask_unaligned(:,:,ii),mask_aligned(:,:,ii),walk_unaligned(:,:,ii)));
end

%% crop aligned walk
r1=inf;
r2=-inf;
c1=inf;
c2=-inf;
for ii = 1 : size(mask_aligned,3)
    [r,c]=find(mask_aligned(:,:,ii));
    r1 = min(min(r), r1);
    r2 = max(max(r), r2);
    c1 = min(min(c), c1);
    c2 = max(max(c), c2);
end
walk_aligned_uncropped = walk_aligned;
walk_aligned = [];
for ii = 1 : size(mask_unaligned,3)
    walk_aligned = cat(3, walk_aligned, walk_aligned_uncropped(r1:r2,c1:c2,ii));
end

%% resize
tmp = double(walk_aligned);
walk_aligned = imresize3(tmp,[args.dims(1) args.dims(2) size(tmp,3)]);

end

function mask_padded = padMask(mask, nrows_frame, ncols_frame, nframes)
[nrows_mask,ncols_mask]=size(mask,[1 2]);
nr = nrows_frame-nrows_mask;
nc=ncols_frame-ncols_mask;
mask_padded = nan(nrows_frame,ncols_frame,nframes);
for ii= 1:nframes
    frame = mask(:,:,ii);
    frame = cat(1,frame,zeros(nr, ncols_mask));
    frame = cat(2, frame, zeros(nrows_frame, nc));
    frame = circshift(circshift(frame,10,1),40,2);
    mask_padded(:,:,ii) = frame;
end
end

function walk_aligned = alignWalks(mask_unaligned,mask_aligned,walk_unaligned)

stats = regionprops(mask_unaligned);
centroid_unaligned = stats.Centroid;

stats = regionprops(mask_aligned);
centroid_aligned = stats.Centroid;

col_shift = round(centroid_aligned(1) - centroid_unaligned(1));
row_shift = round(centroid_aligned(2) - centroid_unaligned(2));
walk_aligned = circshift(circshift(walk_unaligned,row_shift,1), col_shift, 2);

end
