% analyze behav
subjectNum = 3;
NUM_TASK_RUNS = 3;
% orientation session
SETUP = 1; % stimulus assignment 1
FAMILIARIZE = SETUP + 1; % rsvp study learn associates 2
TOCRITERION1 = FAMILIARIZE + 1; % rsvp train to critereon 3
MOT_PRACTICE = TOCRITERION1 + 1;%4
MOT_PREP = MOT_PRACTICE + 1;%5

% day 1
FAMILIARIZE2 = MOT_PREP + 2; % rsvp study learn associates %7
TOCRITERION2 = FAMILIARIZE2 + 1; % rsvp train to critereon
TOCRITERION2_REP = TOCRITERION2 + 1;
RSVP = TOCRITERION2_REP + 1; % rsvp train to critereon

% day 2
STIM_REFRESH = RSVP + 2; %12
SCAN_PREP = STIM_REFRESH + 1; %13
MOT_PRACTICE2 = SCAN_PREP + 1; %14
RECALL_PRACTICE = MOT_PRACTICE2 + 1;
%SCAN_PREP = RECALL_PRACTICE + 1;
RSVP2 = RECALL_PRACTICE + 1; % rsvp train to critereon
FAMILIARIZE3 = RSVP2 + 1; % rsvp study learn associates
TOCRITERION3 = FAMILIARIZE3 + 1; % rsvp train to critereon
MOT_LOCALIZER = TOCRITERION3 + 1; % category classification
RECALL1 = MOT_LOCALIZER + 1;
counter = RECALL1 + 1; MOT = [];
for i=1:NUM_TASK_RUNS
    MOT{i} = counter;
    counter = counter + 1;
end
RECALL2 = MOT{end} + 1; % post-scan rsvp memory test
DESCRIPTION = RECALL2 + 1; %26
ASSOCIATES = DESCRIPTION + 1; %27
base_path = [fileparts(which('mot_realtime04MB.m')) filesep];

behavioral_dir = [base_path 'BehavioralData/' num2str(subjectNum) '/'];

%% look at descriptive ratings
recallSession = [RECALL1 RECALL2];
for i = 1:2
    r = dir(fullfile(behavioral_dir, ['EK' num2str(recallSession(i)) '_' 'SUB'  '*.mat']));
    r = load(fullfile(behavioral_dir,r(end).name));
    trials = table2cell(r.datastruct.trials);
    stimID = cell2mat(trials(:,8));
    cond = cell2mat(trials(:,9));
    rating = cell2mat(trials(:,12));
    easy = find(cond==2);
    hard = find(cond==1);
    easy_score(i) = nanmean(rating(easy));
    hard_score(i) = nanmean(rating(hard));
end

%% look at AB' d' ratings
% YS suggestion: look at the difference between presented first and
% presented after if related--so if getting right once will mess up getting
% right the other time
r = dir(fullfile(behavioral_dir, ['_RECOG' '*.mat']));
r = load(fullfile(behavioral_dir,r(end).name));
trials = table2cell(r.datastruct.trials);
stimID = cell2mat(trials(:,8));
cond = cell2mat(trials(:,9));
acc = cell2mat(trials(:,11));
rt = cell2mat(trials(:,13));

easy = find(cond==2);
hard = find(cond==1);
easyRT = nanmedian(rt(easy));
hardRT = nanmedian(rt(hard));
% should make sure it's not influenced by order for RT******