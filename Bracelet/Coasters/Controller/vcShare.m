//
//  vcShare.m
//  Coasters
//
//  Created by 丁付德 on 15/8/23.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcShare.h"
#import "vcBase+Share.h"
#import "UIImage+GradientColor.h"

@interface vcShare ()
{
    UIView *viewChange;             // 替换的视图
    UIView *viewContent;            // 装分享图片的视图，宽度随里面的数量改变
    UITapGestureRecognizer *tap;
    UIVisualEffectView *effectView;
    UIVisualEffectView *effectViewHead;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet UIImageView *imvBg;



@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl1;
@property (weak, nonatomic) IBOutlet UILabel *lbl2;
@property (weak, nonatomic) IBOutlet UILabel *lbl3;
@property (weak, nonatomic) IBOutlet UILabel *lbl4;
@property (weak, nonatomic) IBOutlet UILabel *lbl5;
@property (weak, nonatomic) IBOutlet UILabel *lbl6;
@property (weak, nonatomic) IBOutlet UILabel *lbl7;
@property (weak, nonatomic) IBOutlet UILabel *lbl8;
@property (weak, nonatomic) IBOutlet UILabel *lbl9;
@property (weak, nonatomic) IBOutlet UILabel *lbl10;
@property (weak, nonatomic) IBOutlet UILabel *lbl11;
@property (weak, nonatomic) IBOutlet UILabel *lbl12;
@property (weak, nonatomic) IBOutlet UIView *lineSecondLast;
@property (weak, nonatomic) IBOutlet UIView *lineLast;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl2Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl5Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl8Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lbl11Top;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewShareHeight;



@property (weak, nonatomic) IBOutlet UIView *viewShare;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblTitleTop;




//- (IBAction)btnClick:(UIButton *)sender;

@end

@implementation vcShare

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initLeftButtonisInHead:nil text:@"分享"];
    
    _viewMainHeight.constant = ScreenHeight - NavBarHeight;
    UIImage *bgImg;
    switch (self.shareType) {
        case SportTpe:
            bgImg = [UIImage gradientColorImageFromColors:@[RGB(10, 61, 72), RGB(81, 195, 213)] gradientType:GradientTypeTopToBottom imgSize:self.view.bounds.size];
            break;
        case SleepTpe:
            bgImg = [UIImage gradientColorImageFromColors:@[RGB(30, 28, 67), RGB(111, 130, 225)] gradientType:GradientTypeTopToBottom imgSize:self.view.bounds.size];
            break;
        case SitupTpe:
            bgImg = [UIImage gradientColorImageFromColors:@[RGB(10, 71, 53), RGB(55, 108, 265)] gradientType:GradientTypeTopToBottom imgSize:self.view.bounds.size];
            break;
        default:
            break;
    }
    self.view.backgroundColor = [UIColor colorWithPatternImage:bgImg];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initView];
    });
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imvTap)];
    [self.imvLogo addGestureRecognizer:tap];
    self.imvLogo.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [self.imvLogo removeGestureRecognizer:tap];
    [effectViewHead removeFromSuperview];
    [super viewWillDisappear:animated];
}

-(void)dealloc
{
    NSLog(@"vcShare 销毁了");
}

-(void)imvTap
{
    [self.imvLogo removeGestureRecognizer:tap];
    CGFloat width = 200 / 720.0 * ScreenWidth;
    
    [UIView transitionWithView:self.imvLogo duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
    {
        if (self.imvLogo.tag) {
            self.imvLogo.frame = CGRectMake((ScreenWidth - width ) / 2, 25, width, width);
            self.imvLogo.layer.cornerRadius = self.imvLogo.frame.size.height / 2;
            [_imvLogo.layer setMasksToBounds:YES];
            if (effectView) {
                effectView.alpha = 0;
                effectViewHead.alpha = 0;
            }
        }else{
            self.imvLogo.frame = CGRectMake(10, 10, ScreenWidth - 20, ScreenWidth - 20);
            self.imvLogo.layer.cornerRadius = 20;
            [_imvLogo.layer setMasksToBounds:YES];
            if (effectView) {
                effectView.alpha = 0.7;
                effectViewHead.alpha = 0.7;
            }
        }
            
    } completion:^(BOOL finished) {
        [self.imvLogo addGestureRecognizer:tap];
        self.imvLogo.tag = self.imvLogo.tag ? 0:1;
    }];
}

