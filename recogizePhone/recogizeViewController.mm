//
//  recogizeViewController.m
//  recogizePhone
//
//  Created by cbwl on 16/12/7.
//  Copyright © 2016年 CYT. All rights reserved.
//

#import "recogizeViewController.h"
#import "OverView.h"
#import <TesseractOCR/TesseractOCR.h>
#import "KNToast.h"
#import <QuartzCore/QuartzCore.h>
#import "GrayScale.h"
#import "ImageUtils.h"///图片工具类
#import "setManger.h"//设置手机号

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import <opencv2/highgui/highgui.hpp>
#import <opencv2/highgui/highgui_c.h>

#endif


int const maxImagePixelsAmount = 3200000; // 3.2 MP

//屏幕宽度和高度
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height

#define Height [UIScreen mainScreen].bounds.size.height
#define Width [UIScreen mainScreen].bounds.size.width
#define XCenter self.view.center.x
#define YCenter self.view.center.y

#define SHeight 20
#define SWidth (XCenter+30)
@interface recogizeViewController ()<G8TesseractDelegate,AVCaptureVideoDataOutputSampleBufferDelegate,UITableViewDelegate,UITableViewDataSource,UIAccelerometerDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIAlertViewDelegate>
{
    
    AVCaptureSession *_session;
    
    
    UIScrollView *_scrollView;
    UIImageView * imageView;
    UIImageView *_showImg;
    OverView * _overView;
    AVCaptureVideoPreviewLayer *layer;
    AVCaptureDeviceInput *input;
    AVCaptureStillImageOutput *output;
    AVCaptureVideoDataOutput *output2;
    UIImage *imageTmp;
    BOOL _getImg;//是否获取图片
    //   Mat cvImage;
}
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,strong) UIImageView *cameraImageView;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic,strong)CALayer *customLayer;
@property (nonatomic,strong)UIView *animationView;
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataAry;//
@property (nonatomic,strong)NSTimer *timer;
@property (nonatomic,strong)NSTimer *timerImg;

@property (nonatomic,strong)  UIImage *creactImg;

@end


@implementation recogizeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor=[UIColor purpleColor];
    //    [self initView2];
    [self initView1];
    /**
     *  获取到加速计的单利对象
     */
    UIAccelerometer * accelertometer = [UIAccelerometer sharedAccelerometer];
    /**
     *  设置加速计的代理
     */
    accelertometer.delegate = self;
    /**
     *  updateInterval  刷新频率，一秒更新30次
     */
    accelertometer.updateInterval = 1.0/1.0;
    
}
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    
    //检测摇动 1.5 为轻摇 。2.0 为重摇
    if (fabs(acceleration.x)>0.1 || abs(acceleration.y>0.1)||abs(acceleration.z>0.1)) {
        //        NSLog(@"你摇动我了")
//    [self focusAtPoint:CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2)];
        
        [self focusAtPoint];

    }
    
}

