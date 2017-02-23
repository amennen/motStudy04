%calculate subjective details during MOT

%cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/1
%number of participants here
subj_dates = {'0326', '0329', '0401', '0427', '0429', '0505'};
NSUB = length(subj_dates);

MOT_REP = [20:22];
trialMean = zeros(length(MOT_REP),20,NSUB);
for MOT = 1:length(MOT_REP)
   
    for s = 1:NSUB
         
    
        date = subj_dates{s};
        %setup = load(['behav_subj_' num2str(subvec(s)) '_stimAssignment.mat']);
        behav_dir = ['/Volumes/norman/amennen/MOT/subjects/' date '161_motStudy01/data/behavioral'];
        
        fn = dir([behav_dir '/' 'EK' num2str(MOT_REP(MOT)) '*SUB*.mat']);
        sub = load([behav_dir '/' fn.name]);
        trials = table2cell(sub.datastruct.trials);
        stimID = cell2mat(trials(:,8));
        cond = cell2mat(trials(:,9));
        rating = cell2mat(trials(:,12));
        visTrials = find(cond<3);
        istart = (MOT-1)*20 + 1;
        iend = istart + 20 -1;
        visbysubj(s,istart:iend) = unique(ceil(visTrials'/4))+ 25*(MOT-1);
        visRating = rating(visTrials);
        byTrial = reshape(visRating,4,length(visRating)/4);
        trialMean(MOT,:,s) = nanmean(byTrial);
        %omit = find(acc2(2,:)==3);
        easy = find(cond==2);
        hard = find(cond==1);
        
        hAvg(s,MOT) = nanmean(rating(hard));
        eAvg(s,MOT) = nanmean(rating(easy));
        hALL(s,:) = rating(hard);
        eALL(s,:) = rating(easy);
        %EhAvg = [std(rating(hard))/sqrt(N_mTurk-1);
        %EeAvg = [std(acc1(1,easy)) std(acc2(1,easy))]/sqrt(N_mTurk-1);
        %EoAvg = [std(acc1(1,omit)) std(acc2(1,omit))]/sqrt(N_mTurk-1);
        %EALLDATA(s,:) = [EhAvg EeAvg EoAvg];
        
    end
end
longstr = zeros(s,60);
for s = 1:NSUB
    longstr(s,:) = reshape(trialMean(:,:,s)',1,60);
end

figure;
for s = 1:NSUB
subplot(3,2,s)
hist(hALL(s,:))
ylim([0 40])
end

figure;
for s = 1:NSUB
subplot(3,2,s)
hist(eALL(s,:))
ylim([0 40])
end
title('Ratings During MOT: Slow Trials')
%now average across all MOT
h_MOTAVG = nanmean(hAvg,2);
e_MOTAVG = nanmean(eAvg,2);

%average across subjects
h_ALLAVG = nanmean(h_MOTAVG);
e_ALLAVG = nanmean(e_MOTAVG);
eh_ALLAVG = nanstd(h_MOTAVG)/sqrt(length(subvec) - 1);
ee_ALLAVG = nanstd(e_MOTAVG)/sqrt(length(subvec) - 1);
ALLDATA = [h_ALLAVG; e_ALLAVG];
eALLDATA = [eh_ALLAVG ;ee_ALLAVG];
figure;
barwitherr(eALLDATA,ALLDATA);
set(gca,'XTickLabel' , ['HARD'; 'EASY']);
title('Average Subjective Details During MOT')
xlabel('MOT Speed Pair')
ylabel('Level of Detail (1-5)')
ylim([1 5.5])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',12)

%remove Nan vals
h_MOTAVG(find(isnan(h_MOTAVG))) = [];
e_MOTAVG(find(isnan(e_MOTAVG))) = [];
[h,p] = ttest2(h_MOTAVG,e_MOTAVG); %p = 0.12
%%
%get ratings before and after MOT for each category
subj_dates = {'0326', '0329', '0401', '0427', '0429', '0505'};
NSUB = length(subj_dates);

base_path = [fileparts(which('behav_test_anne.m')) filesep];
PICFOLDER = [base_path 'stimuli/FIGRIM/ALLSCENES/'];
trialcolumns = [2:25];
%subvec = setdiff(num_subjects,exclude_subj);

RECALL1 = 19;
RECALL2 = 23;
for s = 1:NSUB
    date = subj_dates{s};
    %setup = load(['behav_subj_' num2str(subvec(s)) '_stimAssignment.mat']);
    behav_dir = ['/Volumes/norman/amennen/MOT/subjects/' date '161_motStudy01/data/behavioral'];
    
    fn_R1 = dir([behav_dir '/' 'EK' num2str(RECALL1) '*SUB*.mat']);
    subR1 = load([behav_dir '/' fn_R1.name]);
    trials1 = table2cell(subR1.datastruct.trials);
    stimID1 = cell2mat(trials1(:,8));
    cond1 = cell2mat(trials1(:,9));
    rating1 = cell2mat(trials1(:,12));
    
    fn_R2 = dir([behav_dir '/' 'EK' num2str(RECALL2) '*SUB*.mat']);
    subR2 = load([behav_dir '/' fn_R2.name]);
    trials2 = table2cell(subR2.datastruct.trials);
    stimID2 = cell2mat(trials2(:,8));
    cond2 = cell2mat(trials2(:,9));
    rating2 = cell2mat(trials2(:,12));
    
    omit1 = find(cond1==3);
    easy1 = find(cond1==2);
    hard1 = find(cond1==1);
    
    omit2 = find(cond2==3);
    easy2 = find(cond2==2);
    hard2 = find(cond2==1);
    [~, index1(1,:,s)] = sort(stimID1(hard1));
    [~, index1(2,:,s)] = sort(stimID2(hard2));
    hALL(:,:,s) = [rating1(hard1) rating2(hard2)];
    ALLRATING(s,:) = [rating1' rating2'];
    %hAvg(s,:) = [nanmean(rating1(hard1)) nanmean(rating2(hard2))];
    %eAvg(s,:) = [nanmean(rating1(easy1)) nanmean(rating2(easy2))];
    %oAvg(s,:) = [nanmean(rating1(omit1)) nanmean(rating2(omit2))];
    
    
end

figure;
for s = 1:NSUB
subplot(3,2,s)
hist(ALLRATING(s,:))
ylim([0 50])
end


for s = 1:NSUB

H_Diff(:,s) = hALL(index1(2,:,s)',2,s) - hALL(index1(2,:,s)',1,s);
end
mean_subj = nanmean(H_Diff,1);
E_subj = nanstd(H_Diff)/sqrt(size(H_Diff,1)-1);

figure;
errorbar(hardSpeed,mean_subj,E_subj, '.', 'MarkerSize', 10)
xlabel('Fast Dot Speed')
ylabel('Post - Pre Subjects Subjective Ratings')
title('Ratings Change vs. Dot Speed')
%diff_ratings = hAvg(:,2) - hAvg(:,1);
%diff_ratings = diff_ratings';
p = polyfit(hardSpeed,mean_subj',1);
hold on;
ylim([0 .9])
yfit = polyval(p,hardSpeed);
plot(hardSpeed,yfit, '-r', 'LineWidth', 3)
set(findall(gcf,'-property','FontSize'),'FontSize',18)
legend('Subjects', 'Best Fit')


%avg across subjects
h_ALL = nanmean(hAvg,1);
e_ALL = nanmean(eAvg,1);
o_ALL = nanmean(oAvg,1);

eh_ALL = nanstd(hAvg, [], 1)/sqrt(NSUB-1);
ee_ALL = nanstd(eAvg, [], 1)/sqrt(NSUB-1);
eo_ALL = nanstd(oAvg, [], 1)/sqrt(NSUB-1);
ALLD = [h_ALL ; e_ALL; o_ALL];
eALLD = [eh_ALL ; ee_ALL; eo_ALL];
figure;
barwitherr(eALLD,ALLD)
set(gca,'XTickLabel' , ['Hard'; 'Easy'; 'Omit']);
title('Average Subjective Details During MOT')
xlabel('MOT Speed Pair')
ylabel('Level of Detail (1-5)')
ylim([1 5.5])
fig=gcf;
set(findall(fig,'-property','FontSize'),'FontSize',12)
legend('Pre MOT', 'Post MOT')
