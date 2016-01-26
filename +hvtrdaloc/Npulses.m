%{
hvtrdaloc.Npulses (manual) # number of pulses given for baseline and LTP
-> acq.Ephys
-----
prehv = 0: smallint unsigned # num of pulses given  before light stimulation
posthv = 0: smallint unsigned   # num of pulses given after light
%}

classdef Npulses < dj.Relvar   
    properties(Constant)
        table = dj.Table('hvtrdaloc.Npulses');
    end    
    methods 
        function self = Npulses(varargin)
            self.restrict(varargin{:})
        end
    end
end
