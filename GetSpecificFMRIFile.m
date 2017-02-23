
function [fileAvail specificFile] = GetSpecificFMRIFile(imgDir,scanNum,fileNum)

%2 digit scan string
scanStr = num2str(scanNum, '%2.2i');

%3 digit file string
fileStr = num2str(fileNum, '%3.3i');

specificFile = ['001_0000' scanStr '_000' fileStr '.dcm'];

if exist([imgDir specificFile],'file');
    fileAvail = 1;
else
    fileAvail = 0;
end