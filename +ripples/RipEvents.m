%{
cont.RipEvents (computed) # spike trace filtered usually between 600-6000Hz

->acq.Ephys
->cont.RipParams
->cont.Chan
---
peak   : double # peak time
begin : double # rip time
end: double # peak time
y: double # peak time

%}

classdef RipEvents < dj.Relvar & dj.AutoPopulate
    properties(Constant)
        table = dj.Table('cont.RipEvents');
        popRel = acq.Ephys * cont.RipParams * cont.Chan;
    end
    
    methods
        function self = RipEvents(varargin)
            self.restrict(varargin{:})
        end
    end
    
    methods (Access=protected)
        function makeTuples(self, key)
            tuple = key;
            sourceFolder = fetch1(acq.Ephys(key), 'ephys_path');
            chName = fetch1(cont.Chan(key),'chan_name');
            cscFile = fullfile(sourceFolder,[chName,'.ncs']);
            reader = baseReaderNeuralynx(cscFile);
br = getBaseReader(reader);
Fs = getSamplingRate(br);

% create packetReader for data access
filter = filterFactory.createBandpass(key.cutoff_low-key.transband_low,...
    key.cutoff_low,key.cutoff_high-key.transband_high, ...
    key.cutoff_high, Fs);
fr = filteredReader(reader, filter);



% Limit memory usage
blockSize = 1e6;
pr = packetReader(fr, 1, 'stride', blockSize);
nPack = length(pr);
for p = 1:nPack
    % read filtered data and write it.
    x = pr(p);
    nanInd = find(isnan(x));
    nbNan = length(nanInd);
    if nbNan > 0
        error('%u NaN''s found\n',nbNan)
    end
    % write data to disc
    if p == 1
        [dataSet, written] = seedDataset(fp,x);
    else
        written = written + extendDataset(dataSet, x, written);
    end
    
    displayProgress(p,nPack)
end

            
            
            
            self.insert(tuple);
        end
    end
end