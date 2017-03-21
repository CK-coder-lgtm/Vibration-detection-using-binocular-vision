%initialization
clc
load('calibrationSession.mat');
stereoParams=calibrationSession.CameraParameters;
info=imaqhwinfo;
obj_left = videoinput('winvideo',1);
obj_right = videoinput('winvideo',2);
preview(obj_left)
preview(obj_right)
pause(5);
%get initial value

frame_left = getsnapshot(obj_left);
frame_right = getsnapshot(obj_right);
%convert frame from RGB to YCBCR colorspace（转换到YCBCR空间）  
YCBCR_left = rgb2ycbcr(frame_left); 
YCBCR_right = rgb2ycbcr(frame_right); 
%filter YCBCR image between values and store filtered image to threshold  
%matrix（用各个通道的阈值对其进行二值化处理）  
%Y_MIN = 0;  Y_MAX = 256;  
%Cb_MIN = 100;   Cb_MAX = 127;  
%Cr_MIN = 138;   Cr_MAX = 170;  
Y_MIN = 0;  Y_MAX = 256;  
Cb_MIN = 100;   Cb_MAX = 127;  
Cr_MIN = 138;   Cr_MAX = 170;  
threshold_left=roicolor(YCBCR_left(:,:,1),Y_MIN,Y_MAX)&roicolor(YCBCR_left(:,:,2),Cb_MIN,Cb_MAX)&roicolor(YCBCR_left(:,:,3),Cr_MIN,Cr_MAX);  
threshold_right=roicolor(YCBCR_right(:,:,1),Y_MIN,Y_MAX)&roicolor(YCBCR_right(:,:,2),Cb_MIN,Cb_MAX)&roicolor(YCBCR_right(:,:,3),Cr_MIN,Cr_MAX);  

%perform morphological operations on thresholded image to eliminate noise  
%and emphasize the filtered object(s)（进行形态学处理：腐蚀、膨胀、孔洞填充） 
erodeElement = strel('square', 2) ;  
dilateElement=strel('square', 2) ; %控制膨胀情况 
threshold_left = imerode(threshold_left,erodeElement);  
%threshold_left = imerode(threshold_left,erodeElement);  
threshold_left=imdilate(threshold_left, dilateElement);  
%threshold_left=imdilate(threshold_left, dilateElement);  
threshold_left=imfill(threshold_left,'holes');  
%获取区域的'basic'属性， 'Area', 'Centroid', and 'BoundingBox' 
stats_left = regionprops(threshold_left, 'basic');  
row_left=[stats_left.Centroid];
length_left=size(row_left,2)/2;
Centroid_array1=reshape(row_left,2,length_left);
[maxNum1,max_index1]=max(Centroid_array1(2,:));
nail_locate_left=Centroid_array1(:,max_index1)';

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
nail_locate_right=Centroid_array2(:,max_index2)';

point3d = triangulate(nail_locate_left, nail_locate_right, stereoParams);


