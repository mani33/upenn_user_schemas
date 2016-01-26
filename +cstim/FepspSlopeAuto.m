%{
cstim.FepspSlopeAuto (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
-> cstim.SlopeParams
---
fepsp_slope                 : double                        # slope of epsp mV/ms
slope_onset                 : double                        # onset of slope measurement (uS)
%}

classdef FepspSlopeAuto < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspSlopeAuto')
        %         popRel = (cstim.FpRespTrace - acq.EventsIgnore)*cstim.SlopeParams  % !!! update the populate relation
        popRel = (cstim.FpRespTrace * cstim.SlopeParams) & cstim.SlopeEg
    end
    
    methods
        function self = FepspSlopeAuto(varargin)
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
            
            dy = diff(yso);
            mInd = t>5000 & t < 10000;
            dy = max(yso(mInd))*dy/max(dy(mInd));
            plot(t(2:end),dy,'r')
            xlim([-2000 50000])
            %             tms = t/1000;
            % Compute ylimit
            %             ssy = [y(tms > 0.5 & tms < 10); dy(tms(2:end) > 0.5 & tms(2:end) < 10)];
            %             yl = [min(ssy) max(ssy)];
            %             ylim(yl)
            st = std(yso);
            ylim([min(yso) max(yso)]+0.5*[-st st])
            xt = get(gca,'XTick');
            set(gca,'XTick',xt,'xticklabel',xt/1000)
            
                       
            
            % Use auto method
            [on, off] = fetchn(cstim.SlopeEg(key),'slope_on','slope_off'); % in microsec
            % Smooth the inst slope
            sdy = mconv(dy,sk);
            sind = (t>on) & (t < off);
            vind = find(sind);
            [~,ind] = max(abs(sdy(sind)));
            pkInd = vind(ind);
            n = round(key.slope_win*1e-6/(1/Fs));
            % now correct sind based on this peak
            sind = 1+(round((-(n+1)/2)):round((n/2)))+ pkInd;
            
            
            ts = t(sind);
            ys = y(sind);
            X = [ts*1e-6,ones(size(ts))];
            B = regress(ys,X);
            key.fepsp_slope = B(1);
            yi = X*B;
            plot(X(:,1)*1e6,yi,'m*')
            plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
            plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
            key.slope_onset = t(sind(1));
            
            pause(0.1)
            self.insert(key)
            
        end
    end
    
end
