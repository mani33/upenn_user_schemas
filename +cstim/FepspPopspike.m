%{
cstim.FepspPopspike (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
---
popspike_height   : double       # popspike height in mV
%}

classdef FepspPopspike < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspPopspike')
        popRel = cstim.FpRespTrace - acq.EventsIgnore
    end
    
    methods
        function self = FepspPopspike(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            d = fetch(cstim.FpRespTrace(key)*cont.Fp,'y','t','sampling_rate');
            y = zscore(d.y);
            Fs = d.sampling_rate;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
            yso = mconv(y,sk);
            t = d.t/1000;
            
            clf
            plot(t,y,'k')
            hold all
            plot(t,yso,'r')
            xlim([-2 50])
            
            % Set ylimit
            st = std(yso);
            ylim([min(yso) max(yso)]+st*[-0.5 0.5])
            % Ginput the start and end points to calculate slope
            title('Click the beginning and end each hill on either side of the popspike')
%             pause % This allows for zooming the trace
            [bounds,~] = ginput(4);
            
            [h,tt,yy,ypi] = get_popspike_height(t,y,bounds,'auto',false);
            if isnan(h)
                h = -1;
            end
            key.popspike_height = h;
            hold on
            plot(tt(2),ypi,'m*')
            plot(tt(2),yy(2),'m*')
            plot(tt([1 3]),yy([1 3]),'k-')
            plot([tt(2) tt(2)],[yy(2) ypi],'m','linewidth',2)
            
            xlabel('Time(ms)')
            title('PopSpike')
            box off
            pause
            self.insert(key)
            
        end
    end    
end
