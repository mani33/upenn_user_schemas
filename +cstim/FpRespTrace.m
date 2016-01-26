%{
cstim.FpRespTrace (computed) # Trace of the field potential response trace

-> acq.Events
-> cont.Fp
-> cstim.PeriEventTimes
---
y       : longblob         # voltage trace of the field potential responses
t       : longblob         # time points relative to event onset
%}

classdef FpRespTrace < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cstim.FpRespTrace');
        popRel = cont.Fp * acq.Events('event_ttl = 128') * cstim.PeriEventTimes
    end
    
    methods
        function self = FpRespTrace(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            fn = fetch1(cont.Fp(key),'fp_file');
            fn = strrep(fn,'y:','C:');
            br = baseReaderNeuralynx(fn);           
            tuple = key;
            t = double(key.event_ts + [-key.pre_curr key.post_curr]);
            tuple.y = br(t,'t_range');
            si = getSampleIndex(br,t);
            tuple.t = br(si(1):si(end),'t')'- double(key.event_ts);
            self.insert(tuple)
            close(br)
        end
    end
end