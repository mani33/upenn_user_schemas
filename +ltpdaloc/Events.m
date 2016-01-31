%{
ltpdaloc.Events (computed) # events during, before and after ltp induction
-> acq.Ephys
event_ts       : bigint       # event timestamp
event_ttl      : double # value of the TTL pulse
-----
io = 0: boolean # is it for input-output curve?
preltp = 0: boolean # is the event before LTP induction?
ltpind = 0: boolean  # is the event during LTP induction?
postltp = 0: boolean  # is the event after LTP induction?

%}
% Mani Subramaniyan
% 2015-07-08

classdef Events < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('ltpdaloc.Events');
        popRel = ltpdaloc.ExpGroup & ltpdaloc.Npulses
    end
    methods
        function self = Events(varargin)
            self.restrict(varargin{:})
        end
    end
    methods(Access=protected)
        function makeTuples(self, key)
            np = fetch(ltpdaloc.Npulses(key),'*');
            ev = fetch(acq.Events(key,'event_ttl = 128')*acq.Ephys(key));
            et = double([ev.event_ts]);
            [~,ind] = sort(et);
            ev = ev(ind);
            c = 0;
            if np.io > 0
                for i = 1:np.io
                    c = c + 1;
                    tup = ev(c);
                    tup.io = 1;
                    self.insert(tup)
                end
            end
            
            if np.preltp > 0
                for i = 1:np.preltp
                    c = c+1;
                    tup = ev(c);
                    tup.preltp = 1;
                    self.insert(tup)
                end
            end
            
            if np.ltpind > 0
                for i = 1:np.ltpind
                    c = c+1;
                    tup = ev(c);
                    tup.ltpind = 1;
                    self.insert(tup)
                end
            end
            
            if np.postltp > 0
                for i = 1:np.postltp
                    c = c+1;
                    tup = ev(c);
                    tup.postltp = 1;
                    self.insert(tup)
                end
            end            
        end
    end
end