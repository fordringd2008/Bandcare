//
//  vcNewPerfectInfo.m
//  Coasters
//
//  Created by 丁付德 on 16/1/10.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcNewPerfectInfo.h"
#import "UIButton+WebCache.h"
#import "UIViewController+GetAccess.h"
#import "HJCActionSheet.h"

@interface vcNewPerfectInfo ()<UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, HJCActionSheetDelegate>
{
    int                         selectHeight;
    int                         selectWeight;
    int                         selectTarget;
    int                         selectSitUpsTarget;
    NSString *                  nickNameFromThird;
    NSString *                  logoFromThird;
    BOOL                        isGirl;
    int                         braceletSystem;  // 几代的手环  1 或者 2
}

@property (weak, nonatomic) IBOutlet UIScrollView *scrContent;
@property (weak, nonatomic) IBOutlet UILabel *lblBtnPrompt;


@property (strong, nonatomic) UITextField *     txfNickName;
@property (strong, nonatomic) UIButton *        btnImage;
@property (strong, nonatomic) UIButton *        btnBoy;
@property (strong, nonatomic) UIButton *        btnGirl;
@property (strong, nonatomic) UILabel *         lbl3Prompt;
@property (strong, nonatomic) UILabel *         lbl4Prompt;
@property (strong, nonatomic) UIPickerView*     pickHeight;
@property (strong, nonatomic) UIPickerView*     pickWeight;
@property (strong, nonatomic) UIPickerView*     pickTarget;
@property (strong, nonatomic) UIPickerView*     pickSitUpsTarget;
@property (nonatomic, strong) NSMutableArray    *arrHeight;   //50 - 250
@property (nonatomic, strong) NSMutableArray    *arrWeight;   //20 - 150
@property (nonatomic, strong) NSArray           *arrSex;      //
@property (nonatomic, strong) NSMutableArray    *arrTarget;   //500 - 5000 100递增
@property (nonatomic, strong) NSMutableArray    *arrSitUpsTarget;   //20 - 500 10递增


@property (weak, nonatomic) IBOutlet UIButton *btnSubmit;

- (IBAction)btnClick:(UIButton *)sender;

@property (assign, nonatomic) NSInteger         gender;         // 1:男 2 ： 女 (0 男   1 女)


@end


@implementation vcNewPerfectInfo

-(void)viewDidLoad
{
    [super viewDidLoad];

    [self initLeftButton:nil text: (self.isAcceptBack ? @" " : nil)];
    
    
    self.Bluetooth.delegate = nil;
    
    [self initData];
    [self initView];
    
    [self.txfNickName becomeFirstResponder];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    BOOL isgirl = NO;
    if (self.arrDataFromThird && self.arrDataFromThird.count == 4) {
        if ([self.arrDataFromThird[3] boolValue]) {
            isgirl = YES;
        }
    }
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:!isgirl ? DidConnectColor : GirlColor] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:!isgirl ? DidConnectColor : GirlColor];
    self.navigationController.navigationBar.translucent = NO;
    
    DDWeak(self)
    self.upLoad_Next = ^(NSString *url)
    {
        DDStrong(self)                              // 上传完后的回调
        if (self)
        {
            NSLog(@"回调回来 ----- > url:%@", url);
            if(!url.length)
            {
                NSLog(@"图片上传失败");
                LMBShow(NONetTip);
            }else
            {
                self.userInfo.user_pic_url = url;
                DBSave;
                DDWeak(self)
                NextWaitInMain(
                       DDStrong(self)
                       [self saveToServer];);
            }
        }
    };
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

-(void)viewDidDisappear:(BOOL)animated
{
    self.upLoad_Next = nil;
    [super viewDidDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"vcNewPerfectInfo 销毁了");
}

-(void)back
{
    if (self.btnSubmit.tag == 101 && self.isAcceptBack)
    {
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
        self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:DidConnectColor];
        [super back];
    }
    else if (self.btnSubmit.tag == 102)
    {
        [self.scrContent setContentOffset:CGPointMake(0, 0) animated:YES];
        self.btnSubmit.tag = 101;
        [self initLeftButton:nil text: (self.isAcceptBack ? @" " : nil)];
    }else if(self.btnSubmit.tag == 110) {
        [self.scrContent setContentOffset:CGPointMake(ScreenWidth, 0) animated:YES];
        self.btnSubmit.tag = 102;
        [self.btnSubmit setTitle:kString(@"下一步") forState:UIControlStateNormal];
    }
    else if(self.btnSubmit.tag == 103) {                // 这里可能是有
        [self.scrContent setContentOffset:CGPointMake(ScreenWidth * braceletSystem, 0) animated:YES];
        self.btnSubmit.tag = braceletSystem == 1 ? 102 : 110;
        [self.btnSubmit setTitle:kString(@"下一步") forState:UIControlStateNormal];
    }
}

