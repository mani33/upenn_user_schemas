%{
ltp.ExpGroup (manual) # assign day to experiment relative ltp induction
-> acq.Ephys
-----

%}

classdef ExpGroup < dj.Relvar   
    properties(Constant)
        table = dj.Table('ltp.ExpGroup');
    end    
    methods 
        function self = ExpGroup(varargin)
            self.restrict(varargin{:})
        end
    end
end
