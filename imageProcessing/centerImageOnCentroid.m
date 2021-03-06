function [centeredImage,centeredManipImage] = centerImageOnCentroid(imageFile,maskInfo,centeredDims,bgColor,cropImage,plotSteps,manipulations)
% function [centeredImage,centeredManipImage] = centerImageOnCentroid(imageFile,mask_file,centeredDims,bgColor,cropImage,plotSteps,manipulations)
%
% Description:
%  Centers images on the centroid (center of mass). Expects images with
%  cropped-out objects on uniform backgrounds.
%
% Input:
%  imageFile:     image file path (string).
%  maskInfo:      black-background white-object mask file path (string).
%                 can also be a threshold number at which to auto-mask.
%                 or empty to make not as good of a mask. optional.
%                 (Default: [])
%  centeredDims:  [x y] dimensions of the output image. optional. (Default:
%                 the same size as the input image.)
%  bgColor:       single scalar digit reperesenting the background color
%                 (e.g., 210 for gray). optional. (Default: the most common
%                 color outside of the identified object.)
%  cropImage:     true/false. whether to crop the image. optional.
%                 (Default: true)
%  plotSteps:     true/false. whether to plot each step. optional.
%                 (Default: false)
%  manipulations: optional. two-element cell array containing the
%                 familyName as the first element and the image
%                 manipulation strings to be appended as part of the family
%                 name as the second element.
%                 (Default: {})
%
% Output:
%  centeredImage:       the image, centered on the centroid
%  centeredManipImage:  cell array of the translated manipulated image(s)
%
% NB: uses the function imtranslate(), from the MATLAB File Exchange:
%     http://www.mathworks.com/matlabcentral/fileexchange/27251-imtranslate
%
% See also: IMTRANSLATE
%

if ~exist('plotSteps','var') || isempty(plotSteps)
  plotSteps = false;
end

if ~exist('cropImage','var') || isempty(cropImage)
  cropImage = true;
end

if ~exist('manipulations','var')
  manipulations = {};
end
if ~isempty(manipulations) && cropImage == true
  warning('when using manipulations, cropImage must be false; setting cropImage = false');
  cropImage = false;
end

if ~exist('maskInfo','var') || isempty(maskInfo)
  maskInfo = [];
end

if exist(imageFile,'file')
  im = imread(imageFile);
else
  error('image file %s does not exist',imageFile);
end

if ~isempty(maskInfo)
  if ischar(maskInfo)
    if exist(maskInfo,'file')
      processMaskType = 'external';
      im_mask = imread(maskInfo);
    else
      error('mask file %s does not exist',maskInfo);
    end
  elseif isnumeric(maskInfo)
    processMaskType = 'internal';
  end
else
  processMaskType = 'auto';
end

if strcmp(processMaskType,'external')
  if size(im,1) ~= size(im_mask,1) || size(im,2) ~= size(im_mask,2)
    error('image and mask are not the same size');
  end
end

if ~exist('centeredDims','var') || isempty(centeredDims)
  out_x = size(im,1);
  out_y = size(im,2);
else
  out_x = centeredDims(1);
  out_y = centeredDims(2);
end
% out_xy = [out_x out_y];

if strcmp(processMaskType,'external')
  % convert to gray scale
  im_gray = rgb2gray(im_mask);
  
  % % Bright objects will be the chosen if you use >.
  im_bw = im_gray > 100;
elseif strcmp(processMaskType,'internal')
  % convert to gray scale
  im_gray = rgb2gray(im);
  
  % use Simen's makeMask function to create a mask
  im_bw = makeMask(false,im_gray,maskInfo,0);
elseif strcmp(processMaskType,'auto')
  % convert to gray scale
  im_gray = rgb2gray(im);
  
  % Dark objects will be the chosen if you use <.
  im_bw = im_gray < 100;
end
if plotSteps
  figure;
  imshow(im_bw);
  title('bw');
end

% Do a "hole fill" to get rid of any background pixels.
im_bw = imfill(im_bw, 'holes');
if plotSteps
  figure;
  imshow(im_bw);
  title('bw holes');
end

if strcmp(processMaskType,'external')
  L = logical(im_bw);