-(void)initData
{
    _arrHeight = [NSMutableArray new];
    _arrWeight = [NSMutableArray new];
    _arrTarget = [NSMutableArray new];
    _arrSitUpsTarget = [NSMutableArray new];
    
    int begigWeight = 20;
    int endWeight = 150;
    for (int i = begigWeight; i <= endWeight; i++)
        [_arrWeight addObject:[NSString stringWithFormat:@"%d", i]];
    for (int i = 50; i <= 250; i++)
        [_arrHeight addObject:[NSString stringWithFormat:@"%d", i]];
    for (int i = 5000; i <= 20000; i+=100)
        [_arrTarget addObject:[NSString stringWithFormat:@"%d", i]];
    for (int i = 20; i <= 500; i+=10)
        [_arrSitUpsTarget addObject:[NSString stringWithFormat:@"%d", i]];
    
    
    if(self.arrDataFromThird)
    {
        if (self.arrDataFromThird.count > 1) {
            nickNameFromThird = self.arrDataFromThird[1];
            nickNameFromThird = nickNameFromThird.length > 20 ? [nickNameFromThird substringToIndex:20] : nickNameFromThird;
            if (self.arrDataFromThird.count > 2) {
                logoFromThird = self.arrDataFromThird[2];
                if (self.arrDataFromThird.count > 3) {
                    isGirl = [self.arrDataFromThird[3] boolValue];
                }
                DDWeak(self)
                NextWaitInGlobal(
                     DDStrong(self)
                     self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.arrDataFromThird[2]]]];);
            }
        }
    }
//    ([DFD shareDFD].isForA5 ? 2:1)
    
    braceletSystem = ([DFD shareDFD].isForA5 ? 2:1);
    
}

-(void)initView
{
    self.view.backgroundColor = DidConnectColor;
    self.scrContent.bounces = NO;
    self.scrContent.pagingEnabled = YES;
    self.scrContent.showsHorizontalScrollIndicator = NO;
    self.scrContent.scrollEnabled = NO;
    self.scrContent.contentSize =  CGSizeMake(ScreenWidth * (2 + braceletSystem), 210);
    UIButton *btnBig = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth * (2 + braceletSystem), self.scrContent.bounds.size.height)];
    btnBig.tag = 99;
    [btnBig addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrContent addSubview:btnBig];
    
#pragma mark 左侧
    UIView * view1img = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - RealHeight(253)) / 2.0, 0, RealHeight(253), RealHeight(253))];
    [self.scrContent addSubview:view1img];
    [view1img setUserInteractionEnabled:YES];
//    Border(view1img, DRed);
    
    CGFloat btnImageWidth = view1img.bounds.size.height * 0.8;
    self.btnImage = [[UIButton alloc] initWithFrame:CGRectMake((view1img.bounds.size.width - btnImageWidth) / 2.0, (view1img.bounds.size.height - btnImageWidth ) / 2.0, btnImageWidth, btnImageWidth)];
    self.btnImage.layer.cornerRadius = self.btnImage.bounds.size.height / 2.0;
    self.btnImage.layer.masksToBounds = YES;
    self.btnImage.tag = 1;
    [self.btnImage addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.arrDataFromThird && self.arrDataFromThird.count > 2) {
        [self.btnImage sd_setBackgroundImageWithURL:[NSURL URLWithString:self.arrDataFromThird[2]] forState:UIControlStateNormal placeholderImage:[UIImage imageNamed:@"person_default"]];
    }else
    {
        [self.btnImage setBackgroundImage:[UIImage imageNamed:@"person_default"] forState:UIControlStateNormal];
    }
    
    [view1img addSubview:self.btnImage];
    Border(self.btnImage, DWhite3);
    
    
    self.txfNickName = [[UITextField alloc] initWithFrame:CGRectMake((ScreenWidth - 150) / 2.0, RealHeight(253), 150, RealHeight(74))];
    self.txfNickName.textAlignment = NSTextAlignmentCenter;
    self.txfNickName.textColor = DWhite;
    self.txfNickName.delegate = self;
    self.txfNickName.font = [UIFont systemFontOfSize:14];
    self.txfNickName.text = nickNameFromThird ? nickNameFromThird : @"";
    
    [self.txfNickName setValue:[UIFont systemFontOfSize:14] forKeyPath:@"_placeholderLabel.font"];
    [self.txfNickName setValue:DWhite forKeyPath:@"_placeholderLabel.textColor"];
    [self.scrContent addSubview:self.txfNickName];
    self.txfNickName.placeholder = kString(@"昵称");
