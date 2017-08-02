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
        popRel = ((cont.Chan & cstim.FpRespTrace)*cstim.SlopeParams*cstim.SmoothMethods) - cont.ChanIgnore% !!! update the populate relation
    end
    
    methods
        function self = SlopeEg(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            clf
            [tt,yy] = fetchn(cstim.FpRespTrace(key),'t','y');
            n = length(tt);
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            smn = key.smooth_method_num;
            sk = cstim.getGausswin(0.5,1000*1/Fs);
            % Find the smallest size
            sz = cellfun(@length,tt);
            mz = min(sz);
            %             smn = key.smooth_method_num;
            tmp = struct;
%            
            figure(12221)
             subplot(2,2,1)
            for i = 1:n
                y = yy{i};
                t = tt{i};
                tmp.yy(:,i)= y(1:mz);
                yso = mconv(y,sk);
                plot(t,y,'b')
                hold all
%                 plot(t,yso,'k')
                dy = diff(yso);
                mInd = t>5000 & t < 10000;
%                 dy = max(yso(mInd))*dy/max(dy(mInd));
%                 plot(t(2:end),dy,'r')
                xlim([-2000 50000])
%                 tms = t/1000;

                xt = get(gca,'XTick');
                set(gca,'XTick',xt,'xticklabel',xt/1000)
                tmp.dy(:,i) = dy(1:mz-1);
            end
%             yl = ylim;
            % Averaged
            subplot(2,2,2)
            sel = randperm(n);
            my = zscore(mean(tmp.yy(:,sel(1:15)),2));
            plot(t(1:mz),(my),'k')
            hold on
             xlim([-2000 50000])
            subplot(2,2,4)
            mdy = zscore(mean(tmp.dy,2));
            mmdy = max(my(mInd))*mdy/max(mdy(mInd));
            plot(t(1:mz-1),(mmdy),'r')
            
%             ssy = [my(tms > 0.5 & tms < 10); mdy(tms(2:end) > 0.5 & tms(2:end) < 10)];
%             yl = [min(ssy) max(ssy)];
%             ylim(yl)
            xlim([-2000 50000])
            % Ginput the start and end points to calculate slope
            title('Click the beginning and end of slope computation region')
            [tb,~] = ginput(2);
            
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
            
            sind = (t>tb(1)) & (t < tb(2));
            vind = find(sind);
            
            % Find biggest peak
            nsamples = 2/(1000*1/Fs); % no peak within 2 ms
            [~,locs1] = findpeaks(mdy(sind),'MINPEAKDISTANCE',nsamples);
            [~,locs2] = findpeaks(-mdy(sind));
            locs = [locs1; locs2];
            % Sort by location and take the first peak
          
            pkInd = vind(min(locs));%
            n = round(key.slope_win*1e-6/(1/Fs));
            % now correct sind based on this peak
            sind = 1+(round((-(n+1)/2)):round((n/2)))+ pkInd;
            
            ts = t(sind);
            ys = my(sind);
            X = [ts*1e-6,ones(size(ts))];
            B = regress(ys,X);
            key.slope_val = B(1);
            subplot(2,2,2)
            yi = X*B;
            plot(X(:,1)*1e6,yi,'m*')
            plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
            plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
            
            redoit = input('Is the slope ok? If yes, press ENTER, if no, press any other key','s');
            if ~isempty(redoit)
                error('fix the code')
            end
            
            key.slope_on = tb(1);
            key.slope_off = tb(2);
            %!!! compute missing fields for key here
            self.insert(key)
            
        end
    end
end