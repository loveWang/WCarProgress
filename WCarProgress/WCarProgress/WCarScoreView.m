//
//  WCarScoreView.m
//  WCarProgress
//
//  Created by WXQ on 2017/7/16.
//  Copyright © 2017年 WXQ. All rights reserved.
//

#import "WCarScoreView.h"
#import "UIView+Extension.h"

#define RGB(a,b,c,r)        [UIColor colorWithRed:a/255.0f green:b/255.0f blue:c/255.0f alpha:r]

#define MAIN_GREEN_COLOR     RGB(2,180,128,1.0)

#define MAIN_RED_COLOR       RGB(255,89,114,1.0)
#define MAIN_ORANGE_COLOR    RGB(254,160,64,1.0)


#define DEGREES_TO_RADIANS(degrees) ((degrees)*M_PI)/180
#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define STARTANGLE(radians) 180-radians
#define ENDANGLE(radians)  (360-(90-radians)*2)

@interface WCarScoreView ()
{
    CGFloat _startAngle;
    
    CGFloat _endAngle;
    
    CGFloat _centerCircleX;
    
    CGFloat _centerCircleY;
    
    double _offsetOutAngle;
    
    double _offsetAngle;
}

@property (nonatomic, strong) CAShapeLayer *progressLayer;

@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) NSTimer *progressTime;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) NSTimer *lastTimer;

@property (nonatomic, assign) float currentProgress;

@property (nonatomic, assign) float lastProgress;

@end

@implementation WCarScoreView

- (instancetype)initWithFrame:(CGRect)frame
                   startAngle:(CGFloat)start
                     endAngle:(CGFloat)end {
    if (self = [super initWithFrame:frame]) {
        _startAngle = start;
        _endAngle = end;
        [self initUI];
        [self initData];
    }
    return self;
}

-(void)initUI
{
    UIButton *realTimeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _realTimeButton = realTimeButton;
    [realTimeButton setTitle:@"实时车况" forState:UIControlStateNormal];
    [realTimeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    realTimeButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    realTimeButton.tag = 100;
    [realTimeButton addTarget:self action:@selector(realTimeAndDetectionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:realTimeButton];
    
    UIButton *detectionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _detectionButton = detectionButton;
    [detectionButton setTitle:@"一键检测" forState:UIControlStateNormal];
    [detectionButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    detectionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    detectionButton.layer.borderWidth = 1;
    detectionButton.layer.borderColor = [UIColor whiteColor].CGColor;
    detectionButton.layer.cornerRadius = 20;
    detectionButton.layer.masksToBounds = YES;
    detectionButton.tag = 200;
    [detectionButton addTarget:self action:@selector(realTimeAndDetectionClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:detectionButton];
    
    UILabel *valueLable = [[UILabel alloc] init];
    _valueLable = valueLable;
    valueLable.text = @" - -分";
    valueLable.textColor = [UIColor whiteColor];
    valueLable.font = [UIFont systemFontOfSize:60];
    valueLable.textAlignment = NSTextAlignmentCenter;
    NSInteger length = [valueLable.text length];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:valueLable.text];
    [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18] ,NSBaselineOffsetAttributeName : @35} range:NSMakeRange(length-1, 1)];
    [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:60]} range:NSMakeRange(0, length-1)];
    _valueLable.attributedText = attr;
    [self addSubview:valueLable];
}

//默认数据
- (void)initData
{
    _bgColor = MAIN_GREEN_COLOR;
    self.backgroundColor = _bgColor;
    _fillColor = [UIColor colorWithWhite:1 alpha:0.3];
    _circleRadius = 110;
    _progressRadius = 100;
    _majorScaleNum = 15;
    _majorScaleWidth = 1;
    _majorScaleLength = 8;
    _majorScaleColor = _fillColor;
    _progress = 0.0;
    _centerCircleX = self.width/2;
    _centerCircleY = (self.height-64)/2+64+20;
    _offsetOutAngle = [self calculateAngleValueRadius:_circleRadius difRadius:5];
    _offsetAngle = [self calculateAngleValueRadius:_circleRadius difRadius:12];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat realX = self.width - 100;
    CGFloat realY = 27;
    CGFloat realW = 100;
    CGFloat realH = 30;
    self.realTimeButton.frame = CGRectMake(realX, realY, realW, realH);
    
    CGFloat valueX = 0;
    CGFloat valueY = (self.height-64)/2+54;
    CGFloat valueW = self.width;
    CGFloat valueH = 40;
    self.valueLable.frame = CGRectMake(valueX, valueY, valueW, valueH);
    
    CGFloat deteW = 120;
    CGFloat deteH = 40;
    CGFloat deteX = (self.width - deteW)/2;
    CGFloat deteY = _centerCircleY + _circleRadius*sin(DEGREES_TO_RADIANS(_startAngle));
    self.detectionButton.frame = CGRectMake(deteX, deteY, deteW, deteH);
}

