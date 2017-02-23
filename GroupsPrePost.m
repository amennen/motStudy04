% GropuPrePost: to analyze data across RT and YC groups

% analyze pre- and post- MOT recall periods

%what we want it to do:
% - open session info (pre and post)
% - open trained model
% - open patterns from pre and post scan
% - classify and subtract to see differences
% - plot
% - eventually have this as a function for every subject where date is an
% input, so is run number

% first set filepaths and information

%variables
%subjectNum = 3;
%runNum = 1;
clear all;
projectName = 'motStudy03';
onlyRem = 1; %if should only look at the stimuli that subject answered >1 for remembering in recall 1
rating_thresh = 4;
onlyForg = 0;
post = 0;
plotDir = ['/Data1/code/' projectName '/' 'Plots2' '/' ]; %should be all
%plot dir?
svec = [3 4 5 6 7 8 9 11 12 13];
trainedModel = 'averageModel';
runvec = ones(1,length(svec));
irun2 = find(svec==5);
runvec(irun2) = 2;
nTRsperTrial = 4 + 4; %because 4 in task, then 2 before 2 after
if length(runvec)~=length(svec)
    error('Enter in the runs AND date numbers!!')
end
%datevec = { '1-11-17', '1-13-17'};
datevec = { '1-13-17', '1-14-17', '1-14-17', '1-20-17', '1-21-17', '1-22-17', '1-26-17', '1-28-17', '1-30-17', '2-1-17'};
RT = [3 4 5 6 7 8 9 11 12 13];
YC= [];
RTonly = 1;
NSUB = length(svec);
for s = 1:NSUB
    subjectNum = svec(s);
    if ismember(subjectNum,RT)
        condition = 1;
    else
        condition = 0;
    end
    runNum = runvec(s);
    date = datevec{s};
    featureSelect = 1;
    %normally, scan num for recall 1 is 13 and recall 2 is 21
    recallScan = [13 21];
    if subjectNum == 1
        recallScan = [13 25];
    end
    recallSession = [20 24];
    %date = '7-12-16';
    
    shiftTR = 2;
    
    setenv('FSLOUTPUTTYPE','NIFTI_GZ');
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    process_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/' 'reg' '/'];
    roi_dir = ['/Data1/code/' projectName '/data/'];
    code_dir = ['/Data1/code/' projectName '/' 'code' '/']; %change to wherever code is stored
    locPatterns_dir = fullfile(save_dir, 'Localizer/');
    behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
    addpath(genpath(code_dir));
    scanDate = '7-12-2016';
    subjectName = [datestr(scanDate,5) datestr(scanDate,7) datestr(scanDate,11) num2str(runNum) '_' projectName];
    dicom_dir = ['/Data1/subjects/' datestr(scanDate,10) datestr(scanDate,5) datestr(scanDate,7) '.' subjectName '.' subjectName '/'];
    
    % get recall data from subject
    for i = 1:2
        
        % only take the stimuli that they remember
        if i == 1 %if recall one check
           r = dir(fullfile(behavioral_dir, ['EK' num2str(recallSession(i)) '_' 'SUB'  '*.mat'])); 
           r = load(fullfile(behavioral_dir,r(end).name)); 
           [expat,trials,stimOrder] = GetSessionInfoRT(subjectNum,recallSession(i),behavioral_dir);
           trials = table2cell(r.datastruct.trials);
           stimID = cell2mat(trials(:,8));
           cond = cell2mat(trials(:,9));
           rating = cell2mat(trials(:,12));
           sub.hard = rating(find(cond==1));
           sub.easy = rating(find(cond==2));
           
            sub.Orderhard = sub.hard(stimOrder.hard);
            sub.Ordereasy = sub.easy(stimOrder.easy);
        
            keep.hard = find(sub.Orderhard>=rating_thresh); %in the order of the stimuli-which indices to keep
            keep.easy = find(sub.Ordereasy>=rating_thresh);
            num_kh(s) = length(keep.hard);
            num_ke(s) = length(keep.easy);
        end
        
        scanNum = recallScan(i);
        SESSION = recallSession(i);
        rfn = dir(fullfile(save_dir, ['recallpatternsdata_' num2str(SESSION)  '*.mat']));
        rp = load(fullfile(save_dir,rfn(end).name));
        rpat = rp.patterns;
        [expat,trials,stimOrder] = GetSessionInfoRT(subjectNum,SESSION,behavioral_dir);
        testTrials = find(any(expat.regressor.allCond));
        allcond = rpat.regressor.allCond(:,testTrials);
        categSep = rpat.categSep(:,testTrials);
        categSep = rpat.categSep(:,union(testTrials,testTrials+shiftTR+2)); % go an extra 2 for plotting purposes
        z = reshape(categSep,nTRsperTrial,20); %for 20 trials --make sure this works here!
        byTrial = z';
        RTtrials = byTrial(trials.hard,:);
        %now do in that specific order
        RTtrials = RTtrials(stimOrder.hard,:);
        OMITtrials = byTrial(trials.easy,:);
        OMITtrials = OMITtrials(stimOrder.easy,:);
        
        RTevidence(:,:,i) = RTtrials;
        OMITevidence(:,:,i) = OMITtrials;
        
    end
    
    % now find post - pre difference
    
    if onlyRem 
        PrePostRT = RTevidence(keep.hard,:,2) - RTevidence(keep.hard,:,1);
        PrePostOMIT = OMITevidence(keep.easy,:,2) - OMITevidence(keep.easy,:,1);
        PostOnlyRT1 = RTevidence(keep.hard,:,2);
        PostOnlyOM1 = OMITevidence(keep.easy,:,2);
    elseif onlyRem == 0 && onlyForg == 0
        PrePostRT = RTevidence(:,:,2) - RTevidence(:,:,1);
        PrePostOMIT = OMITevidence(:,:,2) - OMITevidence(:,:,1);
        PostOnlyRT1 = RTevidence(:,:,2);
        PostOnlyOM1 = OMITevidence(:,:,2);
    elseif onlyForg
        forg_hard = setdiff(1:size(RTevidence,1),keep.hard);
        forg_easy = setdiff(1:size(RTevidence,1),keep.easy);
        PrePostRT = RTevidence(forg_hard,:,2) - RTevidence(forg_hard,:,1);
        PrePostOMIT = OMITevidence(forg_easy,:,2) - OMITevidence(forg_easy,:,1);
    end
    PostOnlyRT(s,:) = mean(PostOnlyRT1,1);
    PostOnlyOM(s,:) = mean(PostOnlyOM1,1);
    RTavg(s,:) = mean(PrePostRT,1);
    OMITavg(s,:) = mean(PrePostOMIT,1);
    
    
