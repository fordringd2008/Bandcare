//
//  vcUseHelp.m
//  Coasters
//
//  Created by 丁付德 on 15/9/5.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcUseHelp.h"

@interface vcUseHelp()
//
//@property (weak, nonatomic) IBOutlet UIImageView *imv;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imv;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;



@end

@implementation vcUseHelp

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self initLeftButtonisInHead:nil text:@"使用帮助"];
    self.viewMainHeight.constant = ScreenWidth * (2734 / 720.0);
    self.imv.image = [UIImage imageNamed:([DFD getLanguage] == 1 ? @"help_zh":@"help_en")];
    
    
    
    Border(self.viewMain, DRed);
    Border(self.viewMain.superview, DBlue);
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

@end
