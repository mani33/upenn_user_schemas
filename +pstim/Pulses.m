%{
pstim.Pulses (computed) # individual pulse onset offset times

->pstim.Episodes
light_pulse_num: smallint unsigned # pulse number within an episode
-----
light_pulse_on: bigint # pulse onset time
light_pulse_off: bigint # pulse offset time

%}

classdef Pulses < dj.Relvar & dj.AutoPopulate

	properties(Constant)
        table = dj.Table('pstim.Pulses');
		popRel = pstim.Episodes  % !!! update the populate relation
	end

	methods
		function self = Pulses(varargin)
			self.restrict(varargin{:})
		end
	end

	methods(Access=protected)

		function makeTuples(self, key)
            % find individual light pulses within an episode
            ed = fetch(pstim.Episodes(key),'*');
            [ts,ttl] = fetchn(acq.Events(key,sprintf('event_ts >= %u and event_ts <= %u and event_port = 2',ed.episode_on, ed.episode_off)),'event_ts','event_ttl');
            % Assuming ttl 1 for on and ttl 0 for off
            on = ts(ttl==1);
            off = ts(ttl==0);
            assert((length(on)==length(off)),'light on and off time stamps are messed up')
            % Make sure that we match only the light pulse on with light
            % pulse off because the electrical pulse off also has 0 as ttl
            % value.
%             if length(on)< length(off)
%                 % Pure hack
%                 off = off(2:end);
%                 % Make sure that you removed the intended timestamp
%                 u = unique(diff(off));
%                 if length(u)>1
%                     ud = diff(u);
%                     assert((max(ud)/max(u)) < 0.001, 'you removed the wrong timestamp')
%                 end
%             end
            for i = 1:length(on)
                tu1 = key;
                tu1.light_pulse_num = i;
                tu2 = tu1;
                tu1.light_pulse_on = on(i);
                tu1.light_pulse_off = off(i);
                self.insert(tu1)
                tu2.light_pulse_width = off(i)-on(i);
                makeTuples(pstim.PulseWidth,tu2)
            end
        end
    end

end