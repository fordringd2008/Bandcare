//
//  LineProgressView.m
//  Layer
//
//  Created by Carver Li on 14-12-1.
//
//

#import "LineProgressView.h"

@interface LineProgressView()
{
//    UIView *viewMask;
}

@end;

@implementation LineProgressView

- (id)initWithFrame:(CGRect)frame
{
//    CGRect rect = CGRectMake(frame.origin.x-5, frame.origin.y-5, frame.size.width+10, frame.size.height+10);
    self = [super initWithFrame:frame];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self _defaultInit];
    }
    
    return self;
}

- (void)_defaultInit
{
    self.backgroundColor = [UIColor clearColor];
    self.opaque = NO;
    
    self.total = 100;
    self.value = 100;
    self.animationTotal = 2;
    self.animationDuration = 2;
    self.color = [UIColor blackColor];
    self.completed = 0;
    self.completedColor = [UIColor whiteColor];
    
    self.radius = 30.0;
    self.innerRadius = 20.0;
    self.layer.shadowOpacity = 0;
    
    self.startAngle = M_PI*1.5;
    self.endAngle = M_PI * (1.5+2);
}

+ (Class)layerClass
{
    return [LineProgressLayer class];
}

- (void)setTotal:(int)total
{
    _total = total;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.total = total;
    [layer setNeedsDisplay];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.color = color;
    [layer setNeedsDisplay];
}

-(void)setBgColor:(UIColor *)bgColor
{
    [self setBackgroundColor:bgColor];
    
    [self.layer setShadowOffset:CGSizeMake(5, 5)];
    [self.layer setShadowColor:[bgColor CGColor]];
    
    self.layer.borderWidth = 1;
    self.layer.borderColor = bgColor.CGColor;
}


- (void)setCompletedColor:(UIColor *)completedColor
{
    _completedColor = completedColor;
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.completedColor = completedColor;
    [layer setNeedsDisplay];
}

-(void)setCompleted:(int)completed
{
    [self setCompleted:completed animated:NO];
}

- (void)startAnimation:(int)value
{
    [self setAnimationDuration: (value == 0 ? 1:value) / 100.0 * self.animationTotal];  // 防止 = 0
    [self setCompleted:value / 100.0 * self.total animated:NO];
}

- (void)setCompleted:(int)completed animated:(BOOL)animated
{
    if (completed == self.completed && self.completed)
    {
        return;
    }
    
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    if (animated && self.animationDuration > 0.0f)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"completed"];
        animation.duration = self.animationDuration;
        animation.fromValue = [NSNumber numberWithFloat:self.completed];
        animation.toValue = [NSNumber numberWithFloat:completed];
        animation.delegate = self;
        [self.layer addAnimation:animation forKey:@"currentAnimation"];
    }
    
    layer.completed = completed;
    [layer setNeedsDisplay];
}

-(void)setValue:(CGFloat)value
{
    self.endAngle = M_PI * (1.5+ value / self.total * 2.0);
    self.total = ([[UIScreen mainScreen] bounds].size.height == 480 ? 100 : 150) * (value / 100.0); // 刻度个个数
}


- (void)setRadius:(CGFloat)radius
{
    _radius = radius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.radius = radius;
    [layer setNeedsDisplay];
}

- (void)setInnerRadius:(CGFloat)innerRadius
{
    _innerRadius = innerRadius;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.innerRadius = innerRadius;
    [layer setNeedsDisplay];
}

- (void)setStartAngle:(CGFloat)startAngle
{
    _startAngle = startAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.startAngle = startAngle;
    [layer setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle
{
    _endAngle = endAngle;
    
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.endAngle = endAngle;
    [layer setNeedsDisplay];
}

-(void)setAnimationTotal:(CGFloat)animationTotal
{
    _animationTotal = animationTotal;
}


- (void)setAnimationDuration:(CFTimeInterval)animationDuration
{
    _animationDuration = animationDuration;
    LineProgressLayer *layer = (LineProgressLayer *)self.layer;
    layer.animationDuration = animationDuration;
    [layer setNeedsDisplay];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStart:(CAAnimation *)anim
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStart:)]) {
        [self.delegate LineProgressViewAnimationDidStart:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(LineProgressViewAnimationDidStop:)]) {
        [self.delegate LineProgressViewAnimationDidStop:self];
    }
}

@end

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