-(void)initView2{
//    GoToScanViewController *gotov=[GoToScanViewController new];
//    //    [[UIApplication sharedApplication]keyWindow].rootViewController=gotov;
//    [self.view addSubview:gotov.view];
//    [self addChildViewController:gotov];
}
-(void)initView1{
    // Do any additional setup after loading the view, typically from a nib.
    self.operationQueue = [[NSOperationQueue alloc] init];
    self.dataAry=[[NSMutableArray alloc]init];
    _getImg=NO;
    //   LScannerViewController *scaner=  [[LScannerViewController alloc]init];
    //   [[UIApplication sharedApplication]keyWindow].rootViewController=scaner;
    //    [self.view addSubview:scaner.view];
    //    [self addChildViewController:scaner];
    
    
    //    [self cameraDistrict];
    
    [self creatOverView];
    //
    //    imageView = [[UIImageView alloc]initWithFrame:CGRectMake(30,(Height-SWidth)/2/3,SCREEN_WIDTH-60,SWidth-80)];
    //    //    imageView.image = [UIImage imageNamed:@"saomiao.png"];
    //    [self.view addSubview:imageView];
    //
    
    
    [self creactCamer];
    
    //        [self setOverView];
    
    if (!_showImg){
        _showImg = [[UIImageView alloc]init];
        _showImg.backgroundColor=[UIColor redColor];
        _showImg.contentMode=UIViewContentModeScaleAspectFill;
        _showImg.frame=CGRectMake(_overView.frame.origin.x, 100, _overView.frame.size.width, _overView.frame.size.height);
        
        [self.view addSubview:_showImg];
    }
//    _manager = [[CMMotionManager alloc] init];
//    [_manager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMDeviceMotion * _Nullable motion, NSError * _Nullable error) {
////        [self startZhongli];
//        
//        
//    }];
    
    
    [self creacteAnimationView];//创建对焦动画
    [self.view addSubview:[self initpersonTableView]];
    
    _timer= [NSTimer timerWithTimeInterval:0.2 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    
//    _timerImg= [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(redcogensImageWithTime) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:_timerImg forMode:NSRunLoopCommonModes];
//    [_timerImg setFireDate:[NSDate distantFuture]];
    
}
-(void)timerAction{
    _getImg=YES;
//    [self focusAtPoint];
    [self startAnimation];
}
-(void)creacteAnimationView
{
    _animationView =[[UIView alloc]init];
    _animationView.frame=CGRectMake(SCREEN_WIDTH/2-120, SCREEN_HEIGHT/2-30, 240, 60);
    _animationView.layer.borderColor=[UIColor greenColor].CGColor;
    _animationView.layer.borderWidth=3;
    [self.view addSubview: _animationView ];
    
    
}
-(void)startAnimation{
    _animationView.frame=CGRectMake(SCREEN_WIDTH/2-120, SCREEN_HEIGHT/2-30, 240, 60);
    _animationView.hidden=NO;
    [UIView animateWithDuration:0.3 animations:^{
        _animationView.transform = CGAffineTransformMakeScale(0.2,0.2);
    }completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5 animations:^{
            _animationView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            _animationView.hidden = YES;
        }];
    }];

}
-(void)creactCamer{
    
    _session = [[AVCaptureSession alloc] init];
    
    _session.sessionPreset = AVCaptureSessionPresetPhoto;
    
    layer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:_session];
    
    //        layer.frame = [UIScreen mainScreen].bounds;
    layer.frame = _overView.frame;
    //    layer.affineTransform= CGAffineTransformMakeScale(2, 2);
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;//AVLayerVideoGravityResizeAspectFill
    self.view.layer.contentsRect = CGRectMake(0.0, 0.0, 0.1, 0.05);
    self.view.layer.contentsScale=.1;
    //    layer.bounds=CGRectMake(0, 0, 200, 200);
    //    layer.contentsRect = CGRectMake(0.0, 0.0, 400,400);
    [self.view.layer addSublayer:layer];
    
    self.device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //    _device.videoZoomFactor = 50.0f;
    //    _device.videoZoomFactor
    //    device.focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    //    [device unlockForConfiguration];
    input = [[AVCaptureDeviceInput alloc] initWithDevice:_device error:nil];
    
    output = [[AVCaptureStillImageOutput alloc] init];
    
    dispatch_queue_t captureQueue = dispatch_queue_create("com.kai.captureQueue", NULL);
    
    output2 = [[AVCaptureVideoDataOutput alloc] init];
    
    output2.videoSettings = @{(NSString*)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]};
    
    output2.alwaysDiscardsLateVideoFrames = YES;
    
    
    [output2 setSampleBufferDelegate:self queue:captureQueue];
    
    if ([_session canAddInput:input]){
        
        [_session addInput:input];
        
    }
    
    if ([_session canAddOutput:output]) {
        
        [_session addOutput:output];
        
        [_session addOutput:output2];
        
    }
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button setTitle:@"开启" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(onClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button];
    
    button.bounds = CGRectMake(0, 0, 100, 40);
    
    button.center =  CGPointMake(self.view.center.x, 60);
    
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button2 setTitle:@"关闭" forState:UIControlStateNormal];
    
    [button2 addTarget:self action:@selector(onClick01) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button2];
    
    button2.bounds = CGRectMake(0, 0, 100, 40);
    
    button2.center = CGPointMake(self.view.center.x-130, 60);
    
    
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeSystem];
    
    [button3 setTitle:@"拍照识别" forState:UIControlStateNormal];
    
    [button3 addTarget:self action:@selector(button3Click) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:button3];
    
    button3.bounds = CGRectMake(0, 0, 100, 40);
    
    button3.center = CGPointMake(self.view.center.x+130, 60);
    [_device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    
}
// callback
-(void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if([keyPath isEqualToString:@"adjustingFocus"]){
        [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        //        NSLog(@"Is adjusting focus? %@", adjustingFocus ?@"YES":@"NO");
        //        NSLog(@"Change dictionary: %@", change);
        _getImg=YES;
       
    }
}

- (void)onClick{
    
    [_session startRunning];
    
}

- (void)onClick01{
    
    [_session stopRunning];
}
-(void)button3Click{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    // 设置导航默认标题的颜色及字体大小
    picker.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                                                 NSFontAttributeName : [UIFont boldSystemFontOfSize:18]};
    [self presentViewController:picker animated:YES completion:nil];
}
// 选择了图片或者拍照了
- (void)imagePickerController:(UIImagePickerController *)aPicker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [aPicker dismissViewControllerAnimated:YES completion:nil];
    __block UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    if (image ) {
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        //        [self.fromController setNeedsStatusBarAppearanceUpdate];
        [self recognizeImageWithTesseract:image];
        
    }
    return;
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];//文字方向
//     connection.videoMinFrameDuration = CMTimeMake(1, 11);
    
    
    //    @autoreleasepool {
    //        if (_getImg==YES) {
    //            _getImg=NO;
    _creactImg=[self imageFromSampleBuffer:sampleBuffer];
