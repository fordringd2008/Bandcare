//
//  vcFriendsRanking.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriendsRanking.h"
#import "tvcFriendRank.h"
#import "vcFriendDetails.h"

@interface vcFriendsRanking ()<UITableViewDelegate, UITableViewDataSource, tvcFriendRankDelegate>
{
    BOOL                        isLeft;               // 是否是左布局
    UILabel *                   lblNoDataNotice;
    
    UILabel *lblLeft;
    UILabel *lblRight;
    
    UIView *lineLeft;
    UIView *lineRight;
    UIView *lineMiddle;
    
    UIButton *btnLeft;
    UIButton *btnRight;
    
}

@property (weak, nonatomic) IBOutlet UIView *viewHead;

//@property (weak, nonatomic) IBOutlet UILabel *lblLeft;
//@property (weak, nonatomic) IBOutlet UILabel *lblRight;
//
//@property (weak, nonatomic) IBOutlet UIView *lineLeft;
//@property (weak, nonatomic) IBOutlet UIView *lineRight;
//@property (weak, nonatomic) IBOutlet UIView *lineBottomLeft;
//@property (weak, nonatomic) IBOutlet UIView *lineBottomRight;


@property (weak, nonatomic) IBOutlet UITableView          *tabView;
@property (strong, nonatomic) NSArray                     *arrData;


@end

@implementation vcFriendsRanking

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"今日好友排名"];
    [self initRightButtonisInHead:nil text:@"全球排行榜"];
    
    isLeft = YES;
    [self initData];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.tabView reloadData];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // 这里要看当天的数据是否上传了，因为当天的数据是实时的，如果改变，上传
    [self uploadData:^{ }];
}

-(void)rightButtonClick{
    [self performSegueWithIdentifier:@"rank_to_global" sender:nil];
}

-(void)initData
{
    // 如果没有自己的 加入自己的   加入后 以后就不在加入了 只需更新就行
    NSDate *date = DNow;
    NSNumber *k_date = @([DFD HmF2KNSDateToInt:date]);
    
    DataRecord *dr = [DataRecord findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and dateValue == %@", self.userInfo.access, k_date] inContext:DBefaultContext];
    
    if ([dr.date isToday])
    {
        Friend *fr_mySelf = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
        if (!fr_mySelf)
        {
            fr_mySelf                    = [Friend MR_createEntityInContext:DBefaultContext];
            fr_mySelf.access             = self.userInfo.access;
            fr_mySelf.user_id            = [self.userInfo.user_id description];
            fr_mySelf.user_sport_target  = self.userInfo.user_sport_target;
            fr_mySelf.user_situps_target = self.userInfo.user_situps_target;
            fr_mySelf.user_gender        = self.userInfo.user_gender;
            fr_mySelf.user_nick_name     = self.userInfo.user_nick_name;
            fr_mySelf.user_pic_url       = self.userInfo.user_pic_url;
        }
        
        fr_mySelf.sport_like_num = self.userInfo.sport_like_number;
        fr_mySelf.situps_like_num = self.userInfo.situps_like_number;
        
        fr_mySelf.dateTime = date;
        fr_mySelf.k_date = k_date;
        if (dr) {
            fr_mySelf.sport_num = dr.step_count;
            fr_mySelf.situps_num = dr.situps_count;
        }else{
            fr_mySelf.sport_num = @0;
            fr_mySelf.situps_num = @0;
        }
        
        fr_mySelf.user_nick_name = self.userInfo.user_nick_name;
        fr_mySelf.user_pic_url = self.userInfo.user_pic_url;
        DBSave;
    }
    
    if (isLeft)
    {
        self.arrData = [Friend findAllSortedBy:@"sport_num" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and sport_num != %@", self.userInfo.access, k_date, @0] inContext:DBefaultContext];
    }else
    {
        self.arrData = [Friend findAllSortedBy:@"sport_num" ascending:NO withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and k_date == %@ and situps_num != %@", self.userInfo.access, k_date, @0] inContext:DBefaultContext];
    }
    NSLog(@"%@", @(self.arrData.count));
}

-(void)initView
{
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    if (![DFD shareDFD].isForA5)
    {
        self.tabView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
    }else
    {
        self.tabView.tableHeaderView = ({
            UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 80)];
            viewHead.backgroundColor = self.tabView.backgroundColor;
            
            CGRect rectLeft  = CGRectMake(0, 20, ScreenWidth / 2, 40);
            CGRect rectRight = CGRectMake(ScreenWidth / 2, 20, ScreenWidth / 2, 40);
            
            lblLeft = [[UILabel alloc] initWithFrame:rectLeft];
            lblLeft.text = kString(@"运动步数");
            lblLeft.textColor = DBlack;
            lblLeft.textAlignment = NSTextAlignmentCenter;
            lblLeft.font = [UIFont systemFontOfSize:17];
            lblLeft.backgroundColor = DWhite;
            [viewHead addSubview:lblLeft];
            
            lblRight = [[UILabel alloc] initWithFrame:rectRight];
            lblRight.text = kString(@"仰卧起坐");
            lblRight.textColor = DBlack;
            lblRight.textAlignment = NSTextAlignmentCenter;
            lblRight.font = [UIFont systemFontOfSize:17];
            lblRight.backgroundColor = DWhite;
            [viewHead addSubview:lblRight];
            
            
            btnLeft = [[UIButton alloc] initWithFrame:rectLeft];
            btnLeft.backgroundColor = DClear;
            btnLeft.enabled = NO;
            [btnLeft addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewHead addSubview:btnLeft];
            btnRight = [[UIButton alloc] initWithFrame:rectRight];
            btnRight.backgroundColor = DClear;
            [btnRight addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            [viewHead addSubview:btnRight];
            
            lineMiddle = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 20, 1, 40)];
            lineMiddle.backgroundColor = DLightGray;
            [viewHead addSubview:lineMiddle];
            
            lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 59, ScreenWidth / 2, 1)];
            lineLeft.backgroundColor = SelectedColor;
            [viewHead addSubview:lineLeft];
            
            lineRight = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 59, ScreenWidth / 2, 1)];
            lineRight.backgroundColor = DLightGray;
            [viewHead addSubview:lineRight];
            
            viewHead;
        });
    }
    self.tabView.rowHeight = Bigger(RealHeight(100), 60);
    self.tabView.showsVerticalScrollIndicator = NO;
    self.tabView.scrollEnabled = YES;
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcFriendRank" bundle:nil] forCellReuseIdentifier:@"tvcFriendRank"];
    
    lblNoDataNotice = [[UILabel alloc] initWithFrame:CGRectMake(20, 20 + NavBarHeight + ([DFD shareDFD].isForA5 ?40:0), ScreenWidth - 40, 42)];
    lblNoDataNotice.text = kString(@"今天没有好友的记录,快去提醒Ta们吧~");
    lblNoDataNotice.textAlignment = NSTextAlignmentCenter;
    lblNoDataNotice.font = [UIFont systemFontOfSize:17];
    lblNoDataNotice.textColor = DLightGray;
    lblNoDataNotice.numberOfLines = 2;
