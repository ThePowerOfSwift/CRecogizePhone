//
//  OverView.m
//  TestCamera
//
//  Created by wintone on 14/11/25.
//  Copyright (c) 2014年 zzzili. All rights reserved.
//

#import "OverView.h"
#import <CoreText/CoreText.h>

@implementation OverView{
    
}

- (id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void) drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    [[UIColor colorWithRed:0.3137 green:0.1765 blue:0.4706 alpha:1.0] set];
    //获得当前画布区域
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    //设置线的宽度
    CGContextSetLineWidth(currentContext, 3.0f);
    
    CGContextMoveToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(self.bounds), CGRectGetMinY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMaxX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMaxY(self.bounds));
    CGContextAddLineToPoint(currentContext, CGRectGetMinX(self.bounds), CGRectGetMinY(self.bounds));
    CGContextStrokePath(currentContext);
}

@end
