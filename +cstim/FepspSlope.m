%{
cstim.FepspSlope (computed) # compute raising or falling slope of epsp
-> cstim.FpRespTrace
-> cstim.SlopeParams
-> cstim.SmoothMethods
---
fepsp_slope                 : double                        # slope of epsp mV/ms
slope_onset                 : double                        # onset of slope measurement (uS)
%}

classdef FepspSlope < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FepspSlope')
        popRel = ((cstim.FpRespTrace)*cstim.SlopeParams*cstim.SmoothMethods)&cstim.SlopeEg  % !!! update the populate relation
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
            smn = key.smooth_method_num;
            satisfied = false;
            useExample = true;
            
            while ~satisfied
                clf
                t = d.t; % microsec
                y = y - mean(y(t>2500 & t<4000));
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
                
                yso = mconv(y,sk);
                plot(t,y,'b')
                %                 set(gcf,'Position',[1147         677        1355         618])
%                 shg
                hold all
                plot(t,yso,'k')
                
                dy = diff(yso);
                mInd = t>5000 & t < 10000;
                dy = max(yso(mInd))*dy/max(dy(mInd));
                
                plot(t(2:end),dy,'r')
                xlim([-2000 50000])
                % Make sure that the part of the traces are visible between
                % time points 2 ms and 25 ms
                m2ind = t>2000 & t < 25000;
                btr = cat(1,dy(m2ind(2:end)),y(m2ind));
                ylim([min(btr) max(btr)])
                xt = get(gca,'XTick');
                set(gca,'XTick',xt,'xticklabel',xt/1000)
                
                % Manual selection of window to compute slope
                cname = fetch1(cont.Chan(d),'chan_name');
                title(sprintf('Slope Measurement for %s',cname))
                sdy = mconv(dy,sk);
                
                if useExample
                    [on, off, egSlopes] = fetchn(cstim.SlopeEg(key),'slope_on','slope_off','slope_val'); % in microsec
                    egSlopes = egSlopes{:};
                else
                    title('Select start and end time points around the peak of instantaneous slope')
                    [v2,~] = ginput(2);
                    on = v2(1);
                    off = v2(2);
                end
                sind = (t>on) & (t < off);
                vind = find(sind);
                %                 [~,ind] = max(abs(sdy(sind)));
                %                 pkInd = vind(ind);
                
                % Find biggest peak
                nsamples = 2/(1000*1/Fs); % no peak within 2 ms
                [pk1,locs1] = findpeaks(dy(sind),'MINPEAKDISTANCE',nsamples);
                [pk2,locs2] = findpeaks(-dy(sind));
                locs = [locs1; locs2];
                pk = [pk1; pk2];
                if isempty(pk)
                    satisfied = false;
                    useExample = false;
                    continue
                end
                [~,ind] = max(pk);
                % Sort by location and take the first peak
                pkInd = vind(locs(ind));%
                
                
                n = round(key.slope_win*1e-6/(1/Fs));
                % now correct sind based on this peak
                sind = 1+(round((-(n+1)/2)):round((n/2)))+ pkInd;
                ts = t(sind);
                ys = fy(sind);
                X = [ts*1e-6,ones(size(ts))];
                B = regress(ys,X);
                slope = B(1);
                key.fepsp_slope = slope;
                yi = X*B;
                plot(X(:,1)*1e6,yi,'m*')
                plot([X(1,1) X(1,1)]*1e6,ylim,'k--')
                plot([X(end,1) X(end,1)]*1e6,ylim,'k--')
                sv = find(sind);
                key.slope_onset = t(sv(1));
                %
                egmu = mean(egSlopes);
                egSign = sign(egmu);
                slopeSign = sign(slope);
                %                 egstd = std(egSlopes);
                
                
                if (egSign ~= slopeSign)
                    useExample = false;
                    flippedSlope = true;
                else
                    flippedSlope = false;
                    %                     if (slope > (egmu+15*egstd)) || (slope < (egmu-15*egstd)) % something is not right
                    %                         useExample = false;
                    %                     else
                    satisfied = true;
                    useExample = true;
                    %                     end
                end
                if flippedSlope
                    redoit = input('Is the slope ok? If yes, press ENTER, if no, press any other key','s');
                    if isempty(redoit)
                        satisfied = true;
                    else
                        satisfied = false;
                    end
                end
            end
            self.insert(key)
            pause(0.1)
        end
    end
    
end
