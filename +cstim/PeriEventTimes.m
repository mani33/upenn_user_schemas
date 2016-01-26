%{
cstim.PeriEventTimes (manual) # pre and post event times for picking traces

pre_curr: bigint              # pre event time in microsec
post_curr: bigint              # post event time in microsec
---

%}

classdef PeriEventTimes < dj.Relvar
    properties(Constant)
        table = dj.Table('cstim.PeriEventTimes');
    end
    
    methods
        function self = PeriEventTimes(varargin)
            self.restrict(varargin{:})
        end
    end
end