%% example dicom file: convert to nifti
% new dicom files
projectName = 'motStudy04';
runNum = 2;
subjectName = [datestr(now,5) datestr(now,7) datestr(now,11) num2str(runNum) '_' projectName];
dicom_dir = ['/Data1/subjects/' datestr(now,10) datestr(now,5) datestr(now,7) '.' subjectName '.' subjectName '/'];
imgDir = dicom_dir;
bxhpath='/opt/BXH/1.11.1/bin/';
fslpath='/opt/fsl/5.0.9/bin/';
roi_dir = ['/Data1/code/' projectName '/data/'];

% now the scout outputs one series of files
scanNum = 2; % for T1
t1fn = 'highres';
t1re = 'highres_re';
highresfiles_genstr = sprintf('%s001_00000%s_0*',dicom_dir,num2str(scanNum)); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,highresfiles_genstr,t1fn));
%reorient bxh wrapper
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,t1fn,t1re));
%convert the reoriented bxh wrapper to a nifti file
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,t1re,t1re))
unix(sprintf('%sbet %s.nii.gz %s_brain.nii.gz -R',fslpath,t1re,t1re)) %really weird this runs on 

%register standard to high res
unix(sprintf('%sflirt -in %s_brain.nii.gz -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -out highres2standard -omat highres2standard.mat -cost corratio -dof 12 -searchrx -30 30 -searchry -30 30 -searchrz -30 30 -interp trilinear',fslpath,t1re));
unix(sprintf('%sfnirt --iout=highres2standard_head --in=%s.nii.gz --aff=highres2standard.mat --cout=highres2standard_warp --iout=highres2standard --jout=highres2highres_jac --config=T1_2_MNI152_2mm --ref=$FSLDIR/data/standard/MNI152_T1_2mm.nii.gz --refmask=$FSLDIR/data/standard/MNI152_T1_2mm_brain_mask_dil --warpres=10,10,10', fslpath,t1re));
unix(sprintf('%sapplywarp -i %s_brain.nii.gz -r $FSLDIR/data/standard/MNI152_T1_2mm_brain.nii.gz -o highres2standard -w highres2standard_warp',fslpath,t1re));
%compute inverse transform (standard to highres)
unix(sprintf('%sconvert_xfm -inverse -omat standard2highres.mat highres2standard.mat', fslpath));
unix(sprintf('%sinvwarp -w highres2standard_warp -o standard2highres_warp -r %s_brain.nii.gz',fslpath,t1re));

% ran script below to reoient
% collect field map images
% now new images are file numbers 3 and 4
% convert to dicom first?
%test
% first convert to nifti
%AP SCAN FIRST = 3
scanNum = 3;
APname = 'SE_AP';
AP_re = [APname '_re'];
AP_genstr = sprintf('%s001_00000%s_0*',dicom_dir,num2str(scanNum));
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,AP_genstr,APname));
%reorient bxh wrapper
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,APname,AP_re));
%convert the reoriented bxh wrapper to a nifti file
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,AP_re,AP_re))

% now do the same thing with PA
scanNum = 4;
PAname = 'SE_PA';
PA_re = [PAname '_re'];
PA_genstr = sprintf('%s001_00000%s_0*',dicom_dir,num2str(scanNum));
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,PA_genstr,PAname));
%reorient bxh wrapper
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,PAname,PA_re));
%convert the reoriented bxh wrapper to a nifti file
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,PA_re,PA_re))

% now combine them into a single image
time1 = GetSecs;
fieldmapfn = 'all_SE';
unix(sprintf('%sfslmerge -t %s.nii.gz %s.nii.gz %s.nii.gz', fslpath,fieldmapfn,AP_re,PA_re))

% now run topup! 
multipath = '/Data1/code/multibandutils/';
textfile = 'acqparams.txt';
cnffile = 'b02b0.cnf';
unix(sprintf('%stopup --imain=%s.nii.gz --datain=%s%s --config=%s%s --out=topup_output --iout=topup_iout --fout=topup_fout --logout=topup_logout',fslpath,fieldmapfn,multipath,textfile,multipath,cnffile))

% create magnitude image from topup
unix(sprintf('%sfslmaths topup_iout -Tmean magnitude',fslpath))
% create brain-extracted magnitude image
unix('module load fsl/5.0.9') 
unix(sprintf('%sbet magnitude magnitude_brain',fslpath)) %really weird this runs on 
unix(sprintf('%sfslmaths topup_fout.nii.gz -mul 6.28 fieldmap_rads',fslpath))
time2 = GetSecs;

% look at difference between 2: 
fieldt = time2-time1; % took 519 seconds with all 3 scans (8.5 minutes)
% try for 1 and 3 files
% now after collecting epi can then run epi_reg
scanNum = 5; % not using pace right now
exffn = 'exfunc';
exfre = 'exfunc_re';
exfunc_genstr = sprintf('%s001_00000%s_0*',dicom_dir,num2str(scanNum)); %general string for ALL mprage files**
unix(sprintf('%sdicom2bxh %s %s.bxh',bxhpath,exfunc_genstr,exffn));
%reorient bxh wrapper
unix(sprintf('%sbxhreorient --orientation=LAS %s.bxh %s.bxh',bxhpath,exffn,exfre));
%convert the reoriented bxh wrapper to a nifti file
unix(sprintf('%sbxh2analyze --overwrite --analyzetypes --niigz --niftihdr -s %s.bxh %s',bxhpath,exfre,exfre))

% now register to highres!
t1 = GetSecs;
exfunc2highres_mat='example_func2highres';
highres2exfunc_mat='highres2example_func';
unix(sprintf('%sepi_reg --epi=%s.nii.gz --t1=%s.nii.gz --t1brain=%s_brain.nii.gz --out=%s --fmap=fieldmap_rads --fmapmag=magnitude --fmapmagbrain=magnitude_brain --echospacing=0.000345 --pedir=y',fslpath,exfre,t1re,t1re,exfunc2highres_mat))
timefunc2highres = GetSecs-t1;
unix(sprintf('%sconvert_xfm -inverse -omat %s.mat %s.mat',fslpath,highres2exfunc_mat,exfunc2highres_mat));

% now register mask to all data
roi_name = 'retrieval';
unix(sprintf('%sapplywarp -i %s%s.nii.gz -r %s.nii.gz -o %s_exfunc.nii.gz -w standard2highres_warp.nii.gz --postmat=%s.mat',fslpath,roi_dir,roi_name,exfre,roi_name,highres2exfunc_mat));
% check after here that the applied warp is binary and in the right
% orientation so we could just apply to nifti files afterwards
if exist(sprintf('%s_exfunc.nii.gz',roi_name),'file')
    unix(sprintf('gunzip %s_exfunc.nii.gz',roi_name));
end