//    Border(self.txfNickName, DBlack);
    
    
    UIView *lineNickName = [[UIView alloc] initWithFrame:CGRectMake(self.txfNickName.frame.origin.x, self.txfNickName.frame.origin.y + self.txfNickName.frame.size.height - 5, 150, 1)];
    lineNickName.backgroundColor = DWhite3;
    [self.scrContent addSubview:lineNickName];
    
    UIView *view1Boy = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - RealHeight(264))/ 2.0, RealHeight((253 + 74)), RealHeight(264), RealHeight(264))];
    [self.scrContent addSubview:view1Boy];
//    Border(view1Boy, DRed);
    
    CGFloat boyWidth = view1Boy.bounds.size.height * 0.8;
    self.btnBoy = [[UIButton alloc] initWithFrame:CGRectMake((view1Boy.bounds.size.width - boyWidth) / 2.0, (view1img.bounds.size.height - boyWidth ) / 2.0, boyWidth, boyWidth)];
    self.btnBoy.layer.cornerRadius = self.btnBoy.bounds.size.height / 2.0;
    self.btnBoy.layer.masksToBounds = YES;
    self.btnBoy.tag = 2;
    [self.btnBoy addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view1Boy addSubview:self.btnBoy];
    Border(self.btnBoy, DBlue);
    
    UIView *view1Girl = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - RealHeight(264))/ 2.0, RealHeight((253 + 74 + 264)), RealHeight(264), RealHeight(264))];
    [self.scrContent addSubview:view1Girl];
//    Border(view1Girl, DBlack);
    
    self.btnGirl = [[UIButton alloc] initWithFrame:CGRectMake((view1Girl.bounds.size.width - boyWidth) / 2.0, (view1Girl.bounds.size.height - boyWidth ) / 2.0, boyWidth, boyWidth)];
    self.btnGirl.layer.cornerRadius = self.btnGirl.bounds.size.height / 2.0;
    self.btnGirl.layer.masksToBounds = YES;
    self.btnGirl.tag = 3;
    [self.btnGirl addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [view1Girl addSubview:self.btnGirl];
    Border(self.btnGirl, DBlue);
    
    self.btnBoy.layer.borderColor = DWhite3.CGColor;
    self.btnGirl.layer.borderColor = DWhite3.CGColor;
    
    [self change:!isGirl];
    
#pragma mark 中侧
    
    UILabel *lbl2Height = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 0, 200, 21)];
    lbl2Height.text = kString(@"身高(cm)");
    lbl2Height.textColor = DWhite;
    lbl2Height.font = [UIFont systemFontOfSize:14];
    [self.scrContent addSubview:lbl2Height];

    CGFloat pickWidth = ScreenWidth * 0.3;
    self.pickHeight = [[UIPickerView alloc] initWithFrame:CGRectMake(ScreenWidth +(ScreenWidth - pickWidth) / 2.0, 20, pickWidth, RealHeight(400))];
    self.pickHeight.delegate = self;
    self.pickHeight.dataSource = self;
    [self.scrContent addSubview:self.pickHeight];
    
    
    UILabel *lbl2Weight = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth + 20, 30 + self.pickHeight.bounds.size.height, 200, 21)];
    lbl2Weight.text = kString(@"体重(kg)");
    lbl2Weight.textColor = DWhite;
    lbl2Weight.font = [UIFont systemFontOfSize:14];
    [self.scrContent addSubview:lbl2Weight];
    
    self.pickWeight = [[UIPickerView alloc] initWithFrame:CGRectMake(ScreenWidth + (ScreenWidth - pickWidth) / 2.0, 40 + self.pickHeight.bounds.size.height, pickWidth, RealHeight(400))];
    self.pickWeight.delegate = self;
    self.pickWeight.dataSource = self;
    [self.scrContent addSubview:self.pickWeight];
    
