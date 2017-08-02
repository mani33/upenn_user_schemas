%{
beh.MouseMotion (computed) # compute raising or falling slope of epsp
-> beh.MotionDetParams
-> acq.Sessions
---
fps                 : double                        # frames per second
video_frame_size: tinyblob # video frame size in pixels
mouse_cx: blob # mouse center x coordinate in pixels
mouse_cy: blob # mouse center y coordinate in pixels
t_motion_min: blob # time (min) corresponding to the computed center
displacement: blob # distance mouse moved from previous measurment in pixels
%}

classdef MouseMotion < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('beh.MouseMotion')
        popRel = (acq.Sessions * beh.MotionDetParams)  % !!! update the populate relation
    end
    
    methods
        function self = MouseMotion(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            sess_path = fetch1(acq.Sessions(key),'session_path');
            videoFile = fullfile(sess_path,'VT1.mpg');
            tup = fetch(beh.MotionDetParams,'*');
            data = self.getMotionIndex_centroid(videoFile,tup);
            key.fps = data.fps;
            key.mouse_cx = data.cx;
            key.mouse_cy = data.cy;
            key.video_frame_size = data.video_frame_size;
            key.t_motion_min = data.time_min;
            key.displacement = data.dist;
            self.insert(key)
        end
    end
    methods(Static)
        function data = getMotionIndex_centroid(videoFile,key)
            data = struct;
            vobj = vision.VideoFileReader(videoFile);
            %             frame = double(obj.step());
            vinfo = info(vobj);
            data.fps = vinfo.VideoFrameRate;
            % Get an estimate of the session duration based on ephys
            % recording
            [be,en] = fetchn(acq.Ephys(key),'ephys_start_time','ephys_stop_time');
            dur = (double(en)-double(be))*(1e-6); % sec
            nFrames = round(dur*data.fps);
            data.video_frame_size = vinfo.VideoSize;
            iFrame = -1;
            px = key.mouse_cx;
            py = key.mouse_cy;
            st = strel('disk',key.strel_size);
            
            j = 0;
            tic
            tmax = 100;
            %             while (~vobj.isDone())
            while iFrame < tmax
%                 key.frames_to_skip = 300;
                iFrame = iFrame + 1
                nSkip = key.frames_to_skip+1;
                frame = double(vobj.step());
                if mod(iFrame,nSkip)==0
                    gw = getGausswin2d(key.smooth_ker_size);
                    mouse_radius = key.mouse_radius;
                    j = j + 1;
                    cf = gpuArray((rgb2gray(frame)));
                    cfv = cf(:)';
                    pixStd = std(cfv);
                    zcf = gather(((cf-mean(cfv))/pixStd));
                    szcf = zcf < key.zscore_th;%
                    szcf = (imclose(szcf,st));
                    szcf = gather(imfilter(gpuArray(szcf),gw));
                    [blob_r,blob_c] = find(szcf);
                    data.blob_size(j) = length(blob_r);
                    
                    if isempty(blob_r)
                        % First try simple thresholding
                        szcf = gather(zcf < key.zscore_th);%
                        [blob_r,blob_c] = find(szcf);
                        mouse_det_size = 0.25*median(data.blob_size);
                        mouse_found = length(blob_r)>= mouse_det_size;
                        % Adjust threshold until we can detect enough pixels
                        if ~mouse_found
                            th_original = key.zscore_th;
                            th_low_lim = min(gather(cfv));
                            th_search_vals = linspace(th_original,th_low_lim,30);
                            
                            for iSearch = 1:length(th_search_vals)
                                curr_th = th_search_vals(iSearch);
                                disp(curr_th)
                                szcf = gather(zcf < curr_th);%
                                [blob_r,blob_c] = find(szcf);
                                if length(blob_r)>= mouse_det_size
                                    break
                                end
                            end
                        end
                    end
                    % Center blob coordinates to previously detected mouse center
                    % and take pixels that are only within certain pixels
                    if isnan(px) && ~isempty(blob_r)
                        sel = true(1,length(blob_c));
                    else
                        blob_dist = sqrt((blob_c - px).^2 + (blob_r - py).^2);
                        sel = blob_dist < mouse_radius;
                    end
                    blob_c = blob_c(sel);
                    blob_r = blob_r(sel);
                    
                    cx = median(blob_c);
                    cy = median(blob_r);
                    data.cx(j) = cx;
                    data.cy(j) = cy;
                    
                    data.dist(j) = sqrt((cx-px)^2 + (cy-py)^2);
                    
                    px = cx;
                    py = cy;
                end
                displayProgress(iFrame,nFrames)
            end
            tend = toc;
            release(vobj)
            data.time_min = (0:key.frames_to_skip:iFrame)*(1/data.fps)/60;
            fprintf('Hours taken: %0.2f\n',tend/60/60)
        end
    end
end







