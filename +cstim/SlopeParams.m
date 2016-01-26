%{
cstim.SlopeParams (manual) # params for computing fepsp slopes

slope_win = 500: double  # window in microsec for computing slope
---

%}

classdef SlopeParams < dj.Relvar
    properties(Constant)
        table = dj.Table('cstim.SlopeParams');
    end
    
    methods
        function self = SlopeParams(varargin)
            self.restrict(varargin{:})
        end
    end
end