#pragma mark 右侧
    
    UILabel *lbl3Target = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth * 2 + 20, 0, 300, 21)];
    lbl3Target.text = kString(@"每日运动目标步数");
    lbl3Target.textColor = DWhite;
    lbl3Target.font = [UIFont systemFontOfSize:14];
    [self.scrContent addSubview:lbl3Target];
    
    self.pickTarget = [[UIPickerView alloc] initWithFrame:CGRectMake(ScreenWidth * 2 + (ScreenWidth - pickWidth) / 2.0, 40, pickWidth, RealHeight(400))];
    self.pickTarget.delegate = self;
    self.pickTarget.dataSource = self;
    [self.scrContent addSubview:self.pickTarget];
    
    
    self.lbl3Prompt = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth * 2 + 20, RealHeight(400) + 50, ScreenWidth - 40, 42)];
    self.lbl3Prompt.numberOfLines = 0;
    self.lbl3Prompt.textAlignment = NSTextAlignmentCenter;
    self.lbl3Prompt.textColor = DWhite;
    self.lbl3Prompt.font = [UIFont systemFontOfSize:14];
    self.lbl3Prompt.text = kString(@"这是一句没有完成的话");
    [self.scrContent addSubview:self.lbl3Prompt];
    
    
    self.btnSubmit.layer.borderColor = DWhite3.CGColor;
    self.btnSubmit.tag = 101;
    self.btnSubmit.layer.borderWidth = 1;
    self.btnSubmit.layer.cornerRadius = 5;
    self.btnSubmit.layer.masksToBounds = YES;
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DWhite3] forState:UIControlStateNormal];
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateHighlighted];
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DWhiteA(0.1)] forState:UIControlStateDisabled];
    [self.btnSubmit setTitleColor:DWhite forState:UIControlStateHighlighted];
    [self.btnSubmit setTitleColor:DWhite forState:UIControlStateNormal];
    
    [self.btnSubmit setTitle:kString(@"下一步") forState:UIControlStateNormal];
    self.lblBtnPrompt.hidden = self.btnSubmit.enabled = (BOOL)nickNameFromThird;
    
    [self.pickHeight selectRow:115 inComponent:0 animated:NO];
    [self.pickWeight selectRow:35 inComponent:0 animated:NO];
    selectHeight = [self.arrHeight[115] intValue];
    selectWeight = [self.arrWeight[35] intValue];
    self.lblBtnPrompt.text = kString(@"请填写昵称");
    
#pragma mark 再右侧
    
    if(braceletSystem == 2)
    {
        UILabel *lbl4Target = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth * 3 + 20, 0, 300, 21)];
        lbl4Target.text = kString(@"每日仰卧起坐目标数");
        lbl4Target.textColor = DWhite;
        lbl4Target.font = [UIFont systemFontOfSize:14];
        [self.scrContent addSubview:lbl4Target];
        
        self.pickSitUpsTarget = [[UIPickerView alloc] initWithFrame:CGRectMake(ScreenWidth * 3 + (ScreenWidth - pickWidth) / 2.0, 40, pickWidth, RealHeight(400))];
        self.pickSitUpsTarget.delegate = self;
        self.pickSitUpsTarget.dataSource = self;
        [self.scrContent addSubview:self.pickSitUpsTarget];
        
        
        self.lbl4Prompt = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth * 3 + 20, RealHeight(400) + 50, ScreenWidth - 40, 42)];
        self.lbl4Prompt.numberOfLines = 0;
        self.lbl4Prompt.textAlignment = NSTextAlignmentCenter;
        self.lbl4Prompt.textColor = DWhite;
        self.lbl4Prompt.font = [UIFont systemFontOfSize:14];
        self.lbl4Prompt.text = kString(@"这是一句没有完成的话");
        [self.scrContent addSubview:self.lbl4Prompt];
    }
    
    self.btnSubmit.layer.borderColor = DWhite3.CGColor;
    self.btnSubmit.tag                 = 101;
    self.btnSubmit.layer.borderWidth   = 1;
    self.btnSubmit.layer.cornerRadius  = 5;
    self.btnSubmit.layer.masksToBounds = YES;
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DWhite3] forState:UIControlStateNormal];
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DWhiteA(0.5)] forState:UIControlStateHighlighted];
    [self.btnSubmit setBackgroundImage:[UIImage imageFromColor:DWhiteA(0.1)] forState:UIControlStateDisabled];
    [self.btnSubmit setTitle:kString(@"下一步") forState:UIControlStateNormal];
    self.lblBtnPrompt.hidden = self.btnSubmit.enabled = (BOOL)nickNameFromThird;
    
    [self.pickHeight selectRow:115 inComponent:0 animated:NO];
    [self.pickWeight selectRow:35 inComponent:0 animated:NO];
    [self.pickTarget selectRow:50 inComponent:0 animated:NO];
    isGirl = NO;
    selectHeight = [self.arrHeight[115] intValue];
    selectWeight = [self.arrWeight[35] intValue];
    selectTarget = [self.arrTarget[50] intValue];
    selectSitUpsTarget = [self.arrSitUpsTarget[0] intValue];
    self.lblBtnPrompt.text = kString(@"请填写昵称");
    
    [self refreshPrompt3];
    [self refreshPrompt4];
}

