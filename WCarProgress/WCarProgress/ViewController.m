//
//  ViewController.m
//  WCarProgress
//
//  Created by WXQ on 2017/7/16.
//  Copyright © 2017年 WXQ. All rights reserved.
//

#import "ViewController.h"
#import "WCarScoreView.h"


#define SCREEN_WIDTH   ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT  ([[UIScreen mainScreen] bounds].size.height)

@interface ViewController () <WCarScoreViewDelegate>

@property (nonatomic, strong) WCarScoreView *proView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.proView];
    [self initData];
}


-(void)initData
{
    [self.proView start];
    NSLog(@"请求数据");
    __weak typeof (self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [weakSelf.proView stop];
        NSLog(@"数据返回成功或失败");
        weakSelf.proView.progress = 0.78;
    });
}

#pragma mark --SMTDScoreViewDelegate
-(void)realTimeAndDetectionClick:(NSInteger)tag
{
    switch (tag) {
        case 100:
            NSLog(@"实时车况");
            break;
        case 200:
        {
            NSLog(@"一键检测");
            [self initData];
        }
            break;
        default:
            break;
    }
}

- (WCarScoreView *)proView{
    if (!_proView) {
        _proView = [[WCarScoreView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 300) startAngle:160 endAngle:20];
        _proView.circleRadius = 120;
        _proView.progressRadius = 115;
        _proView.fillColor = [UIColor colorWithWhite:1 alpha:0.3];
        _proView.majorScaleLength = 8;
        _proView.delegate = self;
        _proView.majorScaleColor = [UIColor colorWithWhite:1 alpha:0.3];
        [_proView drawRectPro];
    }
    return _proView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
