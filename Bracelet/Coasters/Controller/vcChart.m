//
//  vcChart.m
//  Coasters
//
//  Created by 丁付德 on 15/10/8.
//  Copyright © 2015年 dfd. All rights reserved.
//

#import "vcChart.h"
#import "vcFirst.h"
#import "vcSecond.h"
#import "vcThird.h"
#import "vcShare.h"

@interface vcChart ()<UIScrollViewDelegate, vcFirstDelegate, vcSecondDelegate, vcThirdDelegate>
{
    UIScrollView  *scrollview;
    NSArray *scrollPages;
    
    UIPageControl *pageControl;
    vcFirst *vcfirst;
    vcSecond *vcsecond;
    vcThird  *vcthird;
}

@end

@implementation vcChart


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButton:nil text:(kString(_model ? @"好友的运动步数记录" : @"运动步数记录"))];
    if (!_model) {
        [self initRightButton:@"share" text:nil];
    }
    
    self.view.backgroundColor = DClear;
    
    self.numberInScrollView = ([DFD shareDFD].isForA5 ? 2:1) + 1;
    [self upDataViewArray:YES];
    [self setUpShowView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if(self.model)
    {
        int endDate = [DFD HmF2KNSDateToInt:DNow];
        int beginDate = [self getNextDayByThisDay:endDate isPre:YES move:6];
        
        RequestCheckAfter(
                          [net getSportData:self.userInfo.access
                                    user_id:self.model.user_id
                                k_date_from:[[DFD HmF2KNSIntToDate:beginDate] toString:@"YYYYMMdd"]
                                  k_date_to:[DNow toString:@"YYYYMMdd"]];,
                          [self dataSuccessBack_getSportData:dic];);
    }
    
    [self upDataViewArray:NO];
    [self setUpShowView];
    
}


-(void)rightButtonClick
{
    [self performSegueWithIdentifier:@"chart_to_share" sender:nil];
}

-(void)dealloc
{
    NSLog(@" vcChart 销毁了");
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}


-(void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)upDataViewArray:(BOOL)isFirst
{
    if (vcfirst)
    {
        vcfirst = [[vcFirst alloc]initWithNibName:@"vcFirst" bundle:nil];
        vcfirst.model = self.model;
        vcfirst.delegate = self;
        vcfirst.view.frame = CGRectMake(ScreenWidth * 0, -NavBarHeight, ScreenWidth, ScreenHeight);
        scrollPages = @[vcfirst.view];
    }
    else
    {
        vcsecond = [[vcSecond alloc]initWithNibName:@"vcSecond" bundle:nil];
        vcsecond.delegate = self;
        vcsecond.model = self.model;
        vcsecond.view.frame = CGRectMake(ScreenWidth * 1, -NavBarHeight, ScreenWidth, ScreenHeight);
        scrollPages = @[vcfirst.view,vcsecond.view];
        
        if (self.numberInScrollView == 3) {
            vcthird = [[vcThird alloc]initWithNibName:@"vcThird" bundle:nil];
            vcthird.delegate = self;
            vcthird.model = self.model;
            vcthird.view.frame = CGRectMake(ScreenWidth * 2, -NavBarHeight, ScreenWidth, ScreenHeight);
            scrollPages = @[vcfirst.view,vcsecond.view, vcthird.view];
        }
    }
}

