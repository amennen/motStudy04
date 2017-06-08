%% now do the same thing for newest data
oldDir = '/Data1/code/motStudy04/code/';
cd(oldDir)
projectName = 'motStudy04';
allspeeds = [];
allsep = [];
nstim = 10;
nTRs = 30;
sepTRs = 17;
FBTRs = 25;
nblock = 3;
goodRange = [0 0.2]; % change back to 0.5 0.15 from wide

svec = [4:8];

nsub = length(svec);
sepbystimC = zeros(nstim,nTRs*3,nsub);

speedH = 1;
speedL = speedH * -1; %now change code for loop
for s = 1:nsub
    subjectNum = svec(s);
    timecourse_high = [];
    timecourse_low = [];
    for iblock = 1:nblock
        blockNum = iblock;
        SESSION = 20 + blockNum;
        %blockNum = SESSION - 20 + 1;
        save_dir = ['/Data1/code/' projectName '/data/' num2str(subjectNum) '/']; %this is where she sets the save directory!
        behavioral_dir = [fileparts(which('mot_realtime04.m')) '/BehavioralData/' num2str(subjectNum) '/'];
        runHeader = fullfile(save_dir,[ 'motRun' num2str(blockNum) '/']);
        fileSpeed = dir(fullfile(behavioral_dir, ['mot_realtime04_' num2str(subjectNum) '_' num2str(SESSION)  '*.mat']));
        names = {fileSpeed.name};
        dates = [fileSpeed.datenum];
        [~,newest] = max(dates);

        matlabOpenFile = [behavioral_dir '/' names{newest}];
        d = load(matlabOpenFile);
        allMotionTRs = convertTR(d.timing.trig.wait,d.timing.plannedOnsets.motion,d.config.TR); %row,col = mTR,trialnumber
        allMotionTRs = allMotionTRs + 4;%[allMotionTRs; allMotionTRs(end,:)+1; allMotionTRs(end,:) + 2]; %add in the next 2 TR's for HDF
        %onlyFbTRs = allMotionTRs(5:end,:);
        TRvector = reshape(allMotionTRs,1,numel(allMotionTRs));
        %FBTRVector = reshape(onlyFbTRs,1,numel(onlyFbTRs));
        run = dir([runHeader '*AVGmotpatternsdata_' num2str(SESSION) '*']);
        names = {run.name};
        dates = [run.datenum];
        [~,newest] = max(dates);
        run = load(fullfile(runHeader,run(end).name));
        categsep = run.patterns.categsep(TRvector - 20); %minus 10 because we take out those 10
        sepbytrial = reshape(categsep,nTRs,10); %right now TR x Trial
        sepbytrial = sepbytrial'; %results by trial number x TR number so 10 x 15
        [~,indSort] = sort(d.stim.id);
        sepinorder = sepbytrial(indSort,:);
        sepbystimC(:,(iblock-1)*nTRs + 1: iblock*nTRs,s ) = sepinorder;
        FBsepbystim(:,(iblock-1)*FBTRs + 1: iblock*FBTRs ) = sepinorder(:,6:end);
        
         % now get all the speed changes
        allSpeed = d.stim.motionSpeed;
        speedbytrial = allSpeed'; %now it's trial x TR's
        speedinorder = speedbytrial(indSort,:);
        speedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs,s ) = speedinorder;
        % PID
        OptimalForget = 0.15;
        maxIncrement = 0.625; %will also have to check this
        Kp = 5;
        Ki = .0; %changed after RT worksop from 0.01
        Kd = .5;
        
        for itrial = 1:10
            calcspeedinorder(itrial,1) = speedinorder(itrial,1);
            for t = 1:30
                if t >1
                    speedNew = calcspeedinorder(itrial,t-1) + PID(calcspeedinorder(itrial,1:t-1),Kp,Ki,Kd,OptimalForget,maxIncrement);
                    calcspeedinorder(itrial,t) = speedNew;
                end
            end
        end
        calcspeedbystim(:,(iblock-1)*nTRs + 1: iblock*nTRs,s ) = calcspeedinorder;
       %subtract to get the difference in speed
        FBds = diff(speedinorder,[],2);
        FBdsbystim(:,(iblock-1)*FBTRs + 1: iblock*FBTRs ) = FBds(:,5:end);
        
        % look how separation evidence is changing by TR
        %allDiff = diff(diff(sepinorder(:,5:end),1,2),1,2)/4;
        %secondDiff = reshape(allDiff,1,numel(allDiff));
        %zTR = length(secondDiff);
        %allSecondDiffB(s,(iblock-1)*zTR + 1: iblock*zTR) = secondDiff;
        % now see how timecourses change
        
        %take this out if going from SPEED and NOT EVIDENCE!
