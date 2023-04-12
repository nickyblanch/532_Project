% ECE 532 COURSE PROJECT

%% Setting up training data
clear;
clc;

% Training images
training_images = dir('E:\532_Course_Project\OpenLabeling\main\input');
training_images = struct2cell(training_images);
training_images = string(training_images(1, :));
training_images(training_images == '.' | training_images == '..') = [];
for i = 1:length(training_images)
    training_images(1, i) = string('E:\532_Course_Project\OpenLabeling\main\input\'+training_images(1, i));
end

% Training boxes
training_boxes = dir('E:\532_Course_Project\OpenLabeling\main\output\YOLO_darknet');
% training_boxes = dir('E:\532_Course_Project\OpenLabeling\main\test_output');
training_boxes = struct2cell(training_boxes);
training_boxes = string(training_boxes(1, :));
training_boxes(training_boxes == '.' | training_boxes == '..') = [];
for i = 1:length(training_boxes)
    training_boxes(1, i) = fileread(string('E:\532_Course_Project\OpenLabeling\main\output\YOLO_darknet\'+training_boxes(1, i)));
    % training_boxes(1, i) = fileread(string('E:\532_Course_Project\OpenLabeling\main\test_output\'+training_boxes(1, i)));
end

% Create table out of data
data = table(training_images', training_boxes');

for i = 1:height(data)
    temp = split(data{i, 2});
    temp(temp == "" | temp == "0") = [];

    pixel_width = double(temp(3)) * 1920;
    pixel_height = double(temp(4)) * 1080;
    x = double(temp(1)) * 1920 - pixel_width/2;
    y = double(temp(2)) * 1080 - pixel_height/2;

    % pixel_width = double(temp(3)) * 682;
    % pixel_height = double(temp(4)) * 384;
    % x = double(temp(1)) * 682 - pixel_width/2;
    % y = double(temp(2)) * 384 - pixel_height/2;

    new_array(i, :) = [x, y, pixel_width, pixel_height];
end


data = table(training_images', mat2cell(new_array, ones(i, 1)));


%% Separate data

rng("default");
shuffledIndices = randperm(height(data));
idx = floor(0.6 * length(shuffledIndices) );

trainingIdx = 1:idx;
% trainingDataTbl = data(shuffledIndices(trainingIdx),:);
trainingDataTbl = data;

validationIdx = idx+1:length(shuffledIndices);
validationDataTbl = data(shuffledIndices(validationIdx),:);

% For loading and storing image data during training and evaluation
imdsTrain = imageDatastore(trainingDataTbl{:,"Var1"});
bldsTrain = boxLabelDatastore(trainingDataTbl(:,"Var2"));

imdsValidation = imageDatastore(validationDataTbl{:,"Var1"});
bldsValidation = boxLabelDatastore(validationDataTbl(:,"Var2"));

% Combine image and box datastores
trainingData = combine(imdsTrain,bldsTrain);
validationData = combine(imdsValidation,bldsValidation);

% Validate input data
% validateInputData(trainingData);
% validateInputData(validationData);

%% Visually confirm process is working

% Display example training image and box label
data = read(trainingData);
I = data{1};
bbox = data{2};
annotatedImage = insertShape(I,"Rectangle",bbox);
annotatedImage = imresize(annotatedImage,2);
figure
imshow(annotatedImage)
reset(trainingData);

%% Create network
inputSize = [416 416 3];

className = "Var2";

rng("default");
trainingDataForEstimation = transform(trainingData,@(data)preprocessData(data,inputSize));
numAnchors = 9;
[anchors,meanIoU] = estimateAnchorBoxes(trainingDataForEstimation,numAnchors);

area = anchors(:, 1).*anchors(:,2);
[~,idx] = sort(area,"descend");

anchors = anchors(idx,:);
anchorBoxes = {anchors(1:3,:)
    anchors(4:6,:)
    anchors(7:9,:)
    };

detector = yolov4ObjectDetector("csp-darknet53-coco",className,anchorBoxes,InputSize=inputSize);

%% Training options
options = trainingOptions("adam",...
    GradientDecayFactor=0.9,...
    SquaredGradientDecayFactor=0.999,...
    InitialLearnRate=0.001,...
    LearnRateSchedule="none",...
    MiniBatchSize=4,...
    L2Regularization=0.0005,...
    MaxEpochs=70,...
    BatchNormalizationStatistics="moving",...
    DispatchInBackground=true,...
    ResetInputNormalization=false,...
    Shuffle="every-epoch",...
    VerboseFrequency=20,...
    ValidationFrequency=1000,...
    CheckpointPath=tempdir,...
    ValidationData=validationData);

%% Begin training
doTraining = true;
if doTraining       
    % Train the YOLO v4 detector.
    [detector,info] = trainYOLOv4ObjectDetector(trainingData,detector,options);
else
    % Load pretrained detector for the example.
    detector = downloadPretrainedYOLOv4Detector();
end

%% Test results
I = imread("TEST_IMAGE.jpg");
[bboxes,scores,labels] = detect(detector,I);

I = insertObjectAnnotation(I,"rectangle",bboxes,scores);
figure
imshow(I)

%% Preprocess Data
function data = preprocessData(data,targetSize)
% Resize the images and scale the pixels to between 0 and 1. Also scale the
% corresponding bounding boxes.

for ii = 1:size(data,1)
    I = data{ii,1};
    imgSize = size(I);
    
    bboxes = data{ii,2};

    I = im2single(imresize(I,targetSize(1:2)));
    scale = targetSize(1:2)./imgSize(1:2);
    bboxes = bboxresize(bboxes,scale);
    
    data(ii,1:2) = {I,bboxes};
end
end