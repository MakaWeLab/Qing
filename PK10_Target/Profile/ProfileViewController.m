//
//  ProfileViewController.m
//  Qing
//
//  Created by Maka on 15/11/18.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "ProfileViewController.h"
#import "ProfilePersonView.h"
#import "ProfilePersonSettingView.h"
#import <Masonry.h>
#import <RESideMenu.h>
#import "LearnListViewController.h"
#import "MCGameIndexViewController.h"
#import <UIViewController+RESideMenu.h>

@interface ProfileViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) ProfilePersonView* personView;

@property (nonatomic,strong) ProfilePersonSettingView* settingView;

@property (nonatomic,strong) UIImageView* backImageView;

@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.backImageView = [[UIImageView alloc]init];
    self.backImageView.image = [UIImage imageNamed:@"img_profile_background"];
    self.backImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:self.backImageView];
    [self.backImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.personView = [ProfilePersonView instanceFromNib];
    self.personView.alpha = 0;
    [self.view addSubview:self.personView];
    [self.personView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.left.right.mas_equalTo(0);
        make.height.mas_equalTo(80);
    }];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIden"];
    [self.view addSubview:self.tableView];
    {
        self.dataSource = [[NSMutableArray alloc]init];
        [self.dataSource addObject:@"实时数据"];
//        [self.dataSource addObject:@"实时开奖"];
//        [self.dataSource addObject:@"历史统计"];
//        [self.dataSource addObject:@"杀号预测"];
        [self.dataSource addObject:@"博弈文学"];
    }
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40+80);
        make.left.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-40);
    }];
    
    self.settingView = [ProfilePersonSettingView instanceFromNib];
    self.settingView.alpha = 0;
    [self.view addSubview:self.settingView];
    [self.settingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(40);
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIden" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.text = self.dataSource[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString* string = self.dataSource[indexPath.row];
    if ([string isEqualToString:@"博弈文学"]) {
        self.sideMenuViewController.contentViewController = [[UINavigationController alloc]initWithRootViewController:[LearnListViewController shareInstance]];
        
    }else if ([string isEqualToString:@"实时数据"]) {
        self.sideMenuViewController.contentViewController = [[UINavigationController alloc]initWithRootViewController:[MCGameIndexViewController shareInstance]];
    }
    [self.sideMenuViewController hideMenuViewController];
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