-(void)refreshSubmit:(BOOL)isEnable
{
    self.btnSubmit.enabled = isEnable;
    self.btnSubmit.backgroundColor = isEnable ? DidConnectColor : DLightGray;
}


//#pragma mark UITextFieldDelegate
//- (void)textFieldDidBeginEditing:(UITextField *)textField
//{
//    self.line.backgroundColor = DWhite;
//}

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

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

// 1 点击头像  2， 男    3， 女     101， 下一步切换到 身高体重   102 下一步切换到目标  103 完成注册     110: 下一步到仰卧起坐目标
- (IBAction)btnClick:(UIButton *)sender
{
    NSLog(@"tag -> %d", (int)sender.tag);
    [self.view endEditing:YES];
    switch (sender.tag) {
        case 1:
        {
            HJCActionSheet *sheet = [[HJCActionSheet alloc] initWithDelegate:self CancelTitle:kString(@"取消") OtherTitles:kString(@"拍照"), kString(@"从手机相册中选择"), nil];
            [sheet show];
        }
            break;
        case 2:
            [self change:YES];
            break;
        case 3:
            [self change:NO];
            break;
        case 101:
        {
            [self.scrContent setContentOffset:CGPointMake(ScreenWidth, 0) animated:YES];
            self.btnSubmit.tag = 102;
            [self initLeftButton:nil text:@" "];
        }
            break;
        case 102:
        {
            [self.scrContent setContentOffset:CGPointMake(ScreenWidth * 2, 0) animated:YES];
            self.btnSubmit.tag = braceletSystem == 1 ? 103:110;
            [self.btnSubmit setTitle:(braceletSystem == 1 ? kString(@"完成"):kString(@"下一步")) forState:UIControlStateNormal];
            
            [self refreshPrompt3];
        }
            break;
        case 110:
        {
            [self.scrContent setContentOffset:CGPointMake(ScreenWidth * 3, 0) animated:YES];
            self.btnSubmit.tag = 103;
            [self initLeftButton:nil text:@" "];
            [self.btnSubmit setTitle:kString(@"完成") forState:UIControlStateNormal];
        }
            break;
        case 103:
        {
            if ([NSString isHaveEmoji:self.txfNickName.text]) {
                LMBShow(@"包含了不能识别的字符");
                return;
            }
            
            MBShowAll;
            HDDAF;
            //  这里要检测， 如果 是第三方登陆，并且有图片，很可能图片没有下载完毕 就点击了保存
            if (logoFromThird)
            {
                [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(chechImgData:) userInfo:@YES repeats:YES];
            }else
            {
                [self chechImgData:nil];
            }
        }
            break;
        default:
            break;
    }
}

-(void)refreshPrompt3
{
    int disTag = selectTarget * (isGirl ? 0.6 : 0.7);
    int heatTag = disTag * selectWeight / 1000;
    
    self.lbl3Prompt.text = [NSString stringWithFormat:@"%@ %d %@, %@ %@", kString(@"相当于"), heatTag, kString(@"千卡"), kString(@"约"), [DFD toStringFromDist:disTag isMetric:YES]];
    ;
}