elseif strcmp(processMaskType,'internal')
  L = logical(rgb2gray(im_bw));
elseif strcmp(processMaskType,'auto')
  % Label the disconnected foreground regions (using 8 conned neighbourhood)
  L = bwlabel(im_bw, 8);
end

% get the most common gray background value
if ~exist('bgColor','var') || isempty(bgColor)
  bgColor = mode(double(im(repmat(L,[1,1,3]) == 0)));
end

if strcmp(processMaskType,'auto')
  % only get the first object
  L(L ~= 1) = 0;
end

if cropImage
  % Get the bounding box around each object
  bb = regionprops(L, 'BoundingBox');
  %bbs = cat(1, bb.BoundingBox);
  thisBB = bb(1).BoundingBox;
  
  % trim the image to the bounding box
  im_bb = im(floor(thisBB(2)):(thisBB(4)+ceil(thisBB(2))),floor(thisBB(1)):(thisBB(3)+ceil(thisBB(1))),:);
  % im_bw_bb = im_bw(floor(bbs(2)):(bbs(4)+ceil(bbs(2))),floor(bbs(1)):(bbs(3)+ceil(bbs(1))),:);
  L_bb = L(floor(thisBB(2)):(thisBB(4)+ceil(thisBB(2))),floor(thisBB(1)):(thisBB(3)+ceil(thisBB(1))),:);
else
  im_bb = im;
  L_bb = L;
end
% calculate the centroid
stat = regionprops(L_bb, 'Centroid');
%centroids = round(cat(1, stat.Centroid));
thisCentroid = round(stat(1).Centroid);
if plotSteps
  figure
  imshow(im_bb);
  hold on
  plot(thisCentroid(:,1), thisCentroid(:,2), 'r*');
  hold off
  title('centroid');
end

%% grow around the centroid so it is in the middle

cent_x = thisCentroid(1);
cent_y = thisCentroid(2);

% cropped image dimensions
im_bb_x = size(im_bb,2);
im_bb_y = size(im_bb,1);

if cent_x < (im_bb_x / 2)
  leftCentroid = true;
  centerXCentroid = false;
elseif cent_x > (im_bb_x / 2)
  leftCentroid = false;
  centerXCentroid = false;
else
  leftCentroid = false;
  centerXCentroid = true;
end

if cent_y < (im_bb_y / 2)
  topCentroid = true;
  centerYCentroid = false;
elseif cent_y > (im_bb_y / 2)
  topCentroid = false;
  centerYCentroid = false;
else
  topCentroid = false;
  centerYCentroid = true;
end

if ~centerXCentroid
  if leftCentroid
    % expand to the left
    add_x = (im_bb_x - cent_x) - cent_x;
    
    % if it's going to be bigger than the background layer, add less
    if im_bb_x + add_x > out_x
     add_x = out_x - im_bb_x;
    end
    
    if im_bb_x + add_x < out_x
      trans2_x = (out_x - (im_bb_x + add_x)) / 2;
    else
      trans2_x = 0;
    end
  elseif ~leftCentroid
    % expand to the right
    add_x = cent_x - (im_bb_x - cent_x);
    
    % if it's going to be bigger than the background layer, add less
    if im_bb_x + add_x > out_x
     add_x = out_x - im_bb_x;
    end
    
    if im_bb_x + add_x < out_x
      trans2_x = (out_x - (im_bb_x + add_x)) / 2;
    else
      trans2_x = 0;
    end
  end
else
  %trans2_x = 0;
  trans2_x = (out_x - im_bb_x) / 2;
end

if ~centerYCentroid
  if topCentroid
    % expand to the top
    add_y = (im_bb_y - cent_y) - cent_y;
    
    % if it's going to be bigger than the background layer, add less
    if im_bb_y + add_y > out_y
     add_y = out_y - im_bb_y;
    end
    
    if im_bb_y + add_y < out_y
      trans2_y = (out_y - (im_bb_y + add_y)) / 2;
    else
      trans2_y = 0;
    end
  elseif ~topCentroid
    % expand to the bottom
    add_y = cent_y - (im_bb_y - cent_y);
    
    % if it's going to be bigger than the background layer, add less
    if im_bb_y + add_y > out_y
     add_y = out_y - im_bb_y;
    end
    
    if im_bb_y + add_y < out_y
      trans2_y = (out_y - (im_bb_y + add_y)) / 2;
    else
      trans2_y = 0;
    end
  end
