%%% Script for processing 96-GLANCE images, finding the location of the
%%% channel and getting mean grey values

%%% Jose Cadavid, University of Toronto, 2021

% V2: Changed the procedure to use a mask for detecting edges, instead of a
% full template of the channel

%% Initialize

% Load image template (must be in folder with codes). Template is a png
% image so we make it a binary image with a single channel. The template is
% perfectly centered
imgT = imread('topEdgeMask_chopped.png');
  %imgT = imread('channel_template_chopped.png');
imgT = imgT(:,:,1)>0;

% Resize template by 50% so the template matching is faster
imgT = imresize(imgT,0.5) == 1;
% Convert to single to do convolutions
imgT = single(imgT);

% ROI size in pixels
sROI = [430, 700];

% Create text file (must add a meaningful name, and this function should
% loop across folders
fid = fopen('results.txt','w');
% Print headers
fprintf(fid,"%s\t%s\t%s \n",'Image', 'Mean gray value', 'CV (%)');

%% Batch process folder

% Get list of files in folder
list = dir(cd);
%Get list of actual images in rep (images are NOT folders. Images should be
%tiff files
imgs={list(~[list.isdir]).name};
ii = 0;
% Loop through files
for i=1:numel(imgs)
    % Name of file
    nameImg = imgs{i};
    % NW: skip extended attribute files i.e. ._
    if startsWith(nameImg,'._')
        continue;
    end
    % Only process if file is tif format (i.e. an image) and it is not a
    % crop
    if endsWith(nameImg,'.tif') && ~contains(nameImg,'crop')
        ii = ii + 1;
        % Load image to be processed - convert to double
        img = double(imread(nameImg));
        disp(strcat('Processing image #', num2str(ii)));
        % Process to find location of the channel and get mean gray value in
        % ROI
        [imgROI, mROI, CV, xM, yM] = processGlanceWell_edge(img, imgT, sROI);
        % Print results
        fprintf(fid, "%s\t%.2f\t%.2f \n",nameImg, mROI, CV);
        % Store the centroids in another matrix
        posAuto(ii,:) = [xM, yM];
        % Save image crop
        imwrite(uint16(imgROI),strcat('crop',nameImg));

        % Plot channel and ROI - uncomment if you want to see the images and the detected ROI
        % imagesc(rescale(log(img+1)))
        % % Set aspect ratio and remove ticks
        % axis image
        % axis off
        % colormap bone
        % hold on
        % % Add detected center and ROI
        % scatter(yM,xM,'ro','filled')
        % plot([yM-sROI(2)/2, yM+sROI(2)/2, yM+sROI(2)/2, yM-sROI(2)/2, yM-sROI(2)/2],...
        %     [xM-sROI(1)/2, xM-sROI(1)/2, xM+sROI(1)/2, xM+sROI(1)/2, xM-sROI(1)/2],'r--','linewidth', 1.5)

        clf
    end
end

% Close file
fclose(fid);
