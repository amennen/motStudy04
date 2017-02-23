%calculate subjective details during MOT

% localizer task: look at detail ratings between hard and easy dot speeds:
% is there a difference?
clear all;
projectName = 'motStudy03';
base_path = [fileparts(which('mot_realtime02.m')) filesep];

svec = [1];

NSUB = length(svec);
LOC = 19;
MOT = [21:23];
nstim = 10;
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];

%% check localizer task
for s = 1:NSUB
    behavioral_dir = [base_path 'BehavioralData/' num2str(svec(s)) '/'];
        r = dir(fullfile(behavioral_dir, ['EK' num2str(LOC) '_' 'SUB'  '*.mat'])); 
        r = load(fullfile(behavioral_dir,r(end).name)); 
        trials = table2cell(r.datastruct.trials);
        stimID = cell2mat(trials(:,8));

        cond = cell2mat(trials(:,9));
        visTrials = find(cond<3);
        condVis = cond(visTrials);
        condVis = reshape(condVis,4,length(condVis)/4);
        condVis = mean(condVis,1);
        rating = cell2mat(trials(:,12));
        ratingVis = rating(visTrials);
        ratingVis = reshape(ratingVis,4,length(ratingVis)/4);
        meanRating = nanmean(ratingVis,1);
        easy = find(condVis==2);
        hard = find(condVis==1);
        rating_easy = mean(meanRating(easy));
        rating_hard = mean(meanRating(hard));
end

%% compute for MOT blocks
for s = 1:NSUB
    behavioral_dir = [base_path 'BehavioralData/' num2str(svec(s)) '/'];
    figure
    hold on;
    for iblock = 1:3 
        SESSION = 20 + iblock;
        r = dir(fullfile(behavioral_dir, ['EK' num2str(SESSION) '_' 'SUB'  '*.mat']));
        r = load(fullfile(behavioral_dir,r(end).name)); 
        trials = table2cell(r.datastruct.trials);
        stimID = cell2mat(trials(:,8));
        cond = cell2mat(trials(:,9));
        visTrials = find(cond<3);
        condVis = cond(visTrials);
        condVis = reshape(condVis,4,length(condVis)/4);
        condVis = mean(condVis,1);
        rating = cell2mat(trials(:,12));
        ratingVis = rating(visTrials);
        ratingVis = reshape(ratingVis,4,length(ratingVis)/4)
        meanRating = nanmean(ratingVis,1);
       
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime02_' num2str(svec(s)) '_' num2str(SESSION)  '*.mat']));
        matlabOpenFile = [behavioral_dir '/' fileSpeed(end).name];
        d = load(matlabOpenFile);
        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        %get average speed over that trial
        meanSpeed = mean(allSpeed,1);
        plot(meanSpeed,meanRating, '.', 'MarkerSize', 7)
   end
end
