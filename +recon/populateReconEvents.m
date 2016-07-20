function populateReconEvents(ephys_keys)
% Mani 2016-04-04
%% Populate recon Events table
% event_ts       : bigint       # event timestamp
% event_ttl      : double # value of the TTL pulse
% -----
% io = 0: boolean # is it for input-output curve?
% day1_preacq_resp = 0: boolean # is it for input-output curve?
% day2_preacq_resp = 0: boolean # is the event before acquiring learning?
% day2_postacq_resp = 0: boolean  # is the event after acquiring learning?
% day3_prerecall_resp = 0: boolean  # is the event before memory recall?
% day3_postrecall_resp = 0
% day4_baseline = 0;
nk = length(ephys_keys);
for ik = 1:nk
    ephys_key = ephys_keys(ik);
    ev = fetch(acq.Events(ephys_key,'event_ttl = 128')*acq.Ephys(ephys_key));
    et = double([ev.event_ts]);
    [~,ind] = sort(et);
    ev = ev(ind);
    c = 0;
    n = length(et);
    exp_type = fetch1(recon.ExpGroup(ephys_key),'exp_type');
    fprintf('Number of events found = %u\n',n)
    for i = 1:n
        c = c + 1;
        tup = ev(c);
        tup.(exp_type) = 1;
        insert(recon.Events,tup)
    end
end
