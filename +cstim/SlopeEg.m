%{
cstim.SlopeEg (computed) # slope computation window onset and offset
-> cont.Chan
-----
slope_on: double # slope computation window beginning in micro sec
slope_off: double # slope computation window end in micro sec
%}

classdef SlopeEg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.SlopeEg')
        popRel = cont.Chan & cstim.FpRespTrace% !!! update the populate relation
    end
    
    methods
        function self = SlopeEg(varargin)
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
            tt = tt(k(1:nKey));
            yy = yy(k(1:nKey));
            tb = zeros(nKey,2);
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            for i = 1:nKey
                y = yy{i};
                t = tt{i};
                yso = mconv(y,cstim.getGausswin(0.5,1000*1/Fs));
                
                clf
                
                plot(t,y,'b')
                hold all
                plot(t,yso,'k')
                
                dy = diff(yso);
                mInd = t>5000 & t < 10000;
                dy = max(yso(mInd))*dy/max(dy(mInd));
                plot(t(2:end),dy,'r')
                xlim([-2000 50000])
                tms = t/1000;
                % Compute ylimit
                ssy = [y(tms > 0.5 & tms < 10); dy(tms(2:end) > 0.5 & tms(2:end) < 10)];
                yl = [min(ssy) max(ssy)];
                ylim(yl)
%                 st = std(yso);
%                 ylim([min(yso) max(yso)]+2*[-st st])
                xt = get(gca,'XTick');
                set(gca,'XTick',xt,'xticklabel',xt/1000)
                
                % Ginput the start and end points to calculate slope
                title('Click the beginning and end of slope computation region')
                pause % This allows for zooming the trace
                [tb(i,:),~] = ginput(2);
            end
            key.slope_on = mean(tb(:,1));
            key.slope_off = mean(tb(:,2));
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end