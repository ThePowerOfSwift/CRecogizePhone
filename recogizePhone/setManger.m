//
//  setManger.m
//  ceshi
//
//  Created by cbwl on 16/12/5.
//  Copyright © 2016年 CYT. All rights reserved.
//

#import "setManger.h"
//屏幕宽度和高度
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

int const maxImagePixelsAmount = 3200000; // 3.2 MP

static id _instance;

@implementation setManger
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    @synchronized(self) {
        if (_instance == nil) {
            _instance = [super allocWithZone:zone];
        }
    }
    return _instance;
}
+ (instancetype)sharedInstanceTool{
    @synchronized(self){
        if(_instance == nil){
            _instance = [[self alloc] init];
        }
    }
    return _instance;
}
-(id)copyWithZone:(struct _NSZone *)zone{
    return _instance;
}

-(NSString *)checkPhoneValue:(NSString *)text;
{
        //从字符串中获取数字
        NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
        NSString *shuzi =[text stringByTrimmingCharactersInSet:nonDigits];
        NSLog(@"第一个数字  %@",shuzi);
        if (shuzi.length<10) {
            return nil;
        }
        NSString * responseString = [shuzi stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"-" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"/" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"'\'" withString:@""];
        
        responseString = [shuzi stringByReplacingOccurrencesOfString:@" " withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"  " withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"   " withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"'" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"?" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"|" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"'\'" withString:@""];
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"i" withString:@""];
        
        responseString = [shuzi stringByReplacingOccurrencesOfString:@"k" withString:@""];
        
        ///正则判断手机号
        NSString *regex =  @"^1+[3578]+\\d{9}";
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
        
        
        
        NSUInteger len = [responseString length];
        //        NSArray *tmp=[responseString componentsSeparatedByString:@""];
        
        for (int i=0;i<len;i++){
            NSString *str=  [NSString stringWithFormat:@"%@",[responseString substringWithRange:NSMakeRange(i, 1)]];
            if ([str isEqualToString:@"1"] ) {
                
                NSString *str2=[responseString substringWithRange:NSMakeRange(i, len-i)];
                if (str2.length>=11) {
                    
                    NSString *str3=[str2 substringWithRange:NSMakeRange(0, 11)];
                    BOOL isMatch = [pred evaluateWithObject:str3];
                    if (isMatch){
                        
                        return str3;
                        break;
                        
                    }
                }
            }
        
    }
    return nil;
}
-(NSString *)recognizeImageWithTesseract:(UIImage *)image finish:(void (^)(UIImage *img))img text:(void (^)(NSString *text))text;
{
    _operationQueue=[[NSOperationQueue alloc]init];
    //  后台执行：
    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
    
    // Animate a progress activity indicator
    //    [self.activityIndicator startAnimating];
    
    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
    // It is assumed that there is a .traineddata file for the language pack
    // you want Tesseract to use in the "tessdata" folder in the root of the
    // project AND that the "tessdata" folder is a referenced folder and NOT
    // a symbolic group in your project
    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
    
    // Use the original Tesseract engine mode in performing the recognition
    // (see G8Constants.h) for other engine mode options
    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
    
    // Let Tesseract automatically segment the page into blocks of text
    // based on its analysis (see G8Constants.h) for other page segmentation
    // mode options
    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
    
    // Optionally limit the time Tesseract should spend performing the
    // recognition
    //operation.tesseract.maximumRecognitionTime = 1.0;
    
    // Set the delegate for the recognition to be this class
    // (see `progressImageRecognitionForTesseract` and
    // `shouldCancelImageRecognitionForTesseract` methods below)
    operation.delegate = self;
    
    // Optionally limit Tesseract's recognition to the following whitelist
    // and blacklist of characters
    //operation.tesseract.charWhitelist = @"01234";
    //operation.tesseract.charBlacklist = @"56789";
    
    // Set the image on which Tesseract should perform recognition
    
//    CGRectMake(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2-40, 240, 80)
    
    UIImage *image3=[self imageFromImage:image inRect:CGRectMake((SCREEN_WIDTH/2-120)*4.0, (SCREEN_HEIGHT/2-40)*1.6, 240, 80)];//裁剪
    
    //    UIImage *image1=[self convertToGrayscale:image3];//二值化
            UIImage *image2=[self grayImage:image3];//灰度
    UIImage *imageblack= [image2 convertToGrayscale];
    UIImage* image1 = scaleAndRotateImage(imageblack, maxImagePixelsAmount);//工具类处理
    
    
    
    operation.tesseract.image = image1;
    img(image1);

    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        //            dispatch_async(dispatch_get_main_queue(), ^{
        NSString *recognizedText = tesseract.recognizedText;
        
        _resultString= [self checkPhoneValue:recognizedText];//手机号验证
        //      NSString *resultString=[[setManger sharedInstanceTool] checkPhoneValue:recognizedText];
        //         if (resultString||resultString.length>0) {
        NSLog(@"recognizedText:%@    结果是   %@",recognizedText, _resultString);
        text(_resultString);
//        _showImg.image=newImage;
    };
    
    // Display the image to be recognized in the view
    //    self.imageToRecognize.image = operation.tesseract.thresholdedImage;
    
    // Finally, add the recognition operation to the queue
    [_operationQueue addOperation:operation];
    return _resultString;
}
#pragma mark  剪切图片  111111
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}


#pragma mark   //灰度

-(UIImage *)grayImage:(UIImage *)source
{
    int width = source.size.width;
    int height = source.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef context = CGBitmapContextCreate (nil,
                                                  width,
                                                  height,
                                                  8,      // bits per component
                                                  0,
                                                  colorSpace,
                                                  kCGImageAlphaNone);
    
    CGColorSpaceRelease(colorSpace);
    
    if (context == NULL) {
        return nil;
    }
    
    CGContextDrawImage(context,
                       CGRectMake(0, 0, width, height), source.CGImage);
    
    UIImage *grayImage = [UIImage imageWithCGImage:CGBitmapContextCreateImage(context)];
    CGContextRelease(context);
    
    return grayImage;
}
@end
