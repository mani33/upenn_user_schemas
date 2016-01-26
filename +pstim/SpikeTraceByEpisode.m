%{
pstim.SpikeTraceByEpisode (computed) # my newest table
-> pstim.Episodes
-> pstim.PeriEventTimes
-> cont.SpikeTrace
-----
y       : longblob         # voltage trace of the spike responses
%}

classdef SpikeTraceByEpisode < dj.Relvar & dj.AutoPopulate

	properties(Constant)
		table = dj.Table('pstim.SpikeTraceByEpisode')
		popRel = (pstim.Episodes * cont.SpikeTrace) * pstim.PeriEventTimes
	end

	methods
		function self = SpikeTraceByEpisode(varargin)
			self.restrict(varargin{:})
		end
	end
    
    methods(Access=protected)
        
        function makeTuples(self, keys)
            %!!! compute missing fields for key here
            for key = keys'
                [on,off] = fetchn(pstim.Episodes(key),'episode_on','episode_off');
                fn = fetch1(cont.SpikeTrace(key),'spike_tr_file');
                fn = strrep(fn,'y:','C:');
                br = baseReaderNeuralynx(fn);                
                ti = [-key.pre_light key.post_light] + [on off];
                key.y = br(double(ti),'t_range');
                self.insert(key)
            end
        end
    end

end