%{
pstim.RawTraceByPulse (computed) # raw data around each light pulse
-> pstim.Pulses
-> pstim.PeriEventTimes
-> cont.Chan
-----
y       : longblob         # raw voltage trace in Volts

%}

classdef RawTraceByPulse < dj.Relvar & dj.AutoPopulate

	properties(Constant)
		table = dj.Table('pstim.RawTraceByPulse')
		popRel = (pstim.Pulses * cont.Chan) * pstim.PeriEventTimes
	end

	methods
		function self = RawTraceByPulse(varargin)
			self.restrict(varargin{:})
		end
	end

	methods(Access=protected)

		function makeTuples(self, keys)
            for key = keys'
                [on,off] = fetchn(pstim.Pulses(key),'light_pulse_on','light_pulse_off');
                fn = fetch1(cont.Chan(key),'chan_filename');
                br = baseReaderNeuralynx(fn);
                ti = [-key.pre_light key.post_light] + [on off];
                key.y = br(double(ti),'t_range');
                self.insert(key)
            end
        end
	end

end