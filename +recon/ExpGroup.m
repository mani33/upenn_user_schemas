%{
recon.ExpGroup (manual) # memory reconsolidation ltp associated with IA

-> acq.Ephys
-----
exp_id : int unsigned # experiment id
exp_type: enum('io','day1_preacq_resp','day2_preacq_resp','day2_postacq_resp','day3_prerecall_resp','day3_postrecall_resp','day4_baseline') # what was exactly done? baseline? LTP induction etc

%}

classdef ExpGroup < dj.Relvar   
    properties(Constant)
        table = dj.Table('recon.ExpGroup');
    end    
    methods 
        function self = ExpGroup(varargin)
            self.restrict(varargin{:})
        end
    end
end