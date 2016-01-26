%{
cstim.MeanCurr (computed) # my newest table
-> acq.Ephys
event_ts       : bigint       # event timestamp
-----
microamps_mean: double # peak current averaged across trials
%}

classdef MeanCurr < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cstim.MeanCurr');
        popRel = acq.Ephys & cstim.Current
    end
    
    methods
        function self = MeanCurr(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            % Get all peak current levels
            dk = fetch(cstim.Current(key),'*');
            am = [dk.microamps_max];
            figure
            plot(am,'k*','markerfacecolor','k')
            title('pick the lower bound')
            grid on
            [~,lb] = ginput();
            title('pick the upper bound')
            [~,ub] = ginput();
            n = length(lb);
            assert(n==length(ub),'number of points in upper and lower bounds not same')
            for i = 1:n
                % Find the keys that are within the range                
                ind = find(am > lb(i) & am < ub(i));
                sam = am(ind);
                mn = round(mean(sam));
                for j = 1:length(ind)
                    sk = dk(ind(j));
                    sk.microamps_mean = mn;
                    sk = rmfield(sk,{'microamps_max','current_ts'});
                    self.insert(sk)
                end
            end            
        end
    end    
end