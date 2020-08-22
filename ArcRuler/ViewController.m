//
//  ViewController.m
//  test
//
//  Created by ww on 2020/8/17.
//  Copyright © 2020 ww. All rights reserved.
//

#import "ViewController.h"
#import "WWRuler/WWRulerView.h"

@interface ViewController ()<WWRulerViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    WWRulerView *ruler = [[WWRulerView alloc] initWithFrame:CGRectMake(0.0, 100.0, self.view.frame.size.width, 200.0)];
    ruler.delegate = self;
    [ruler showStraightRuler];
    [self.view addSubview:ruler];
    
    ruler = [[WWRulerView alloc] initWithFrame:CGRectMake(0.0, 400.0, self.view.frame.size.width, 200.0)];
    ruler.delegate = self;
    [ruler showArcRuler];
    [self.view addSubview:ruler];
}

- (void)rulerView:(WWRulerView *)ruler didSelectedValueChange:(CGFloat)value {
    NSLog(@"didSelectedValueChange--%f", value);
}

@end
