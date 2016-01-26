%{
cstim.FepspPopspikeAuto (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
---
popspike_height   : double       # popspike height in mV
%}

classdef FepspPopspikeAuto < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspPopspikeAuto')
        popRel = cstim.FpRespTrace & cstim.PopspikeEg
    end
    
    methods
        function self = FepspPopspikeAuto(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            d = fetch(cstim.FpRespTrace(key)*cont.Fp,'y','t','sampling_rate');
            y = d.y;
            Fs = d.sampling_rate;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
            yso = mconv(y,sk);
            
            clf
            t = d.t;
            plot(t,y,'b')
            hold all
            plot(t,yso,'k')
            
            xlim([-2000 50000])
            % Compute ylimit
            st = std(yso);
            ylim([min(yso) max(yso)]+0.5*[-st st])
            
            
            xt = get(gca,'XTick');
            set(gca,'XTick',xt,'xticklabel',xt/1000)
            
            bounds = fetch1(cstim.PopspikeEg(key),'popspike_bounds');
            [h,tt,yy,ypi] = get_popspike_height(t,y,bounds([1 end]),'auto',true);
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
            pause(0.1)
            self.insert(key)
            
        end
    end
    
end
