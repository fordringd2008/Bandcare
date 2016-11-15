//
//  tvcFriend.h
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "MGSwipeTableCell.h"

#define kDeleteButtonWidth      60.0f
#define kTagButtonWidth         0.0f
#define kCriticalTranslationX   30
#define kShouldSlideX           -2


@interface tvcFriend : MGSwipeTableCell
{
    BOOL _shouldSlide;
    UIPanGestureRecognizer *_pan;
    UITapGestureRecognizer *_tap;
    UIButton *_deleteButton;
}

@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (weak, nonatomic) IBOutlet UIImageView *imvRight;
@property (weak, nonatomic) IBOutlet UIView *viewHot;

@property (strong, nonatomic)  Friend *model;

@property (nonatomic, assign) BOOL isSlided;

+ (instancetype)cellWithTableView:(UITableView *)tableView;
@end
