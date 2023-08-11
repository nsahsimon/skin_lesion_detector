
#include "opencv2/opencv.hpp"
#include "blob.hpp"
#include "yuv2bgr.hpp"
#include <iostream>

// Function to get corners
int32_t _skinLesionDetector(
	uint8_t* plane0Bytes, uint8_t* plane1Bytes, uint8_t* plane2Bytes,
	int width, int height, float roiWidthFactor, float roiHeightFactor,
	int bytesPerRowPlane0 = 1, int bytesPerRowPlane1 = 2, int bytesPerRowPlane2 = 2,
	int bytesPerPixelPlane0 = 1, int bytesPerPixelPlane1 = 2, int bytesPerPixelPlane2 = 2
	) {
	
    Mat image = yuv2bgr(
        plane0Bytes, plane1Bytes, plane2Bytes,
        width, height, 
        bytesPerRowPlane0, bytesPerRowPlane1, bytesPerRowPlane2,
	    bytesPerPixelPlane0, bytesPerPixelPlane1, bytesPerPixelPlane2);

    int blobCount = detectBlobs(image,roiWidthFactor,roiHeightFactor);
    return blobCount;
	
}