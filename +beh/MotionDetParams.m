%{
beh.MotionDetParams (computed) # params for computing mouse motion
-> acq.Sessions
zscore_th: double # zscore threshold below which the mouse's intensity lies
frames_to_skip: tinyint unsigned # number of video frames to skip during motion det
smooth_ker_size: tinyint unsigned # Gaussian smoothing kernel size
mouse_radius: smallint unsigned # max radius of mouse pixels
strel_size: smallint unsigned # matlab strel function call input size
---
video_file: varchar(256) # video file name
mouse_cx: double # x position of mouse in the first frame
mouse_cy: double # y position of mouse in the first frame
%}

classdef MotionDetParams < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('beh.MotionDetParams');
        popRel = acq.Sessions% !!! update the populate relation
    end
        
    methods
        function self = MotionDetParams(varargin)
            self.restrict(varargin{:})
        end
    end
     methods(Access=protected)
        function makeTuples(self, key)
            sess_path = fetch1(acq.Sessions(key),'session_path');
            videoFile = fullfile(sess_path,'VT1.mpg');
%             videoFile = strrep(videoFile,'y:\','C:\');
            h = set_motion_det_params(videoFile,key);
            waitfor(h,'Value')            
        end
    end
end