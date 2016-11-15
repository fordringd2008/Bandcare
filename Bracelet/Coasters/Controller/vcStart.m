//
//  StartViewController.m
//
//
//  Created by yyh on 14/12/23.
//  Copyright (c) 2014年 yyh. All rights reserved.
//

#import "vcStart.h"

#define  btnHiddenFrame        CGRectMake(ScreenWidth, ScreenHeight * 0.5, ScreenWidth * 0.3, 50)
#define  btnShowFrame          CGRectMake(ScreenWidth * 0.6, ScreenHeight * 0.5, ScreenWidth * 0.3, 50)
//
#if isOnlyFirst == 0
    static const int number = 3;
#else
    static const int number = 2;
#endif

@interface vcStart ()<UIScrollViewDelegate>
{
    BOOL isScrollEnd;
    UIButton *btnGo;
}

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
//@property (nonatomic, strong) UIButton *startButton;
@end

@implementation vcStart

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initScrollView];
    [self initPageControl];
    // 500 120
    [self initBtnGo];
}

//添加scrollView
- (void)initScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    self.scrollView.bounces = NO;
    for (int i = 0; i < number; i ++)
    {
        NSString *imageName;
        imageName = [NSString stringWithFormat:@"start%d",i + 1 + ([DFD getLanguage] == 1 ? 0 : 10)];
        if (number == 3 && i == 1) {
            imageName = [NSString stringWithFormat:@"start0%d",i + 1 + ([DFD getLanguage] == 1 ? 0 : 10)];
        }
        UIImageView *imgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:imageName]];
        imgView.frame = CGRectMake(ScreenWidth * i, 0, ScreenWidth, ScreenHeight);
        [_scrollView addSubview:imgView];
    }
    
    self.scrollView.delegate = self;
    self.scrollView.contentSize = CGSizeMake(ScreenWidth * number, ScreenHeight);
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    
    self.scrollView.contentOffset = CGPointMake(0, 0);
    [self.view addSubview:self.scrollView];
}

- (void)initPageControl
{
    self.pageControl = [UIPageControl new];
    self.pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    self.pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    self.pageControl.bounds = CGRectMake(0, 0, 90, 20);
    self.pageControl.center = CGPointMake(ScreenWidth / 2, ScreenHeight - 40);
    [self.pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    self.pageControl.numberOfPages = number;//self.scrollView.contentSize.width/ScreenWidth;
    self.pageControl.currentPage = 0;
    
    self.scrollView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.pageControl];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    self.pageControl.currentPage = scrollView.contentOffset.x / ScreenWidth;
    [self showButton:self.pageControl.currentPage];
}


- (void)changePage:(UIPageControl *)aPageControl
{
    [self.scrollView setContentOffset:CGPointMake(aPageControl.currentPage * ScreenWidth, 0) animated:YES];
    [self showButton:aPageControl.currentPage];
}

//显示按钮
- (void)showButton:(NSInteger )index
{
    if (index == number - 1)
    {
        self.scrollView.scrollEnabled = NO;
        self.pageControl.hidden = YES;
        [btnGo setHidden:NO];
    }
}

-(void)initBtnGo
{
    btnGo = [[UIButton alloc] initWithFrame:CGRectMake(
                                                       (ScreenWidth - ScreenWidth * (500.0 / 1242.0)) / 2,
                                                       ScreenHeight * (1800.0 / 2280) + (IPhone4 ? 20 : 20),
                                                       ScreenWidth * (500.0 / 1242.0),
                                                       ScreenWidth * (130.0 / 1242.0))];
    [btnGo addTarget:self action:@selector(changeRootViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btnGo];
    [btnGo setHidden:YES];
}

- (void)changeRootViewController
{
    if (self.getPermissions)
        self.getPermissions();
    
    if (self.gotoMainStory)
        self.gotoMainStory();
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
