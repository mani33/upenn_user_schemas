%{
pstim.FpByPulse (computed) # my newest table
-> pstim.Pulses
-> pstim.PeriEventTimes
-> cont.Fp
-----
y: longblob # field potential trace around a given light pulse
%}

classdef FpByPulse < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('pstim.FpByPulse')
        popRel = (pstim.Pulses * cont.Fp) * pstim.PeriEventTimes
    end
    
    methods
        function self = FpByPulse(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, keys)
            for key = keys'
                [on,off] = fetchn(pstim.Pulses(key),'light_pulse_on','light_pulse_off');
                fn = fetch1(cont.Fp(key),'fp_file');
                fn = strrep(fn,'y:','C:');
                br = baseReaderNeuralynx(fn);
                ti = [-key.pre_light key.post_light] + [on off];
                key.y = br(double(ti),'t_range');
                self.insert(key)
            end
        end
    end
    
end