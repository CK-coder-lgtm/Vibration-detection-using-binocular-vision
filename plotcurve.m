distance=zeros(600,1);
t=(0:0.1:59.9)';
for i=1:600
    starttime=clock;
    frame_left = getsnapshot(obj_left);
    frame_right = getsnapshot(obj_right);
    %formatSpec1='frame_right_%3d.jpg';
    %formatSpec2='frame_left_%3d.jpg';
    %imagename1=sprintf(formatSpec1,i);
    %imagename2=sprintf(formatSpec2,i);
    %imwrite(frame_right,imagename2,'jpg');
    %imwrite(frame_left,imagename1,'jpg');
    YCBCR_left = rgb2ycbcr(frame_left); 
    YCBCR_right = rgb2ycbcr(frame_right); 
    Y_MIN = 0;  Y_MAX = 256;  
    Cb_MIN = 100;   Cb_MAX = 127;  
    Cr_MIN = 138;   Cr_MAX = 170;  
    threshold_left=roicolor(YCBCR_left(:,:,1),Y_MIN,Y_MAX)&roicolor(YCBCR_left(:,:,2),Cb_MIN,Cb_MAX)&roicolor(YCBCR_left(:,:,3),Cr_MIN,Cr_MAX);  
    threshold_right=roicolor(YCBCR_right(:,:,1),Y_MIN,Y_MAX)&roicolor(YCBCR_right(:,:,2),Cb_MIN,Cb_MAX)&roicolor(YCBCR_right(:,:,3),Cr_MIN,Cr_MAX);  
    erodeElement = strel('square',2) ;  
    dilateElement=strel('square', 2) ; %控制膨胀情况 4,2
    threshold_left = imerode(threshold_left,erodeElement); 
    %threshold_left = imerode(threshold_left,erodeElement);     
    threshold_left=imdilate(threshold_left, dilateElement);  
    %threshold_left=imdilate(threshold_left, dilateElement);  
    threshold_left=imfill(threshold_left,'holes');  
    stats_left = regionprops(threshold_left, 'basic');  
    row_left=[stats_left.Centroid];
    length_left=size(row_left,2)/2;
    Centroid_array1=reshape(row_left,2,length_left);
    [maxNum1,max_index1]=max(Centroid_array1(2,:));
    nail_locate_left_trans=Centroid_array1(:,max_index1)';

    threshold_right = imerode(threshold_right,erodeElement); 
    %threshold_right = imerode(threshold_right,erodeElement); 
    threshold_right=imdilate(threshold_right, dilateElement);  
    %threshold_right=imdilate(threshold_right, dilateElement);  
    threshold_right=imfill(threshold_right,'holes');  
    stats_right = regionprops(threshold_right, 'basic');  
    row_right=[stats_right.Centroid];
    length_right=size(row_right,2)/2;
    Centroid_array2=reshape(row_right,2,length_right);
    [maxNum2,max_index2]=max(Centroid_array2(2,:));
    nail_locate_right_trans=Centroid_array2(:,max_index2)';
    
    %calculate the distance and plot the figure
     point3d_trans= triangulate(nail_locate_left_trans, nail_locate_right_trans, stereoParams);
     distance(i,1)=(point3d_trans(1,1)-point3d(1,1))/1000;
     %distance(i,1)=norm(point3d_trans-point3d)/1000;
 %    if distance(i,1)>0.12
 %        distance(i,1)=distance(i-1,1);
 %    end
    plot(t,distance);
    axis([0,60,-0.2,0.2]);
            xlabel('时间/s');
            ylabel('位移/m');
    plottime=clock;
    while etime(plottime,starttime)<0.1
        pause(0.001);
        plottime=clock;
    end
end
