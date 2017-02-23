% want to plot the dot speed and category separation timecourse
% need: speed (from behavioral file)
% category separation (can also pull from behavioral file)
close all;
clear all;
projectName = 'motStudy03';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 15;
nblock = 3;
svec = [8];

nsub = length(svec);
sepbystim = zeros(nstim,nTRs*nblock);
speedbystim = zeros(nstim,nTRs*nblock);
MOT_PREP = 5;
colors = [207 127 102;130 161 171; 207 64 19]/255;

%colors = [110 62 106;83 200 212; 187 124 181]/255;
plotstim = 1; %if you want trial by trial plots
allplotDir = ['/Data1/code/' projectName '/' 'Plots2' '/' ];

for s = 1:nsub
    subjectNum = svec(s);
    allsep = [];
    fbsep = [];
    allspeeds = [];
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 20 + blockNum;
        behavioral_dir = [fileparts(which('mot_realtime02.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/'];
        classOutputDir = fullfile(save_dir,['motRun' num2str(blockNum)], 'classOutput/');
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime02_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        
        %get hard speed
        prep = dir([behavioral_dir 'mot_realtime02_' num2str(subjectNum) '_' num2str(MOT_PREP)  '*.mat']);
        prepfile = [behavioral_dir prep(end).name];
        lastRun = load(prepfile);
        hardSpeed(s) = 30 - lastRun.stim.tGuess(end);
        
        plotDir = ['/Data1/code/' projectName '/' 'Plots2' '/' num2str(subjectNum) '/'];
        if ~exist(plotDir, 'dir')
            mkdir(plotDir);
        end
        
        % get the speed for every trial in that block

        allSpeed = d.stim.motionSpeed; %matrix of TR's
        speedVector = reshape(allSpeed,1,numel(allSpeed));
        
        % now find the category separation for that block 
        
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        for i=1:length(TRvector)
            fileTR = TRvector(i) + 2;
            [~, tempfn{fileTR}] = GetSpecificClassOutputFile(classOutputDir,fileTR);
            tempStruct = load(fullfile(classOutputDir, tempfn{fileTR}));
            categsep(i) = tempStruct.classOutput;
        end
        
        sepbytrial = reshape(categsep,15,10);
        sepbytrial = sepbytrial'; %results by trial number, TR number
        fbsepbytrial = sepbytrial(:,5:end);
        
        sepvec = reshape(sepbytrial,1,numel(sepbytrial));
        fbsepvec = reshape(fbsepbytrial, 1, numel(fbsepbytrial));
        
        speedbytrial = reshape(speedVector,nTRs,nstim);
        speedbytrial = speedbytrial';
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        speedinorder = speedbytrial(indSort,:);
        
        %test if fb only
        fbsepinorder = sepinorder(:,5:end);
        fbspeedinorder = speedinorder(:,5:end);
        nTRs2 = 11; %change back to 11 and sep... afterwards
        sepbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = sepinorder;
        speedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedinorder;
        fbsepbystim(:,(iblock-1)*nTRs2 + 1: iblock*nTRs2 ) = fbsepinorder;
        fbspeedbystim(:,(iblock-1)*nTRs2 + 1: iblock*nTRs2 ) = fbspeedinorder;
        sepmixed(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = sepbytrial;
        speedmixed(:,(iblock-1)*nTRs + 1: iblock*nTRs ) = speedbytrial;
        
        
        allspeeds = [allspeeds speedVector];
        allsep = [allsep sepvec];
        fbsep = [fbsep fbsepvec];
        
    end
    
    newspeedbystim = reshape(speedbystim,1,numel(speedbystim));
    newsepbystim = reshape(sepbystim,1,numel(sepbystim));
    [good] = find(newsepbystim > 0.05 & newsepbystim < 0.15);
    goodSpeeds = newspeedbystim(good);
    [thisfig,maxLoc] = plotDist(goodSpeeds,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of Good Speeds', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sgoodspeedsdist.pdf', plotDir), '-dpdf')
    
    fbnewspeedbystim = reshape(fbspeedbystim,1,numel(fbspeedbystim));
    fbnewsepbystim = reshape(fbsepbystim,1,numel(fbsepbystim));
    [fbgood] = find(fbnewsepbystim > 0.05 & fbnewsepbystim < 0.15);
    fbgoodSpeeds = fbnewspeedbystim(fbgood);
    [thisfig,maxLoc,counts1] = plotDist(fbgoodSpeeds,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of Good Speeds, Fb Only', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    goodSpeedFb(s) = mean(fbgoodSpeeds);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_goodspeedsdist.pdf', plotDir), '-dpdf')
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    fbnewspeedbystim = reshape(fbspeedbystim,1,numel(fbspeedbystim));
    fbnewsepbystim = reshape(fbsepbystim,1,numel(fbsepbystim));
    %[fbgood] = find(fbnewsepbystim > 0.05 & fbnewsepbystim < 0.15);
    %fbgoodSpeeds = fbnewspeedbystim(fbgood);
    [thisfig,maxLoc,counts2] = plotDist(fbnewspeedbystim,1,1,-1:.5:6.5);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    title(sprintf('Subject %i Distribution of All Speeds, Fb Only', subjectNum))
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_allspeedsdist.pdf', plotDir), '-dpdf')
    %look up how to change yaxis categories
    %do to later: rearrange all motion trials by stimulus ID and then plot on
    %subplots every block
    
    counts_div = counts1./counts2;
    bins = -1:.5:6.5;
    bins_interp = linspace(bins(1),bins(end),500);
    counts_interp = interp1(bins,counts_div,bins_interp, 'spline');
    
    %#METHOD 2: DIVIDE BY AREA
    fighandle = figure;
    bar(bins,counts_div/nansum(counts_div));
    hold on
    %plot(xi,fks*length(inData), 'r')
    xlabel('Dot Speed')
    ylim([0 .8])
    xlim([-.5 7])
    plot(bins_interp, counts_interp/nansum(counts_div), 'color', [84 255 199]/255, 'LineWidth', 3);
    title(sprintf('Subject %i Distribution of Good/All, Fb Only', subjectNum))
    ylabel('Frequency')
    xlabel('Dot Speed')
    %ylim([0 0.3])
    [z i] = max(counts_div);
    maxLoc = bins(i);
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(4.7,.75,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(4.7,.65, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(fighandle, sprintf('%sfb_allspeedsratiodist.pdf', plotDir), '-dpdf')
    
    
    
    
    [thisfig,maxLoc] = plotDist(allsep,1,1,[-.5:.1:.5]);
    ylim([0 .4])
    xlim([-.7 .7])
    title(sprintf('Subject %i Evidence Distribution', subjectNum))
    xlabel('Target-Lure Evidence')
    line([0.1 0.1], [0 1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--');
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(-.68,.38,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(-.68,.33, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sevidencedist.pdf', plotDir), '-dpdf')
    
    xvals = [-.5:.1:.5];
    [thisfig,maxLoc,nCounts] = plotDist(fbsep,1,1,xvals);
    ylim([0 .4])
    xlim([-.7 .7])
    title(sprintf('Subject %i Evidence Distribution, Fb Only', subjectNum))
    xlabel('Target-Lure Evidence')
    line([0.1 0.1], [0 1], 'color', 'r', 'LineWidth', 2, 'LineStyle', '--');
    line([maxLoc maxLoc], [0 1], 'color', 'k', 'LineWidth', 2);
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    text(-.68,.38,['cm = ' num2str(maxLoc)], 'FontSize', 18);
    text(-.68,.33, sprintf('fastS = %4.1f', hardSpeed(s)), 'FontSize', 18)
    print(thisfig, sprintf('%sfb_evidencedist.pdf', plotDir), '-dpdf')
    idealInd = find(xvals >0.05 & xvals <0.15);
    ratioIdeal(s) = nCounts(idealInd);
    allcm(s) = maxLoc;
    
    
    figure;
    for rep = 1:(length(allsep)/15)-1
        line([rep*nTRs+.5 rep*nTRs + .5], [-1 1], 'color', 'c', 'LineWidth', 2);
    end
    hold on
    plot(allsep,'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 6)
    xlabel('TR Number (2s)')
    ylabel('Category Evidence')
    ylim( [-.7 .7])
    xlim([1 450])
    title(sprintf('Subject: %i All Evidence' ,subjectNum));
    set(findall(gcf,'-property','FontSize'),'FontSize',20)
    % now make plots for each stimuli
    
    %%
    if plotstim
        for stim = 1:nstim
            thisfig = figure(stim*50);
            clf;
            x = 1:nTRs*nblock;
            [hAx,hLine1, hLine2] = plotyy(x,sepbystim(stim,:),x,speedbystim(stim,:));
            xlabel('TR Number (2s)')
            ylabel(hAx(2), 'Dot Speed', 'Color', 'k')
            ylabel(hAx(1), 'Category Evidence', 'Color', 'k')
            ylim(hAx(2),[-20 5])
            ylim(hAx(1), [-1 1])
            xlim([0.5 45.5])
            set(hLine2, 'LineStyle', '-', 'Color', colors(2,:), 'LineWidth', 5)
            set(hLine1, 'LineStyle', '-', 'Color', colors(1,:), 'LineWidth', 3, 'Marker', '.', 'MarkerSize', 25)
            linkaxes([hAx(1) hAx(2)], 'x');
            title(sprintf('Subject: %i Stimulus ID: %i',subjectNum,stim));
            set(findall(gcf,'-property','FontSize'),'FontSize',20)
            set(findall(gcf,'-property','FontColor'),'FontColor','k')
            set(hAx(1), 'FontSize', 12)
            set(hAx(2), 'YColor', colors(2,:), 'FontSize', 16, 'YTick', [-20:5:5]); %'YTickLabel', {'0', '1', '2', '3', '4', '5})
            set(hAx(1), 'YColor', colors(1,:), 'FontSize', 16, 'YTick', [-1:.5:1], 'YTickLabel', {'-1', '-0.5', '0', '0.5', '1'});
            hold on;
            legend('Ev', 'Dot Speed')
            for rep = 1:2
                line([rep*nTRs+.5 rep*nTRs + .5], [-10 15], 'color', 'k', 'LineWidth', 2);
            end
            line([0 46], [0.1 0.1], 'color', [140 136 141]/255, 'LineWidth', 2.5,'LineStyle', '--');
            %         savefig(sprintf('%sstim%i.fig', plotDir,stim));
            print(thisfig, sprintf('%sstim%i.pdf', plotDir,stim), '-dpdf')
        end
    end
end

%% now compare cm of feedback-adapt for RT and YC
% nold = 4;
firstgroup = allcm(iRT);
secondgroup = allcm(iYC);
avgratio = [mean(firstgroup) mean(secondgroup)];
eavgratio = [std(firstgroup)/sqrt(length(firstgroup)-1) std(secondgroup)/sqrt(length(secondgroup)-1)];
thisfig = figure;
barwitherr(eavgratio,avgratio)
set(gca,'XTickLabel' , ['RT';'YC']);
xlabel('Subject Group')
ylabel('CM of Evidence')
title('CM of Evidence by Subject Group')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
ylim([-.2 0.2])
%print(thisfig, sprintf('%scmbygroup.pdf', allplotDir), '-dpdf')

%% now look at if max dot speeds determine anything
% looking at the mean center of mass of evidence
%speed2 = hardSpeed(end-nnew+1:end);
figure;
plot(hardSpeed(iRT),allcm(iRT), 'k.', hardSpeed(iYC),allcm(iYC), 'r.');
xlabel('Staircased Speed')
ylabel('CM Evidence')

% mean dot speed used in feedback
thisfig = figure;
%plot(speed2,goodSpeed2, '.')
s = 100;
scatter(hardSpeed(iRT),goodSpeedFb(iRT), s,'fill','MarkerEdgeColor','b',...
    'MarkerFaceColor','c',...
    'LineWidth',3.5);
p = polyfit(hardSpeed(iRT),goodSpeedFb(iRT),1);
yfit = polyval(p,hardSpeed(iRT));
hold on;
plot(hardSpeed(iRT),yfit, '--k', 'LineWidth', 3)
scatter(hardSpeed(iYC),goodSpeedFb(iYC), s,'fill','MarkerEdgeColor','k',...
    'MarkerFaceColor','r',...
    'LineWidth',3.5);
xlabel('Staircased Speed')
ylabel('Mean of Good Speed during FB')
title('Good Speed vs. Staircased Speed')
set(findall(gcf,'-property','FontSize'),'FontSize',20)
%print(thisfig, sprintf('%sgoodfbspeedvsstaircased.pdf', allplotDir), '-dpdf')
