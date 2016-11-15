//
//  vcFriendDetails.m
//  Coasters
//
//  Created by 丁付德 on 15/9/6.
//  Copyright (c) 2015年 dfd. All rights reserved.
//

#import "vcFriendDetails.h"
#import "tvcIndex.h"
#import "vcChart.h"
#import "NSMutableArray+Sort.h"
#import "tvcFriendDetails.h"
#import "LXEmojiKeyboardView.h"
#import "LXGrowingInputView.h"
#import <Masonry.h>

#define tableViewHeight         Bigger(RealHeight(100), 50)

@interface vcFriendDetails ()<UITableViewDataSource, UITableViewDelegate, LXGrowingInputViewDelegate>
{
    UITapGestureRecognizer *tap;
    UIVisualEffectView *effectView;
    UIVisualEffectView *effectViewHead;
    BOOL _isForKeybaordTypeChange;
    BOOL isSending;                                 // 是否正在发送
    NSString *content;
}

@property (weak, nonatomic) IBOutlet UIView *viewMain;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewMainHeight;
@property (weak, nonatomic) IBOutlet UIView *viewFirst;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewFirstHeight;;
@property (weak, nonatomic) IBOutlet UIImageView *imvLogo;
@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UIImageView *imvGender;
@property (weak, nonatomic) IBOutlet UIButton *btnRemind;
@property (weak, nonatomic) IBOutlet UILabel *lblRemind;
@property (weak, nonatomic) IBOutlet UILabel *lblLastTime;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imvTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lblNameTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *btnRemindTop;


@property (weak, nonatomic) IBOutlet UITableView *tabView;
@property (strong, nonatomic) NSMutableArray *arrData;                      // 显示的字符集合

@property (strong, nonatomic) LXEmojiKeyboardView * emojiView;
@property (strong, nonatomic) LXGrowingInputView * inputView;

@property (weak, nonatomic) IBOutlet UIView *viewHead;


@end

@implementation vcFriendDetails

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"详细信息"];
    [self initRightButtonisInHead:@"cupcare-Data" text:nil];
    
    self.model = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat:@"access == %@ and user_id == %@", self.model.access, self.model.user_id] inContext:DBefaultContext];
    
    [self initData];
    [self initView];
    
    tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imvTap)];
    [self.imvLogo addGestureRecognizer:tap];
    self.imvLogo.userInteractionEnabled = YES;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [self removeObserverForKeyboardNotifications];
}

-(void)dealloc
{
    NSLog(@"vcFriendDetails 被销毁了");
    [self.imvLogo removeGestureRecognizer:tap];
    [effectViewHead removeFromSuperview];
}

-(void)rightButtonClick
{
    [self performSegueWithIdentifier:@"details_to_chart" sender:nil];
}

-(void)initData
{
    self.arrData = [NSMutableArray arrayWithCapacity:6];
    
    [self.arrData addObject:self.model.user_sport_target];
    [self.arrData addObject:self.model.sport_num];
    
    int hourSleep = 0;
    int sleepStart = [[self.model.user_sleep_start_time substringToIndex:2] intValue];
    int sleepEnd = [[self.model.user_sleep_end_time substringToIndex:2] intValue];
    hourSleep = sleepStart > sleepEnd ? 24 - (sleepStart - sleepEnd) : sleepEnd - sleepStart;
    
    [self.arrData addObject:[NSString stringWithFormat:@"%d%@", hourSleep, kString(@"小时")]];
    [self.arrData addObject:[NSString stringWithFormat:@"%@%@", [self getDeepNormalShallowHours][0], kString(@"小时")]];
    
    if ([self.model.user_situps_target intValue]) {
        [self.arrData addObject:self.model.user_situps_target];
        [self.arrData addObject:self.model.situps_num];
    }else{
        [self.arrData addObject:@""];
        [self.arrData addObject:@""];
    }
}


