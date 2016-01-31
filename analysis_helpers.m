%%
for i = 1:4
    x = fetchn(cstim.FpRespTrace(key,sprintf('chan_num = %d',11+i)),'y');
    x = cellfun(@(x) x(1:2470),x,'uni',false);
    xx = [x{:}];
    subplot(2,2,i)
    plot(mean(xx,2))
end
shg

%% Find the number of pulses before LTP induction in the combined light and ltp induction sessions
close all
it = fetchn(acq.Events(key,'event_ttl = 128'),'event_ts');
fprintf('total pulses: %u\n',length(it))
x = diff(it);
plot(it,ones(size(it)),'k*')
ind = find(x < 10000000,1);
hold on
plot(it(ind-1),1,'rO')
title('last baseline pulse shown in red circle')
fprintf('pulses before LTP induction: %u\n',ind-1)