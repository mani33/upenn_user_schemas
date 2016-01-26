%{
cstim.PopspikeEg (computed) # slope computation window onset and offset
-> cont.Chan
-----
popspike_bounds: tinyblob # beginning and end time of each hill on either side of the popspike
%}

classdef PopspikeEg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.PopspikeEg')
        popRel = cont.Chan & cstim.FpRespTrace% !!! update the populate relation
    end
    
    methods
        function self = PopspikeEg(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            % Randomly pick 10 keys and set example
            nKey = 10;
            [tt,yy] = fetchn(cstim.FpRespTrace(key),'t','y');
            n = length(tt);
            k = randperm(n);
%             tt = tt(k(1:nKey));
%             yy = yy(k(1:nKey));
            tb = zeros(nKey,4);
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            N = nKey;
            cc = 1;
            i = 0;
            while cc <= N
                i = i+1;
                j = k(i);
                y = zscore(yy{j});
                t = tt{j};
                yso = mconv(y,cstim.getGausswin(0.5,1000*1/Fs));
                
                clf
                
                plot(t,y,'k')
                hold all
                plot(t,yso,'r')
                
                xlim([-2000 50000]) 
                xt = get(gca,'XTick');
                set(gca,'XTick',xt,'xticklabel',xt/1000)
                % Set ylimit
                st = std(yso);
                ylim([min(yso) max(yso)]+st*[-0.5 0.5])
                % Ginput the start and end points to calculate slope
                title('Click the beginning and end each hill on either side of the popspike')
                pause % This allows for zooming the trace
                
                [tb(cc,:),~] = ginput(4);
                % If you want to skip the trace, just click at least one
                % point on the negative time side
                if all(tb(cc,:)> 0)
                    cc = cc+1;
                end
            end
            key.popspike_bounds = median(tb,1);            
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end