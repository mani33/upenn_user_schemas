%{
pstim.Episodes (computed) # episodes of light stim(eg.20Hz stim for 1s)

-> acq.Ephys
episode_num: smallint unsigned # episode number
---
episode_on:  bigint #  episode start timestamp
episode_off: bigint # episode end timestamp

%}

classdef Episodes < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('pstim.Episodes');
%         popRel = acq.Ephys & acq.Events('event_ttl = 128') & acq.LightPulseFreq
        popRel = acq.Ephys & acq.Events('event_ttl = 1') & acq.LightPulseFreq
    end
    
    methods
        function self = Episodes(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            % Compute episode onset and offset times. We just make an
            % assumption that episodes are separated by at least 2 sec and
            et = fetchn(acq.Events(key,'event_ttl = 1'),'event_ts');
            % We will just walk through pairs of sequential events and see
            % how far apart they are. If far apart, it might be that an
            % episode starts.
            
            % Time is in micro sec
            
            % Estimate pulse duration
            on = fetchn(acq.Events(key,'event_ttl = 1 and event_port = 2'),'event_ts');
            off = fetchn(acq.Events(key,'event_ttl = 0 and event_port = 2'),'event_ts');
            assert(length(on)==length(off),'light on and off timestamps are not paired')
            pd = max(off-on);
            
            n = length(et);
            assert(n > 1,'At least two events are required')
            d = diff(et);
            tmp = struct;
            hz = fetch1(acq.LightPulseFreq(key),'light_pulse_freq');
            max_interpulse_int = 1e6*(1/hz);
            c = 0;
            epi_started = false;
            for i = 1:n-1
                di = d(i);
                if di < (1.1*max_interpulse_int)% episode starts
                    if ~epi_started
                    c = c + 1;
                    tmp.epi_start(c) = et(i);
                    epi_started = true;
                    end
                    inepisode = true;
                else
                    inepisode = false;
                end
                if (epi_started && ~inepisode)
                    tmp.epi_end(c) = et(i)+max_interpulse_int + pd;
                    epi_started = false;
                end
                if (inepisode && i==(n-1))
                    tmp.epi_end(c) = et(i+1)+max_interpulse_int + pd;
                    epi_started = false;
                end
            end
            ne = length(tmp.epi_start);
            for i = 1:ne
                tu = key;
                tu.episode_num = i;
                tu.episode_on = double(tmp.epi_start(i));
                tu.episode_off = double(tmp.epi_end(i));
                self.insert(tu)
            end
        end
    end
end