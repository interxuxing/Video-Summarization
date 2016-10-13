function [ motion_magnitude,motion_magnitude_back ] = summe_computeMotion(imageList,frameRange,FPS,Params )
%summe_computeMotion Computes the motion magnitude over a range of frames   

    fprintf('Compute forward motion\n');    
    frames=imageList(frameRange(1):frameRange(2));
    %motion是指一帧一帧同一点的位置变换，先正着算一遍，再反着算一遍，why
    motion_magnitude=getMagnitude(frames,Params,FPS);
    
    fprintf('Compute backward motion\n')    
    frames=imageList(frameRange(2):-1:frameRange(1));  
    %反着算
    motion_magnitude_back=getMagnitude(frames,Params,FPS);
    motion_magnitude_back=flip(motion_magnitude_back);
    
end
    
function [motion_magnitude]=getMagnitude(imageList,Params,FPS)
    motion_magnitude=zeros(length(imageList),1);
    for startFrame=1:Params.stepSize:length(imageList)-Params.stepSize
        % Load the first image
        frame = imread(imageList{startFrame});
        
        %如果有上次追踪的点，就从上次追踪的点开始，如果没的话就从（0，0）开始
        if ~exist('frameSize','var')
            frameSize=sqrt(size(frame,1)*size(frame,2));
        end
        if ~exist('new_points','var')
            old_points=zeros(0,2);
        else
            old_points=new_points(points_validity,:);
        end


        % Detect points
        minQual=Params.minQual;
        points=[];
        tries=0;
        %找特征点
        while (size(old_points,1)+size(points,1)) < Params.num_tracks*0.95 && tries<5 % we reinitialize only, if we have too little points
            %minqual表示可接受的角点是满足检测测度值为大于等于图像中最大检测测度值的比例，较大时可以减少误检.但是minqual越大，检测到的角
            %点越少，可能就达不到要求的track的点数。
            points=detectFASTFeatures(rgb2gray(frame),'MinQuality',minQual);
            minQual=minQual/5;
            tries=tries+1;
        end        
        if numel(points) > 0
            old_points=[old_points; points.Location];
        end
    %特征点挺多的时候，也只取num_tracks个点
        if size(old_points,1) > Params.num_tracks
            indices=randperm(size(old_points,1));
            old_points=old_points(indices(1:Params.num_tracks),:);
        end


        % Compute
        % magnitude此处用的是klt算法即点追踪，就是从特征点开始，在下一帧中寻找上一帧的特征点，
        %返回下一帧该特征点的位置，points_validity是指这个点有没有被利用
        if (length(old_points) >= Params.min_tracks) % if at least k points are detected
            % Initialize tracker
            pointTracker = vision.PointTracker;
            initialize(pointTracker,old_points,frame);
            for frameNr=1:Params.stepSize-1
                frame = imread(imageList{startFrame+frameNr});
                %返回下一帧该特征点的位置，points_validity是指这个点有没有被利用
                [new_points,points_validity] = step(pointTracker,frame);
            end

            diff=new_points(points_validity,:)-old_points(points_validity,:);
            diff=mean(norm(diff));
            %按照Params.stepSize，每Params.stepSize之间赋相同值。
            % add it to the array and normalize by frame size
            motion_magnitude(startFrame:startFrame+Params.stepSize-1)=(FPS/Params.stepSize)*diff./frameSize;
        end
    end
end

