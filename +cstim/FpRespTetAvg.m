%{
cstim.FpRespTetAvg (computed) # my newest table

-> cont.TetChan
-> acq.Events
-> cont.FpParams
-> cstim.PeriEventTimes

-----
y       : longblob         # voltage trace of the field potential responses
t       : longblob         # time points relative to event onset
%}

classdef FpRespTetAvg < dj.Relvar & dj.AutoPopulate
    
    properties(Constant)
        table = dj.Table('cstim.FpRespTetAvg')
        popRel = (cont.TetChan *(acq.Events('event_ttl = 128') * cstim.PeriEventTimes * cont.FpParams)) & cstim.FpRespTrace
    end
    
    methods
        function self = FpRespTetAvg(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods(Access=protected)
        
        function makeTuples(self, key)
            %!!! compute missing fields for key here
            
            chan = fetch1(cont.TetChan(key),'chan_nums');
            cn = sprintf('%u,',chan);
            cn = ['chan_num in (' cn(1:end-1) ')'];
            rel = cstim.FpRespTrace(key,cn);
            if count(rel)==4
                [y,t] = fetchn(rel,'y','t');
                mn = min(cellfun(@length,y));
                yy = cellfun(@(x) x(1:mn),y,'uni',0);
                key.t = cellfun(@(x) x(1:mn),t(1),'uni',0);
                key.y = mean(cat(2,yy{:}),2);                
                self.insert(key)
            end
        end
        
    end
    
end