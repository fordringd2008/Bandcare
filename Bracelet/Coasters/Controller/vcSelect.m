//
//  vcSelect.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/5.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcSelect.h"
#import "tvcSelect.h"
#import "vcNewPerfectInfo.h"
#import "vcBase+Share.h"

@interface vcSelect () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray *arrData;

@end

@implementation vcSelect

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNavTitle:self title:kString(@"选择您拥有的设备")];
    [self initLeftButton:nil text:@"重新登录"];
    
    self.arrData = @[ @[@"shouhuan1",kString(@"一代手环"),kString(@"关注健康，关注运动")],
                      @[@"shouhuan2",kString(@"二代手环"),kString(@"仰卧起坐一起来")]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"DHL"] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage imageFromColor:DidConnectColor];
    self.navigationController.navigationBar.translucent = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)back
{
    // 这里要删除所有本地用户信息
    SetUserDefault(userInfoAccess, nil);
    SetUserDefault(userInfoData, nil);
    [self clearDataFrom3Class];
    [DFD returnUserNil];
    self.userInfo = nil;
    DBSave;
    [super back];
}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return 1;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    tvcSelect *cell = [tvcSelect cellWithTableView:tableView];
    cell.arrData = self.arrData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [DFD shareDFD].isForA5 = (BOOL)indexPath.row;
    [self performSegueWithIdentifier:@"select_newperfect" sender:nil];
}

#pragma mark - Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqual:@"select_newperfect"])
    {
        vcNewPerfectInfo *vc = (vcNewPerfectInfo *)segue.destinationViewController;
        vc.isAcceptBack = self.isAcceptBack;
        vc.arrDataFromThird = self.arrDataFromThird;
    }
    
}

    
    
    

@end
