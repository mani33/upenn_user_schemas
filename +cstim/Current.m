%{
cstim.Current (computed) # Values of stimulation current used

-> acq.Events
-> acq.Ephys
---
microamps_max       : double         # peak level of current actually delivered
current_ts=CURRENT_TIMESTAMP: timestamp             # automatic timestamp. Do not edit
%}

classdef Current < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cstim.Current');
        popRel = (acq.Ephys*acq.Events('event_ttl = 128')) & acq.Resistors & cstim.StimTrace
    end
    
    
    methods
        function self = Current(varargin)
            self.restrict(varargin{:})
        end
    end
    methods (Access=protected)
        function makeTuples(self, key)
            y = fetch1(cstim.StimTrace(key)*acq.Ephys,'y');
            % use V = IR to convert recorded volts to microamps
            key.microamps_max = 1e6 * max(abs(y))/fetch1(acq.Resistors(key),'ohms');
            self.insert(key)
        end
    end
end
