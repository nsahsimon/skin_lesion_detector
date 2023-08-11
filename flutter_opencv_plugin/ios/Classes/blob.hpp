#include "opencv2/opencv.hpp"
#include <iostream>

#ifndef BLOB
using namespace cv;
using namespace std;

int detectBlobsFromPath(string filename )
{
	// Read image
	Mat im = imread(filename, IMREAD_GRAYSCALE );
    // imshow("image", im);
    // waitKey();

	// Setup SimpleBlobDetector parameters.
	SimpleBlobDetector::Params params;

	// Change thresholds
	params.minThreshold = 10;
	params.maxThreshold = 200;

	// Filter by Area.
	params.filterByArea = true;
	params.minArea = 500;

	// Filter by Circularity
	params.filterByCircularity = true;
	params.minCircularity = 0.1;

	// Filter by Convexity
	params.filterByConvexity = true;
	params.minConvexity = 0.57;

	// Filter by Inertia
	params.filterByInertia = true;
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
	// imshow("keypoints", im_with_keypoints );
	// waitKey(0);

    return keypoints.size();
}


int detectBlobs(Mat image, float roiWidthFactor, float roiHeightFactor)
{
    if (image.empty()) {
        //std::cout << "Could not read the image." << std::endl;
        return -1;
    }

    // Convert the color image to grayscale
    cv::cvtColor(image, image, cv::COLOR_BGR2GRAY);
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

	// Setup SimpleBlobDetector parameters.
	SimpleBlobDetector::Params params;

	// Change thresholds
	params.minThreshold = 10;
	params.maxThreshold = 200;

	// Filter by Area.
	params.filterByArea = true;
	params.minArea = 500;

	// Filter by Circularity
	params.filterByCircularity = true;
	params.minCircularity = 0.1;

	// Filter by Convexity
	params.filterByConvexity = true;
	params.minConvexity = 0.57;

	// Filter by Inertia
	params.filterByInertia = true;
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
	// imshow("keypoints", im_with_keypoints );
	// waitKey(0);

    return keypoints.size();
}

#endif
