%{
pstim.PeriEventTimes (manual) # pre and post event times for picking traces


pre_light: bigint              # pre event time in microsec
post_light: bigint              # post event time in microsec
---


%}

classdef PeriEventTimes < dj.Relvar
    properties(Constant)
        table = dj.Table('pstim.PeriEventTimes');
    end
    
    methods
        function self = PeriEventTimes(varargin)
            self.restrict(varargin{:})
        end
    end
end