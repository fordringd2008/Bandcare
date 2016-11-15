//
//  vcGlobalRank.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/25.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcGlobalRank.h"
#import "tvcFriendRank.h"

@interface vcGlobalRank ()<UITableViewDelegate, UITableViewDataSource>
{
    BOOL                        isLeft;               // 是否是左布局
    int                         rank;
    FriendInGlobal *            fg_mySelf;
    
    UILabel *lblLeft;
    UILabel *lblRight;
    
    UIView *lineLeft;
    UIView *lineRight;
    UIView *lineMiddle;
    
    UIButton *btnLeft;
    UIButton *btnRight;
}

@property (weak, nonatomic) IBOutlet UIView *viewHead;


@property (weak, nonatomic) IBOutlet UITableView        *tabView;

@property (strong, nonatomic) NSArray                     *arrData;



@end

@implementation vcGlobalRank

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"全球排行榜"];
    
    isLeft = YES;
    [self initData];
    [self initView];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    RequestCheckNoWaring(
         [net getTodayGlobalRank:self.userInfo.access
                 today_real_date:[DNow toString:@"YYYYMMdd"]];,
         [self dataSuccessBack_getTodayGlobalRank:dic];)
}

-(void)initData
{
    [FriendInGlobal MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access]  inContext:DBefaultContext];
    DBSave
    
    Friend *fr_mySelf = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
    fg_mySelf         = [FriendInGlobal MR_createEntityInContext:DBefaultContext];
    fg_mySelf.access  = self.userInfo.access;
    fg_mySelf.user_id = [self.userInfo.user_id description];
    fg_mySelf.rank    = @(rank ? rank : 1);
    
    fg_mySelf.nick_name   = self.userInfo.user_nick_name;
    fg_mySelf.url         = self.userInfo.user_pic_url;
    fg_mySelf.user_gender = self.userInfo.user_gender;
    
    if ([fg_mySelf.sport_num intValue] < [fr_mySelf.sport_num intValue]) {
        fg_mySelf.sport_num = fr_mySelf.sport_num;
    }
    if ([fg_mySelf.situp_num intValue] < [fr_mySelf.situps_num intValue]) {
        fg_mySelf.situp_num = fr_mySelf.situps_num;
    }
    
    [self refreshData];
}

-(void)refreshData
{
    NSArray *arrFg;
    if (isLeft) {
        arrFg = [FriendInGlobal findAllSortedBy:@"rank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and  sport_num != %@", self.userInfo.access, @0] inContext:DBefaultContext];
    }else{
        arrFg = [FriendInGlobal findAllSortedBy:@"rank" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@ and situp_num != %@", self.userInfo.access, @0] inContext:DBefaultContext];
    }
    
    [arrFg enumerateObjectsUsingBlock:^(FriendInGlobal *fg, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([fg.access isEqualToString:self.userInfo.access] &&
            [fg.user_id isEqualToString:[self.userInfo.user_id description]]) {
            fg_mySelf = fg;
            *stop = YES;
        }
    }];
    if (arrFg.count > 20) {
        arrFg = [arrFg subarrayWithRange:NSMakeRange(0, 20)];
    }
    
    _arrData = @[ @[fg_mySelf], arrFg ];

}

-(void)initView
{
    
    self.view.backgroundColor = DLightGrayBlackGroundColor;
    if (![DFD shareDFD].isForA5) {
        UIView *viewTableHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 1)];
        self.tabView.tableHeaderView = viewTableHead;
    }else
    {
        self.tabView.tableHeaderView = ({
            UIView *viewHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 60)];
            viewHead.backgroundColor = self.tabView.backgroundColor;
            
            CGRect rectLeft  = CGRectMake(0, 0, ScreenWidth / 2, 40);
            CGRect rectRight = CGRectMake(ScreenWidth / 2, 0, ScreenWidth / 2, 40);
            
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
            
            lineMiddle = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 0, 1, 40)];
            lineMiddle.backgroundColor = DLightGray;
            [viewHead addSubview:lineMiddle];
            
            lineLeft = [[UIView alloc] initWithFrame:CGRectMake(0, 39, ScreenWidth / 2, 1)];
            lineLeft.backgroundColor = SelectedColor;
            [viewHead addSubview:lineLeft];
            
            lineRight = [[UIView alloc] initWithFrame:CGRectMake(ScreenWidth / 2, 39, ScreenWidth / 2, 1)];
            lineRight.backgroundColor = DLightGray;
            [viewHead addSubview:lineRight];
            
            viewHead;
        });
    }
    self.tabView.rowHeight = Bigger(RealHeight(100), 60);
    self.tabView.backgroundColor = DLightGrayBlackGroundColor;
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcFriendRank" bundle:nil] forCellReuseIdentifier:@"tvcFriendRank"];
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
    
    
}

-(void)dataSuccessBack_getTodayGlobalRank:(NSDictionary *)dic{
    if (CheckIsOK)
    {
        DDWeak(self)
        [FriendInGlobal objectsByArray:dic[@"today_global_rank"]
                               context:DBefaultContext
                          perfectBlock:^(id model) {
                              DDStrong(self)
                              FriendInGlobal *fg = model;
                              fg.access = self.userInfo.access;
                          }];
        
        [FriendInGlobal objectsByArray:dic[@"situps_today_global_rank"]
                               context:DBefaultContext
                          perfectBlock:^(id model) {
                              DDStrong(self)
                              FriendInGlobal *fg = model;
                              fg.access = self.userInfo.access;
                          }];
        rank = [dic[@"my_rank"] intValue];
        [self refreshData];
        [self.tabView reloadData];
    }
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (section) {
        int a = (int)((NSArray *)(self.arrData[1])).count;
        return a;
    }
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return  2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return section ? 10:0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendRank *cell = [tvcFriendRank cellWithTableView:tableView];
    FriendInGlobal *model = self.arrData[indexPath.section][indexPath.row];
    cell.isStep = isLeft;
    if (!indexPath.section) {
        cell.isMySelf = YES;
    }
    cell.fgModel = model;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
