//
//  UUBarChart.m
//  UUChartDemo
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUBarChart.h"
#import "UUChartLabel.h"
#import "UUBar.h"

@interface UUBarChart ()
{
    UIScrollView *myScrollView;
}
@end

@implementation UUBarChart
{
    NSHashTable *_chartLabelsForX;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UULabelHeight = 10;
        UUYLabelwidth = 30;
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width-UUYLabelwidth, frame.size.height)];
        myScrollView.scrollEnabled = NO;
        
        [self addSubview:myScrollView];
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame isSpecial:(BOOL)isSpecial arrColor:(NSArray*)arrColor{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
//        UULabelHeight = 22;
        UUYLabelwidth = 44;
        UULabelHeight = 10;
//        UUYLabelwidth = 30;
        self.isSpecial = YES;
        self.arrColor = arrColor;
        self.clipsToBounds = YES;
        myScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(UUYLabelwidth, 0, frame.size.width-UUYLabelwidth, frame.size.height)];
        myScrollView.scrollEnabled = NO;
        
        [self addSubview:myScrollView];
    }
    return self;
}



-(void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    [self setYLabels:yValues];
}

-(void)setYLabels:(NSArray *)yLabels
{
    NSInteger max = 0;
    NSInteger min = 1000000000;
    for (NSArray * ary in yLabels) {
        for (NSString *valueString in ary) {
            NSInteger value = [valueString integerValue];
            if (value > max) {
                max = value;
            }
            if (value < min) {
                min = value;
            }
        }
    }
    if (max < 5) {
        max = 5;
    }
    if (self.showRange) {
        _yValueMin = (int)min;
    }else{
        _yValueMin = 0;
    }
    _yValueMax = (int)max;
    
    if (_chooseRange.max!=_chooseRange.min) {
        _yValueMax = _chooseRange.max;
        _yValueMin = _chooseRange.min;
    }
    
    int tagLevel = self.isSpecial ? 4 : 5;
    float level = (_yValueMax-_yValueMin) / (double)(tagLevel - 1);
    CGFloat chartCavanHeight = self.frame.size.height - UULabelHeight*3;
    CGFloat levelHeight = chartCavanHeight / (double)(tagLevel - 1);
    
//    int tagWidth = self.isSpecial ? 44 : UUYLabelwidth;
//    int tagHeight = self.isSpecial ? 22 : UULabelHeight;
    for (int i=0; i<tagLevel; i++)
    {
        CGFloat value = level * i+_yValueMin;
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(0,
                                                                              chartCavanHeight-i*levelHeight+(self.isSpecial ? 10 : 5),
                                                                              UUYLabelwidth,
                                                                              UULabelHeight)];
        label.textColor = DWhite;
        label.text = [NSString stringWithFormat:@"%.0f",value];
        if (self.isSpecial) {
            switch ([label.text intValue]) {
                case 0:
                    label.text = @"";
                    break;
                case 1:
                    label.text = kString(@"浅度");
                    break;
                case 2:
                    label.text = kString(@"中度");
                    break;
                case 3:
                    label.text = kString(@"深度");
                    break;
                    
                default:
                    break;
            }
        }
        
//        Border(label, DRed);
        [self addSubview:label];
    }
    
    // 划线
    
    for (int i=0; i<tagLevel; i++)
    {
        if (i != tagLevel - 1) continue;
        
        CAShapeLayer *shapeLayer = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:CGPointMake(UUYLabelwidth,UULabelHeight+i*levelHeight )];
        [path addLineToPoint:CGPointMake(self.frame.size.width,UULabelHeight+i*levelHeight)];
        [path closePath];
        shapeLayer.path = path.CGPath;
        shapeLayer.strokeColor = DWhiteA(0.3).CGColor;
        shapeLayer.fillColor = [[UIColor whiteColor] CGColor];
        shapeLayer.lineWidth = 1;
        
        if (!self.isSpecial) {
            [self.layer addSublayer:shapeLayer];
        }
        else if (i == tagLevel - 1) {
            [self.layer addSublayer:shapeLayer];
        }
    }
}