//    [[setManger sharedInstanceTool]recognizeImageWithTesseract:_creactImg finish:^(UIImage *img) {
//        
//        
//        
//    } text:^(NSString *text) {
//        
//        
//    }];
    NSString *result=  [[setManger sharedInstanceTool] recognizeImageWithTesseract:_creactImg finish:^(UIImage *img) {
       
        dispatch_async(dispatch_get_main_queue(), ^{
            
            _showImg.image=img;
            
        });
                       } text:^(NSString *text) {
        NSLog(@"识别的结果 %@",text);
        
        if (text&&text.length>9) {
            [_session stopRunning];
            UIAlertView *alert= [[UIAlertView alloc ]initWithTitle:@"识别结果" message:text delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            
            [self.dataAry insertObject:text atIndex:0];
            [self.tableView reloadData];
        }

    } ];
   
    
}
-(void)redcogensImageWithTime{
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
    
    UIImage *image3=[self imageFromImage:_creactImg inRect:CGRectMake(_overView.frame.origin.x*4.0, _overView.frame.origin.y*1.6, _overView.frame.size.width, _overView.frame.size.height-0)];//裁剪
    
    //    UIImage *image1=[self convertToGrayscale:image3];//二值化
    //        UIImage *image2=[self grayImage:image3];//灰度
    UIImage *imageblack= [image3 convertToGrayscale];
//    UIImage* newImage = scaleAndRotateImage(imageblack, maxImagePixelsAmount);//工具类处理
    
    
    
    operation.tesseract.image = imageblack;
    
    // Optionally limit the region in the image on which Tesseract should
    // perform recognition to a rectangle
    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
    
    // Specify the function block that should be executed when Tesseract
    // finishes performing recognition on the image
    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
        // Fetch the recognized text
        //            dispatch_async(dispatch_get_main_queue(), ^{
        NSString *recognizedText = tesseract.recognizedText;
        
        NSString *resultString= [self checkPhoneValue:recognizedText];//手机号验证
        //      NSString *resultString=[[setManger sharedInstanceTool] checkPhoneValue:recognizedText];
        //         if (resultString||resultString.length>0) {
        NSLog(@"结果是   %@", resultString);
        
        //             [[KNToast shareToast ]initWithText:resultString offSetY:50];
        //             [self.dataAry insertObject:resultString atIndex:0];
        //             [self.tableView reloadData];
        //
        //         }
        
        
        
        //            [[setManger new]checkPhoneValue:recognizedText resultStr:^{
        ////                [[KNToast shareToast ]initWithText:str3 offSetY:50];
        ////                [self.dataAry insertObject:str3 atIndex:0];
        ////                //                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataAry.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        ////                [self.tableView reloadData];
        ////
        //           //            }];
        
        //                NSLog(@"结果是   %@", recognizedText);
        
        //            });
        _showImg.image=imageblack;
        
    };
    
    // Display the image to be recognized in the view
    //    self.imageToRecognize.image = operation.tesseract.thresholdedImage;
    
    // Finally, add the recognition operation to the queue
    [self.operationQueue addOperation:operation];
    
    //    });
}
#pragma mark  剪切图片  111111
- (UIImage *)imageFromImage:(UIImage *)image inRect:(CGRect)rect {
    CGImageRef sourceImageRef = [image CGImage];
    CGImageRef newImageRef = CGImageCreateWithImageInRect(sourceImageRef, rect);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    return newImage;
}
//识别扫描框
- (void) creatOverView
{
    //长方形框
    _overView =[[OverView alloc] initWithFrame: CGRectMake(SCREEN_WIDTH/2-120,SCREEN_HEIGHT/2-40, 240, 80)];
    _overView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_overView];
    //    [self drawShapeLayer];//重绘透明部分
    
    //    _line = [[UIImageView alloc] initWithFrame:CGRectMake(_overView.x+5, 61, _overView.width-10,2)];
    //    _line.image = [UIImage imageNamed:@"saomiao1.png"];
    //    [self.view addSubview:_line];
    //    [self setOverView];
    //    upOrdown = NO;
    //    num =0;
    //    timer = [NSTimer timerWithTimeInterval:.1 target:self selector:@selector(animation) userInfo:nil repeats:YES];
    //    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationUp];
    
    CGImageRelease(quartzImage);
    
    //裁剪图片
    //    CGRect tempRect =_overView.frame;
    //    CGFloat scale = 1080/SCREEN_WIDTH; //720为当前分辨率(1280*720)
    //    CGFloat x = (SCREEN_WIDTH - CGRectGetMaxX(tempRect))*scale;
    //    CGFloat y = CGRectGetMinY (tempRect)*1920/SCREEN_HEIGHT;
    //    CGFloat w = tempRect.size.width*scale;
    //    CGFloat h = tempRect.size.height*(1920/SCREEN_HEIGHT);
    //    CGRect rect = CGRectMake(x, y, w, h);
    //    CGImageRef imageRef = image.CGImage;
    //    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
    //    UIGraphicsBeginImageContext(rect.size);
    //    CGContextRef context1 = UIGraphicsGetCurrentContext();
    //    CGContextDrawImage(context1, rect, subImageRef);
    //    UIImage *image1 = [UIImage imageWithCGImage:subImageRef];
    //    UIGraphicsEndImageContext();
    //    CGImageRelease(subImageRef);
    return (image);
    
}
- (void)viewDidDisappear:(BOOL)animated{
    
    [super viewDidDisappear:animated];
    
    [_session stopRunning];
    [_timer invalidate];
}
//相机的其它参数设置
//AVCaptureFlashMode  闪光灯
//AVCaptureFocusMode  对焦
//AVCaptureExposureMode  曝光
//AVCaptureWhiteBalanceMode  白平衡
//闪光灯和白平衡可以在生成相机时候设置
//曝光要根据对焦点的光线状况而决定,所以和对焦一块写
//point为点击的位置
- (void)focusAtPoint{
    CGPoint point=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    CGSize size = self.view.bounds.size;
    CGPoint focusPoint = CGPointMake( point.y /size.height ,1-point.x/size.width );
    NSError *error;
    if ([self.device lockForConfiguration:&error]) {
        //对焦模式和对焦点
        if ([self.device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
            [self.device setFocusPointOfInterest:focusPoint];
            [self.device setFocusMode:AVCaptureFocusModeAutoFocus];
            _getImg=YES;
        }
        //曝光模式和曝光点
        if ([self.device isExposureModeSupported:AVCaptureExposureModeAutoExpose ]) {
            [self.device setExposurePointOfInterest:focusPoint];
            [self.device setExposureMode:AVCaptureExposureModeAutoExpose];
        }
        
        [self.device unlockForConfiguration];
        //设置对焦动画
        //        _focusView.center = point;
        //        _focusView.hidden = NO;
        
    }
    
}
#pragma mark 识别图像
-(void)recognizeImageWithTesseract:(UIImage *)image
{
    
}
//{
//    //  后台执行：
//    //    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//    
//    // Animate a progress activity indicator
//    //    [self.activityIndicator startAnimating];
//    
//    // Create a new `G8RecognitionOperation` to perform the OCR asynchronously
//    // It is assumed that there is a .traineddata file for the language pack
//    // you want Tesseract to use in the "tessdata" folder in the root of the
//    // project AND that the "tessdata" folder is a referenced folder and NOT
//    // a symbolic group in your project
//    G8RecognitionOperation *operation = [[G8RecognitionOperation alloc] initWithLanguage:@"eng"];
//    
//    // Use the original Tesseract engine mode in performing the recognition
//    // (see G8Constants.h) for other engine mode options
//    operation.tesseract.engineMode = G8OCREngineModeTesseractOnly;
//    
//    // Let Tesseract automatically segment the page into blocks of text
//    // based on its analysis (see G8Constants.h) for other page segmentation
//    // mode options
//    operation.tesseract.pageSegmentationMode = G8PageSegmentationModeAutoOnly;
//    
//    // Optionally limit the time Tesseract should spend performing the
//    // recognition
//    //operation.tesseract.maximumRecognitionTime = 1.0;
//    
//    // Set the delegate for the recognition to be this class
//    // (see `progressImageRecognitionForTesseract` and
//    // `shouldCancelImageRecognitionForTesseract` methods below)
//    operation.delegate = self;
//    
//    // Optionally limit Tesseract's recognition to the following whitelist
//    // and blacklist of characters
//    //operation.tesseract.charWhitelist = @"01234";
//    //operation.tesseract.charBlacklist = @"56789";
//    
//    // Set the image on which Tesseract should perform recognition
//    
//    UIImage *image3=[self imageFromImage:image inRect:CGRectMake(_overView.frame.origin.x*4.0, _overView.frame.origin.y*1.6, _overView.frame.size.width, _overView.frame.size.height-0)];//裁剪
//    
//    //    UIImage *image1=[self convertToGrayscale:image3];//二值化
//    //        UIImage *image2=[self grayImage:image3];//灰度
//    UIImage *imageblack= [image3 convertToGrayscale];
//    UIImage* newImage = scaleAndRotateImage(imageblack, maxImagePixelsAmount);//工具类处理
//    
//    
//    
//    operation.tesseract.image = newImage;
//    
//    // Optionally limit the region in the image on which Tesseract should
//    // perform recognition to a rectangle
//    //operation.tesseract.rect = CGRectMake(20, 20, 100, 100);
//    
//    // Specify the function block that should be executed when Tesseract
//    // finishes performing recognition on the image
//    operation.recognitionCompleteBlock = ^(G8Tesseract *tesseract) {
//        // Fetch the recognized text
//        //            dispatch_async(dispatch_get_main_queue(), ^{
//        NSString *recognizedText = tesseract.recognizedText;
//        
//        NSString *resultString= [self checkPhoneValue:recognizedText];//手机号验证
//        //      NSString *resultString=[[setManger sharedInstanceTool] checkPhoneValue:recognizedText];
//        //         if (resultString||resultString.length>0) {
//        NSLog(@"结果是   %@", resultString);
//        //             [[KNToast shareToast ]initWithText:resultString offSetY:50];
//        //             [self.dataAry insertObject:resultString atIndex:0];
//        //             [self.tableView reloadData];
//        //
//        //         }
//        
//        
//        
//        //            [[setManger new]checkPhoneValue:recognizedText resultStr:^{
//        ////                [[KNToast shareToast ]initWithText:str3 offSetY:50];
//        ////                [self.dataAry insertObject:str3 atIndex:0];
//        ////                //                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataAry.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
//        ////                [self.tableView reloadData];
//        ////
//        //           //            }];
//        
//        //                NSLog(@"结果是   %@", recognizedText);
//        
//        //            });
//        _showImg.image=newImage;
//        
//    };
//    
//    // Display the image to be recognized in the view
//    //    self.imageToRecognize.image = operation.tesseract.thresholdedImage;
//    
//    // Finally, add the recognition operation to the queue
//    [self.operationQueue addOperation:operation];
//    
//    //    });
//}
-(NSString *)checkPhoneValue:(NSString *)text{
    //从字符串中获取数字
    NSCharacterSet* nonDigits =[[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSString *shuzi =[text stringByTrimmingCharactersInSet:nonDigits];
    NSLog(@"第一个数字  %@",shuzi);
    
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
    responseString = [shuzi stringByReplacingOccurrencesOfString:@"i" withString:@"1"];
    responseString = [shuzi stringByReplacingOccurrencesOfString:@"k" withString:@""];
    
    ///正则判断手机号
    NSString *regex =  @"^1+[3578]+\\d{9}";
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    
    
    NSUInteger len = [responseString length];
    //        NSArray *tmp=[responseString componentsSeparatedByString:@""];
    NSString *str3;
    for (int i=0;i<len;i++){
        NSString *str=  [NSString stringWithFormat:@"%@",[responseString substringWithRange:NSMakeRange(i, 1)]];
        if ([str isEqualToString:@"1"] ) {
            
            NSString *str2=[responseString substringWithRange:NSMakeRange(i, len-i)];
            if (str2.length>=11) {
                
                str3=[str2 substringWithRange:NSMakeRange(0, 11)];
                BOOL isMatch = [pred evaluateWithObject:str3];
                if (isMatch){
                    //                    [[iToast makeText:str3] show];
                    //                    [[KNToast shareToast]initWithText:str3 duration:1.5];
                    [_session stopRunning];
                    UIAlertView *alert=  [[UIAlertView alloc]initWithTitle:@"识别结果" message:str3 delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                    [alert show];
                    
                    
                    
                    [[KNToast shareToast ]initWithText:str3 offSetY:50];
                    [self.dataAry insertObject:str3 atIndex:0];
                    //                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataAry.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
                    [self.tableView reloadData];
                    [_timerImg setFireDate:[NSDate distantFuture]];
                    return str3;
                    
                }
            }
        }
    }
    
    return str3;
}
#pragma mark OPENCV 图片处理 测试
-(void)setImageUseopenCV{
    //    cv::Mat image = imread("E:/VS2013/face/xuelian/png/1.png", CV_LOAD_IMAGE_GRAYSCALE);
    cv::Mat image;
    //     UIImageToMat(_creactImg, image);
    
    if (image.empty())
    {
        std::cout << "read image failure" << std::endl;
        return ;
    }
    
    
    // 全局二值化
    int th = 100;//阈值
    cv::Mat global;
    threshold(image, global, th, 255, CV_THRESH_BINARY_INV);
    
    
    // 局部二值化
    
    int blockSize = 7;
    int constValue = 11;
    cv::Mat local;
    adaptiveThreshold(image, local, 255, CV_ADAPTIVE_THRESH_MEAN_C, CV_THRESH_BINARY_INV, blockSize, constValue);
    
    
    imshow("globalThreshold", global);
    imshow("localThreshold", local);
    cv::waitKey(0);
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    [_session startRunning];
}
//二值化
- (UIImage *)convertToGrayscale:(UIImage*)img{
    
    CGSize size = [img size];
    
    int width = size.width;
    
    int height = size.height;
    
    // the pixels will be painted to this array
    
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [img CGImage]);
    
    int tt = 1;
    
    CGFloat intensity;
    
    int bw;
    
    for(int y = 0; y < height; y++) {
        
        for(int x = 0; x < width; x++) {
            
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            intensity = (rgbaPixel[tt] + rgbaPixel[tt + 1] + rgbaPixel[tt + 2]) / 3. / 255.;
            
            if (intensity > 0.45) {
                
                bw = 255;
                
            } else {
                
                bw = 0;
                
            }
            
            rgbaPixel[tt] = bw;
            
            rgbaPixel[tt + 1] = bw;
            
            rgbaPixel[tt + 2] = bw;
            
        }
        
    }
    
    // create a new CGImageRef from our context with the modified pixels
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    
    CGContextRelease(context);
    
    CGColorSpaceRelease(colorSpace);
    
    free(pixels);
    
    // make a new UIImage to return
    
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    
    CGImageRelease(image);
    
    return resultUIImage;
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
#pragma mark 缩放图片
-(UIImage*) OriginImage:(UIImage *)sourceImage scaleToSize:(CGSize)size
{
    UIImage *newImage = nil;
    CGSize imageSize = sourceImage.size;
    CGFloat width = imageSize.width;
    CGFloat height = imageSize.height;
    CGFloat targetWidth = size.width;
    CGFloat targetHeight = size.height;
    CGFloat scaleFactor = 0.0;
    CGFloat scaledWidth = targetWidth;
    CGFloat scaledHeight = targetHeight;
    CGPoint thumbnailPoint = CGPointMake(0.0, 0.0);
    if(CGSizeEqualToSize(imageSize, size) == NO){
        CGFloat widthFactor = targetWidth / width;
        CGFloat heightFactor = targetHeight / height;
        if(widthFactor > heightFactor){
            scaleFactor = widthFactor;
        }        else{
            scaleFactor = heightFactor;
        }
        scaledWidth = width * scaleFactor;
        scaledHeight = height * scaleFactor;
        if(widthFactor > heightFactor){
            thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5;
        }else if(widthFactor < heightFactor){
            thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5;
        }
    }
    
    UIGraphicsBeginImageContext(size);
    
    CGRect thumbnailRect = CGRectZero;
    thumbnailRect.origin = thumbnailPoint;
    thumbnailRect.size.width = scaledWidth;
    thumbnailRect.size.height = scaledHeight;
    [sourceImage drawInRect:thumbnailRect];
    newImage = UIGraphicsGetImageFromCurrentImageContext();
    if(newImage == nil){
        NSLog(@"scale image fail");
    }
    
    UIGraphicsEndImageContext();
    return newImage;
    
}
#pragma mark - 添加模糊效果
- (void)setOverView {
    CGFloat width = CGRectGetWidth(self.view.frame);
    CGFloat height = 320;
    CGFloat x = CGRectGetMinX(imageView.frame);
    CGFloat y = CGRectGetMinY(imageView.frame);
    CGFloat w = CGRectGetWidth(imageView.frame);
    CGFloat h = CGRectGetHeight(imageView.frame);
    [self creatView:CGRectMake(0, 0, width, y)];
    [self creatView:CGRectMake(0, y, x, h)];
    [self creatView: CGRectMake(0, y + h, width, height - y - h)];
    [self creatView:CGRectMake(x + w, y, width - x - w, h)];
}

- (void)creatView:(CGRect)rect {
    CGFloat alpha = 0.5;
    UIColor *backColor = [UIColor blackColor];
    UIView *view = [[UIView alloc] initWithFrame:rect];
    view.backgroundColor = backColor;
    view.alpha = alpha;
    [self.view addSubview:view];
}

#pragma mark 生成TableView 表

#pragma mark tableView 初始化下单table
-(UITableView *)initpersonTableView
{
    if (_tableView != nil) {
        return _tableView;
    }
    
    CGRect rect = self.view.frame;
    rect.origin.x = 0.0;
    rect.origin.y = SCREEN_HEIGHT/2+120;
    rect.size.width = SCREEN_WIDTH;
    rect.size.height =SCREEN_HEIGHT/2-120;
    
    self.tableView = [[UITableView alloc] initWithFrame:rect style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    //    _tableView.backgroundColor = ViewBgColor;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    return _tableView;
}


#pragma tableView delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.dataAry.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    return 10.0;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.01;
}
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    return nil;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    return 40;
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellName = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellName];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellName];
    }
    cell.textLabel.text=[NSString stringWithFormat:@"%d,电话: %@",_dataAry.count-indexPath.row,_dataAry[indexPath.row]];
    return cell;
}

@end
