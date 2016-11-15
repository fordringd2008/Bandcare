//
//  vcORCode.m
//  Coasters
//
//  Created by 丁付德 on 15/8/12.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcORCode.h"
#import "QRCodeGenerator.h"
#import "vcShare.h"
#import "vcBase+Share.h"



@interface vcORCode ()
{
    BOOL isShowed;
    UIView *viewContent;
    CGRect viewShareHiddenFrame;
    CGRect viewShareShowFrame;
}

@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;


@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblFirst;
@property (weak, nonatomic) IBOutlet UILabel *lblSecond;
@property (weak, nonatomic) IBOutlet UIView *viewShare;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareBottom;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvLogoLeft;

@end

@implementation vcORCode

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"我的二维码"];
    [self initRightButtonisInHead:@"share" text:nil];
    
    self.viewMainHeight.constant =  ScreenHeight;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initView];
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(15, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    btn.titleLabel.textColor = DWhite;
    [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
    [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
    
    [btn setTitle:kString(text) forState: UIControlStateNormal];
    [btn setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
    [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
    [btn setTitleColor:DWhite forState:UIControlStateNormal];
    [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [self.viewHead addSubview:btn];
    
    self.viewHead.backgroundColor = DidConnectColor;
    self.viewHeadHeight.constant = NavBarHeight;
}



-(void)initView
{
    [_imvLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url] placeholderImage: DefaultLogoImage];
    _imvLogo.layer.borderColor = DLightGray.CGColor;
    _imvLogo.layer.borderWidth = 1;
    _imvLogo.layer.cornerRadius = 40;
    [_imvLogo.layer setMasksToBounds:YES];
    
    _lblFirst.text = self.userInfo.user_nick_name;
    _lblSecond.text = [self.userInfo.loginType intValue] > 1 ? @"" : self.userInfo.account;
    
    _imvLogoLeft.constant = 20;
    int widthTag = RealWidth(440);
    UIImageView *imv = [[UIImageView alloc] initWithFrame:CGRectMake((ScreenWidth - widthTag) / 2, 120, widthTag, widthTag)];
    
    if (self.userInfo.orData)
        imv.image = [UIImage imageWithData:self.userInfo.orData];
    else
    {
        // www.sz-hema.com/download###{"email":"123@qq.com"}
        // http://www.sz-hema.com/download###{"email":"123@qq.com","phone":"13512349999","third_party_id":"123456789"}
        NSString *accountType = @"third_party_id";
        switch ([self.userInfo.loginType intValue]) {
            case 0:
                accountType = @"email";
                break;
            case 1:
                accountType = @"phone";
                break;
                
            default:
                break;
        }
        NSString *urlString = [NSString stringWithFormat:@"%@###{\"%@\":\"%@\"}", orReaderPrefix, accountType, self.userInfo.account];
        //NSString *urlString = @"https://itunes.apple.com/us/app/id1018688518";
        NSLog(@"二维码地址：%@", urlString);
        imv.image = [QRCodeGenerator qrImageForString:urlString imageSize:imv.bounds.size.width];
        self.userInfo = myUserInfo;
        self.userInfo.orData = UIImagePNGRepresentation(imv.image);
        DBSave;
    }
    [_viewMain addSubview:imv];
    
    
    
    UILabel *lblOther = [[UILabel alloc] initWithFrame:CGRectMake(0, 140 + widthTag, ScreenWidth, 42)];
    lblOther.font = [UIFont systemFontOfSize:14];
    lblOther.numberOfLines = 0;
    lblOther.textAlignment = NSTextAlignmentCenter;
    lblOther.textColor = DLightGray;
    lblOther.text = kString(@"扫一扫上面的二维码,加我好友");
    [_viewMain insertSubview:lblOther atIndex:0];
    
    [self initShareButton];
    
}

-(void)rightButtonClick
{
    [self showShareView:YES];
}

-(void)initShareButton
{
    NSInteger isAddCount = 0;                       // 已添加的个数
    BOOL isHaveWeiXin = [self isHave:1];
    BOOL isHaveXinLang = [self isHave:2];
    BOOL isHaveQQ = [self isHave:3];
    BOOL isHaveFacebook = [self isHave:4];
    
    if (isDevelemont) {
        if (!isHaveWeiXin && !isHaveXinLang && !isHaveQQ && !isHaveFacebook) {
            isHaveWeiXin = isHaveXinLang = isHaveQQ = isHaveFacebook = YES;
        }
    }
    
    int numberInViewContent = 0;
    numberInViewContent += (isHaveWeiXin ? 2:0);
    numberInViewContent += (isHaveXinLang ? 1:0);
    numberInViewContent += (isHaveQQ ? 2:0);
    numberInViewContent += (isHaveFacebook ? 2:0);
    
    
    CGFloat oneWidth = (ScreenWidth - 20) / 7.0;
    _viewShareHeight.constant = oneWidth * 1.1;
    
    viewShareHiddenFrame =  CGRectMake(0, ScreenHeight+20, ScreenWidth, _viewShareHeight.constant);
    viewShareShowFrame =  CGRectMake(0, ScreenHeight - _viewShareHeight.constant-NavBarHeight, ScreenWidth, _viewShareHeight.constant);
    _viewShareBottom.constant = 0-_viewShareHeight.constant*1.5;
    
    viewContent = [[UIView alloc] initWithFrame:CGRectMake((ScreenWidth - numberInViewContent * oneWidth) / 2, (_viewShareHeight.constant - oneWidth) / 2, numberInViewContent * oneWidth, oneWidth)];
    [_viewShare addSubview:viewContent];
    
    if (isHaveWeiXin)
    {
        [self addButtonAddImage:isAddCount++ type:1];
        [self addButtonAddImage:isAddCount++ type:2];
    }
    if (isHaveXinLang)
        [self addButtonAddImage:isAddCount++ type:3];
    if (isHaveQQ)
    {
        [self addButtonAddImage:isAddCount++ type:5];
        [self addButtonAddImage:isAddCount++ type:4];
    }
    if (isHaveFacebook)
    {
        [self addButtonAddImage:isAddCount++ type:6];
        [self addButtonAddImage:isAddCount++ type:7];
    }
}


// 添加  index： 前面有几个   type：1： 微信好友  2： 微信朋友圈 3：新浪微博 4：QQ空间 5：qq好友  6：facebook 7: twitter
-(void)addButtonAddImage:(NSInteger)index type:(NSInteger)type
{
    CGFloat oneWidth = (ScreenWidth - 20) / 7.0;
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(index * oneWidth, 0, oneWidth, oneWidth)];
    btn.tag = type;
    btn.backgroundColor = DClear;
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImage *imgNormal = [UIImage new];
    UIImage *imgHighlight = [UIImage new];
    
    switch (type) {
        case 1:
            imgNormal = [UIImage imageNamed:@"share_weixin"];
            imgHighlight = [UIImage imageNamed:@"share_weixin_highlight"];
            break;
        case 2:
            imgNormal = [UIImage imageNamed:@"share_pengyouquan"];
            imgHighlight = [UIImage imageNamed:@"share_pengyouquan_highlight"];
            break;
        case 3:
            imgNormal = [UIImage imageNamed:@"share_weibot"];
            imgHighlight = [UIImage imageNamed:@"share_weibot_highlight"];
            break;
        case 4:
            imgNormal = [UIImage imageNamed:@"share_qq_zone"];
            imgHighlight = [UIImage imageNamed:@"share_qq_zone_highlight"];
            break;
        case 5:
            imgNormal = [UIImage imageNamed:@"share_qq"];
            imgHighlight = [UIImage imageNamed:@"share_qq_highlight"];
            break;
        case 6:
            imgNormal= [UIImage imageNamed:@"share_facebook"];
            imgHighlight = [UIImage imageNamed:@"share_facebook_highlight"];
            break;
        case 7:
            imgNormal = [UIImage imageNamed:@"share_twitter"];
            imgHighlight = [UIImage imageNamed:@"share_twitter_highlight"];
            break;
            
        default:
            break;
    }
    
    // top, left, bottom, right
    [btn setImageEdgeInsets: UIEdgeInsetsMake(oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2, oneWidth * 0.2)];
    
    [btn setImage:imgNormal forState:UIControlStateNormal];
    [btn setImage:imgHighlight forState:UIControlStateHighlighted];
    
    [viewContent addSubview:btn];
}

- (void)btnClick:(UIButton *)sender
{
    [self showShareView:YES];
    [self share:sender.tag url:nil title:nil];
}

-(void)showShareView:(BOOL)isShow
{
    if(isShowed) isShow = NO;
    if(isShow)
    {
        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewShare setFrame:viewShareShowFrame];
         } completion:^(BOOL finished) {
             isShowed = YES;
         }];
    }
    else
    {
        [UIView transitionWithView:self.view duration:0.2 options:UIViewAnimationOptionBeginFromCurrentState animations:^
         {
             [self.viewShare setFrame:viewShareHiddenFrame];
         } completion:^(BOOL finished) {
             isShowed = NO;
         }];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
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
