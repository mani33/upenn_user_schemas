%{
ltp.ExpGroup (manual) # assign day to experiment relative ltp induction
-> acq.Ephys
-----
exp_id : int unsigned # experiment id
day: int # which day relative to ltp induction eg: day -1,0,1,2 

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
