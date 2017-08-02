%{
his.ElecLesionIm (manual) # images of electrolytic lesion marking electrodes
-> acq.Animals
chan_num        : tinyint                # A/D channel number (0 - n); for stim electrode use -1.
---
im                          : longblob                      # image matrix
ap_loc                      : double                        # anterior posterior location inferred by visual inspection
side                        : smallint                      # left side = 0; right side = 1
%}

classdef ElecLesionIm < dj.Relvar
    
    properties(Constant)
        table = dj.Table('his.ElecLesionIm')       
    end
    
    methods
        function self = ElecLesionIm(varargin)
            self.restrict(varargin{:})
        end
    end
end
