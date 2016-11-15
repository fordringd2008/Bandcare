//
//  vcLeft.m
//  MasterDemo
//
//  Created by 丁付德 on 15/6/24.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcLeft.h"
#import "tvcLeft.h"
#import "vcIndex.h"

//#define BIGFRAME CGRectMake(0, 110, 220, 280)
//#define SMALLFRAME CGRectMake(-160, self.view.frame.size.height/2, 0, 0)
//#define ANIMATIONTIME 0.35

#define viewBackGroundColo



@interface vcLeft () <UITableViewDelegate, UITableViewDataSource>
{
    CGRect BIGFRAME;
    CGRect SMALLFRAME;
    NSTimeInterval ANIMATIONTIME;
    BOOL isLeft;                        //  是否离开
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrBig;
@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imgLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblemail;
@property (weak, nonatomic) IBOutlet UITableView *tblMain;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tbvHeight;
@property (weak, nonatomic) IBOutlet UIView *viewBig;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewBigBottom;


@property (strong, nonatomic) NSArray *arrTblImgData;           // 默认的图片
@property (strong, nonatomic) NSArray *arrTblImgData2;          // 选中时的图片
@property (strong, nonatomic) NSArray *arrTblNameData;

@end

@implementation vcLeft

-(instancetype)init
{
    self = [super init];
    if (self) {
        [self initLeft];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initTable];
    [self initData];
    [self initView];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    isLeft = NO;
    [self checkUser];
    [self.view setFrame:CGRectMake(-100, 0, ScreenWidth, ScreenHeight)];
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    [self.tblMain reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIView transitionWithView:self.view duration:ANIMATIONTIME options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [self.view setFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    } completion:^(BOOL finished) {}];
    isLeft = YES;
    [self.tblMain setUserInteractionEnabled:YES];
    [super viewWillDisappear:animated];
}

-(void)initLeft
{
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.left = self;
}


-(void)initView
{
    self.scrWidth.constant = 267.0;
    self.viewMainHeight.constant = ScreenHeight;
    
    self.view.backgroundColor = RGB(64,64,64);// [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:1];
    self.viewBigBottom.constant = 0;
    [self.viewBig.layer setMasksToBounds:YES];
    
    
    self.imgHeight.constant = RealHeight(50)+20;
    self.lblHeight.constant = RealHeight(50);
    self.tbvHeight.constant = RealHeight(64);
    self.tblMain.rowHeight = 50;

    BIGFRAME = CGRectMake(0, self.tblMain.frame.origin.y, 260, 375);
    SMALLFRAME = CGRectMake(-160, self.tblMain.frame.origin.y, 0, 0);
    ANIMATIONTIME = 0.35;
    
    self.imgLogo.layer.cornerRadius = 25;
    self.imgLogo.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgLogo.layer.borderWidth = 1;
    [self.imgLogo.layer setMasksToBounds:YES];
    
    self.lblemail.text = myUserInfo.account;
}

-(void)checkUser
{
    if (self.userInfo)
    {
        [self.imgLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url] placeholderImage: DefaultLogoImage];
        self.lblemail.text = self.userInfo.user_nick_name.length ? self.userInfo.user_nick_name : self.userInfo.account;
    }
}


#pragma mark UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrTblImgData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcLeft *cell = [tvcLeft cellWithTableView:tableView];
    cell.imgLogo.image = [UIImage imageNamed:self.arrTblImgData[indexPath.row]];
    cell.lblName.text = self.arrTblNameData[indexPath.row];
    
    switch (indexPath.row) {
        case 0:
        case 2:
        case 3:
        case 5:
            [cell.viewRedDot setHidden:YES];
            break;
        case 1:
        {
            NSInteger count = [[FriendRequest numberOfEntitiesWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and type == %@ and isOver == %@", self.userInfo.access, @(1), @(NO)] inContext:DBefaultContext] integerValue];
            if (count)
                [cell.viewRedDot setHidden:NO];
            else
                [cell.viewRedDot setHidden:YES];
        }
            break;
        case 4:
        {
            [cell.viewRedDot setHidden:YES];
        }
            break;
            
        default:
            break;
    }
    
    cell.lblName.highlightedTextColor =  DidConnectColor;
    cell.imgLogo.highlightedImage = [UIImage imageNamed:self.arrTblImgData2[indexPath.row]];
    cell.imvBig.highlightedImage = [UIImage imageFromColor:RGBA(0, 0, 0, 0.9)];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.Bluetooth.isLink && !self.Bluetooth.isBeginOK) return;   // 防止导航条出错
    if(isLeft) return;
    isLeft = YES;
    
    [self.tblMain setUserInteractionEnabled:NO];                        // 防止点击触发特效
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    AppDelegate *delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [delegate.sideViewController hideSideViewController:YES];
    [self.delegate selected:indexPath.row];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return Bigger(RealHeight(110), 50);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(void)initTable
{
    self.tblMain.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tblMain.backgroundColor = [UIColor clearColor];
}

-(void)initData
{
    self.arrTblImgData = @[@"cupcare-Individual", @"cupcare-Friends", @"cupcare-alarm_clock", @"cupcare-Set_up"];
    self.arrTblImgData2 = @[@"cupcare-Individual02", @"cupcare-Friends02", @"cupcare-alarm_clock02", @"cupcare-Set_up02"];
    self.arrTblNameData = @[kString(@"个人信息"), kString(@"我的好友"), kString(@"闹钟"), kString(@"设置")];
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
