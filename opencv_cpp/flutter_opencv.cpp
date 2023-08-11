
#include "opencv2/opencv.hpp"
#include "skin_lesion_detector.hpp"
#include <iostream>

///Place all function you'll like to expose to flutter side here


// Function to determin the number of skint lessions in the taget area
extern "C" __attribute__((visibility("default"))) __attribute__((used))
int32_t skinLesionDetector(
	uint8_t* plane0Bytes, uint8_t* plane1Bytes, uint8_t* plane2Bytes,
	int width, int height,
	int bytesPerRowPlane0 = 1, int bytesPerRowPlane1 = 2, int bytesPerRowPlane2 = 2,
	int bytesPerPixelPlane0 = 1, int bytesPerPixelPlane1 = 2, int bytesPerPixelPlane2 = 2
	) {
	
    int result = _skinLesionDetector(
        plane0Bytes, plane1Bytes, plane2Bytes,
        width, height, 
        bytesPerRowPlane0, bytesPerRowPlane1, bytesPerRowPlane2,
	    bytesPerPixelPlane0, bytesPerPixelPlane1, bytesPerPixelPlane2);

    return result;
	
}