//
//  vcFriend.m
//  Coasters
//
//  Created by 丁付德 on 15/8/11.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriend.h"
#import "QRCodeReaderViewController.h"
#import "tvcFriend.h"
#import "vcFriendDetails.h"
#import "TAlertView.h"
#import "WBPopMenuModel.h"
#import "WBPopMenuSingleton.h"


@interface vcFriend ()<UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate,QRCodeReaderDelegate>
{
    NSString *addAccount;
    
    NSInteger countOfFirst;                 // 第一个分区的行数

    
    BOOL isLeft;                            // 是否离开
    NSTimer *timer;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;



@property (strong, nonatomic) UITableView *tabView;
@property (strong, nonatomic) NSMutableArray *arrData;

@property (strong, nonatomic) NSIndexPath *currentIndexPath;          // 要删除的行

@end

@implementation vcFriend

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initLeftButtonisInHead:nil text:@"我的好友"];
    [self initRightButtonisInHead:@"addFriend" text:nil];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    isLeft = NO;
    [self initData];
    [self refreshData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    isLeft = YES;
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    NSLog(@" vcFriend 销毁了");
}

-(void)initData
{
    RequestCheckNoWaring(
          [net getFriendsInfo:self.userInfo.access
             today_real_date:[DNow toString:@"YYYYMMdd"]];,
          [self dataSuccessBack_getFriendsInfo:dic];);
}

-(void)refreshData
{
    NSInteger countForAddFriend = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @(1), @(NO)] inContext:DBefaultContext] integerValue];
    if (countForAddFriend)
        countOfFirst = 2;
    else
        countOfFirst = 1;
    
    NSMutableArray *arrDat = [[Friend findAllSortedBy:@"user_id" ascending:YES withPredicate:[NSPredicate predicateWithFormat:@"access == %@", self.userInfo.access] inContext:DBefaultContext] mutableCopy];
    
    Friend *fr_self = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
    
    if (fr_self)
        [arrDat removeObject:fr_self];
    self.arrData = [arrDat mutableCopy];
    [_tabView reloadData];
}


-(void)initView
{
    _viewMainHeight.constant = ScreenHeight;
    self.view.backgroundColor = self.viewMain.backgroundColor = DLightGrayBlackGroundColor;
    [self initTable];
}

-(void)rightButtonClick
{
//    TAlertView *alterSelect = [[TAlertView alloc] initWithTitle:@"请选择" message:@""];
//    NSArray *arr = @[@"通过账号", @"通过二维码"];
//    __block vcFriend *blockSelf = self;
//    void (^block_1)() =  ^(){
//        TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入好友账号:" message:@""];
//        [alterAccount showWithTXFActionSure:^(id str) {
//            [blockSelf addFriendByAccount:str accountType: [(NSString*)str isEmailType] ? 1:2]; } cancel:^{}];
//    };
//    
//    void (^block_2)() =  ^(){ [blockSelf addFriendByCamera]; };
//    NSArray *arrBlock = @[block_1, block_2];
//    [alterSelect showWithAcitons:arr arrActions:arrBlock];
    
    NSArray *arrTitle = @[ kString(@"通过账号"), kString(@"通过二维码")];
    NSArray *arrImage = @[ @"circle_input", @"right_menu_QR" ];
    
    NSMutableArray *obj = [NSMutableArray array];
    for (NSInteger i = 0; i < arrTitle.count; i++){
        WBPopMenuModel * info = [WBPopMenuModel new];
        info.image = arrImage[i];
        info.title = arrTitle[i];
        [obj addObject:info];
    }
    DDWeak(self)
    [[WBPopMenuSingleton shareManager] showPopMenuSelecteWithFrame:200
                                                             right:4
                                                              item:obj
                                                            action:^(NSInteger index) {
                                                                [weakself rightSelect:index];
                                                            }];
}

-(void)rightSelect:(NSInteger)index
{
    DDWeak(self)
    if (index == 0)
    {
        TAlertView *alterAccount =[[TAlertView alloc] initWithTitle:@"请输入好友账号:" message:@""];
        [alterAccount showWithTXFActionSure:^(id str)
        {
            [weakself addFriendByAccount:str
                              accountType: [(NSString*)str
                                            isEmailType] ? 1:2];
        }cancel:^{} ];
    }else{
        [self addFriendByCamera];
    }
}

