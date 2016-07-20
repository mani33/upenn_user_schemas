%{
recon.Events (manual) # events during, before and after fear conditioning
-> acq.Ephys
event_ts       : bigint       # event timestamp
event_ttl      : double # value of the TTL pulse
-----
io = 0: boolean # is it for input-output curve?
day1_preacq_resp = 0: boolean # is it for input-output curve?
day2_preacq_resp = 0: boolean # is the event before acquiring learning?
day2_postacq_resp = 0: boolean  # is the event after acquiring learning?
day3_prerecall_resp = 0: boolean  # is the event before memory recall?
day3_postrecall_resp = 0: boolean  # is the event after memory recall?
day4_baseline = 0: boolean  # is the event the day after memory recall?
%}
% Mani Subramaniyan
% 2016-07-18

classdef Events < dj.Relvar 
    properties(Constant)
        table = dj.Table('recon.Events');
    end
    methods
        function self = Events(varargin)
            self.restrict(varargin{:})
        end
    end
end

