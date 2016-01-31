%{
cstim.SlopeEg (computed) # slope computation window onset and offset
-> cont.Chan
-> cstim.SlopeParams
-----
slope_on: double # slope computation window beginning in micro sec
slope_off: double # slope computation window end in micro sec
slope_val: blob # values of slope
%}

classdef SlopeEg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.SlopeEg')
        popRel = (cont.Chan & cstim.FpRespTrace)*cstim.SlopeParams% !!! update the populate relation
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
            
%             tt = tt(k(1:nKey));
%             yy = yy(k(1:nKey));
            tb = zeros(nKey,2);
            
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            kc = 0;
            
            while kc < nKey
                rk = ceil(rand*n);
                y = yy{rk};
                t = tt{rk};
                sk = cstim.getGausswin(0.5,1000*1/Fs);
                yso = mconv(y,sk);
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
                %                 pause % This allows for zooming the trace
                [ttb,~] = ginput(2);
                if diff(ttb) < 5*key.slope_win % you want to skip this trace
                    kc = kc + 1;
                    tb(kc,:) = ttb;
                    
                    
                    % Smooth the inst slope
                    sdy = mconv(dy,sk);
                    sind = (t>tb(kc,1)) & (t < tb(kc,2));
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
                    key.slope_val(kc) = B(1);
                    yi = X*B;
                    plot(X(:,1)*1e6,yi,'m*')
                    plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
                    plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
                end
            end
            key.slope_on = mean(tb(:,1));
            key.slope_off = mean(tb(:,2));
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end