%% Display the photos and groundtruth for analysis dataset
%   analysis_gt.m
%   need choose_dataset.m,choose_video.m,and parseImg.m
%   Allows the user to choose and analyze a dataset's gt
%   already test with
%   OTB100,OTB50,OTB2013,NUS-PRO,VOT2013,VOT2014,VOT2015,VOT2016,Temper-Color-128,UAV123,
%   to do 
%   ALOV300++,ILSVRC2015,NUS-PRO split to 2 parts(with gt and without gt)
%   Lijie Liu, 2017/3/21
clc
clear
%% load the photos and groundtruth in the config
basepath = 'F:';
dataset_path = choose_dataset(basepath);NUS=0;vot=0;ALOV=0;groundtruth=1;
if(strcmp(dataset_path,strcat(basepath,'/OTB100/'))==1);end;%[x,y,w,h]

if(strcmp(dataset_path,strcat(basepath,'/OTB50/'))==1);end;

if(strcmp(dataset_path,strcat(basepath,'/OTB2013/'))==1);end;

if(strcmp(dataset_path,strcat(basepath,'/NUS-PRO/'))==1);dataset_path=strcat(basepath,'/NUS-PRO/data');NUS=1;end;

if(strcmp(dataset_path,strcat(basepath,'/vot2013/'))==1);end;%[x,y,w,h]

if(strcmp(dataset_path,strcat(basepath,'/vot2014/'))==1);vot=1;end;%[x1,y1,x2,y2,x3,y3,x4,y4]

if(strcmp(dataset_path,strcat(basepath,'/vot2015/'))==1);vot=1;end;%[x1,y1,x2,y2,x3,y3,x4,y4]

if(strcmp(dataset_path,strcat(basepath,'/vot2016/'))==1);vot=1;end;%[x1,y1,x2,y2,x3,y3,x4,y4]

if(strcmp(dataset_path,strcat(basepath,'/Temple-color-128/'))==1);end;%[x,y,w,h]

if(strcmp(dataset_path,strcat(basepath,'/UAV123/'))==1);dataset_path='F:/UAV123/data_seq/UAV123/';end;%[x,y,w,h]

if(strcmp(dataset_path,strcat(basepath,'/imagedata++/'))==1);vot=1;ALOV=1;end;%[x1,y1,x2,y2,x3,y3,x4,y4] but 5 frames one label

base_path = dataset_path;
video_path = choose_video(base_path);
if(ALOV==1)
    video_path = choose_video(video_path);
end
config.imgDir = fullfile(video_path, 'img'); %has img folder
if(~exist(config.imgDir,'dir'))
    config.imgDir = video_path; %no img folder
end
config.imgList = parseImg(config.imgDir);
gtPath = fullfile(video_path, 'groundtruth_rect.txt'); %for OTB
if(~exist(gtPath,'file'))
    gtPath = fullfile(video_path, 'groundtruth.txt'); %for VOT
end
if(~exist(gtPath,'file')) %for Temple128
    fsep = filesep;
    pos_v = strfind(gtPath,fsep);
    p = gtPath(pos_v(length(pos_v)-1)+1:pos_v(length(pos_v))-1); % -1: delete the last character '/' or '\'
    gtPath = fullfile(video_path, strcat(p,'_gt.txt'));
end
if(~exist(gtPath,'file')) %for UAV123
    fsep = filesep;
    pos_v = strfind(gtPath,fsep);
    p = gtPath(pos_v(length(pos_v)-1)+1:pos_v(length(pos_v))-1); % -1: delete the last character '/' or '\'
    gtPath = fullfile('F:/UAV123/anno/UAV123',strcat(p,'.txt'));
end
if(~exist(gtPath,'file')) %for ALOV
    fsep = '/';
    pos_v = strfind(video_path,fsep);
    p1 = video_path(pos_v(length(pos_v)-2)+1:pos_v(length(pos_v)-1)-1); %parent catagory
    p2 = video_path(pos_v(length(pos_v)-1)+1:pos_v(length(pos_v))-1); % filename
    gtPath = fullfile('F:\alov300++_rectangleAnnotation_full',p1,strcat(p2,'.ann'));
end
if(~exist(gtPath,'file')) %for NUS-PRO no groundtruth
    groundtruth=0;
end
if(groundtruth==1)
    config.gt = importdata(gtPath);
end

if(ALOV==1&&groundtruth==1)
    gt = config.gt;
    for To = 1:length(config.imgList)
        i=floor(To/5)+1;
        gt2(To,:)=gt(i,2:9);
    end        
    config.gt = gt2;
end

nFrames = length(config.imgList);
for To = 1:nFrames
    img = imread(config.imgList{To});
    size(img(1));
    figure(1);
    set(gcf,'Position',[50 50 size(img,2) size(img,1)],'MenuBar','none','ToolBar','none');
    hd = imshow(img,'initialmagnification','fit'); hold on;
    %initial magnification 'fit' Scale the entire image to fit the window
    if(groundtruth==0)
        %do nothing for NUS-PRO without gt
    elseif(vot==1)
        line([config.gt(To,1) config.gt(To,3)],[config.gt(To,2) config.gt(To,4)],'Color', [1 0 0], 'Linewidth', 2); %(x1,x2)(y1,y2)
        line([config.gt(To,3) config.gt(To,5)],[config.gt(To,4) config.gt(To,6)],'Color', [1 0 0], 'Linewidth', 2);
        line([config.gt(To,5) config.gt(To,7)],[config.gt(To,6) config.gt(To,8)],'Color', [1 0 0], 'Linewidth', 2);
        line([config.gt(To,7) config.gt(To,1)],[config.gt(To,8) config.gt(To,2)],'Color', [1 0 0], 'Linewidth', 2);
    elseif(NUS==1)
        rectangle('Position', [config.gt(To,1) config.gt(To,2) config.gt(To,3)-config.gt(To,1) config.gt(To,4)-config.gt(To,2)], 'EdgeColor', [1 0 0], 'Linewidth', 2); %red is gt
    else
        rectangle('Position', config.gt(To,1:4), 'EdgeColor', [1 0 0], 'Linewidth', 2); %red is gt   RGB ex. [0.4 0.6 0.7]
    end
    set(gca,'position',[0 0 1 1]);    %gca get current axis handle
    %[left bottom width height] width means width multiple
    text(10,10,num2str(To),'Color','y', 'HorizontalAlignment', 'left', 'FontWeight','bold', 'FontSize', 30);
    hold off;
    drawnow;
    %pause(0.1); %for slow analysis
end