-(void)initView
{
    self.viewFirst.backgroundColor = DidConnectColor;
    
    self.imvLogo.layer.cornerRadius = ScreenWidth * (20 / 75.0) / 2;
    [self.imvLogo.layer setMasksToBounds:YES];
    
    _viewFirstHeight.constant = RealHeight(650);
    _imvTop.constant = IPhone4 ? 10 : RealHeight(78);
    _lblNameTop.constant = _btnRemindTop.constant = IPhone4 ? 10 : RealHeight(30);
    
    
    [self.imvLogo sd_setImageWithURL:[NSURL URLWithString:self.model.user_pic_url] placeholderImage: DefaultLogoImage];
    self.lblName.text = self.model.user_nick_name;
    self.imvGender.image =  [UIImage imageNamed:([self.model.user_gender boolValue] ?  @"gender_female" : @"gender_male")];
    self.lblRemind.text = kString(@"提醒Ta运动");
    
    [self.btnRemind setBackgroundImage:[UIImage imageFromColor:RGB(250, 131, 20)] forState:UIControlStateNormal];
    [self.btnRemind setBackgroundImage:[UIImage imageFromColor:DRed] forState:UIControlStateHighlighted];
    self.btnRemind.layer.cornerRadius = 5;
    [self.btnRemind.layer setMasksToBounds:YES];
    
    [self.tabView registerNib:[UINib nibWithNibName:@"tvcFriendDetails" bundle:nil] forCellReuseIdentifier:@"tvcFriendDetails"];
    self.tabView.backgroundColor = DClear;
    self.tabView.userInteractionEnabled = NO;
    
    if(SystemVersion >= 8)
    {
        effectView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        effectView.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        effectView.alpha = 0;
        [self.viewFirst insertSubview:effectView belowSubview:self.imvLogo];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            effectViewHead = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 65)];
            effectViewHead.effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            effectViewHead.alpha = 0;
            [self.view.window addSubview:effectViewHead];
        });
    }
    
    [self refreshLastRemindTime];
}

