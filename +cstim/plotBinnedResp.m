function [b_traces,bin_cen_t,trace_t] = plotBinnedResp( key, chan, binwidth, varargin )
%PLOTBINNEDRESP Plot epsp response averaged over a small time window
%   Detailed explanation goes here
% Inputs:
% key - database key that restricts the fepsp trace tuples
% chan - channel number
% binwidth - in minutes, to bin the responses
% Outputs:
% t - time in milli sec
% traces - raw averaged traces
% Mani Subramaniyan 2016-04-05
args.trace_bounds = [-5 20];
args.start_col = [0 0 0];
[et,y,t] = fetchn(cstim.FpRespTrace(key,sprintf('chan_num = %u',chan)),'event_ts','y','t');
et = double(et);
[et,ind] = sort(et);
y = y(ind);
% All t's are pretty puch the same. so just pick one.
t = t{1}*1e-3; % convert to ms
tsInd = t >= args.trace_bounds(1) &  t <= args.trace_bounds(2);
trace_t = t(tsInd);
% Select the trace between given time points
tr = cellfun(@(y) y(tsInd), y, 'uni',false);
msz = min(cellfun(@length, tr));
tr = cellfun(@(x) x(1:msz), tr,'uni', false);
% Now, format time into minutes
et = format_time(et);
[b_traces,bin_cen_t] = bin_traces(tr,et,binwidth);

% Plot traces
cm = colormap('winter');
sz = size(cm,1);
nb = length(bin_cen_t);
np = round(sz/nb);

for i = 1:nb
    cc = cm((i-1)*np+1,:);
    plot(trace_t,b_traces{i},'color',cc)
    hold on
end

