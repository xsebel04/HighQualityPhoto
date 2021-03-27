//
//  OpenCVWrapper.mm
//  HighQualityPhoto
//
//  Created by Vít Šebela on 17.03.2021.
//

#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
#import <opencv2/imgcodecs/ios.h>
 
using namespace cv;
using namespace std;

#define NUMBER_OF_IMAGES 4
#define CHANNELS 3
#define RESIZE_200
#define RESIZE_300
#define RESIZE_400

const int MAX_FEATURES = 500;
const float GOOD_MATCH_PERCENT = 0.15f;


@implementation OpenCVWrapper
 
//Resize the image to 200% width and 200% height using 'Nearest Neighbor'
//Auto align all the layers
//Average the layers by setting each layer's opacity to 1/layer number (the 1st layer will be 1/1 so 100% opacity, the 2nd layer will be 1/2 so 50% opacity, and the 4th layer will be 1/4 or 25% opacity, and so on).
//Sharpen the image using a Radius setting of 2, and a suitable Amount setting (we used 200% for the 4 image stack and 300% for the 20 image stack – the more images you stack the more amenable the composite will be to aggressive sharpening)

- (UIImage*) process4: (UIImage *) image1
                image2: (UIImage *) image2
                image3: (UIImage *) image3
                image4: (UIImage *) image4{
//    cout << "Print something" << endl;
    
    Mat im1, im2, im3, im4;
    UIImageToMat(image1,im1);
    UIImageToMat(image1,im2);
    UIImageToMat(image1,im3);
    UIImageToMat(image1,im4);
    
    cout << im1.size() << endl;
    
    Mat images[] = {im1, im2, im3, im4};
    
//    resizeImages(images, 2, 4); // first 4 is factor and second is number of images in array
    
    Mat alignedImages[4];
    alignedImages[0] = im1;
    
    for (int i = 1; i < 4; i++) { // starting from 1 because first image of four is reference for alignment
        alignImages(images[i], im1, alignedImages[i]);
    }
    
//    resizeImages(alignedImages, 1.5, 4);
//    Mat im = alignedImages[0];
//    Mat averagedImage = averageOfImages(alignedImages, 4); // 4 if number of images in array
    
    Mat averagedImage = calculateMedian(alignedImages, 4);
//
    Mat sharpenedImage = unsharpIm(averagedImage, 2, 1, 'g'); // g for gaussian, m for median blur
//    cout << "im here" << endl;
    Mat imgs[] = {sharpenedImage};
//    Mat imgs[] = {averagedImage};
//    resizeImages(imgs, 1.5, 1);
    Mat temp = sharpenedImage;
    resize(temp, sharpenedImage, cv::Size(), 2, 2, INTER_LANCZOS4);
    return MatToUIImage(sharpenedImage);
//    return MatToUIImage(averagedImage);
//    return MatToUIImage(im);
}

- (UIImage*) process8: (UIImage *) image1
                image2: (UIImage *) image2
                image3: (UIImage *) image3
                image4: (UIImage *) image4
                image5: (UIImage *) image5
                image6: (UIImage *) image6
                image7: (UIImage *) image7
           image8: (UIImage *) image8 {
    
    return image1;
}

