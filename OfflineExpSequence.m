%%so now this would be all the commands you would want to do ONLY for
%%fmri session
%first these are all the session numbers

%openSUBJECT = 4; %experimental subject number
prev = 1; %if today's date (0) or previous date (1)
scanNow = 0; %if using triggers (1)
runNum = 1; %what number subject they are today

SPTB_PATH = ['/Data1/code/SPTBanne'];
addpath(genpath(SPTB_PATH));
% if prev
%     allScanNums = [7:2:19];
% else
%     allScanNums = [7 11:2:21];
% end
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
%last input is scan number

% 1: SCOUT
% 2: MPRAGE
% 3: AP Scan
% 4: PA Scan
% 5: Example functional
% 6: LOCALIZER
% 7: RECALL 1
% 8: MOT 1
% 9: MOT 2
% 10: MOT 3
% 11: RECALL 2
datevec = {'4-19-17',  '4-20-17', '4-22-17', '4-23-17', '5-10-17', '5-11-17'};
subjectVec = [3 4 5 6 7 8];
for s = 1:length(subjectVec)
SUBDATE = datevec{s};
SUBJECT = subjectVec(s);
roi_name = 'retrieval';
roi_name = 'retrieval_NOFM';
%% LOCALIZER FILE PROCESS
% number of TR's total: 1376 (should be 688 originally)
scanNum = 6; % for subject 5 it's 7
if SUBJECT == 5
    scanNum = 7;
end
crossval = 0;
featureSelect = 1;
OfflineLocalizerNiftiFileProcess(SUBJECT,crossval,featureSelect,prev,scanNow,scanNum,MOT_LOCALIZER,runNum,roi_name,SUBDATE)
end
%%
block = 1;
roi_name = 'retrieval';

OfflineRealTimeNiftiFileProcess(SUBJECT,featureSelect,prev,scanNow,scanNum,MOT{block},block,runNum,roi_name) %,rtfeedback)


%% RECALL 1
% number of TR's total: 474
scanNum = 7;
mot_realtime04MB(SUBJECT,RECALL1,[],scanNum,scanNow);



%% RECALL 2
scanNum = 11;
mot_realtime04MB(SUBJECT,RECALL2,[],scanNum,scanNow);
%% ANALYZE RECALL DATA
% do for recall 1 and recall 2
makeFile = 1;
scanNum1 = 7;
scanNum2 = 11;
featureSelect = 1;
if prev
   date = '2-1-17';
end
RecallNiftiFileProcess(SUBJECT,runNum,scanNum1,RECALL1,date,featureSelect,makeFile,1);
RecallNiftiFileProcess(SUBJECT,runNum,scanNum2,RECALL2,date,featureSelect,makeFile,2);
%% ANALYZE RECALL DATA FOR ANOTHER MASK

scanNum1 = 13;
scanNum2 = 21;
datevec = { '4-19-17', '4-20-17', '4-22-17', '4-23-17', '5-10-17', '5-11-17'};
svec = [3:8];
runvec = ones(1,length(svec));
nsub = length(svec);
for s = 1:nsub
    SUBJECT = svec(s);
    date = datevec{s};
    runNum = runvec(s);
    AnatNiftiFileProcess(SUBJECT,runNum,scanNum1,RECALL1,date);
    AnatNiftiFileProcess(SUBJECT,runNum,scanNum2,RECALL2,date);
end