//
//  Constants.h
//  Demo
//
//  Created by 李 久龙 on 13-10-20.
//  Copyright (c) 2013年 applnc. All rights reserved.
//

#ifndef Demo_Constants_h
#define Demo_Constants_h

//Color
#define RGB(r, g, b)    [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:1.0]

//Frame
#define kWindowHeight CGRectGetHeight([UIScreen mainScreen].applicationFrame)
#define kWindowHeightWithoutNavigationBar (kWindowHeight - 44)
#define kTabBarHeight 49
#define kWindowHeightWithoutTabbar ((kWindowHeight - kTabBarHeight) + (SystemVersionGreaterThanOrEqualTo7 ? 20 : 0))
#define kWindowHeightWithoutNavigationBarAndTabbar (kWindowHeightWithoutNavigationBar - kTabBarHeight)
#define kWindowWidth CGRectGetWidth([UIScreen mainScreen].bounds)
#define kContentFrameWithoutNavigationBar CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kWindowHeightWithoutNavigationBar)
#define kContentFrame CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kWindowHeight + (SystemVersionGreaterThanOrEqualTo7 ? 20 : 0))
#define kContentFrameWithoutNavigationBarAndTabBar CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kWindowHeightWithoutNavigationBarAndTabbar)
#define kContentFrameWithoutTabBar CGRectMake(0, 0, CGRectGetWidth([UIScreen mainScreen].bounds), kWindowHeightWithoutTabbar)

#endif

// 版权属于原作者
// http://code4app.com (cn) http://code4app.net (en)
// 发布代码于最专业的源码分享网站: Code4App.com 
