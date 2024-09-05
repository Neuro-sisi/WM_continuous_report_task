function [deg_matrix,deg_matrix_label] = recuevalid_v1_getTrialParams_60valid
% 26 June, 2023
% retrocue-validity-60% valid cue
% 250 trials in total

% set trial number
trial_Num = 250; 
tNumRcueV = 0.6*trial_Num; % retrocue-valid
tNumRcueINV = 0.4*trial_Num; % retrocue-invalid


% set target degree
tar_deg_pool = [1:1:180];
for t = 1:trial_Num
    tardeg_list(t,:) = randsample(tar_deg_pool,2);
end
clear t

% set target color type: 1-orange, 2-blue
tarcol_type = [1; 2;]; 
tarcol_list(:,1) = repmat(tarcol_type,floor(trial_Num/length(tarcol_type)),1);
tarcol_list(trial_Num,1) = randperm(2,1);
tarcol_list(:,2) = 3-tarcol_list(:,1);

% set cue type: 1-retro-valid, 2-retro-invalid
cuetype_list = zeros(trial_Num,1);
cuetype_list(1:tNumRcueV,1) = 1;
cuetype_list(1+tNumRcueV:trial_Num,1) = 2;


% set cue side: 1-left, 2-right
cueside_type = [1*ones(length(tarcol_type),1); 2*ones(length(tarcol_type),1);]; % 1-left; 2-right
% cueside_list = repmat(cueside_type,trial_Num/length(cueside_type),1);
% trial number can't be devided by 4
cueside_list = repmat(cueside_type,floor(trial_Num/length(cueside_type)),1);
cueside_list(trial_Num-1:trial_Num,1) = [1;2;];


% get cue color: 1-orange, 2-blue
cuecol_list = zeros(trial_Num,1); 
for t = 1:trial_Num
    if t < tNumRcueV+1 % valid cue
        cuecol_list(t,1) = tarcol_list(t,cueside_list(t,1));
    elseif t > tNumRcueV && t < tNumRcueV+tNumRcueINV+1 % invalid cue
        cuecol_list(t,1) = tarcol_list(t,3-cueside_list(t,1));
    end
end
clear t


% get probed target degree
for t = 1:trial_Num
    probe_tardeg_list(t,1) = tardeg_list(t,cueside_list(t,1)); % both for retro & neutral cue
end
clear t

% get probed target color
for t = 1:trial_Num
    probe_tarcol_list(t,1) = tarcol_list(t,cueside_list(t,1));
end
clear t


% shuffle all trials
trial_seq_raw = [1:1:trial_Num]';

deg_matrix_raw = [trial_seq_raw tardeg_list tarcol_list cuetype_list cueside_list cuecol_list probe_tardeg_list probe_tarcol_list];

deg_matrix = [trial_seq_raw shuffle(deg_matrix_raw,1)];

deg_matrix_label = {'1-trial_No'; '2-trial_seq_raw'; '3-4-tardeg_list'; '5-6-tarcol_list'; '7-cuetype_list1retroValid2retroInvalid3neutral'; '8-cueside_list1left2right'; '9-cuecol_list1oran2blue3black'; '10-probe_tardeg_list'; '11-probe_tarcol_list';};

end






