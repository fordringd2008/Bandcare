//
//      ┏┛ ┻━━━━━┛ ┻┓
//      ┃　　　　　　 ┃
//      ┃　　　━　　　┃
//      ┃　┳┛　  ┗┳　┃
//      ┃　　　　　　 ┃
//      ┃　　　┻　　　┃
//      ┃　　　　　　 ┃
//      ┗━┓　　　┏━━━┛
//        ┃　　　┃   神兽保佑
//        ┃　　　┃   代码无BUG！
//        ┃　　　┗━━━━━━━━━┓
//        ┃　　　　　　　    ┣┓
//        ┃　　　　         ┏┛
//        ┗━┓ ┓ ┏━━━┳ ┓ ┏━┛
//          ┃ ┫ ┫   ┃ ┫ ┫
//          ┗━┻━┛   ┗━┻━┛
//
//  Created by 丁付德 on 16/7/16.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcSearchHelp.h"

#pragma mark - 宏命令

@interface vcSearchHelp ()
{
    
}

@property (weak, nonatomic) IBOutlet UILabel *lbl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblHeight;
@property (weak, nonatomic) IBOutlet UIButton *btnGotoSet;



@end

@implementation vcSearchHelp

#pragma mark - override
- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"返回"];
    [self initView];
}

#pragma mark - ------------------------------------- 生命周期
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    
    [super viewWillDisappear:animated];
}

- (void)back
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)dealloc
{
    // 这里移除观察者
    NSLog(@"vcSearchHelp销毁了");
}

// 初始化布局控件
- (void)initView
{
    NSLog(@"vcSearchHelp initView");
    NSString *text = kString(@"1 > 为什么第一绑定需要配对 ？\n  答：手环在配对后，才能收到iPhone的来电、短信、QQ等信息.\n\n2 > 搜索不到手环 ？\n  答：可能的原因有 \n    1, 手环电量不足.\n    2, iPhone蓝牙未打开.\n    3, 手环与手机距离太远.\n    4, 手环已经和iPhone绑定了，需要在设置中进行解除绑定，操作如图.");
    
//    NSString *abc = @"> Why it need matching when connecting ？\nAnswer：In order to receive iPhone calls, SMS, QQ and other information after pairing.\n\n2 > Can not find Bandcare ？\nAnswer：May be\n\t1, Bandcare\'s power is shortage.\n\t2, Bandcare is too far away to iPhone.\n\t3, Bandcare has been tied to iPhone, need to be released in the setting of binding, like the following.";
    
    
    self.lbl.text = text;
    self.lblHeight.constant = [DFD getTextSizeWith:text fontNumber:14 biggestWidth:(ScreenWidth - 30)].height + 30;
    self.viewHeight.constant = self.lblHeight.constant + ScreenWidth * 1334.0 / 720 + 40;
    [self.btnGotoSet setTitle:kString(@"去设置蓝牙") forState:UIControlStateNormal];
}


- (IBAction)btnClick:(id)sender {
    NSLog(@"去设置");
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=Bluetooth"]];
}
































@end
