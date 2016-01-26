%{
cstim.FepspSlope (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
-> cstim.SlopeParams
---
fepsp_slope                 : double                        # slope of epsp mV/ms
slope_onset                 : double                        # onset of slope measurement (uS)
%}

classdef FepspSlope < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspSlope')
        popRel = (cstim.FpRespTrace - acq.EventsIgnore)*cstim.SlopeParams  % !!! update the populate relation
    end
    
    methods
        function self = FepspSlope(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            d = fetch(cstim.FpRespTrace(key)*cont.Fp,'y','t','sampling_rate');
            y = d.y;
            Fs = d.sampling_rate;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
            
            
            clf
            t = d.t;
            y = y - mean(y(t>2500 & t<4000));
            yso = mconv(y,sk);
            
            plot(t,y,'b')
            hold all
            plot(t,yso,'k')
            
            dy = diff(yso);
            mInd = t>5000 & t < 10000;
            dy = max(yso(mInd))*dy/max(dy(mInd));
          
            plot(t(2:end),dy,'r')
            xlim([-2000 50000])
            
            st = std(yso);
            ylim([min(yso) max(yso)]+0.5*[-st st])
            xt = get(gca,'XTick');
            set(gca,'XTick',xt,'xticklabel',xt/1000)
            
            % Manual selection of window to compute slope
            title('Slope Measurement')
            
            % Ginput the start and end points to calculate slope
            [tb,~] = ginput(1);
            % Extract the trace between the bounds and fit a linear model
            % and get the slope
            sind = t>=tb & t<=(tb+key.slope_win);
            
            ts = t(sind);
            ys = y(sind);
            X = [ts*1e-6,ones(size(ts))];
            B = regress(ys,X);
            key.fepsp_slope = B(1);
            yi = X*B;
            plot(X(:,1)*1e6,yi,'m*')
            plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
            plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
            sv = find(sind);
            key.slope_onset = t(sv(1));
            pause
            self.insert(key)
            
        end
    end
    
end
