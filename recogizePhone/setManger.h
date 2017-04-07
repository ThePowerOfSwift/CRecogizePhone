//
//  setManger.h
//  ceshi
//
//  Created by cbwl on 16/12/5.
//  Copyright © 2016年 CYT. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TesseractOCR/TesseractOCR.h>
#import "ImageUtils.h"//图片处理工具类
#import "GrayScale.h"//图片灰度处理工具类



@interface setManger : NSObject<G8TesseractDelegate>
{
    NSString *_resultString;
    NSOperationQueue *_operationQueue;
}
+ (instancetype)sharedInstanceTool;
-(NSString *)checkPhoneValue:(NSString *)text;
-(NSString *)recognizeImageWithTesseract:(UIImage *)image finish:(void (^)(UIImage *img))img text:(void (^)(NSString *text))text;
#pragma mark  剪切图片  111111
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect;
#pragma mark   //灰度
-(UIImage *)grayImage:(UIImage *)source;
@end
