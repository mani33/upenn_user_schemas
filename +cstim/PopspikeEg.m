%{
cstim.PopspikeEg (computed) # slope computation window onset and offset
-> cont.Chan
-> cstim.SmoothMethods
-----
popspike_bounds: tinyblob # beginning and end time of each hill on either side of the popspike
popspike_height: tinyblob # height of popspike

%}

classdef PopspikeEg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.PopspikeEg')
        popRel = (cont.Chan & cstim.FpRespTrace)*cstim.SmoothMethods% !!! update the populate relation
    end
    
    methods
        function self = PopspikeEg(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            % Randomly pick 5 keys and set example
            nKey = 10;
            [ttd,yyd] = fetchn(cstim.FpRespTrace(key),'t','y');
            n = length(ttd);
            tb = zeros(nKey,4);
            ph = zeros(1,nKey);
            Fs = fetch1(cont.Fp(key),'sampling_rate');
            cc = 1;
            gw = cstim.getGausswin(0.5,1000*1/Fs);
            smn = key.smooth_method_num;
            while cc <= nKey
                rp = ceil(n*rand);
                y = zscore(yyd{rp});
                t = ttd{rp};
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
                
                yso = mconv(y,gw);
                t = t/1000;
                clf
                
                plot(t,y,'k')
                hold all
                plot(t,yso,'r')
                
                xlim([-5 50])
                st = std(yso);
                ylim([min(yso) max(yso)]+st*[-0.5 0.5])
                % Ginput the start and end points to calculate slope
                title('Click the beginning and end each hill on either side of the popspike')
                [tb(cc,:),~] = ginput(4);
                [ph(cc),tt,yy,ypi] = get_popspike_height(t,fy,tb(cc,:),'auto',false);
                
                
                hold on
                col = rand(1,3);
                plot(tt(2),ypi,'*','color',col)
                plot(tt(2),yy(2),'*','color',col)
                plot(tt([1 3]),yy([1 3]),'k-')
                plot([tt(2) tt(2)],[yy(2) ypi],'color',col,'linewidth',4)
                pause(0.2)
                
                % If you want to skip the trace, hit any key other than
                % ENTER
                redoit = input('Is the slope ok? If yes, press ENTER, if no, press any other key','s');
                if isempty(redoit)
                    cc = cc + 1;
                end
            end
            
            key.popspike_height = median(ph);
            key.popspike_bounds = median(tb,1);
            %!!! compute missing fields for key here
            self.insert(key)
        end
    end
    
end