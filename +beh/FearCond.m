%{
beh.FearCond (manual) # my newest table
-> acq.Animals
-----
shock_intensity: double # shock intensity in mA
percent_freezing: double # freezing level
%}

classdef FearCond < dj.Relvar
     properties(Constant)
        table = dj.Table('beh.FearCond');
    end
    
    methods
        function self = FearCond(varargin)
            self.restrict(varargin{:})
        end
    end
end