else
  %trans2_y = 0;
  trans2_y = (out_y - im_bb_y) / 2;
end

if ~centerXCentroid
  trans1_x = add_x;
else
  trans1_x = 0;
end
if ~centerYCentroid
  trans1_y = add_y;
else
  trans1_y = 0;
end

%% do the translation

[centeredImage] = translateAroundCentroid(im_bb, leftCentroid, topCentroid, trans1_x, trans1_y, trans2_x, trans2_y, out_x, out_y, bgColor, plotSteps);

%% are there manipulated images to prcess as well?

if ~isempty(manipulations)
  [orig_path,current_file,ext] = fileparts(imageFile);
  
  familyName = manipulations{1}{1};
  fNameInd = strfind(current_file,familyName);
  speciesNameExemplarNum = current_file((fNameInd(1)+length(familyName)):end);
  speciesName = speciesNameExemplarNum(~isstrprop(speciesNameExemplarNum,'digit'));
  exemplarNumStr = speciesNameExemplarNum(isstrprop(speciesNameExemplarNum,'digit'));
  
  % initialize to hold the centered manipualted images
  centeredManipImage = cell(1,length(manipulations{2}));
  for m = 1:length(manipulations{2})
    manip_file = fullfile(strcat(orig_path,manipulations{2}{m}),sprintf('%s%s_%s%s%s',familyName,manipulations{2}{m},speciesName,exemplarNumStr,ext));
    if exist(manip_file,'file')
      im_manip = imread(manip_file);
    else
      error('manipulated image file %s does not exist',manip_file);
    end
    
    % make 3D if we need to
    if ndims(im_manip) == 2
      im_manip = repmat(im_manip,[1 1 3]);
    end
    
    % translate the manipulated image
    [cManipImage] = translateAroundCentroid(im_manip, leftCentroid, topCentroid, trans1_x, trans1_y, trans2_x, trans2_y, out_x, out_y, bgColor, plotSteps);
    centeredManipImage{m} = cManipImage;
  end
else
  centeredManipImage = {};
end

%% clean up

if plotSteps
  close all
end

%% reusable function to do translation

function [centeredImage] = translateAroundCentroid(im_bb, leftCentroid, topCentroid, trans1_x, trans1_y, trans2_x, trans2_y, out_x, out_y, bgColor, plotSteps)

im_bb_t = imtranslate(im_bb,[trans1_y, trans1_x, 0],bgColor,'linear',0);
if plotSteps
  figure
  imshow(im_bb_t);
  title('1');
end

if ~leftCentroid
  im_bb_t = imtranslate(im_bb_t,[0, -trans1_x, 0],bgColor,'linear',1);
  if plotSteps
    figure
    imshow(im_bb_t);
    title('1 right');
  end
end

if ~topCentroid
  im_bb_t = imtranslate(im_bb_t,[-trans1_y, 0, 0],bgColor,'linear',1);
  if plotSteps
    figure
    imshow(im_bb_t);
    title('1 bottom');
  end
end

if trans2_x > 0 || trans2_y > 0
  im_bb_t2 = imtranslate(im_bb_t,[trans2_y, trans2_x, 0],bgColor,'linear',0);
  if plotSteps
    figure
    imshow(im_bb_t2);
    title('2');
  end
  im_bb_t3 = imtranslate(im_bb_t2,[-trans2_y, trans2_x, 0],bgColor,'linear',0);
  if plotSteps
    figure
    imshow(im_bb_t3);
    title('3');
  end
  centeredImage = imtranslate(im_bb_t3,[trans2_y, -trans2_x, 0],bgColor,'linear',1);
  if plotSteps
    figure
    imshow(centeredImage);
    title('4');
    hold on
    plot((out_x / 2), (out_y / 2), 'r*');
    hold off
  end
end

end % translateAroundCentroid

end % centerImageOnCentroid
