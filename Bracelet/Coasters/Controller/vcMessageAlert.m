//
//  vcMessageAlert.m
//  Bracelet
//
//  Created by 丁付德 on 16/3/7.
//  Copyright © 2016年 dfd. All rights reserved.
//

#import "vcMessageAlert.h"

@interface vcMessageAlert ()

@property (weak, nonatomic) IBOutlet UIView *viewHead;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewHeadHeight;


@property (nonatomic, strong) NSArray *arrData;

@end

@implementation vcMessageAlert

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initLeftButtonisInHead:nil text:@"返回"];
}

//-(void)initLeftButton:(NSString *)imgName text:(NSString *)text
//{
//    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(17, (NavBarHeight - 35 ) / 2 + 10, 80, 35)];
//    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    btn.titleLabel.font = [UIFont systemFontOfSize:15];
//    btn.titleLabel.textColor = DWhite;
//    [btn setImage: [UIImage imageNamed:@"back"] forState: UIControlStateNormal];
//    [btn setImage: [UIImage imageNamed:@"back02"] forState: UIControlStateHighlighted];
//    
//    [btn setTitle:kString(text) forState: UIControlStateNormal];
//    [btn setImageEdgeInsets: UIEdgeInsetsMake(6, -5, 6, 0)];
//    [btn setTitleEdgeInsets: UIEdgeInsetsMake(0, -3, 0, -70)];
//    [btn setTitleColor:DWhite forState:UIControlStateNormal];
//    [btn setTitleColor:DWhiteA(0.5) forState:UIControlStateHighlighted];
//    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
//    [self.viewHead addSubview:btn];
//    
//    self.viewHead.backgroundColor = DidConnectColor;
//    self.viewHeadHeight.constant = NavBarHeight;
//}


#pragma mark UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return self.arrData.count;
}

#pragma mark UITableViewDelegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    <#cell控制器名称#>*cell = [<#cell控制器名称#> cellWithTableView:tableView];
//    <#数据模型#> *model = <#数据源#>[indexPath.row];
//    cell.model = model;
//    return cell;
//    
    static NSString *ID = @"Cell"; // 标识符
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    cell.textLabel.text = self.arrData[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    <#数据模型#> *model = self.arrData[indexPath.row];
//    [self performSegueWithIdentifier:@"<#连接线名称#>" sender:model];
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
