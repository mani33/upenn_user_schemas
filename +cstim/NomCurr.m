%{
cstim.NomCurr (computed) # nomial curr vals set in stim isolator knob

-> acq.Ephys
event_ts       : bigint       # event timestamp
-----
microamps: double # current value set in the knob by experimenter
%}

classdef NomCurr < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cstim.NomCurr');
        popRel = acq.Ephys & acq.Events('event_ttl = 128')
    end
    
    methods
        function self = NomCurr(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        function makeTuples(self, key)
            
            keys = fetch(acq.Events(key,'event_ttl = 128'));
            et = fetch1(acq.Ephys(key),'ephys_start_time');
            % Get matlab file path
            fp = fullfile(fetch1(acq.Ephys(key),'ephys_path'),'current_levels_uamps.mat');
            load(fp)
            iocurr = [data.io_current_levels{:}];
            curr = [iocurr(:)' data.test_pulse_curr];
            assert(length(keys)==length(curr),'Current levels not matching with number of stim events')
            for ik = 1:length(keys)
                tup = keys(ik);
                tup.ephys_start_time = et;
                tup.microamps = curr(ik);
                self.insert(tup)
            end
            %            if nc==1 % This indicates that it is not an input/output testing session
            %               for tup = keys'
            %                   tup.ephys_start_time = et;
            %                   tup.microamps = c;
            %                   self.insert(tup)
            %               end
            %            else
            %                % It is an I/O session
            %                cc = [c{:}];
            %                assert(length(keys)==length(cc),'Current levels not matching with number of stim events')
            %                ts = double([keys.event_ts]);
            %                assert(issorted(ts),'events are not in the correct temporal order')
            %                for ik = 1:length(keys)
            %                    tup = keys(ik);
            %                    tup.ephys_start_time = et;
            %                    tup.microamps = cc(ik);
            %                    self.insert(tup)
            %                end
            %            end
        end
    end
end