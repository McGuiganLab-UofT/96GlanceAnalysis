# 96 Well-Glance Analysis Scripts

Scripts for analyzing images of microgels from the 96-well version of the Glance model described
and presented in the article **"3D microgels to quantify tumour cell properties and therapy response dynamics"**. If you use or modify these scripts, we kindly ask you to cite the aforementioned publication.

## Requirements

We have tested these scripts with MATLAB 2019a or newer. You will also need the MATLAB image analysis toolbox.

## Usage

Download the functions in the repository and add them to your MATLAB path. Then, navigate to the directory that contains the images to be analyzed and run the "glanceSegmentationScript" file. This script loads the template image that will be used to detect the location of the Glance channel with convolution, and calls the "processGlanceWell_edge" function on all of the images. The script will export a crop of the ROI of each image, and a text file with mean gray values in these ROIs.