-(void)realTimeAndDetectionClick:(UIButton *)sender
{
    if (_lastTimer == nil && _timer == nil && _progressTime == nil) {
        if ([_delegate respondsToSelector:@selector(realTimeAndDetectionClick:)]) {
            [_delegate realTimeAndDetectionClick:sender.tag];
        }
    }
}

#pragma mark ---进度弧
-(void)drawRectPro
{
    [self drowOuter];
    [self drawScale];
    [self drowBottom];
    [self drowProgress];
}

//外层
-(void)drowOuter
{
    double offsetAngle = [self calculateAngleValueRadius:self.circleRadius difRadius:1];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(_centerCircleX, _centerCircleY) radius:self.circleRadius startAngle:DEGREES_TO_RADIANS(STARTANGLE(_endAngle)) endAngle:DEGREES_TO_RADIANS(_startAngle+ENDANGLE(_endAngle)) clockwise:YES];
    [path addArcWithCenter:CGPointMake(_centerCircleX, _centerCircleY) radius:self.circleRadius-2 startAngle:DEGREES_TO_RADIANS(STARTANGLE(offsetAngle)+ENDANGLE(offsetAngle)) endAngle:DEGREES_TO_RADIANS(180-offsetAngle) clockwise:NO];
    [path closePath];
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = path.CGPath;
    arc.fillColor = self.fillColor.CGColor;
    arc.strokeColor = self.fillColor.CGColor;
    [self.layer addSublayer:arc];
    
}
//刻度
-(void)drawScale
{
    CGFloat totalScale = self.majorScaleNum;
    //每个刻度旋转的度数
    CGFloat perAngle = (_endAngle+360 - _startAngle - 10)/ _majorScaleNum;
    for (NSInteger i = 0; i < totalScale + 1; i ++) {
        CGFloat startAngle = _startAngle + perAngle*i;
        CGFloat endAngle = startAngle + 1/(2*M_PI*_circleRadius)*360;
        UIBezierPath *majorPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(_centerCircleX, _centerCircleY)
                                                                 radius:_circleRadius + 7
                                                             startAngle:DEGREES_TO_RADIANS(startAngle + 5)
                                                               endAngle:DEGREES_TO_RADIANS(endAngle + 5)
                                                              clockwise:YES];
        CAShapeLayer *majorLayer = [CAShapeLayer layer];
        majorLayer.strokeColor = self.fillColor.CGColor;
        majorLayer.path = [majorPath CGPath];
        majorLayer.lineWidth = self.majorScaleLength;
        [self.layer addSublayer:majorLayer];
    }
}
//内层背景
-(void)drowBottom
{
    UIBezierPath *path = [self getProgressPath:1.0];
    CAShapeLayer *arc = [CAShapeLayer layer];
    arc.path = path.CGPath;
    arc.fillColor = self.fillColor.CGColor;
    arc.strokeColor = self.fillColor.CGColor;
    [self.layer addSublayer:arc];
}
//内层进度
-(void)drowProgress
{
    UIBezierPath *path = [self getProgressPath:0.0];
    CAShapeLayer *arc = [CAShapeLayer layer];
    _progressLayer = arc;
    arc.path = path.CGPath;
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    _gradientLayer = gradientLayer;
    gradientLayer.frame = self.frame;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:1 alpha:0.4].CGColor,(__bridge id)[UIColor colorWithWhite:1 alpha:1].CGColor];
    gradientLayer.startPoint = CGPointMake(0,0.5);
    gradientLayer.endPoint = CGPointMake(1,0.5);
    CALayer *lay = [CALayer layer];
    [lay addSublayer:gradientLayer];
    lay.mask = _progressLayer;
    [self.layer addSublayer:lay];
}

-(UIBezierPath *)getProgressPath:(CGFloat)progress
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path setLineWidth:1.0];
    [path addArcWithCenter:CGPointMake(_centerCircleX, _centerCircleY) radius:_progressRadius startAngle:DEGREES_TO_RADIANS(STARTANGLE(_offsetOutAngle)) endAngle:DEGREES_TO_RADIANS(180-_offsetOutAngle+ENDANGLE(_offsetOutAngle)*progress) clockwise:YES];
    [path addArcWithCenter:CGPointMake(_centerCircleX, _centerCircleY) radius:_progressRadius - 7 startAngle:DEGREES_TO_RADIANS(STARTANGLE(_offsetAngle)+ENDANGLE(_offsetAngle)*progress) endAngle:DEGREES_TO_RADIANS(180-_offsetAngle) clockwise:NO];
    return path;
}