void alignImages(Mat &imToAlign, Mat &imRef, Mat &im1Reg) {
    
    // Variables to store keypoints and descriptors
    std::vector<KeyPoint> keypoints1, keypoints2;
    Mat descriptors1, descriptors2;

    // Detect ORB features and compute descriptors.
    cv::Ptr<Feature2D> orb = ORB::create(MAX_FEATURES);
    orb->detectAndCompute(imToAlign, Mat(), keypoints1, descriptors1);
    orb->detectAndCompute(imRef, Mat(), keypoints2, descriptors2);

    // Match features.
    std::vector<DMatch> matches;
    cv::Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create("BruteForce-Hamming");
    matcher->match(descriptors1, descriptors2, matches, Mat());

    // Sort matches by score
    std::sort(matches.begin(), matches.end());

    // Remove not so good matches
    const int numGoodMatches = matches.size() * GOOD_MATCH_PERCENT;
    matches.erase(matches.begin()+numGoodMatches, matches.end());

    // Draw top matches
//    Mat imMatches;
//    drawMatches(imToAlign, keypoints1, imRef, keypoints2, matches, imMatches);
//    imwrite("/Users/vitsebela/Developer/OpenCV_Test/OpenCV_Test/resources/4pack/matches.jpg", imMatches);

    // Extract location of good matches
    std::vector<Point2f> points1, points2;

    for(size_t i = 0;i<matches.size();i++){
        points1.push_back(keypoints1[matches[i].queryIdx].pt);
        points2.push_back(keypoints2[matches[i].trainIdx].pt);
    }
    
    Mat h;
    // Find homography
    h = findHomography(points1, points2, RANSAC);

    // Use homography to warp image
    warpPerspective(imToAlign, im1Reg, h, imRef.size());
}

Mat unsharpIm(Mat img, double sigma, double amount, char c) {
    Mat blurry, sharp1, denoised;
    
    if (c == 'g') {
        GaussianBlur(img, blurry, cv::Size(), sigma);
    } else {
        medianBlur(img, blurry, 5); // Median blur is less noisy and keeps the edges sharp as pepper
    }
    int threshold = 5;
    Mat lowConstrastMask = abs(img - blurry) < threshold;
    Mat sharpened = img*(1+amount) + blurry*(-amount);
//    addWeighted(img, 1 + amount, blurry, 1-amount, 0, sharp1);
    return sharpened;
}

//Postup pro zpracovani
//Bring all images into Photoshop as a stack of layers
//Resize the image to 200% width and 200% height using 'Nearest Neighbor'
//Auto align all the layers
//Average the layers by setting each layer's opacity to 1/layer number (the 1st layer will be 1/1 so 100% opacity, the 2nd layer will be 1/2 so 50% opacity, and the 4th layer will be 1/4 or 25% opacity, and so on).
//Sharpen the image using a Radius setting of 2, and a suitable Amount setting (we used 200% for the 4 image stack and 300% for the 20 image stack – the more images you stack the more amenable the composite will be to aggressive sharpening)

/*
 * param1 - images[] - array of images to be averaged
 * param2 - N - number of images contained inside the array
 * return value: Returns averaged image
 */
Mat averageOfImages(Mat images[], int N){
    
    cout << images[0].size() << endl;
    cout << images[0].cols << endl;
    cout << images[0].rows << endl;
    
    Mat averaged = Mat::zeros(images[0].rows, images[0].cols, CV_64FC4);

    Mat temp;

    cout << "In average" << endl;
    images[0].convertTo(averaged, CV_64FC4);

    for (int i = 0; i < N; i++) {
        images[i].convertTo(temp, CV_64FC4);
        averaged += temp;
    }
    
    cout << "After loop in average" << endl;
    averaged.convertTo(averaged, CV_8U, 1./N);
    
    return averaged;
    
}

Mat calculateMedian(Mat images[], int N){
    
    Mat median = images[0];
    uchar tempArr[CHANNELS][N];
    for (int r = 0; r < images[0].rows; r++) {
        for (int c = 0; c < images[0].cols; c++) {
            for (int i = 0; i < CHANNELS; i++) { // iterate over
                for (int j = 0; j < N; j++) { // iterate over
                    tempArr[i][j] = images[j].at<Vec3b>(r,c).val[i];
                }
                int n = sizeof(tempArr[0]) / sizeof(tempArr[0][0]);
                sort(tempArr[i], tempArr[i] + n);
            }
            
            for (int i = 0; i < CHANNELS; i++) {
                median.at<Vec3b>(r,c).val[i] = tempArr[i][1];
            }
        }
    }
    
    return median;
}

void resizeImages(Mat images[], int factor, int N){
    Mat temp;
    for (int i = 0; i < N; i++) {
        temp = images[i];
        resize(temp, images[i], cv::Size(), factor, factor, INTER_LANCZOS4); // factor is number for multiplication of cols and rows
//        cout << images[i].size << endl;
    }
}

@end