//加载滑动视图
-(void)setUpShowView
{
    if (scrollview) {
        
        [scrollview removeFromSuperview];
        
        [pageControl removeFromSuperview];
    }
    
    scrollview = [[UIScrollView alloc]initWithFrame:CGRectMake(0,0,ScreenWidth, ScreenHeight)];
    scrollview.showsVerticalScrollIndicator   = NO;
    scrollview.showsHorizontalScrollIndicator = NO;
    scrollview.pagingEnabled                  = YES;
    scrollview.contentSize                    = CGSizeMake(scrollview.frame.size.width * self.numberInScrollView, 0);
    scrollview.scrollsToTop                   = NO;
    scrollview.delegate                       = self;
    scrollview.bounces                        = NO;
    scrollview.directionalLockEnabled         = YES;
    scrollview.backgroundColor                = DidConnectColor;
    
    for (int i = 0; i < scrollPages.count; i++) {
        [scrollview addSubview:[scrollPages objectAtIndex:i]];
    }
    
    pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(ScreenWidth / 4  , ScreenHeight - ((IPhone4 | IPhone5) ? 15 : 30) , ScreenWidth / 2, 15)];
    pageControl.currentPage                   = scrollPages.count;
    pageControl.hidesForSinglePage            = NO;
    pageControl.userInteractionEnabled        = NO;
    pageControl.numberOfPages                 = scrollPages.count;
    pageControl.pageIndicatorTintColor        = RGB(129, 227, 255);
    pageControl.currentPageIndicatorTintColor = RGB(3, 199, 255);
    
    [self.view insertSubview:scrollview atIndex:0];
    
    [self.view addSubview:pageControl];
    
    CGPoint offset = CGPointMake(scrollview.frame.size.width * self.myCurrentPage, 0);
    [scrollview setContentOffset:offset animated:YES];
    pageControl.currentPage = self.myCurrentPage;
}

-(void)dataSuccessBack_getSportData:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSArray *arrData = dic[@"sport_data"];
        if (!arrData) return;
        NSMutableArray *arr_Friend = [NSMutableArray new];
        for (int i = 0; i < arrData.count; i++)
        {
            NSDictionary *dicData = arrData[i];
            NSString *k_date = dicData[@"k_date"];
            NSString *sport_array = dicData[@"sport_array"];
            NSString *distance = dicData[@"distance"];
            NSString *sport_num = dicData[@"sport_num"];
            NSString *situps_num = dicData[@"situps_num"];
            
            NSMutableDictionary *dic_sub = [NSMutableDictionary new];
            [dic_sub setObject:@([k_date integerValue]) forKey:@"dateValue"];
            NSDate *date = [DFD HmF2KNSIntToDate:[k_date intValue]];
            [dic_sub setObject:date forKey:@"date"];
            [dic_sub setObject:sport_array forKey:@"sport_array"];
            [dic_sub setObject:self.model.user_situps_target forKey:@"target"];
            [dic_sub setObject:@([date getFromDate:3]) forKey:@"day"];              // 天 方便查找
            [dic_sub setObject:@([sport_num intValue]) forKey:@"sport_num"];        //
            [dic_sub setObject:@([distance intValue]) forKey:@"distance"];          //
            [dic_sub setObject:@([situps_num intValue]) forKey:@"situps_num"];      // 
            
            [arr_Friend addObject:dic_sub];
        }
        vcfirst.arrDataForFriend = arr_Friend;
        vcsecond.arrDataForFriend = arr_Friend;
        vcthird.arrDataForFriend = arr_Friend;
        [vcfirst selectTabIndex:1];
        [vcsecond selectTabIndex:1];
        [vcthird selectTabIndex:2];
    }
}

