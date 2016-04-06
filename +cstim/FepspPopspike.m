%{
cstim.FepspPopspike (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
-> cstim.SmoothMethods
---
popspike_height   : double       # popspike height in mV
%}

classdef FepspPopspike < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspPopspike')
        popRel = (cstim.FpRespTrace - acq.EventsIgnore)*cstim.SmoothMethods
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
            smn = key.smooth_method_num;
            if smn == 0              
                yso = y;
                sk = [];
            elseif smn == 1 % gauss win method
                fp = fetch1(cstim.SmoothMethods(key),'filter_params');
                kstd = fp.std_msec;
                sk = cstim.getGausswin(kstd,1000*1/Fs);             
                yso = mconv(y,sk);
            else
                error('Undefined smoothing method')
            end
%             sk = cstim.getGausswin(0.5,1000*1/Fs);
            
            t = d.t/1000;
            satisfied = false;
            useExample = true;
            while ~satisfied
                figure(1)
                clf
                plot(t,y,'k')
%                 set(gcf,'Position',[47   856   948   482])
                hold all
                plot(t,yso,'r')
                xlim([-2 50])
                
                % Set ylimit
                st = std(yso);
                ylim([min(yso) max(yso)]+st*[-0.5 0.5])
                % Ginput the start and end points to calculate slope
                if useExample
                    bounds = fetch1(cstim.PopspikeEg(key),'popspike_bounds');
                    egh = fetch1(cstim.PopspikeEg(key),'popspike_height');
                else
                    [bounds,~] = ginput(4);
                end
                [h,tt,yy,ypi] = get_popspike_height(t,y,bounds,'auto',false,'smooth_ker',sk);
                
                if isnan(h)
                    h = -1;
                end
                key.popspike_height = h;
                hold on
                col = rand(1,3);
                plot(tt(2),ypi,'*','color',col)
                plot(tt(2),yy(2),'*','color',col)
                plot(tt([1 3]),yy([1 3]),'k-')
                plot([tt(2) tt(2)],[yy(2) ypi],'color',col,'linewidth',4)
                
                
                xlabel('Time(ms)')
                title('PopSpike')
                box off
                
                % Intelligent auto method
                if (h > 5*egh) || (h < 0.1*egh) % something is not right
                    useExample = false;
                else
                    satisfied = true;
                    useExample = true;
                end
            end
            pause(0.1)
            self.insert(key)
            
        end
    end
end
