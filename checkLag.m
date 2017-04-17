% check lag in file receiving
z = load('BehavioralData/2/mot_realtime04_2_21_14Apr17_1418.mat')
newFile = z.rtData.newestFile;
delay = [];
for f =1:length(newFile)
    name = newFile{f};
    if ~isempty(name)
    startI = 5;
    fileNumber = str2double(name(startI:(length(name)-4)));
    delay(end+1) = f-fileNumber;
    end
end