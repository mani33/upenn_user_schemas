function [cx,cy,blob_r,blob_c] = process_frame(frame,th,mouse_size,pix_std,smooth_ker)
% [cx,cy,blob_r,blob_c] = process_frame(frame,th,mouse_size,smooth_ker)
% To be used with getMotionIndex and set_motion_det_params functions.
% Mani Subramaniyan
% 2016-08-23

cfv = frame(:);
zcf = ((frame-mean(cfv))/pix_std);
szcf = gather(imfilter(zcf < th,smooth_ker));
[blob_r,blob_c] = find(szcf);
% Center blob coordinates to previously detected mouse center
% and take pixels that are only within 150 pixels
blob_dist = sqrt((blob_c - pcx).^2 + (blob_r - pcy).^2);
sel = blob_dist < mouse_size;
blob_c = blob_c(sel);
blob_r = blob_r(sel);
hold on
plot(blob_c,blob_r,'g.')
cx = median(blob_c);
cy = median(blob_r);