// accountType : 1 邮箱  2,电话  3 第三方
-(void)addFriendByAccount:(NSString *)str accountType:(int)accountType
{
    NSLog(@"%@", str);
    if (!str)
    {
        LMBShow(@"无效的二维码");return;
    }
    NSString *typeString = [NSString stringWithFormat:@"0%d", accountType];
    NSString *content = [NSString stringWithFormat:@"%@ %@", self.userInfo.user_nick_name, kString(@"申请加您为好友")];
    if ([str isEqualToString:self.userInfo.account])
    {
        [self dataSuccessBack_applyFriend:@{@"status":@"8"}];
    }
    else
    {
        RequestCheckAfter(
              [net applyFriend:self.userInfo.access
                friend_account:str
           friend_account_type:typeString
                  push_content:content];,
              [self dataSuccessBack_applyFriend:dic];);
    }
}

-(void)addFriendByCamera
{
    QRCodeReaderViewController *reader = [QRCodeReaderViewController new];
    reader.modalPresentationStyle = UIModalPresentationFormSheet;
    reader.delegate = self;
    
    DDWeak(self)
    [reader setCompletionWithBlock:^(NSString *resultAsString)
    {
        DDStrong(self)
        [self.navigationController popViewControllerAnimated:YES];
        NSLog(@"----  %@", resultAsString);
        NSRange range = [resultAsString rangeOfString:orReaderPrefix];
        if (range.length > 0)
        {
            NSString *dicString = [resultAsString substringFromIndex:range.length + 3];
            NSDictionary *dicDataFromOR = [DFD dictionaryWithJsonString:dicString];
            NSString *email = dicDataFromOR.allValues[0];
            int accountType = 0;
            if ([dicDataFromOR.allKeys[0] isEqualToString:@"email"]) {
                accountType = 1;
            }else if ([dicDataFromOR.allKeys[0] isEqualToString:@"phone"]) {
                accountType = 2;
            }else if ([dicDataFromOR.allKeys[0] isEqualToString:@"third_party_id"]) {
                accountType = 3;
            }
            [self addFriendByAccount:email accountType:accountType];
        }
        else LMBShow(@"无效的二维码");
    }];
    
    [self.navigationController pushViewController:reader animated:YES];
}

-(void)hideScan
{
//    [self presentViewController:reader animated:YES completion:NULL];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

- (void)readerDidCancel:(QRCodeReaderViewController *)reader
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)initTable
{
    _tabView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight - NavBarHeight) style:UITableViewStyleGrouped];
    _tabView.contentSize = CGSizeMake(ScreenWidth, ScreenHeight);
    _tabView.dataSource = self;
    _tabView.delegate = self;
    _tabView.showsVerticalScrollIndicator = NO;
    _tabView.scrollEnabled = YES;
    _tabView.backgroundColor = DClear;
    [_tabView registerNib:[UINib nibWithNibName:@"tvcFriend" bundle:nil] forCellReuseIdentifier:@"tvcFriend"];
    _tabView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 20)];
        view.backgroundColor = _tabView.backgroundColor;
        view;
    });
    [_viewMain addSubview:_tabView];
}

#pragma mark UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    if (!section) {
        return countOfFirst;
    }
    else
        return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriend *cell = [tvcFriend cellWithTableView:tableView];
    [cell.viewHot setHidden:YES];
    if (indexPath.section && self.arrData.count)              // 好友列表
    {
        [cell.imvRight setHidden:YES];
        Friend  *model = self.arrData[indexPath.row];
        cell.model = model;
        
        MGSwipeButton *btnDelete = [MGSwipeButton buttonWithTitle:kString(@"删除") backgroundColor:[UIColor redColor]];
        cell.rightButtons = @[btnDelete];
        cell.rightSwipeSettings.transition = MGSwipeTransitionBorder;
        DDWeak(self)
        btnDelete.callback = ^BOOL(MGSwipeTableCell * sender)
        {
            DDStrong(self)
            self.currentIndexPath = indexPath;
            [self goToDeleteData];
            return NO;
        };
    }
    else
    {
        cell.lbl.font = [UIFont systemFontOfSize:14];
        if(countOfFirst > 1 && indexPath.row == 0)
        {
            cell.imv.image = [UIImage imageNamed:@"news_notice"];
            cell.lbl.text = kString(@"好友申请");
            [cell.viewHot setHidden:NO];
        }
        else
        {
            cell.imv.image = [UIImage imageNamed:@"rank_icon"];
            cell.lbl.text = kString(@"今日好友排名");
        }
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return section ? 20:0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section)
        return Bigger(RealHeight(100), 60);//  60;
    else
        return Bigger(RealHeight(90), 50);//  50;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 0 && ((indexPath.row == 0 && countOfFirst == 1) || (indexPath.row == 1 && countOfFirst == 2)))
    {
        [self performSegueWithIdentifier:@"friend_to_rank" sender:nil];
    }
    else if(indexPath.section == 0 && indexPath.row == 0 && countOfFirst == 2)
    {
        [self performSegueWithIdentifier:@"friend_to_request" sender:nil];
    }
    else if(indexPath.section)
    {
        Friend *model = self.arrData[indexPath.row];
        [self performSegueWithIdentifier:@"friend_to_details" sender:model];
    }
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section && self.arrData.count) {
        return kString(@"我的好友");
    }
    else
        return @"";
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section)
        return YES;
    else
        return NO;
}

//- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
//    
//    if (editingStyle == UITableViewCellEditingStyleDelete)
//    {
//        currentIndexPath = indexPath;
//        //[self deleteTableData];
//        [self goToDeleteData];
//    }
//}


// 去执行操作
-(void)goToDeleteData
{
    TAlertView *alert = [[TAlertView alloc] initWithTitle:@"提示" message:@"确定要解除好友关系吗?"];
    [alert showWithActionSure:^
     {
         Friend *fr = self.arrData[self.currentIndexPath.row];
         RequestCheckAfter(
               [net updateFriendship:self.userInfo.access
                           friend_id:fr.user_id
                         ship_status:@"3"];,
               [self dataSuccessBack_updateFriendship:dic];);
         [self deleteTableData];
     } cancel:^{}];
}

// 确认删除这一行
-(void)deleteTableData
{
    Friend *fr = self.arrData[self.currentIndexPath.row];                    // 这个本地的对象
    [self.arrData removeObject:fr];
    [Friend MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.userInfo.access, fr.user_id] inContext:DBefaultContext];
    // 这些请求是以前的记录不用删除
//    [FriendRequest MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and friend_id == %@", self.userInfo.access, fr.user_id]];
    DBSave;
    
    [_tabView deleteRowsAtIndexPaths:[NSArray arrayWithObject:self.currentIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    [_tabView endUpdates];
}

////修改编辑按钮文字
//- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return kString(@"删除");
//}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"friend_to_details"])
    {
        vcFriendDetails *vc = (vcFriendDetails *)segue.destinationViewController;
        vc.model = sender;
    }
}

-(void)dataSuccessBack_applyFriend:(NSDictionary *)dic
{
    NSInteger statue = [dic[@"status"] integerValue];
    switch (statue) {
        case 0:
            LMBShow(@"申请已发送");
            break;
        case 5:
            LMBShow(@"好友不存在");
            break;
        case 8:
            LMBShow(@"不能对用户自身操作");
            break;
        case 9:
            LMBShow(@"你们已是好友关系");
            break;
    }
    
}

-(void)dataSuccessBack_updateFriendship:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        NSLog(@"删除成功");
    }
}

-(void)dataSuccessBack_getFriendsInfo:(NSDictionary *)dic
{
    if(CheckIsOK)
    {
        NSArray *arrData = dic[@"friends_info"];
        if (!arrData) return;
        // 好友数据中，自己的不删
        NSArray *arrFriendOld = [Friend findAllWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id != %@", self.userInfo.access, self.userInfo.user_id] inContext:DBefaultContext];
        for (Friend *f in arrFriendOld) {
            f.tag = @NO;
        }
        
        DDWeak(self)
        [Friend objectsByArray:dic[@"friends_info"]
                       context:DBefaultContext
                  perfectBlock:^(id model) {
                      DDStrong(self)
                      Friend *fr = model;
                      fr.access = self.userInfo.access;
                      fr.tag    = @YES;
                  }];
        
        self.userInfo.sport_like_number = @([((NSDictionary *)dic[@"user_like_num"])[@"sport_like_num"] intValue]);
        self.userInfo.situps_like_number = @([((NSDictionary *)dic[@"user_like_num"])[@"situps_like_num"] intValue]);
        
        
        
        [Friend MR_deleteAllMatchingPredicate:[NSPredicate predicateWithFormat:@"access == %@ and tag == %@", self.userInfo.access, @NO] inContext:DBefaultContext];
        
        DBSave;
        [self refreshData];
    }
}

@end
