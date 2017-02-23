%calculate subjective details during MOT

%cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/1
%number of participants here
cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/
base_path = [fileparts(which('behav_test_anne.m')) filesep];
PICFOLDER = [base_path 'stimuli/FIGRIM/ALLSCENES/'];
num_subjects = 1:21;
exclude_subj = [2 14];
subvec = setdiff(num_subjects,exclude_subj);
trialcolumns = [2:25];
subvec = setdiff(num_subjects,exclude_subj);
Nstim = 16;
Npres = 4;
MOT_REP = [20:22];
for MOT = 1:length(MOT_REP)
    for s = 1:length(subvec)
        cd(num2str(subvec(s)))
        setup = load(['behav_subj_' num2str(subvec(s)) '_stimAssignment.mat']);
        subf = dir(['EK' num2str(MOT_REP(MOT)) '*SUB*mat']);
        sub = load(subf.name);
        trials = table2cell(sub.datastruct.trials);
        stimID = cell2mat(trials(:,9));
        cond = cell2mat(trials(:,10));
        rating = cell2mat(trials(:,13));
        
        %omit = find(acc2(2,:)==3);
        easy = find(cond==2);
        hard = find(cond==1);
        
        hAvg(s,MOT) = nanmean(rating(hard));
        eAvg(s,MOT) = nanmean(rating(easy));
        
        %EhAvg = [std(rating(hard))/sqrt(N_mTurk-1);
        %EeAvg = [std(acc1(1,easy)) std(acc2(1,easy))]/sqrt(N_mTurk-1);
        %EoAvg = [std(acc1(1,omit)) std(acc2(1,omit))]/sqrt(N_mTurk-1);
        %EALLDATA(s,:) = [EhAvg EeAvg EoAvg];
        
        
        cd ..
    end
end
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
cd /Volumes/norman/amennen/behav_test_anne/Participant' Data'/
base_path = [fileparts(which('behav_test_anne.m')) filesep];
PICFOLDER = [base_path 'stimuli/FIGRIM/ALLSCENES/'];
num_subjects = 1:21;
exclude_subj = [2 14];
subvec = setdiff(num_subjects,exclude_subj);
trialcolumns = [2:25];
subvec = setdiff(num_subjects,exclude_subj);
Nstim = 16;
Npres = 4;

for s = 1:length(subvec)
    cd(num2str(subvec(s)))
    setup = load(['behav_subj_' num2str(subvec(s)) '_stimAssignment.mat']);
    
    subf = dir(['EK' num2str(19) '*SUB*mat']);
    sub = load(subf.name);
    trials1 = table2cell(sub.datastruct.trials);
    stimID1 = cell2mat(trials1(:,9));
    cond1 = cell2mat(trials1(:,10));
    rating1 = cell2mat(trials1(:,13));
    
    subf = dir(['EK' num2str(23) '*SUB*mat']);
    sub = load(subf.name);
    trials2 = table2cell(sub.datastruct.trials);
    stimID2 = cell2mat(trials2(:,9));
    cond2 = cell2mat(trials2(:,10));
    rating2 = cell2mat(trials2(:,13));
    
    omit1 = find(cond1==3);
    easy1 = find(cond1==2);
    hard1 = find(cond1==1);
    
    omit2 = find(cond2==3);
    easy2 = find(cond2==2);
    hard2 = find(cond2==1);
    
    hAvg(s,:) = [nanmean(rating1(hard1)) nanmean(rating2(hard2))];
    eAvg(s,:) = [nanmean(rating1(easy1)) nanmean(rating2(easy2))];
    oAvg(s,:) = [nanmean(rating1(omit1)) nanmean(rating2(omit2))];
    
    
    cd ..
end


%avg across subjects
h_ALL = nanmean(hAvg,1);
e_ALL = nanmean(eAvg,1);
o_ALL = nanmean(oAvg,1);

eh_ALL = nanstd(hAvg, [], 1)/sqrt(length(subvec)-1);
ee_ALL = nanstd(eAvg, [], 1)/sqrt(length(subvec)-1);
eo_ALL = nanstd(oAvg, [], 1)/sqrt(length(subvec)-1);
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