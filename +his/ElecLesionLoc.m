%{
his.ElecLesionLoc (computed) # Elec lesion locations with histology images
->his.MouseAtlas
->his.ElecLesionIm
-----
xy_loc: tinyblob # xy loc of the lesion on image in his.MouseAtlas
%}

classdef ElecLesionLoc < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('his.ElecLesionLoc');
        popRel = his.ElecLesionIm & his.MouseAtlas;
    end
    
    methods
        function self = ElecLesionLoc(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            [raw_im,ap] = fetchn(his.ElecLesionIm(key), 'im','ap_loc');
            tuple.ap_loc = ap;
            atlas_im = fetch1(his.MouseAtlas(key,sprintf('ap_loc = %0.2f',ap)), 'im');
            figure
            set(gcf,'Position',[2134 379 1383 930])
            subplot(1,2,1)
            imshow(raw_im{:})
            subplot(1,2,2)
            imshow(atlas_im)
            hold on
            satisfied = false;
            title('Click on the location of the tip of the lesion on the atlas image')
            disp('Go ahead and zoom images if you want. Then hit enter')
            pause
            
            while ~satisfied
                [x,y] = ginput(1);
                h = plot(x,y,'rO');
                 redoit = input('Is the location ok? If yes, press ENTER, if no, press any other key','s');
                 if isempty(redoit)
                     satisfied = true;
                 end
                 delete(h)
            end
            tuple.xy_loc = [x y];
            self.insert(tuple)
        end
    end
end