#pragma mark - scrollView 委托方法 当scrollView移动结束的时候调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = fabs(scrollView.contentOffset.x) / scrollView.frame.size.width;
    if (pageControl.currentPage != index)
    {
        _myCurrentPage = pageControl.currentPage = index;
        switch (_myCurrentPage) {
            case 0:
                [self initLeftButton:nil text:(_model ? @"好友的运动步数记录" :  @"运动步数记录")];
                [vcsecond pickerViewDisappear];
                break;
            case 1:
                [self initLeftButton:nil text:(_model ? @"好友的睡眠记录" :  @"睡眠记录")];
                [vcfirst pickerViewDisappear];
                [vcthird pickerViewDisappear];
                break;
            case 2:
                [self initLeftButton:nil text:(_model ? @"好友的仰卧起坐记录" :  @"仰卧起坐记录")];
                [vcsecond pickerViewDisappear];
                break;
        }
    }
    
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"chart_to_share"])
    {
        vcShare *sh = (vcShare *)segue.destinationViewController;
        NSMutableArray *arrShare =  [NSMutableArray new];
        NSString *str1;
        NSString *str2;
        switch (_myCurrentPage) {
            case 0:
            {
                str2 = kString(@"运动步数记录");
                switch (vcfirst.indexSub) {
                    case 1:
                        str1 = [NSString stringWithFormat:@"%d-%d-%d %@",(int)vcfirst.yearSub1, (int)vcfirst.monthSub1, (int)vcfirst.daySub1, str2];
                        break;
                    case 2:
                        str1 = [NSString stringWithFormat:@"%d-%d %@",(int)vcfirst.yearSub2, (int)vcfirst.monthSub2, str2];
                        break;
                    case 3:
                        str1 = [NSString stringWithFormat:@"%d %@",(int)vcfirst.yearSub3, str2];
                        break;
                        
                    default:
                        break;
                }
                [arrShare addObject:str1];
                [arrShare addObject:vcfirst.lbl1.text];
                [arrShare addObject:vcfirst.lbl2.text];
                [arrShare addObject:vcfirst.lbl3.text];
                [arrShare addObject:vcfirst.lbl4.text];
                [arrShare addObject:vcfirst.lbl5.text];
                [arrShare addObject:vcfirst.lbl6.text];
                [arrShare addObject:vcfirst.lbl7.text];
                [arrShare addObject:vcfirst.lbl8.text];
                if (vcfirst.indexSub == 1)  [arrShare addObject:vcfirst.lbl9.text];
                [arrShare addObject:vcfirst.lbl10.text];
                [arrShare addObject:vcfirst.lbl11.text];
                if (vcfirst.indexSub == 1)  [arrShare addObject:vcfirst.lbl12.text];
                sh.arrShareData = arrShare;
                sh.shareType = SportTpe;
            }
                break;
            case 1:
            {
                str2 = kString(@"睡眠记录");
                switch (vcsecond.indexSub) {
                    case 1:
                        str1 = [NSString stringWithFormat:@"%ld-%ld-%ld %@",(long)vcsecond.yearSub1, (long)vcsecond.monthSub1, (long)vcsecond.daySub1, str2];
                        break;
                    case 2:
                        str1 = [NSString stringWithFormat:@"%ld-%ld %@",(long)vcsecond.yearSub2, (long)vcsecond.monthSub2, str2];
                        break;
                    case 3:
                        str1 = [NSString stringWithFormat:@"%ld %@",(long)vcsecond.yearSub3, str2];
                        break;
                        
                    default:
                        break;
                }
                [arrShare addObject:str1];
                [arrShare addObject:vcsecond.lbl1.text];
                [arrShare addObject:vcsecond.lbl2.text];
                [arrShare addObject:vcsecond.lbl3.text];
                [arrShare addObject:vcsecond.lbl4.text];
                [arrShare addObject:vcsecond.lbl5.text];
                [arrShare addObject:vcsecond.lbl6.text];
                [arrShare addObject:vcsecond.lbl7.text];
                [arrShare addObject:vcsecond.lbl10.text];
                sh.arrShareData = arrShare;
                sh.shareType = SleepTpe;
            }
                break;
            case 2:
            {
                str2 = kString(@"仰卧起坐记录");
                switch (vcthird.indexSub) {
                    case 1:
                        str1 = [NSString stringWithFormat:@"%ld-%ld %@",(long)vcthird.yearSub2, (long)vcthird.monthSub2, str2];
                        break;
                    case 2:
                        str1 = [NSString stringWithFormat:@"%ld %@",(long)vcthird.yearSub3, str2];
                        break;
                        
                    default:
                        break;
                }
                [arrShare addObject:str1];
                [arrShare addObject:vcthird.lbl1.text];
                [arrShare addObject:vcthird.lbl2.text];
                [arrShare addObject:vcthird.lbl3.text];
                [arrShare addObject:vcthird.lbl4.text];
                [arrShare addObject:vcthird.lbl5.text];
                [arrShare addObject:vcthird.lbl6.text];
                [arrShare addObject:vcthird.lbl7.text];
                [arrShare addObject:vcthird.lbl10.text];
                sh.arrShareData = arrShare;;
                sh.shareType = SitupTpe;
            }
                break;
                
            default:
                break;
        }
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

#pragma mark vcFirstDelegate, vcSecondDelegate, vcThirdDelegate
-(void)pageControlHidden:(BOOL)isHidden
{
    pageControl.hidden = isHidden;
}




@end
