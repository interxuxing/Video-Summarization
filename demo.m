addpath('./dof/lowdof')
addpath('../superframes_v01')
addpath('../SumMe/matlab');
HOMEDATA='../SumMe/GT/';
HOMEVIDEOS='../SumMe/videos/';
HOMEFRAMES='./frame/';
HOMEIMAGES='../test/frame';

%videoName='Uncut_Evening_Flight';
%% Take a random video
videoList=dir([HOMEVIDEOS '/*.mp4']);
[~,videoName]=fileparts(videoList(round(rand()*24+1)).name)
fileName = [HOMEVIDEOS videoName '.mp4']; 
obj = VideoReader(fileName);
numFrames = obj.NumberOfFrames;% 帧的总数
frameScore=zeros(numFrames,1);
 for k = 1 : numFrames% 读取数据
     frame = read(obj,k);
     
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算score
     feature_vector = low_depth_of_field_indicators(frame);
     frameScore(k,:)=sum(feature_vector,2)*3;
     frameScore=round(frameScore);
     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % imshow(frame);%显示帧
     imwrite(frame,strcat(HOMEFRAMES,num2str(k),'.jpg'));% 保存帧
 end
 
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算superframe
 default_parameters;
 FPS=29;
Params.lognormal.mu=1.16571;
Params.lognormal.sigma=0.742374;
%获取图片的信息，比如什么日期，大小，名称之类的
images=dir(fullfile(HOMEIMAGES,'*.jpg'));
%得到图片的路径
imageList=cellfun(@(X)(fullfile(HOMEIMAGES,X)),{images(:).name},'UniformOutput',false);

%% Run Superframe segmentation
tic
[superFrames,motion_magnitude_of] = summe_superframeSegmentation(imageList,FPS,Params);
toc


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算每一大段的得分，再解决背包问题
% load('superFrames.mat');
% load('framescore.mat');
su_score=superScore(superFrames,frameScore);
[score,list]=beibao(superFrames,su_score);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%计算F
summary_selection=evaluate(list,frameScore,superFrames);
[f_measure,summary_length]=summe_evaluateSummary(summary_selection,videoName,HOMEDATA)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
show_summary(list,imageList,superFrames);


figure