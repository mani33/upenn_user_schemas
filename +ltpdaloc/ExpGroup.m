%{
ltpdaloc.ExpGroup (manual) # assign day to experiment 
-> acq.Ephys
-----
exp_id : int unsigned # experiment id
exp_type: enum('baseline1','ltp','baseline2','ltphv','baseline3') # what was exactly done? baseline? LTP induction etc

%}

classdef ExpGroup < dj.Relvar   
    properties(Constant)
        table = dj.Table('ltpdaloc.ExpGroup');
    end    
    methods 
        function self = ExpGroup(varargin)
            self.restrict(varargin{:})
        end
    end
end
