function [imgROI, mROI, CV, xM, yM] = processGlanceWell_edge(img, imgT, sROI)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Function to process an image from 96-GLANCE. The function processes a
% stitched image of a well and uses a fixed template as a mask for locating
% the center of the Glance channel by finding its top and bottom edges
% (outline)

% Jose Cadavid, University of Toronto, 2021

% Inputs:
%     img = single-channel grayscale image (raw) of the full GLANCE well,
%           converted to double
%     imgT = Template with the mask to find the top and bottom edges
%           of the Glance channel. Should be converted to single or double
%     sROI = 2x1 vector with the size of the ROI in pixels

% Outputs:
%     imgROI = cropped image corresponding to the rectangular ROI
%     mROI = mean gray value in ROI

%% Process image to find location of the channel

% Get size of template image
[sxT, syT]= size(imgT);

% Filter image - blur slightly to get a better location of the channel.
% Size of Gaussian kernel should change for images acquired with a
% different magnification. Size 3 works the best for these images
imgF = imgaussfilt(img, 3);

% Resize filtered image to find the channel faster (fewer convolutions)
imgF = imresize(imgF,0.5);

% Log transform image - this enhances the contrast of the image and
% equalizes the histogram a bit
imgLog = log(imgF + 1);

% Get gradient of image in vertical direction (which should align with
% channels. Log transform gradient, it seems to improve accuracy
[~,Gy] = imgradientxy(imgLog);
imgGrad = log(1+abs(Gy));

% Do convolution of the gradient with the template. We are trying to find
% the point at which the edges of the channel line up with the theoretical
% edges (given by the template)
imgConv = conv2(imgGrad, imgT, 'valid');
%imgConv = conv2(double(imbinarize(rescale(imgLog))), imgT, 'valid');
% Get location of maximum overlap - tentative center of channel. maxC is
% the maximum correlation; it should ideally be 1 indicating a perfect
% match between channel and template channel. If it's too low, we can also
% say that the quality of the channel was bad, either due to seeding or to
% segmentation, so we can flag it
[~,idx]=max(imgConv(:));

% Get coordinates of maximum point. xM is an index for a row, and yM is an
% index for a column
[xM,yM]=ind2sub(size(imgConv),idx);

% Correct coordinates to align with center of the template
xM = xM + round(sxT/2) ;
yM = yM + round(syT/2);

%% Process ROI: Different functionalities can be added

% Correct coordinates to account for the 50% scaling done to the images
xM = 2*xM;
yM = 2*yM;

% Get rectangular ROI from raw grayscale image
imgROI = img(xM-round(sROI(1)/2):xM+round(sROI(1)/2), yM-round(sROI(2)/2):yM+round(sROI(2)/2));

% Get 10 ROI withing ROI to analyze spatial distribution of cells
mSubROI = zeros(10,1);

for i=1:10
    subROI = imgROI(:,(i-1)*round(sROI(2)/10)+1:i*round(sROI(2)/10));
    mSubROI(i) = mean(subROI,'all');
end

% Get mean gray value in entire ROI (from the raw image)
mROI = mean(imgROI,'all');

% Get coefficient of variation from sub ROIs
CV = 100*std(mSubROI)/mean(mSubROI);
