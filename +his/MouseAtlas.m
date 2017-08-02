%{
his.MouseAtlas (manual) # Images of mouse atlas
ap_loc: double # Anterior-Posterior location from Bregma
-----
im: longblob # image matrix

%}

classdef MouseAtlas < dj.Relvar
     properties(Constant)
        table = dj.Table('his.MouseAtlas');
    end
    
    methods
        function self = MouseAtlas(varargin)
            self.restrict(varargin{:})
        end
    end
end