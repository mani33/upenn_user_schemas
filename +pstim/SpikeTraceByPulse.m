%{
pstim.SpikeTraceByPulse (computed)# photo stimulated trace of a light pulse
-> pstim.Pulses
-> pstim.PeriEventTimes
-> cont.SpikeTrace
-----
y: longblob # spike voltage trace around a given light pulse
%}

classdef SpikeTraceByPulse < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('pstim.SpikeTraceByPulse')
        popRel = (pstim.Pulses * cont.SpikeTrace) * pstim.PeriEventTimes
    end
    
    methods
        function self = SpikeTraceByPulse(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, keys)
            for key = keys'
                [on,off] = fetchn(pstim.Pulses(key),'light_pulse_on','light_pulse_off');
                fn = fetch1(cont.SpikeTrace(key),'spike_tr_file');
                fn = strrep(fn,'y:','C:');
                br = baseReaderNeuralynx(fn);
                ti = [-key.pre_light key.post_light] + [on off];
                key.y = br(double(ti),'t_range');
                self.insert(key)
            end
        end
    end    
end