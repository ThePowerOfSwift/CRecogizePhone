//
//  ViewController.m
//  recogizePhone
//
//  Created by cbwl on 16/12/7.
//  Copyright © 2016年 CYT. All rights reserved.
//

#import "ViewController.h"
#import "recogizeViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    recogizeViewController *recogize=[recogizeViewController new];
    [self.view addSubview:recogize.view];
    [self addChildViewController:recogize];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