//计算角度
-(double)calculateAngleValueRadius:(CGFloat)radius difRadius:(CGFloat)difRadius
{
    double offsetAngle = 0.0;
    //double x1 = self.width/2 + radius*cos(DEGREES_TO_RADIANS(_startAngle));
    double y1 = _centerCircleY + radius*sin(DEGREES_TO_RADIANS(_startAngle));
    double valueA = fabs(sqrt((radius-difRadius)*(radius-difRadius)-((y1-_centerCircleY)*(y1-_centerCircleY))) - _centerCircleX);
    //利用余弦定理求角弧度
    double fa = radius*sin(DEGREES_TO_RADIANS(_startAngle));
    double fb = radius-difRadius;
    double fc = (_centerCircleX - valueA);
    double offsetRadian = acos((fb*fb+fc*fc-fa*fa)/(2*fb*fc));
    offsetAngle = RADIANS_TO_DEGREES(offsetRadian);
    return offsetAngle;
}
#pragma mark ---定时器
-(void)openProgressTimer
{
    NSTimer *progressTime = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(valueFlicker) userInfo:nil repeats:YES];
    _progressTime = progressTime;
    [[NSRunLoop currentRunLoop] addTimer:progressTime forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

-(void)openlastTimer
{
    NSTimer *lastTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(ChangeCircleValuelast) userInfo:nil repeats:YES];
    _lastTimer = lastTimer;
    [[NSRunLoop mainRunLoop] addTimer:lastTimer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

-(void)openTimer
{
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(ChangeCircleValue) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    [[NSRunLoop currentRunLoop] run];
}

#pragma mark ---数值跳动
-(void)start
{
    [NSThread detachNewThreadSelector:@selector(openProgressTimer) toTarget:self withObject:nil];
}

-(void)stop
{
    [_progressTime invalidate];
    _progressTime = nil;
}

-(void)valueFlicker
{
    NSInteger value = arc4random()%100;
    [self performSelectorOnMainThread:@selector(setValueForLable:) withObject:@(value) waitUntilDone:YES];
}

-(void)ChangeCircleValuelast
{
    _lastProgress -= 0.01;
    if (_lastProgress < 0) {
        [_lastTimer invalidate];
        _lastTimer = nil;
        [NSThread detachNewThreadSelector:@selector(openTimer) toTarget:self withObject:nil];
        return;
    }
    [self performSelectorOnMainThread:@selector(setValueForProgress:) withObject:@(_lastProgress) waitUntilDone:YES];
}

-(void)ChangeCircleValue
{
    _currentProgress += 0.01;
    if (_currentProgress > _progress) {
        _lastProgress = _progress;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    [self performSelectorOnMainThread:@selector(setValueForProgress:) withObject:@(_currentProgress) waitUntilDone:YES];
}
#pragma mark ---赋值
- (void)setProgress:(CGFloat)progress
{
    NSLog(@"progress====%f",progress);
    _progress = progress;
    if (_lastProgress > 0) {
        _currentProgress = 0.0;
        [NSThread detachNewThreadSelector:@selector(openlastTimer) toTarget:self withObject:nil];
    }else{
        _lastProgress = progress;
        _currentProgress = 0.0;
        [NSThread detachNewThreadSelector:@selector(openTimer) toTarget:self withObject:nil];
    }
}

-(void)setValueForProgress:(NSNumber *)currentProgress
{
    float value = [currentProgress floatValue];
    UIBezierPath *path = [self getProgressPath:value];
    _progressLayer.path = path.CGPath;
    _gradientLayer.locations = @[@(value*0.5) ,@(value*0.75)];
    int valueNum = round(value*100.0);
    [self setValueForLable:@(valueNum)];
    if (valueNum >= 0 && valueNum < 60) {
        self.backgroundColor = MAIN_RED_COLOR;
    }else if(valueNum >= 60 && valueNum < 80){
        self.backgroundColor = MAIN_ORANGE_COLOR;
    }else{
        self.backgroundColor = MAIN_GREEN_COLOR;
    }
}

-(void)setValueForLable:(NSNumber *)value
{
    NSString *str = [NSString stringWithFormat:@" %ld分",[value integerValue]];
    NSInteger length = [str length];
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:str];
    [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18] ,NSBaselineOffsetAttributeName : @35} range:NSMakeRange(length-1, 1)];
    [attr setAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:60]} range:NSMakeRange(0, length-1)];
    _valueLable.attributedText = attr;
}


@end
