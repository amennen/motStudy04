% this is for plotting classifier evidence and dot speed

% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
close all;
clear all;
projectName = 'motStudy02';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
sepTRs = 17;
nblock = 3;
%svec = 8:15; %[3:5 7]; %subjects 3,4,5,7 are for initial RT, subjects 8-10 are after changes
svec = 16
nsub = length(svec);
sepbystim = zeros(nstim,nTRs*3);
speedbystim = zeros(nstim,nTRs*3);
num2avg = 2; %including starting point--change to 2 now that we're only smoothing over 2 TR's
allplotDir = ['/Data1/code/' projectName '/' 'Plots' '/' ];
shifts = -3:8;
ds= 1; %whether or not to look at changes in dot speed or just dot speed
for s = 1:nsub
    subjectNum = svec(s);
    runNum = 1;
    save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
    locPatterns_dir = fullfile(save_dir, 'Localizer/');
    allfn = dir([locPatterns_dir 'loctrainedModel_' num2str(runNum) '*']); %
    %take the last model saved
    load(fullfile(locPatterns_dir, allfn(end).name));
    allLast = dir([locPatterns_dir 'locpatternsdata_' '*']);
    loc = load(fullfile(locPatterns_dir, allLast(end).name)); 
    goodVox = loc.patterns.sigVox;

 for z = 1:length(shifts)
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 19 + blockNum;
        %blockNum = SESSION - 20 + 1;
        
        %behavioral_dir = ['/Data1/code/' projectName '/' 'code' '/BehavioralData/' num2str(subjectNum) '/'];
        behavioral_dir = [fileparts(which('mot_realtime01.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = findNewestFile(behavioral_dir,fullfile(behavioral_dir, ['mot_realtime01_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        plotDir = ['/Data1/code/' projectName '/' 'Plots' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end
        d = load(fileSpeed);
        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        allMotionTRs = [allMotionTRs(3:end,:); allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        TRvector = TRvector + shifts(z);
        run = dir([runHeader 'motpatternsdata_' num2str(SESSION) '*']);
        run = load(fullfile(runHeader,run(end).name));
        
        allData = run.patterns.raw_sm_filt_z;
        for iTrial = 1:size(run.patterns.raw_sm_filt_z,1)
        [patterns.predict(iTrial), patterns.activations(1:2,iTrial)] = predict_ridge(run.patterns.raw_sm_filt_z(iTrial,goodVox),trainedModel);
        patterns.categsep(iTrial) = patterns.activations(1,iTrial) - patterns.activations(2,iTrial);
        end
        categsep = patterns.categsep(TRvector-10);
        %categsep = run.patterns.categsep(TRvector - 10); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,nTRs,10);
        sepbytrial = sepbytrial'; %results by trial number, TR number
        speedbytrial = reshape(speedVector,nTRs,nstim);
        speedbytrial = speedbytrial';
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        speedinorder = speedbytrial(indSort,:);
        if ds
        sepbystim(:,(iblock-1)*(nTRs-1) + 1: iblock*(nTRs-1),s ) = sepinorder(:,2:end);
        speedbystim(:,(iblock-1)*(nTRs-1) + 1: iblock*(nTRs-1),s ) = diff(speedinorder,1,2); %instead of speed in order bc relative speed only (could also normalize speed)
      else
        subjmeanspeed = mean(reshape(speedinorder,1,numel(speedinorder)));
        subjstdspeed = std(reshape(speedinorder,1,numel(speedinorder)));
        sepbystim(:,(iblock-1)*(nTRs) + 1: iblock*(nTRs),s ) = sepinorder;
        speedbystim(:,(iblock-1)*(nTRs) + 1: iblock*(nTRs),s ) = (speedinorder-subjmeanspeed)./subjstdspeed; 
        end
    end
    newseps = reshape(sepbystim(:,:,s),1,numel(sepbystim(:,:,s)));
    newspeeds = reshape(speedbystim(:,:,s),1,numel(speedbystim(:,:,s)));
    [rho,pval] = corrcoef([newspeeds' newseps']);
    corrcoeff(s,z) = rho(1,2);
    
    %this is to plot correlations shifted by zero
%     h = figure;
%     x = newspeeds;
%     y = newseps;
%     scatter(newspeeds,newseps,'fill','MarkerEdgeColor','b',...
%         'MarkerFaceColor','c',...
%         'LineWidth',2.5);
%     xlabel('Speed')
%     ylabel('Evidence')
%     [rho,pval] = corrcoef([newspeeds' newseps']);
%     corrcoeff(s) = rho(1,2);
%     text(2,.85,['corr = ' num2str(rho(1,2))]);
%     text(2,.65, ['p = ' num2str(pval(1,2))])
%     
%     p = polyfit(x,y,1);
%     yfit = polyval(p,x)
%     hold on;
%     plot(x,yfit, '--k', 'LineWidth', 3);
%     text(2,.45, ['slope = ' num2str(p(1))])
%     
%     ylim([-1 1])
%     xlim([0 15 ])
%     title(sprintf('Subject %i Real-time Evidence vs. Speed',subjectNum));
%     set(findall(gcf,'-property','FontSize'),'FontSize',20)
%     print(h, sprintf('%sINSTcorrelations.pdf', plotDir), '-dpdf')
    end
end
h1 = figure;
allRT = mean(corrcoeff,1);
eRT = std(corrcoeff,[],1)/sqrt(nsub-1);
mseb(1:length(allRT),allRT, eRT)
title(sprintf('Classifier Evidence and Normalized Speed Correlations'))
xlim([1 length(allRT)])
ylim([-.1 0.25])
set(gca, 'XTick', 1:length(allRT))
set(gca,'XTickLabel',['-3'; '-2'; '-1'; ' 0'; ' 1'; ' 2'; ' 3'; ' 4'; ' 5'; ' 6'; ' 7'; ' 8']);
ylabel('Correlation')
xlabel('TR Shift')
set(findall(gcf,'-property','FontSize'),'FontSize',16)
print(h1, sprintf('%scorrSHIFT_ds.pdf', allplotDir), '-dpdf')

%line([3 3], [-1 1], 'Color', 'k', 'LineWidth', 3);
%line([6 6], [-1 1], 'Color', 'k', 'LineWidth', 3);
%now average over all subjects
%avges = mean(corrcoeff,1)
%figure;
%plot(avges, '.', 'MarkerSize', 6)
%set(gca,'XTick' , [1:5]);
%set(gca,'XTickLabel' , ['-2'; '-1'; ' 0'; ' 1'; ' 2']);