end
%take data only from RT group
RT_i = find(ismember(svec,RT));
nRT = length(RT_i);
if post
    RTgroup_RT = PostOnlyRT;
    RTgroup_OM = PostOnlyOM;
else
    RTgroup_RT = RTavg(RT_i,:);
    RTgroup_OM = OMITavg(RT_i,:);
end

% calculate number of kept trials too!
h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(RTgroup_RT,1);
eRT = nanstd(RTgroup_RT,[],1)/sqrt(nRT-1);
allOMIT = nanmean(RTgroup_OM,1);
eOMIT = nanstd(RTgroup_OM,[],1)/sqrt(nRT-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
ylim([-.5 .3])
if onlyRem
    avg_kh = mean(num_kh)/10;
    avg_ke = mean(num_ke)/10;
    text(4,-0.3, sprintf('Average kept rt = %.2f',avg_kh));
    text(4,-0.35, sprintf('Average kept omit = %.2f',avg_ke));
    title(sprintf('Post MOT Classifier; n = %i; boundary = %i',nRT,rating_thresh))
else
title(sprintf('Post MOT Classifier; n = %i',nRT))
end
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

xlim([1 nTRsperTrial])
%ylim([-.25 .25])
print(h1, sprintf('%sresults21_9sub_post_boundary5.pdf', plotDir), '-dpdf')

%%
h1 = figure;
%alldiffmeans = [RTavg;OMITavg];
%alldiffstd = [std(PrePostRT)/sqrt(size(PrePostRT,1)-1);std(PrePostOMIT)/sqrt(size(PrePostRT,1)-1)];
allRT = nanmean(YCgroup_RT,1);
eRT = nanstd(YCgroup_RT,[],1)/sqrt(nYC-1);
allOMIT = nanmean(YCgroup_OM,1);
eOMIT = nanstd(YCgroup_OM,[],1)/sqrt(nYC-1);
alldiffmeans = [allRT;allOMIT];
alldiffstd = [eRT;eOMIT];
mseb(1:nTRsperTrial,alldiffmeans, alldiffstd)
legend('Realtime', 'Omit')
title(sprintf('Post - Pre MOT Classifier Difference, YC n = %i',nYC))
set(gca, 'XTick', [1:nTRsperTrial])
%set(gca,'XTickLabel',['-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; '6'; '7'; '8'; '9'; ']);
ylabel('Target - Lure Evidence')
xlabel('TR (2s)')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);

xlim([1 nTRsperTrial])
ylim([-.25 .25])
%print(h1, sprintf('%sresults_updated0914_aonlyForg.pdf', plotDir), '-dpdf')
