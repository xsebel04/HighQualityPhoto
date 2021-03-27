//
//  OpenCVWrapper.h
//  HighQualityPhoto
//
//  Created by Vít Šebela on 17.03.2021.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenCVWrapper.h"

NS_ASSUME_NONNULL_BEGIN

@interface OpenCVWrapper : NSObject
- (UIImage*) process4: (UIImage *) image1
                image2: (UIImage *) image2
                image3: (UIImage *) image3
                image4: (UIImage *) image4;

- (UIImage*) process8: (UIImage *) image1
                image2: (UIImage *) image2
                image3: (UIImage *) image3
                image4: (UIImage *) image4
                image5: (UIImage *) image5
                image6: (UIImage *) image6
                image7: (UIImage *) image7
                image8: (UIImage *) image8;

@end

NS_ASSUME_NONNULL_END
