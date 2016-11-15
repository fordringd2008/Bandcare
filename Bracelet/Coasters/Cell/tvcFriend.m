//
//  tvcFriend.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "tvcFriend.h"

@implementation tvcFriend

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.viewHot.layer.cornerRadius = 5;
    self.imv.layer.cornerRadius = ( self.bounds.size.height - 16 ) / 2;
    self.imv.layer.borderWidth = 1;
    self.imv.layer.borderColor = DLightGrayBlackGroundColor.CGColor;
    [self.imv.layer setMasksToBounds:YES];
    
//    _deleteButton = [UIButton new];
//    _deleteButton.backgroundColor = [UIColor redColor];
//    [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
//    _deleteButton.frame = CGRectMake(0, 0, kDeleteButtonWidth, 60);
//    [self insertSubview:_deleteButton belowSubview:self.contentView];
//    
//    
//    _pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];;
//    _pan.delegate = self;
//    _pan.delaysTouchesBegan = YES;
//    [self.contentView addGestureRecognizer:_pan];
//    
//    _tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapView:)];
//    _tap.delegate = self;
//    _tap.enabled = NO;
//    [self.contentView addGestureRecognizer:_tap];
}

- (void)panView:(UIPanGestureRecognizer *)pan1
{
    CGPoint point = [pan1 translationInView:pan1.view];
    if (self.contentView.frame.origin.x <= kShouldSlideX) {
        _shouldSlide = YES;
    }
    
    if (fabs(point.y) < 1.0) {
        if (_shouldSlide) {
            [self slideWithTranslation:point.x];
        } else if (fabs(point.x) >= 1.0) {
            [self slideWithTranslation:point.x];
        }
    }
    
//    if (pan.state == UIGestureRecognizerStateEnded) {
//        CGFloat x = 0;
//        if (self.contentView.frame.origin.x < -kCriticalTranslationX && !self.isSlided) {
//            x = -(kTagButtonWidth);
//        }
//        [self cellSlideAnimationWithX:x];
//        _shouldSlide = NO;
//    }
    
//    [pan setTranslation:CGPointZero inView:pan.view];
    
}

- (void)tapView:(UITapGestureRecognizer *)tap
{
    NSLog(@"--- >panView");
    if (self.isSlided) {
        [self cellSlideAnimationWithX:0];
    }
}


- (void)slideWithTranslation:(CGFloat)value
{
    if (self.contentView.frame.origin.x < -(kTagButtonWidth) * 1.1 || self.contentView.frame.origin.x > 30) {
        value = 0;
    }
    CGRect frame = self.frame;
    frame.origin.x+=value;
    [self.contentView setFrame:frame];
    NSLog(@"---- %.1f", frame.origin.x);
}

- (void)cellSlideAnimationWithX:(CGFloat)x
{
    [UIView animateWithDuration:0.4 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:2 options:UIViewAnimationOptionLayoutSubviews animations:^{
        CGRect rect = self.contentView.frame;
        rect.origin.x = x;
        self.contentView.frame = rect;
    } completion:^(BOOL finished) {
        self.isSlided = (x != 0);
    }];
}

#pragma mark - gestureRecognizer delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    
    if (self.contentView.frame.origin.x <= kShouldSlideX && otherGestureRecognizer != _pan && otherGestureRecognizer != _tap) {
        NSLog(@"11");
        return NO;
    }
    return YES;
}

-(void)setModel:(Friend *)model
{
    [self.imv sd_setImageWithURL:[NSURL URLWithString:model.user_pic_url] placeholderImage: DefaultLogoImage];
    
    self.lbl.text = model.user_nick_name;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"tvcFriend"; // 标识符
    tvcFriend *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil) {
        cell = [[[NSBundle mainBundle]loadNibNamed:@"tvcFriend" owner:nil options:nil] lastObject];
    }
    return cell;
}
@end
