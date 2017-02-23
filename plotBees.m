% plotBees: plot distrubition for beeswarm functions
% compare feedback
% figure out why the violin plots look so weird now, show second derivative evidence too 


%close all;
%clear all;
thisDir = '/Data1/code/motStudy03/code/';
cd(thisDir)
projectName = 'motStudy03';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
FBTRs = 11;
nblock = 3;
svec = [3:9 11 12 13];

iRT = find(ismember(svec,RT));


% for i = 1:length(YC_m)
%     iYC_m(i) = find(svec==YC_m(i));
% end
% for i = 1:length(svec)
%     n_rem(i) = length(findRememberedStim(svec(i)));
%     remembered{i} = findRememberedStim(svec(i));
% end
% for i = 1:length(iYC_m)
%     overlapping{i} = intersect(remembered{iRT_m(i)},remembered{iYC_m(i)});
% end
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
allds_RT = [];
allev_RT = [];
allspeed_RT = [];
allds_YC = [];
allev_YC = [];
allspeed_YC = [];
goodTrials =0;
for s = 1:nsub
    subjectNum = svec(s);

    remStim = findRememberedStim(subjectNum);
    subject_ds = [];
    subject_ev = [];
    subject_speed = [];
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 20 + blockNum;
        
        behavioral_dir = [fileparts(which('mot_realtime02.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime02_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        names = {fileSpeed.name};
        dates = [fileSpeed.datenum];
        [~,newest] = max(dates);
        plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end
        matlabOpenFile = [behavioral_dir '/' names{newest}];
        d = load(matlabOpenFile);
        
        %goodTrials = find(ismember(d.stim.id,remStim));
        
        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        allMotionTRs = allMotionTRs + 2;%[allMotionTRs; allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF
        onlyFbTRs = allMotionTRs(5:end,:);
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        FBTRVector = reshape(onlyFbTRs,1,numel(onlyFbTRs));
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        names = {run.name};
        dates = [run.datenum];
        [~,newest] = max(dates);
        run = load(fullfile(runHeader,run(end).name));
        categsep = run.patterns.categsep(TRvector - 10); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,nTRs,10);
        sepbytrial = sepbytrial';
        if goodTrials
            sepbytrial = sepbytrial(:,goodTrials);
        end
        allsepchange = diff(sepbytrial,1,1);
        FBsepchange = reshape(allsepchange(4:end,:),1,numel(allsepchange(4:end,:)));
        allsep = reshape(sepbytrial(5:end,:),1,numel(sepbytrial(5:end,:)));
        if goodTrials
            allSpeed = allSpeed(:,goodTrials);
        end
        allspeedchanges = diff(allSpeed,1,1);
            
        FBspeed = reshape(allSpeed(5:end,:),1,numel(allSpeed(5:end,:)));
        FBspeedchange = reshape(allspeedchanges(4:end,:),1,numel(allspeedchanges(4:end,:)));
        FBTRs = length(FBspeedchange);
        if ismember(subjectNum,RT)
            allds_RT = [allds_RT FBspeedchange];
            allev_RT = [allev_RT allsep];
            allspeed_RT = [allspeed_RT FBspeed];
        else
            allds_YC = [allds_YC FBspeedchange];
            allev_YC = [allev_YC allsep];
            allspeed_YC = [allspeed_YC FBspeed];
        end
        subject_ds = [subject_ds FBspeedchange];
        subject_ev = [subject_ev allsep];
        subject_speed = [subject_speed FBspeed];
        
        ds((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeedchange;
        ev((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = allsep;
        speed((iblock-1)*FBTRs + 1: iblock*FBTRs ,s) = FBspeed;
        
        % look how separation evidence is changing by TR
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        
        allDiff = diff(diff(sepinorder(:,5:end),1,2),1,2)/4;
        secondDiff = reshape(allDiff,1,numel(allDiff));
        zTR = length(secondDiff);
        allSecondDiff(s,(iblock-1)*zTR + 1: iblock*zTR) = secondDiff;
        
    end
    bySubj_ds{s} = subject_ds;
    bySubj_ev{s} = subject_ev;
    bySubj_speed{s} = subject_speed;
end
%% separate groups
ds_RT = ds;%(:,iRT);
allds_RT = reshape(ds_RT,1,numel(ds_RT));
ev_RT = ev;%;(:,iRT);
allev_RT = reshape(ev_RT,1,numel(ev_RT));
speed_RT = speed;%(:,iRT);
allspeed_RT = reshape(speed_RT,1,numel(speed_RT));

%run plotBees in motStudy2
%% plot

cats={'RT' 'Old'}; %category labels
[~,mHUCp]=ttest2(allev_RT,allev_old);
pl={allev_RT', allev_old'}; %these are all the elements (rows) in each condition (columns)
ps=[mHUCp]; %so here I'm plotting 
yl='Retrieval Evidence During MOT'; %y-axis label
thisfig = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(xt,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
title('Distribution of Evidence During MOT')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
%print(thisfig, sprintf('%sbeesbygroup.pdf', allplotDir), '-dpdf')



%violin plots
thisfig = figure;
distributionPlot(pl, 'showMM', 2, 'xNames', cats, 'ylabel', yl, 'colormap', copper)
xlim([.5 2.5])
ylim([-1 1])
title('Distribution of Evidence During MOT')
xlabel('Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%print(thisfig, sprintf('%sviolinsbygroup.pdf', allplotDir), '-dpdf')

%% do separately for each subject

cats = {'R1', 'Y1', 'R2', 'Y2', 'R3', 'Y3', 'R4', 'Y4', 'R5', 'Y5', 'R6', 'Y6'};
pl = {bySubj_ev{iRT_m(1)}', bySubj_ev{iYC_m(1)}', bySubj_ev{iRT_m(2)}', bySubj_ev{iYC_m(2)}', bySubj_ev{iRT_m(3)}', bySubj_ev{iYC_m(3)}', bySubj_ev{iRT_m(4)}', bySubj_ev{iYC_m(4)}',bySubj_ev{iRT_m(5)}', bySubj_ev{iYC_m(5)}', bySubj_ev{iRT_m(6)}', bySubj_ev{iYC_m(6)}'};
for j = 1:length(iRT_m) %do for each pair
    [~,mp(j)] = ttest2(bySubj_ev{iRT_m(j)}',bySubj_ev{iYC_m(j)}');
end
ps = [mp];
yl='Retrieval Evidence During MOT'; %y-axis label
thisfig = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig(1:2:length(iRT_m)*2,yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Classifier Evidence During MOT by Subject')
%plot bands
line([0 46], [0.15 0.15], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
line([0 46], [0.1 0.1], 'color', [0 0 0 ]/255, 'LineWidth', 2.5,'LineStyle', '--');
line([0 46], [0.05 0.05], 'color', [140 136 141]/255, 'LineWidth', 1.5,'LineStyle', '--');
print(thisfig, sprintf('%sbeesbysubj.pdf', allplotDir), '-dpdf')

%% now look at data
%% histograms of second deriv
cats = {'RT', 'Old RT'};
SDRT = abs(reshape(allSecondDiff,numel(allSecondDiff),1));
SDYC = abs(reshape(oldSecondDiff(iYC,:),numel(oldSecondDiff(iYC,:)),1));
pl = {SDRT, SDYC};
clear mp;
[~,mp] = ttest2(SDRT,SDYC);
ps = [mp];
yl='Second Derivative'; %y-axis label
h = figure;plotSpread(pl,'xNames',cats,'showMM',2,'yLabel',yl); %this plots the beeswarm
h=gcf;set(h,'PaperOrientation','landscape'); %these two lines grabs some attributes important for plotting significance
xt = get(gca, 'XTick');yt = get(gca, 'YTick');
hold on;plotSig([1 2],yt,ps,0);hold off; %keep hold on and do plotSig.
%pn=[picd num2str(vers) '-' num2str(scramm) 'ChangeInPrecision'];%print(pn,'-depsc'); %print fig
%ylim([-1.25 1.25])
set(findall(gcf,'-property','FontSize'),'FontSize',16)
title('Second Derivative by Group');
%print(h, sprintf('%sbeesSECONDD.pdf', allplotDir), '-dpdf')

thisfig = figure;
distributionPlot(pl, 'showMM', 2, 'xNames', cats, 'ylabel', yl, 'colormap', copper)
xlim([.5 2.5])
ylim([-.05 .4])
title('Second Difference of Evidence During MOT')
xlabel('Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%print(thisfig, sprintf('%sviolinsSECONDD.pdf', allplotDir), '-dpdf')


secondRT = allSecondDiff(iRT,:);
secondYC = allSecondDiff(iYC,:);
RTvec = reshape(secondRT,1,numel(secondRT));
YCvec = reshape(secondYC,1,numel(secondYC));

[c1,b1] = hist(RTvec,[-1.5:.15:1.5]);
hold on;
[c2,b] = hist(YCvec,b1);
RTnorm = c1/sum(c1);
YCnorm = c2/sum(c2);

figure;
bar(b,[RTnorm' YCnorm']);
%ylim([0 .3]);
xlim([-1.5 1.5]);
legend('RT', 'YC')


