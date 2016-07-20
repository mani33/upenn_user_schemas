% Populate ExpGroup table for IA reconsolidation LTP experiments
%%
[ids, folders] = xlsread('C:\Users\Mani\Dropbox\reconsolidation_sessions.xlsx','A1:G9');
folders = folders(:,2:end);
expTypes = folders(1,:);
sessions = folders(2:end,:);

nMice = size(sessions,1);
nExp = length(expTypes);

for i = 1:nMice
    for iExp = 1:nExp
        sess = sessions{i,iExp};
        k = fetch(acq.Ephys(acq.Sessions(sprintf('session_path like "%%%s%%"',sess))));
        k.exp_id = i;
        k.exp_type = expTypes{iExp};
        insert(recon.ExpGroup,k)
    end
end
