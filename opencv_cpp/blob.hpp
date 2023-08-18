#include "opencv2/opencv.hpp"
#include <iostream>

#ifndef BLOB
using namespace cv;
using namespace std;


cv::Mat hairRemove(cv::Mat image) {
    // Convert image to grayscale
    cv::Mat grayScale;
    cv::cvtColor(image, grayScale, cv::COLOR_RGB2GRAY);
    
    // Kernel for morphologyEx
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(17, 17));
    
    // Apply MORPH_BLACKHAT to grayscale image
    cv::Mat blackhat;
    cv::morphologyEx(grayScale, blackhat, cv::MORPH_BLACKHAT, kernel);
    
    // Apply thresholding to blackhat
    cv::Mat threshold;
    cv::threshold(blackhat, threshold, 10, 255, cv::THRESH_BINARY);
    
    // Inpaint with original image and threshold image
    cv::Mat finalImage;
    cv::inpaint(image, threshold, finalImage, 1, cv::INPAINT_TELEA);
    
    cv::medianBlur(finalImage, finalImage, 5);
    
    return finalImage;
}


int detectBlobsFromPath(string filename )
{
	// Read image
	Mat im = imread(filename);
	// Define the new dimensions for resizing
    cv::Size newSize(360, 360);  // New width and height
    
    // Resize the image
    cv::resize(im, im, newSize);

	im = hairRemove(im);
    imshow("image no hair", im);
    waitKey(0);


	// Convert the color image to grayscale
    cv::cvtColor(im, im, cv::COLOR_BGR2GRAY);
	imshow("Gray image", im);
    waitKey(0);

	// Apply Otsu's thresholding
    cv::Mat binaryImage;
    cv::threshold(im, im, 0, 255, cv::THRESH_BINARY + cv::THRESH_OTSU);
	imshow("binary image", im);
    waitKey(0);
    
	// Define a kernel for morphological operations (structuring element)
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    
    // Apply morphological opening
    cv::morphologyEx(im, im, cv::MORPH_OPEN, kernel);
	imshow("Morphed image", im);
    waitKey(0);

	// Define a kernel for erosion (structuring element)
    cv::Mat kernelErode = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    
    // Apply erosion
    cv::erode(im, im, kernelErode, Point(-1, -1), 3);
	imshow("Eroded image", im);
    waitKey(0);

	int imageArea = im.cols * im.rows;

	// // Apply histogram equalization
    
    // equalizeHist(unEqImg, im);
    // imshow("Equalized image", im);
    // waitKey(0);


	// Setup SimpleBlobDetector parameters.
	SimpleBlobDetector::Params params;

	// Change thresholds
	params.minThreshold = 10;
	params.maxThreshold = 200;

	// Filter by Area.
	params.filterByArea = true;
	params.minArea = int(imageArea * 0.1);//100;
	params.maxArea = 10000000;

	// Filter by Circularity
	params.filterByCircularity = true;
	params.minCircularity = 0.3;
	params.maxCircularity = 1000000;

	// Filter by Convexity
	params.filterByConvexity = false;
	params.minConvexity = 0.57;

	// Filter by Inertia
	params.filterByInertia = false;
	params.minInertiaRatio = 0.01;


	// Storage for blobs
	vector<KeyPoint> keypoints;


#if CV_MAJOR_VERSION < 3   // If you are using OpenCV 2

	// Set up detector with params
	SimpleBlobDetector detector(params);

	// Detect blobs
	detector.detect( im, keypoints);
#else 

	// Set up detector with params
	Ptr<SimpleBlobDetector> detector = SimpleBlobDetector::create(params);   

	// Detect blobs
	detector->detect( im, keypoints);
#endif 

	// Draw detected blobs as red circles.
	// DrawMatchesFlags::DRAW_RICH_KEYPOINTS flag ensures
	// the size of the circle corresponds to the size of blob

	Mat im_with_keypoints;
	drawKeypoints( im, keypoints, im_with_keypoints, Scalar(0,0,255), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );

	// Show blobs
	imshow("keypoints", im_with_keypoints );
	waitKey(0);

    return keypoints.size();
}


int detectBlobs(Mat image, float roiWidthFactor, float roiHeightFactor)
{
    if (image.empty()) {
        //std::cout << "Could not read the image." << std::endl;
        return -1;
    }

    // Convert the color image to grayscale
    // cv::cvtColor(image, image, cv::COLOR_BGR2GRAY);
    //imshow("image", im);
    //waitKey();

    int imageWidth = image.cols;
    int imageHeight = image.rows;
    int width = roiWidthFactor * imageWidth;  // width of the ROI
    int height = roiHeightFactor * imageHeight; // height of the ROI
    // Define the coordinates of the top-left and bottom-right corners of the ROI
    int x = (imageWidth -  width) / 2 ;  // top-left x-coordinate
    int y = (imageHeight -  height) / 2 ; // top-left y-coordinate


    // Crop the image to the defined ROI
    cv::Mat im = image(cv::Rect(x, y, width, height));

	// Define the new dimensions for resizing
    cv::Size newSize(360, 360);  // New width and height
    
    // Resize the image
    cv::resize(im, im, newSize);

	im = hairRemove(im);

	// Convert the color image to grayscale
    cv::cvtColor(im, im, cv::COLOR_BGR2GRAY);

	// Apply Otsu's thresholding
    cv::Mat binaryImage;
    cv::threshold(im, im, 0, 255, cv::THRESH_BINARY + cv::THRESH_OTSU);
    
	// Define a kernel for morphological operations (structuring element)
    cv::Mat kernel = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    
    // Apply morphological opening
    cv::morphologyEx(im, im, cv::MORPH_OPEN, kernel);

	// Define a kernel for erosion (structuring element)
    cv::Mat kernelErode = cv::getStructuringElement(cv::MORPH_RECT, cv::Size(5, 5));
    
    // Apply erosion
    cv::erode(im, im, kernelErode, Point(-1, -1), 3);

	int imageArea = im.cols * im.rows;

	// Setup SimpleBlobDetector parameters.
	SimpleBlobDetector::Params params;

	// Change thresholds
	params.minThreshold = 10;
	params.maxThreshold = 200;

	// Filter by Area.
	params.filterByArea = true;
	params.minArea = int(imageArea * 0.1);//100;
	params.maxArea = 10000000;

	// Filter by Circularity
	params.filterByCircularity = true;
	params.minCircularity = 0.3;
	params.maxCircularity = 1000000;

	// Filter by Convexity
	params.filterByConvexity = false;
	params.minConvexity = 0.57;

	// Filter by Inertia
	params.filterByInertia = false;
	params.minInertiaRatio = 0.01;


	// Storage for blobs
	vector<KeyPoint> keypoints;


#if CV_MAJOR_VERSION < 3   // If you are using OpenCV 2

	// Set up detector with params
	SimpleBlobDetector detector(params);

	// Detect blobs
	detector.detect( im, keypoints);
#else

	// Set up detector with params
	Ptr<SimpleBlobDetector> detector = SimpleBlobDetector::create(params);

	// Detect blobs
	detector->detect( im, keypoints);
#endif

	// Draw detected blobs as red circles.
	// DrawMatchesFlags::DRAW_RICH_KEYPOINTS flag ensures
	// the size of the circle corresponds to the size of blob

	Mat im_with_keypoints;
	drawKeypoints( im, keypoints, im_with_keypoints, Scalar(0,0,255), DrawMatchesFlags::DRAW_RICH_KEYPOINTS );

	// Show blobs
	imshow("keypoints", im_with_keypoints );
	waitKey(0);

    return keypoints.size();
}

#endif
