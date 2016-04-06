%{
cstim.SlopeEg (computed) # slope computation window onset and offset
-> cont.Chan
-> cstim.SlopeParams
-> cstim.SmoothMethods
-----
slope_on: double # slope computation window beginning in micro sec
slope_off: double # slope computation window end in micro sec
slope_val: blob # values of slope
%}

classdef SlopeEg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.SlopeEg')
        popRel = (cont.Chan & cstim.FpRespTrace)*cstim.SlopeParams*cstim.SmoothMethods% !!! update the populate relation
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
            tb = zeros(nKey,2);            
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            kc = 1;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
             smn = key.smooth_method_num;
            while kc < nKey
                rk = ceil(rand*n);
                y = yy{rk};
                t = tt{rk};                
                yso = mconv(y,sk);
                clf
                
                if smn == 0
                    fy = y;
                elseif smn == 1 % gauss win method
                    fp = fetch1(cstim.SmoothMethods(key),'filter_params');
                    kstd = fp.std_msec;
                    sk = cstim.getGausswin(kstd,1000*1/Fs);
                    fy = mconv(y,sk);
                else
                    error('Undefined smoothing method')
                end
                
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
                xt = get(gca,'XTick');
                set(gca,'XTick',xt,'xticklabel',xt/1000)
                
                % Ginput the start and end points to calculate slope
                title('Click the beginning and end of slope computation region')
                [ttb,~] = ginput(2);               
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
                ys = fy(sind);
                X = [ts*1e-6,ones(size(ts))];
                B = regress(ys,X);
                key.slope_val(kc) = B(1);
                
                yi = X*B;
                plot(X(:,1)*1e6,yi,'m*')
                plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
                plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
                
                redoit = input('Is the slope ok? If yes, press ENTER, if no, press any other key','s');
                if isempty(redoit)
                    kc = kc + 1;
                end
            end
            key.slope_on = mean(tb(:,1));
            key.slope_off = mean(tb(:,2));
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
end