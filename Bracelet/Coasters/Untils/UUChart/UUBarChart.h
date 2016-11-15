//
//  UUBarChart.h
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UUColor.h"
#define chartMargin     10
#define xLabelMargin    15
#define yLabelMargin    15
//#define UULabelHeight   10
//#define UUYLabelwidth   30 // 44

@interface UUBarChart : UIView
{
    int UULabelHeight;
    int UUYLabelwidth;
}

- (id)initWithFrame:(CGRect)frame isSpecial:(BOOL)isSpecial arrColor:(NSArray*)arrColor;

/**
 * This method will call and troke the line in animation
 */

-(void)strokeChart;

@property (strong, nonatomic) NSArray * xLabels;

@property (strong, nonatomic) NSArray * yLabels;

@property (strong, nonatomic) NSArray * yValues;

@property (nonatomic) CGFloat xLabelWidth;

@property (nonatomic) float yValueMax;
@property (nonatomic) float yValueMin;

@property (nonatomic, assign) BOOL showRange;

@property (nonatomic, assign) CGRange chooseRange;

@property (nonatomic, retain) NSMutableArray *ShowHorizonLine;

@property (nonatomic, strong) NSArray * colors;

@property (assign) NSInteger Interval;                  //  x轴 间隔几个显示

- (NSArray *)chartLabelsForX;

@property (assign, nonatomic) BOOL isSpecial;                      //  为第二个界面准备

@property (assign, nonatomic) BOOL xLblIsAlighLeft;                //  柱子是否在 两个 x轴 label 之间  默认 不是 (在 label的正上方)

@property (strong, nonatomic) NSArray *arrColor;

















@end
