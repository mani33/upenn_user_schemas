%{
his.MouseAtlasHippo (lookup) # Just the hippo of the mouse atlas
-> his.MouseAtlas
side: smallint # left side = 0; right side = 1
-----
im:         longblob                      # image matrix
offset_x: double # x position relative to the full atlas image
offset_y: double # y position relative to the full atlas image
%}

classdef MouseAtlasHippo < dj.Relvar
    properties(Constant)
        table = dj.Table('his.MouseAtlasHippo');
    end
    
    methods
        function self = MouseAtlasHippo(varargin)
            self.restrict(varargin{:})
        end
    end
    
end