-(void)setXLabels:(NSArray *)xLabels
{
    if( !_chartLabelsForX ){
        _chartLabelsForX = [NSHashTable weakObjectsHashTable];
    }

    _xLabels = xLabels;
    NSInteger num = xLabels.count - (self.xLblIsAlighLeft ? 1:0);
    _xLabelWidth = myScrollView.frame.size.width/num;
//    CGFloat xWidth = 20;
    
//    Border(myScrollView, DYellow);
    
    
    CGFloat xTag = self.xLblIsAlighLeft ? _xLabelWidth / 2 : 0;
    
    
    for (int i=0; i<xLabels.count; i++)
    {
        CGFloat x;
        if (i == 0) {
            if ([xLabels[i] intValue] >= 10) {
                x = -1;
            }else
                x = 0;
        }else{
            x = (i *  _xLabelWidth )-3 - xTag - (i == xLabels.count - 1 ? 7:0);
        }
            
        UUChartLabel * label = [[UUChartLabel alloc] initWithFrame:CGRectMake(x, self.frame.size.height - UULabelHeight - 5, _xLabelWidth + 8, UULabelHeight)];
        label.text = xLabels[i];
        label.textColor = DWhite;
        if (!i && self.xLblIsAlighLeft) {
            label.textAlignment = NSTextAlignmentLeft;
        }else
            label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = DClear;
        if (i % self.Interval == 0)
        {
            [myScrollView addSubview:label];
            [myScrollView bringSubviewToFront:label];
        }
        
        
    }
    
    float max = (([xLabels count]-1)*_xLabelWidth + chartMargin)+_xLabelWidth;
    if (myScrollView.frame.size.width < max-10) {
        myScrollView.contentSize = CGSizeMake(max, self.frame.size.height);
    }
}

-(void)setColors:(NSArray *)colors
{
    _colors = colors;
}
- (void)setChooseRange:(CGRange)chooseRange
{
    _chooseRange = chooseRange;
}
-(void)strokeChart
{
    CGFloat chartCavanHeight = myScrollView.frame.size.height - UULabelHeight*3;
    //NSLog(@"-----------  chartCavanHeight = %.0f", chartCavanHeight);
    
    for (int i=0; i<_yValues.count; i++) {
        if (i==2)
            return;
        NSArray *childAry = _yValues[i];
        for (int j=0; j<childAry.count; j++)
        {
            NSString *valueString = childAry[j];
            float value = [valueString floatValue];
            
            float grade = ((float)value-_yValueMin) / ((float)_yValueMax-_yValueMin);
            UUBar * bar = [[UUBar alloc] initWithFrame:CGRectMake(
                                                                  (j+(_yValues.count==1?0:0.25))*_xLabelWidth +i*_xLabelWidth * 0.1, //
                                                                  0,
                                                                  _xLabelWidth, //  * (_yValues.count==1?0.8:0.45)
                                                                  chartCavanHeight + UULabelHeight)];
            
            //NSLog(@"x:%f, width:%f", bar.frame.origin.x,bar.frame.size.width);
            bar.barColor = [_colors objectAtIndex:i];
            bar.isSpecial = self.isSpecial;
            
            int tag = grade * 10;
            if (self.isSpecial)
            {
                switch (tag) {
                    case 10:
                        bar.barColor = self.arrColor[0];
                        break;
                    case 6:
                        bar.barColor = self.arrColor[1];
                        break;
                    case 3:
                        bar.barColor = self.arrColor[2];
                        break;
                        
                    default:
                        break;
                }
            }
            
            bar.grade = grade;
//            Border(bar, DRed);
            [myScrollView addSubview:bar];
        }
    }
}


- (NSArray *)chartLabelsForX
{
    return [_chartLabelsForX allObjects];
}

@end






















