%{
cstim.SlopeEg2 (computed) # slope computation window onset and offset
-> cont.Chan
-> cstim.SlopeParams
-> cstim.SmoothMethods
-----
slope_on: double # slope computation window beginning in micro sec
slope_off: double # slope computation window end in micro sec
slope_val: blob # values of slope
%}

classdef SlopeEg2 < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.SlopeEg2')
        popRel = (cont.Chan & cstim.FpRespTrace)*cstim.SlopeParams*cstim.SmoothMethods% !!! update the populate relation
    end
    
    methods
        function self = SlopeEg2(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            clf
            [tt,yy] = fetchn(cstim.FpRespTrace(key),'t','y');
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            smn = key.smooth_method_num;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
            
            %             smn = key.smooth_method_num;
            subplot(1,2,1)
            title('Select beginning and end points of response')
            for i = 1:length(tt)
                y = mconv(yy{i} - mean(yy{i}), sk);
                plot(tt{i},y)
                hold all
            end
            [t_lims, ~] = ginput(2);
            start = find(tt{1} > t_lims(1),1);
            stop = find(tt{2} > t_lims(2),1);
            derY = [];
            for i = 1:length(tt)
                y = mconv(yy{i} - mean(yy{i}), sk);
                derY(stop + 1) = y(start + 2) - y(start);
            end
            avg_der = mean(derY);
            
            for i = 1:length(tt)
                y = yy{i}(start: stop);
                y2 = mconv(y - mean(y), sk);
                if avg_der > 0
                    y3 = y2/max(y2);
                    [~, pl] = max(y3);
                end
                if avg_der < 0
                    y3 = y2/min(y2);
                    [~, pl] = min(y3);
                end
                plot((-pl : length(y3) - pl - 1)  , y3)
                ylim([-1.5 1.5]);
                hold all
            end
           
            % Ginput the start and end points to calculate slope
            title('Click the beginning and end of slope computation region')
            [tb,~] = ginput(2);
            
            
            
            redoit = input('Is the slope ok? If yes, press ENTER, if no, press any other key','s');
            if ~isempty(redoit)
                error('Too bad')
            end
            
            key.slope_on = tb(1);
            key.slope_off = tb(2);
            %!!! compute missing fields for key here
            self.insert(key)
            
        end
    end
end