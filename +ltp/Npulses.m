%{
ltp.Npulses (manual) # number of pulses given for baseline and LTP
-> acq.Ephys
-----
io = 0: smallint unsigned # number of pulses given for i/o curve
preltp = 0: smallint unsigned # num of pulses given  before LTP induction
ltpind = 0: smallint unsigned   # num of pulses given during LTP induction
postltp = 0: smallint unsigned   # num of pulses given after after LTP
%}

classdef Npulses < dj.Relvar   
    properties(Constant)
        table = dj.Table('ltp.Npulses');
    end    
    methods 
        function self = Npulses(varargin)
            self.restrict(varargin{:})
        end
    end
end
