//
//  CircleView.h
//  Bracelet
//
//  Created by 丁付德 on 16/3/14.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#define PI 3.14159265358979323846

@interface CircleView : UIView


// 1，圆圆
-(id) initWithFrameAndValue:(CGRect)frame width:(CGFloat)width;

// 2，实心圆
-(id) initWithFrameAndValue:(CGRect)frame R:(CGFloat)R G:(CGFloat)G B:(CGFloat)B A:(CGFloat)A;



@end
