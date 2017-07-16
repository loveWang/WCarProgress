//
//  WCarScoreView.h
//  WCarProgress
//
//  Created by WXQ on 2017/7/16.
//  Copyright © 2017年 WXQ. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WCarScoreViewDelegate <NSObject>

-(void)realTimeAndDetectionClick:(NSInteger)tag;

@end

@interface WCarScoreView : UIView

//背景色
@property (nonatomic, strong) UIColor *bgColor;
//外圈半径
@property (nonatomic, assign) CGFloat circleRadius;
//内圈半径
@property (nonatomic, assign) CGFloat progressRadius;
//外圈 内圈弧背景颜色
@property (nonatomic, strong) UIColor *fillColor;
//外层刻度总数
@property (nonatomic, assign) NSInteger majorScaleNum;
//刻度颜色
@property (nonatomic, strong) UIColor *majorScaleColor;
//刻度长度
@property (nonatomic, assign) CGFloat majorScaleLength;
//刻度宽度
@property (nonatomic, assign) CGFloat majorScaleWidth;
//进度值
@property (nonatomic, assign) CGFloat progress;
//分数值
@property (nonatomic, strong) UILabel *valueLable;
//实时车况
@property (nonatomic, strong) UIButton *realTimeButton;
//一键检测
@property (nonatomic, strong) UIButton *detectionButton;

@property (nonatomic, weak) id<WCarScoreViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame
                   startAngle:(CGFloat)start
                     endAngle:(CGFloat)end;

-(void)start;

-(void)stop;

-(void)drawRectPro;



@end