-(void)initView
{
    _lblTitleTop.constant = IPhone4 ?  RealHeight(35): RealHeight(65);
    _lbl2Top.constant = IPhone4 ?  RealHeight(40):RealHeight(70);
    [_imvLogo sd_setImageWithURL:[NSURL URLWithString:self.userInfo.user_pic_url] placeholderImage: DefaultLogoImage];
    _imvLogo.layer.cornerRadius = ScreenWidth * (20 / 72.0) / 2;
    [_imvLogo.layer setMasksToBounds:YES];
    
    if (IPhone4) {
        _lbl2Top.constant = _lbl5Top.constant = _lbl11Top.constant = 10;
        _lbl8Top.constant = 20;
    }
    
    _lblName.text = self.userInfo.user_nick_name;
    _lblTitle.text = _arrShareData[0];
    _lbl1.text = _arrShareData[1];
    _lbl2.text = _arrShareData[2];
    _lbl3.text = _arrShareData[3];
    _lbl4.text = _arrShareData[4];
    _lbl5.text = _arrShareData[5];
    _lbl6.text = _arrShareData[6];
    _lbl7.text = _arrShareData[7];
    if (_arrShareData.count == 9) {
        _lbl10.text = _arrShareData[8];
        _lbl8.hidden = _lbl9.hidden = _lbl11.hidden = _lbl12.hidden = _lineSecondLast.hidden = _lineLast.hidden = YES;
    }else if (_arrShareData.count == 11) {
        _lbl8.text = _arrShareData[8];
        _lbl10.text = _arrShareData[9];
        _lbl11.text = _arrShareData[10];
        _lbl9.hidden = _lbl12.hidden = _lineLast.hidden = YES;
        
    }else if (_arrShareData.count == 13) {
        _lbl8.text = _arrShareData[8];
        _lbl9.text = _arrShareData[9];
        _lbl10.text = _arrShareData[10];
        _lbl11.text = _arrShareData[11];
        _lbl12.text = _arrShareData[12];
    }
    
    [self initShareButton];
    
    if(SystemVersion >= 8)
    {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectView.alpha = 0;
        [self.viewMain insertSubview:effectView belowSubview:self.imvLogo];
        
        effectViewHead = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
        effectViewHead.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectViewHead.alpha = 0;
        [self.view.window addSubview:effectViewHead];
    }
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
    
    
    viewChange = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, _viewShareHeight.constant)];
//    Border(viewChange, DRed);
    UIImageView *imvChangeLogo = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 50, (_viewShareHeight.constant - 25) / 2, 25, 25)];
    imvChangeLogo.image = [UIImage imageNamed:@"logo"];
    [viewChange addSubview:imvChangeLogo];
    
    [_viewShare addSubview:viewChange];
    
    UILabel *lblChange = [[UILabel alloc] initWithFrame:CGRectMake(ScreenWidth / 2 - 20, (_viewShareHeight.constant - 21) / 2, 100, 21)];
    lblChange.text = [DFD getIOSName];
    lblChange.textColor = DWhite;
    [viewChange addSubview:lblChange];
    
    [self change:NO];
}

-(void)change:(BOOL)isChage
{
    [viewContent setHidden:isChage];
    [viewContent.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = isChage;
    }];
    [viewChange setHidden:!isChage];
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




- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}

- (void)btnClick:(UIButton *)sender
{
    [self change:YES];
    [self share:sender.tag url:nil title:nil];
    [self change:NO];
}





@end
