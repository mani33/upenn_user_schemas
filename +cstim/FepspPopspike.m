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
            satisfied = false;
            useExample = true;
            while ~satisfied
                clf
                plot(t,y,'k')
                set(gcf,'Position',[47   856   948   482])
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
                [h,tt,yy,ypi] = get_popspike_height(t,y,bounds,'auto',false);
               
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
            
                    if (h > 2*egh) || (h < 0.33*egh) % something is not right
                        useExample = false;
                    else
                        satisfied = true;
                        useExample = true;
                    end
               
%                 % See if you are satisfied. If, yes, simply hit Enter key; if
%                 % not hit the 'n' key and you will be asked to select 4 points
%                 v = input('Are you satisfied? Hit ENTER if yes; Hit any other key if no','s');
%                 if isempty(v)
%                     satisfied = true;
%                 else
%                     useExample = false;
%                 end
                
            
            end
            pause(0.1)
            self.insert(key)
            
        end
    end
end
