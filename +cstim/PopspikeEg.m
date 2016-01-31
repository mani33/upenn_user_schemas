%{
cstim.PopspikeEg (computed) # slope computation window onset and offset
-> cont.Chan
-----
popspike_bounds: tinyblob # beginning and end time of each hill on either side of the popspike
popspike_height: tinyblob # height of popspike
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
            % Randomly pick 5 keys and set example
            nKey = 5;
            [ttd,yyd] = fetchn(cstim.FpRespTrace(key),'t','y');
            n = length(ttd);
            k = randperm(n);
            tb = zeros(nKey,4);
            ph = zeros(1,nKey);
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            N = nKey;
            cc = 1;
            i = 0;
            while cc <= N
                i = i+1;
                j = k(i);
                y = zscore(yyd{j});
                t = ttd{j};
                yso = mconv(y,cstim.getGausswin(0.5,1000*1/Fs));
                t = t/1000;
                clf
                
                plot(t,y,'k')
                hold all
                plot(t,yso,'r')
                
                xlim([-5 50]) 
%                 xt = get(gca,'XTick');
%                 set(gca,'XTick',xt,'xticklabel',xt/1000)
                % Set ylimit
                st = std(yso);
                ylim([min(yso) max(yso)]+st*[-0.5 0.5])
                % Ginput the start and end points to calculate slope
                title('Click the beginning and end each hill on either side of the popspike')
%                 pause % This allows for zooming the trace
                
                [tb(cc,:),~] = ginput(4);
                
                 [ph(cc),tt,yy,ypi] = get_popspike_height(t,y,tb(cc,:),'auto',false);
               
   
                hold on
                col = rand(1,3);
                plot(tt(2),ypi,'*','color',col)
                plot(tt(2),yy(2),'*','color',col)
                plot(tt([1 3]),yy([1 3]),'k-')
                plot([tt(2) tt(2)],[yy(2) ypi],'color',col,'linewidth',4)
                pause(0.2)
                
                % If you want to skip the trace, just click at least one
                % point on the negative time side
                if all(tb(cc,:)> 0)
                    cc = cc+1;
                end
            end
                       
            key.popspike_height = median(ph);
            key.popspike_bounds = median(tb,1);            
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end