%         for i = 1:nstim % because we're using all the stimuli now
%             tcourse = sepbytrial(i,:);
%             x1 = 1:length(tcourse);
%             x2 = 1:.5:length(tcourse);
%             y2 = interp1q(x1',tcourse',x2');
%             for j = 3:length(y2) - avgRange
%                 if y2(j-1) < highB && y2(j) > highB %then this is a POSITIVE CROSSING POINT
%                     timecourse_high(end+1,:) = y2(j-2:j+avgRange);
%                 elseif y2(j-1) > lowB && y2(j) < lowB %% then this is a NEGATIVE crossing point
%                     timecourse_low(end+1,:) = y2(j-2:j+avgRange);
%                 end
%             end
%         end
    
       %would be +-1.25 because that's what the setting for max increase
        %or decrease?
        avgRange = 12;
        timecourse_high = nan(1,15); %because that's the number of time points in the timecourse
        timecourse_low = nan(1,15);
        for i = 1:nstim % because we're using all the stimuli now
            tcourse = sepbytrial(i,:);
            dscourse = FBds;
            x1 = 1:length(dscourse);
            x2 = 1:1:length(dscourse);
            y2 = interp1q(x1',dscourse',x2');
            
            x1s = 1:length(tcourse);
            x2s = 1:1:length(tcourse);
            y2s = interp1q(x1',tcourse',x2');
            for j = 3:length(y2) - avgRange -1
                if y2(j-1) < speedH && y2(j) > speedH %then this is a POSITIVE CROSSING POINT
                    timecourse_high(end+1,:) = y2s(j-2+1:j+avgRange+1);
                elseif y2(j-1) > speedL && y2(j) < speedL %% then this is a NEGATIVE crossing point
                    timecourse_low(end+1,:) = y2s(j-2+1:j+avgRange+1); %you go + 1 because of the index difference
                end
            end
        end
    end
    %take the average of nTRs in range
    %remove feedback and just look at all datapoints
    z1 =find(FBsepbystim>=goodRange(1));
    z2 = find(FBsepbystim<=goodRange(2));
    nGoodRangeC(s) = length(intersect(z1,z2))/numel(FBsepbystim);
    nConsecC(s) = sum(diff(intersect(z1,z2))==1)/numel(FBsepbystim);
    nLowC(s) = length(find(FBsepbystim<=goodRange(1)))/numel(FBsepbystim);
    nHighC(s) = length(find(FBsepbystim>=goodRange(2)))/numel(FBsepbystim);
    vectorSepC(s,:) = reshape(FBsepbystim,1,numel(FBsepbystim));
     if isnan(timecourse_high)
        avg_highC(s,:) = nan(1,30);
    else
        avg_highC(s,:) = nanmean(timecourse_high);
    end
    if isnan(timecourse_low)
        avg_lowC(s,:) = nan(1,30);
    else
        avg_lowC(s,:) = nanmean(timecourse_low);
    end
    timetohigh = [];
    timetolow = [];
    for i = 1:nstim
        tcourse = sepbystimC(i,:,s);
        pointsLow = find(tcourse<0);
        pointsHigh = find(tcourse>0.2);
        difftogethigh = [];
        difftogetlow = [];
        if ~isempty(pointsLow)
            for j = 1:length(pointsLow)
                if pointsLow(j) < length(tcourse) % only look if not at the end
                    inspect = tcourse(pointsLow(j)+1:end);
                    nextpoint = find(inspect>0);
                    if ~isempty(nextpoint)
                        difftogethigh(end+1) = (nextpoint(1) + pointsLow(j)) - pointsLow(j);
                    end
                end
            end
        end
        if ~isempty(pointsHigh)
            for j = 1:length(pointsHigh)
                if pointsHigh(j) < length(tcourse) % only look if not at the end
                    inspect = tcourse(pointsHigh(j)+1:end);
                    nextpoint = find(inspect<0.2);
                    if ~isempty(nextpoint)
                        difftogetlow(end+1) = (nextpoint(1) + pointsHigh(j)) - pointsHigh(j);
                    end
                end
            end
        end
        timetohigh(i) = mean(difftogethigh);
        timetolow(i) = mean(difftogetlow);
        
    end
    alltimehighC(s) = nanmean(timetohigh);
    alltimelowC(s) = nanmean(timetolow);
end
%%
folder= '/jukebox/norman/amennen/PythonMot4';
save('AVGcompareExp4.mat','nGoodRangeC', 'speedbystim', 'avg_highC','avg_lowC', 'nLowC',  'nHighC', 'vectorSepC', 'nConsecC', 'sepbystimC',  'alltimehighC', 'alltimelowC');
unix(['scp ' 'AVGcompareExp4.mat' ' amennen@apps.pni.princeton.edu:' folder '/' ])