-(void)imvTap
{
    [self.imvLogo removeGestureRecognizer:tap];
    [self editViewHide];
    CGFloat width = 200 / 720.0 * ScreenWidth;
    [UIView transitionWithView:self.imvLogo duration:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^
     {
         if (self.imvLogo.tag) {
             self.imvLogo.frame = CGRectMake((ScreenWidth - width ) / 2, 10, width, width);
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


-(NSArray *)getDeepNormalShallowHours{
    
    int left = [[self.model.user_sleep_start_time substringToIndex:2] intValue];
    int right = [[self.model.user_sleep_end_time substringToIndex:2] intValue];
    int number = left < right ? (right - left) : (24 - (left - right));

    int numberDeep = 0;
    int numberModerate = 0;
    int numberShallow = 0;
    if (left < right)  // 只拿今天的数据
    {
        NSString *arrHourStr = self.model.sport_array;
        NSArray *arrHour = [arrHourStr componentsSeparatedByString:@","];
        if (arrHour.count == 24 && [self.model.sport_num intValue]) {
            for (int i = 0; i < number; i++)
            {
                NSNumber *num = [self getNumberFromStep:arrHour[left+i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
    }else              // 拿一部分昨天的数据
    {
        NSString *arrHourStr = self.model.sport_array;
        NSString *arrHourStr_yes = self.model.sport_array_yeaterday;
        
        NSArray *arrHour_yes = [arrHourStr_yes componentsSeparatedByString:@","];
        
        int stepNumber_yesterday = 0;
        for (NSString *str in arrHour_yes) {
            stepNumber_yesterday += [str intValue];
        }
        
        if (arrHour_yes.count == 24 && stepNumber_yesterday) {
            for (int i = 0; i < (24 - left); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour_yes[left+i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
        
        NSArray *arrHour = [arrHourStr componentsSeparatedByString:@","];
        if (arrHour.count == 24 && [self.self.model.sport_num intValue]) {
            for (int i = 0; i < (number - (24 - left)); i++) {
                NSNumber *num = [self getNumberFromStep:arrHour[i]];
                numberShallow += ([num intValue] == 1 ? 1:0);
                numberModerate += ([num intValue] == 2 ? 1:0);
                numberDeep += ([num intValue] == 3 ? 1:0);
            }
        }
    }
    
    // 如果没有这天的数据，返回4个数量的数组， 否则返回3个
    if (!numberDeep && !numberModerate && !numberShallow) {
        return @[@(numberDeep),@(numberModerate),@(numberShallow),@0];
    }
    return @[@(numberDeep),@(numberModerate),@(numberShallow)];
}



#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return (([DFD shareDFD].isForA5 ? 3:2));
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcFriendDetails *cell = [tvcFriendDetails cellWithTableView:tableView];
    switch (indexPath.row) {
        case 0:
            cell.imv.image = [UIImage imageNamed:@"running_02"];
            cell.lbl1.text = kString(@"日目标运动步数");
            cell.lbl2.text = kString(@"今日运动步数");
            cell.lbl3.text = [NSString stringWithFormat:@"%@", self.arrData[0]];
            cell.lbl4.text = [NSString stringWithFormat:@"%@", self.arrData[1]];
            break;
        case 1:
            cell.imv.image = [UIImage imageNamed:@"sleep_02"];
            cell.lbl1.text = kString(@"昨晚睡眠时长");
            cell.lbl2.text = kString(@"深度睡眠时长");
            cell.lbl3.text = [NSString stringWithFormat:@"%@", self.arrData[2]];
            cell.lbl4.text = [NSString stringWithFormat:@"%@", self.arrData[3]];
            break;
        case 2:
            cell.imv.image = [UIImage imageNamed:@"sit_ups_02"];
            cell.lbl1.text = kString(@"仰卧起坐目标数");
            cell.lbl2.text = kString(@"今日完成个数");
            cell.lbl3.text = [NSString stringWithFormat:@"%@", self.arrData[4]];
            cell.lbl4.text = [NSString stringWithFormat:@"%@", self.arrData[5]];
            break;
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  tableView.bounds.size.height / 3;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    if (self.isViewLoaded && !self.view.window) self.view = nil;
}


#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"details_to_chart"])
    {
        vcChart *vc = (vcChart *)segue.destinationViewController;
        vc.model = self.model;
    }
}


- (IBAction)btnClick:(id)sender
{
    NSLog(@"%f", fabs([self.model.lastRemindDatetime timeIntervalSinceNow]));
    if (!self.model.lastRemindDatetime || fabs([self.model.lastRemindDatetime timeIntervalSinceNow]) > 1 * 60 * 60) // 60 * 60 一个小时
    {
        if (!self.emojiView) {
            [self initRemind];
        }
    }
    else
    {
        LMBShow(@"你刚刚已经提醒过Ta一次了,稍后再提醒吧");
    }
}


-(void)initRemind
{
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.emojiView = [[LXEmojiKeyboardView alloc] initWithFrame:CGRectMake(0, 0, 320, 200)];
    self.emojiView.length = 30;
    self.emojiView.arrData = @[ kString(@"多运动有益身体健康！"), kString(@"奔跑吧，朋友！"), kString(@"今天你有完成运动目标吗？")];
    
    LXGrowingInputView * inputView = [[LXGrowingInputView alloc] init];
    inputView.translatesAutoresizingMaskIntoConstraints = NO;
    inputView.length = 30;
    [self.view addSubview:inputView];
    
    [inputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.view);
        make.bottom.equalTo(self.view);
        make.height.mas_equalTo(45);
    }];
    
    inputView.delegate = self;
    _inputView = inputView;
    
    [_inputView setFrame:CGRectMake(0 , ScreenHeight, ScreenWidth, 45)];
    [UIView transitionWithView:_inputView duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        [_inputView setFrame:CGRectMake(0 , ScreenHeight-45, ScreenWidth, 45)];
    } completion:^(BOOL finished) {}];
}

#pragma mark - UIKeyboard
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShown:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void)removeObserverForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShown:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    CGSize kbSize = [[dict objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGFloat keyboardHeight = kbSize.height;
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).with.offset(-keyboardHeight);
    }];
    
    [UIView animateWithDuration:durtion - 0.5 animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    if (_isForKeybaordTypeChange) {
        return;
    }
    
    NSDictionary *dict = [notification userInfo];
    NSTimeInterval durtion = [[dict objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view);
    }];
    
    [UIView animateWithDuration:durtion animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Delegate
- (void) inputView:(LXGrowingInputView *)inputView willChangeHeight:(float)height {
    
    if (height > 100) {
        return;
    }
    
    [_inputView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

- (void)inputView:(LXGrowingInputView *)inputView keyboardChangeButtonClick:(UIButton *)button keyboardType:(LXKeyboardType)type {
    
    _isForKeybaordTypeChange = YES;
    
    NSTimeInterval durtion = 0;
    if ([inputView.textView isFirstResponder]) {
        durtion = 0.06;
    }
    
    [inputView.textView resignFirstResponder];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (type == LXKeyboardTypeDefault) {
            _emojiView.textView = nil;
        }
        else {
            _emojiView.textView = _inputView.textView;
        }
        
        [_inputView.textView reloadInputViews];
        [_inputView.textView becomeFirstResponder];
    });
}

- (void) didInputViewSendButtonClick:(LXGrowingInputView *)inputView {
    _isForKeybaordTypeChange = NO;
    [_inputView.textView resignFirstResponder];
    content = inputView.textView.text;
    if (content.length) [self passRemind];
}

-(void)passRemind
{
    if (isSending) return;
    isSending = YES;
    NextWaitInMainAfter( if(self)self->isSending = NO;, 10);
    NSString *pushContent = [NSString stringWithFormat:@"%@", content];
    
    if ([NSString isHaveEmoji:content]) {
        LMBShow(@"包含了不能识别的字符");
        return;
    }
    
    NSLog(@"------ > 请求一次");
    RequestCheckBefore(
           [net pushHintInfo:self.userInfo.access
                        type:@"3"
                   friend_id:self.model.user_id
                hint_content:pushContent];,
           [self dataSuccessBack_pushDrinkHint:dic];,
           DDStrong(self)
           if(self)self->isSending = NO;)
}

-(void)refreshLastRemindTime
{
    
    self.lblLastTime.text = [NSString stringWithFormat:@"%@:%@", kString(@"上次提醒时间"), [self.model.lastRemindDatetime isToday] ? [DFD toStringForShow:self.model.lastRemindDatetime] : @"---"];
}


-(void)dataSuccessBack_pushDrinkHint:(NSDictionary *)dic
{
    if (CheckIsOK)
    {
        LMBShow(@"已发送提醒");
        Friend *fr = [Friend findFirstWithPredicate:[NSPredicate predicateWithFormat: @"access == %@ and user_id == %@", self.userInfo.access, self.model.user_id] inContext:DBefaultContext];
        fr.lastRemindDatetime = self.model.lastRemindDatetime = DNow;
        DBSave;
        
        self.lblLastTime.text = [NSString stringWithFormat:@"%@:%@", kString(@"上次提醒时间"), [DFD toStringForShow:self.model.lastRemindDatetime]];
        
        [self refreshLastRemindTime];
        [self editViewHide];
    }
}

-(void)editViewHide
{
    if (!_emojiView) return;
    _isForKeybaordTypeChange = YES;
    NSTimeInterval durtion = 0;
    if ([_inputView.textView isFirstResponder]) durtion = 0.03;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(durtion * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView transitionWithView:_inputView duration:0.3 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            [_inputView setFrame:CGRectMake(0 , ScreenHeight+100, ScreenWidth, 45)];
            [_emojiView setFrame:CGRectMake(0 , ScreenHeight+100, ScreenWidth, 45)];
        } completion:^(BOOL finished) {
            [_inputView removeFromSuperview];
            [_emojiView removeFromSuperview];
            _inputView = nil;
            _emojiView = nil;
        }];
    });
}


@end
