//
//  GrayScale.h
//  XOGameFrame
//
//  Created by song on 11-1-12.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface UIImage (grayscale)

- (UIImage *)convertToGrayscale ;//灰度处理
-(UIImage*)scaleToSize:(CGSize)size;//图片处理
@end
