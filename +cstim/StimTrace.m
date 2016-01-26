%{
cstim.StimTrace (computed) # Trace of the stimulus channel

-> acq.Events
-> cstim.PeriEventTimes
---
y       : blob         # voltage trace of the stimulus channel

%}

classdef StimTrace < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cstim.StimTrace');
        popRel = (acq.Events('event_ttl = 128'))*cstim.PeriEventTimes 
    end
    
    
    methods
        function self = StimTrace(varargin)
            self.restrict(varargin{:})
        end
    end
    methods (Access=protected)
        function makeTuples(self, key)
            fp = fetch1(acq.Sessions(key),'session_path');
            fn = fullfile(fp,'stim.ncs');
            br = baseReaderNeuralynx(fn);
            ev = double(fetchn(acq.Events(key,'event_ttl = 128'),'event_ts'));
            n = length(ev);
            for i = 1:n
                tuple = key;
                % key.pre_event is in microseconds
                t = ev(i) + [-key.pre_curr key.post_curr];
                tuple.y = br(double(t),'t_range');
                self.insert(tuple)
            end
            close(br)
        end
    end
end