-(void)refreshPrompt4
{
    self.lbl4Prompt.text = [NSString stringWithFormat:@"%@ %.0f %@", kString(@"相当于消耗热量"), selectSitUpsTarget * 0.24, kString(@"千卡")];
}

- (void)chechImgData:(NSTimer *)timer
{
    NSLog(@"-------- > 进来了");
    if (!timer)
    {
        MBShowAll;
        if (self.image)
        {                              // 如果用户更改了图片
            [self getTokenAndUpload:^{}];
        }
        else
        {
            [self saveToServer];
        }
    }else
    {
        if (self.image) {
            [timer DF_stop];
            timer = nil;
            [self getTokenAndUpload:^{}];
        }
    }
}

-(void)change:(BOOL)isBoy
{
    LSNavigationController *lnav = (LSNavigationController *)self.navigationController;
    if (isBoy)
    {
        [lnav.navigationBar setBackgroundImage:[UIImage imageFromColor:DidConnectColor] forBarMetrics:UIBarMetricsDefault];
        lnav.navigationBar.shadowImage = [UIImage imageFromColor:DidConnectColor];
    }
    else
    {
        [lnav.navigationBar setBackgroundImage:[UIImage imageFromColor:GirlColor] forBarMetrics:UIBarMetricsDefault];
        lnav.navigationBar.shadowImage = [UIImage imageFromColor:GirlColor];
    }
    [lnav refreshBackgroundImage];
    
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:isBoy ? DidConnectColor : GirlColor];
    
    if(isBoy)
    {
        self.btnBoy.layer.borderColor = DWhite.CGColor;
        self.btnGirl.layer.borderColor = DWhiteA(0.3).CGColor;
        self.view.backgroundColor = DidConnectColor;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:DidConnectColor] forBarMetrics:UIBarMetricsDefault];
        [self.btnBoy setBackgroundImage:[UIImage imageNamed:@"male_enable"] forState:UIControlStateNormal];
        [self.btnGirl setBackgroundImage:[UIImage imageNamed:@"female_disable"] forState:UIControlStateNormal];
        self.gender = 1;
    }
    else
    {
        self.btnGirl.layer.borderColor = DWhite.CGColor;
        self.btnBoy.layer.borderColor = DWhiteA(0.3).CGColor;
        self.view.backgroundColor = GirlColor;
        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageFromColor:GirlColor] forBarMetrics:UIBarMetricsDefault];
        [self.btnBoy setBackgroundImage:[UIImage imageNamed:@"male_disable"] forState:UIControlStateNormal];
        [self.btnGirl setBackgroundImage:[UIImage imageNamed:@"female_enable"] forState:UIControlStateNormal];
        self.gender = 2;
    }
}


#pragma mark UIPickerViewDataSource;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.pickHeight]) {
        return self.arrHeight.count;
    }else if ([pickerView isEqual:self.pickWeight]) {
        return self.arrWeight.count;
    }
    else if ([pickerView isEqual:self.pickTarget]) {
        return self.arrTarget.count;
    }
    else if ([pickerView isEqual:self.pickSitUpsTarget]) {
        return self.arrSitUpsTarget.count;
    }
    
    return  10;
}
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = DWhite;
    if ([pickerView isEqual:self.pickHeight]) {
        label.text = self.arrHeight[row];
    }else if ([pickerView isEqual:self.pickWeight]) {
        label.text = self.arrWeight[row];
    }
    else if ([pickerView isEqual:self.pickTarget]) {
        label.text = self.arrTarget[row];
    }
    else if ([pickerView isEqual:self.pickSitUpsTarget]) {
        label.text = self.arrSitUpsTarget[row];
    }
    
    return label;
}

//选中某一行
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([pickerView isEqual:self.pickHeight]) {
        selectHeight = [self.arrHeight[row] intValue];
    }else if ([pickerView isEqual:self.pickWeight]) {
        selectWeight = [self.arrWeight[row] intValue];
    }
    else if ([pickerView isEqual:self.pickTarget]) {
        selectTarget = [self.arrTarget[row] intValue];
        [self refreshPrompt3];
    }
    else if ([pickerView isEqual:self.pickSitUpsTarget]) {
        selectSitUpsTarget = [self.arrSitUpsTarget[row] intValue];
        [self refreshPrompt4];
    }
}

