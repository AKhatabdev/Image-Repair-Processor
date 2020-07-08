%% IRP (Image Repair processing)
%% Author: Awais Khatab
%% Licence: MIT

%% Initialize Matlab environment.
    clc; clear; close all;

%% Read images(input).
    inputImage1=imread('img1.jpg');   figure; imshow(inputImage1); title('Input Image 1');
    inputImage2=imread('img2.jpg');   figure; imshow(inputImage2); title('Input Image 2');

    grayImage1= rgb2gray(inputImage1);  % Convert the 'img1.jpg' into grayscale image.

%% Resize the 'img2.jpg' into the size of 'img1.jpg'
    resizedImage2(:,:,1)= imresize(inputImage2(:,:,1), size(grayImage1));
    resizedImage2(:,:,2)= imresize(inputImage2(:,:,2), size(grayImage1));
    resizedImage2(:,:,3)= imresize(inputImage2(:,:,3), size(grayImage1));

%% Remove the noise in the resized image2.
    denoisedImage(:,:,1)=imgaussfilt(resizedImage2(:,:,1),5);
    denoisedImage(:,:,2)=imgaussfilt(resizedImage2(:,:,2),5);
    denoisedImage(:,:,3)=imgaussfilt(resizedImage2(:,:,3),5);

%% Detect the missing areas in the input "image1.jpg".
    [row,col] = find(grayImage1==255);

%% Replace the detected missing part in "image1.jpg" with the corresponding areas in "image2.jpg"
    replacedImage=inputImage1;
    for k=1:length(row)
        replacedImage(row(k),col(k),1)=denoisedImage(row(k),col(k),1);
        replacedImage(row(k),col(k),2)=denoisedImage(row(k),col(k),2);
        replacedImage(row(k),col(k),3)=denoisedImage(row(k),col(k),3);
    end
    figure; imshow(replacedImage); title('Replaced image');


%% Making sure that the replacement is seamless.
    missedPart=(grayImage1==255);
    % Filter the "missing area" in "image1.jpg".
    denoisedMissedPart = imopen(missedPart,strel('disk', 2));
    % Extend the "missing area" in "image1.jpg" for 20 pixels.
    ExtendedMissedPart=imdilate(denoisedMissedPart,strel('disk', 20));
    % Remove the seam part.
    seamRemovedPart= ExtendedMissedPart-missedPart ;

    % Average "denosed image2.jpg" and "image1.jpg"  for seam-removed area.
    [row,col] =find(seamRemovedPart>0);
    for k=1:length(row)
        replacedImage(row(k),col(k),1)=uint8(0.5*(double(replacedImage(row(k),col(k),1))+double(denoisedImage(row(k),col(k),1))));
        replacedImage(row(k),col(k),2)=uint8(0.5*(double(replacedImage(row(k),col(k),2))+double(denoisedImage(row(k),col(k),2))));
        replacedImage(row(k),col(k),3)=uint8(0.5*(double(replacedImage(row(k),col(k),3))+double(denoisedImage(row(k),col(k),3))));
    end

%% Take the final image and write it into ".JPG" and ".PNG" files, for user convenience.
    FinalImage=replacedImage;
    figure; imshow(FinalImage); title('Final image after image processing has been completed');

    imwrite(FinalImage,'outputImageResult.jpg');
    imwrite(FinalImage,'outputImageResult.png');


%% Display the similarity between the recovered image and "Penguins.jpg".
    PenguinsImage=imread('Penguins.jpg');

    pixelWiseDifference=(abs(double(PenguinsImage(:,:,1))-double(FinalImage(:,:,1)))+...
        abs(double(PenguinsImage(:,:,2))-double(FinalImage(:,:,2)))+...
        abs(double(PenguinsImage(:,:,3))-double(FinalImage(:,:,3))))/3 ;

    similarityScore=mean(mean(pixelWiseDifference))

    xlabel(strcat('\fontsize{15}\color{blue}Similarity score is : \color{red}',num2str(similarityScore),'\color{blue}[pixels].  This score will be between 0 and 255. The closer the score is to 0, the better the result after image processing!'))

%% TODO: Add universal image input --> Folder "Images"
%% TODO: Improve Algorithm to enhance and create perfect restoration
