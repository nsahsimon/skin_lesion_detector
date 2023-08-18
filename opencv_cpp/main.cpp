
#include "opencv2/opencv.hpp"
#include "blob.hpp"
#include <iostream>

using namespace cv;
using namespace std;

int main( int argc, char** argv )
{

    string filename = "C:/Users/SMARTECH/Desktop/ME/freelance/off_market_places/skin_cancer_detection/opencv_cpp/images/img4.jpeg";
    Mat im = imread(filename);
    // int blobCount = detectBlobsFromPath(filename);
    int blobCount = detectBlobs(im, 0.3, 0.3);
    cout<<"Detected "<<blobCount<<" blobs"<<endl;

    return 0;

}