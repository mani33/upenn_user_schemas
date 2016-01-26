%{
pstim.PulseWidth (computed) # my newest table
->pstim.Pulses
-----
light_pulse_width: double # width of pulse in micro seconds
%}

classdef PulseWidth < dj.Relvar
	methods
		function self = PulseWidth(varargin)
			self.restrict(varargin{:})
		end
	end

	methods

		function makeTuples(self, key)
		%!!! compute missing fields for key here
			self.insert(key)
		end
	end

end