//    [self.view addSubview:lblNoDataNotice];
    
#warning Test  这里在切换的时候，需要重新刷新显示
    
    lblNoDataNotice.hidden = (BOOL)_arrData.count;
}

- (void)btnClick:(UIButton *)sender
{
    if (isLeft == [sender isEqual:btnLeft]) return;
    if ([sender isEqual:btnRight]) {
        lineLeft.backgroundColor  = DLightGray;
        lineRight.backgroundColor = SelectedColor;
        btnLeft.enabled = YES;
        btnRight.enabled = NO;
        isLeft = NO;
    }else{
        lineLeft.backgroundColor  = SelectedColor;
        lineRight.backgroundColor = DLightGray;
        btnLeft.enabled = NO;
        btnRight.enabled = YES;
        isLeft = YES;
    }
    NSLog(@"刷新数据源");
#warning Bug 刷新数据源
}

-(void)dataSuccessBack_pushLikeInfo:(NSDictionary *)dic{
    if (CheckIsOK) {
        NSLog(@"点赞成功");
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendRank *cell = [tvcFriendRank cellWithTableView:tableView];
    if (self.arrData.count > 0)
    {
        cell.isStep = isLeft;
        cell.model = self.arrData[indexPath.row];
        
        cell.lblNumber.text = [NSString stringWithFormat:@"%d", (int)indexPath.row + 1];
        
        if ([cell.model.user_id isEqualToString: [self.userInfo.user_id description]] || (isLeft ? [cell.model.last_sportlike_kDate intValue]:[cell.model.last_situplike_kDate intValue]) == [DFD HmF2KNSDateToInt:DNow]) {
            cell.btnlike.enabled = NO;
        }else{
            cell.btnlike.enabled = YES;
        }
    }
    cell.delegate = self;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Friend *fr = self.arrData[indexPath.row];
    if (![fr.user_id isEqualToString:[self.userInfo.user_id description]])
        [self performSegueWithIdentifier:@"rank_to_details" sender:fr];
}

#pragma mark tvcFriendRankDelegate
-(void)btnClickLike:(tvcFriendRank *)cell
{
    __block tvcFriendRank *blockCell = cell;
    NSString *userid = cell.model.user_id;
    int type = cell.isStep ? 5:6;
    
    void (^likeBlock)(tvcFriendRank *cell, BOOL isLike) = ^(tvcFriendRank *cell, BOOL isLike)
    {
        Friend *fr = cell.model;
        if (cell.isLiked)
        {
            if (cell.isStep) {
                fr.sport_like_num = @([fr.sport_like_num intValue]+(isLike ? 1:-1));
                fr.last_sportlike_kDate = isLike ? @([DFD HmF2KNSDateToInt:DNow]) : nil;
            }else{
                fr.situps_like_num = @([fr.situps_like_num intValue]+(isLike ? 1:-1));
                fr.last_situplike_kDate = isLike ? @([DFD HmF2KNSDateToInt:DNow]) : nil;
            }
            DBSave;
            if(isLike)
            {
                cell.lblLikeNumber.text = [NSString stringWithFormat:@"%d", [cell.lblLikeNumber.text intValue]+(isLike ? 1:-1)];
            }
        }
    };
    
    likeBlock(cell, YES);
    
    
//    k_date
    
    
    RequestCheckBefore(
           [net pushLikeInfo:self.userInfo.access
                        type:type
                   friend_id:userid
             today_real_date:[DNow toString:@"YYYYMMdd"]];,
           [self dataSuccessBack_pushLikeInfo:dic];,
           likeBlock(blockCell, NO);)
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"rank_to_details"])
    {
        vcFriendDetails *vc = (vcFriendDetails *)segue.destinationViewController;
        vc.model = sender;
    }
}






@end