#pragma mark - UITextViewDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *strAccount = [self.txfNickName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    BOOL isOK = YES;
    if (strAccount.length == 0)
    {
        isOK = NO;
        self.lblBtnPrompt.text = kString(@"请填写昵称");
    }
    if ([strAccount rangeOfString:@"null"].length || [strAccount rangeOfString:@"nil"].length || [strAccount rangeOfString:@"NULL"].length) {
        isOK = NO;
        self.lblBtnPrompt.text = kString(@"昵称中包含了不能识别的字符");
    }
    
    self.btnSubmit.enabled = self.lblBtnPrompt.hidden = isOK;
//    NSLog(@"--- >text:%@,  %hhd %hhd",self.txfNickName.text, self.btnSubmit.enabled, self.lblBtnPrompt.hidden);
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!range.length) {
        NSString *str = [NSString stringWithFormat:@"%@%@", textField.text, string];
        if (str.length >20) {
            return NO;
        }
    }else
    {
        NSString *str = [textField.text substringWithRange:NSMakeRange(0, textField.text.length - range.length)];
        if (str.length >20) {
            return NO;
        }
    }
    return YES;
}

#pragma mark HJCActionSheetDelegate
- (void)actionSheet:(HJCActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [DFD getPictureFormPhotosOrCamera:buttonIndex != 1
                                   vc:self
                    checekBeforeBlock:^{[self getAccessNext:(buttonIndex == 1 ? CameraAccess:PhotosAccess ) block:^{}];}];
}

#pragma mark UINavigationControllerDelegate
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    for (UINavigationItem *item in navigationController.navigationBar.subviews)
    {
        if ([item isKindOfClass:[UIButton class]]&&([item.title isEqualToString:@"取消"]||[item.title isEqualToString:@"Cancel"]))
        {
            UIButton *button = (UIButton *)item;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            break;
        }
    }
}


#pragma mark -- 选中图片后的方法
// 选中图片后的方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image= [info objectForKey:@"UIImagePickerControllerEditedImage"];
    self.image = image;
    [self.btnImage setBackgroundImage:image forState:UIControlStateNormal];
    [self dismissViewControllerAnimated:YES completion:^{}];
}

-(void)saveToServer
{
    NSMutableDictionary *dic = [NSMutableDictionary new];
    if (!self.userInfo.access) self.userInfo.access = GetUserDefault(userInfoAccess);
    [dic setValue:self.userInfo.access forKey:@"access"];
    [dic setValue:self.userInfo.user_pic_url forKey:@"user_pic_url"];
    [dic setValue:self.txfNickName.text forKey:@"user_nick_name"];
    [dic setValue:@(self.gender - 1) forKey:@"user_gender"];
    [dic setValue:@(selectHeight) forKey:@"user_height"];
    [dic setValue:@(selectWeight) forKey:@"user_weight"];
    [dic setValue:[DFD dateToString:self.userInfo.user_birthday stringType:@"YYYYMMdd"]  forKey:@"user_birthday"];
    [dic setValue:@(selectTarget) forKey:@"user_sport_target"];
    [dic setValue:self.userInfo.user_sleep_start_time forKey:@"user_sleep_start_time"];
    [dic setValue:self.userInfo.user_sleep_end_time forKey:@"user_sleep_end_time"];
    [dic setValue:@(selectSitUpsTarget) forKey:@"user_situps_target"];

    RequestCheckAfter(
          self.btnBoy.tag = self.btnBoy.tag;
          [net updateUserInfo:dic];,
          [self dataSuccessBack_updateUserInfo:dic];);
}

-(void)dataSuccessBack_updateUserInfo:(NSDictionary *)dic
{
    MBHide;
    if (CheckIsOK) {
        NSLog(@"保存OK, 跳转");
        self.userInfo.user_nick_name = self.txfNickName.text;
        self.userInfo.user_gender = @((BOOL)(self.gender - 1));
        self.userInfo.user_height = @(selectHeight);
        self.userInfo.user_weight = @(selectWeight);
        self.userInfo.user_sport_target = @(selectTarget);
        self.userInfo.isNeedUpdate = @NO;
        self.userInfo.update_time = @([(NSString *)dic[@"update_time"] longLongValue]);
        DBSave;
        
        DDWeak(self)
        NextWaitInMainAfter([weakself gotoMainStoryBoard];, 0.5);
    }
}


@end
