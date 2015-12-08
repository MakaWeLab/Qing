//
//  LearnListViewController.m
//  Qing
//
//  Created by chaowualex on 15/12/5.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "LearnListViewController.h"
#import "WebViewController.h"
#import <MBProgressHUD.h>

@interface LearnListViewController ()

@property (nonatomic,strong) NSMutableArray* dataSource;

@end

@implementation LearnListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.dataSource = [NSMutableArray array];
    self.navigationItem.title = @"博弈文学";
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuseIden"];
    [self queryDataListFromRemote];
}

+(instancetype)shareInstance
{
    static LearnListViewController* shareController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareController = [[self alloc]init];
    });
    return shareController;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryDataListFromRemote
{
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        NSMutableDictionary* dic = [NSMutableDictionary dictionary];
        NSMutableArray* mArray = [NSMutableArray array];
        [dic setObject:mArray forKey:@"value"];
        
        {
            NSMutableDictionary* d = [NSMutableDictionary dictionary];
            [d setObject:@"pk10稳赚技巧" forKey:@"name"];
            [d setObject:@"http://blog.sina.cn/dpool/blog/s/blog_1535243080102vnk3.html" forKey:@"url"];
            [mArray addObject:d];
        }
        
        if (dic) {
            NSArray* array  = [dic objectForKey:@"value"];
            [self.dataSource addObjectsFromArray:array];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
        }
    });
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIden"];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    NSDictionary* dic = self.dataSource[indexPath.row];
    cell.textLabel.text = [dic objectForKey:@"name"];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary* dic = self.dataSource[indexPath.row];
    WebViewController* web = [[WebViewController alloc]init];
    web.url = [dic objectForKey:@"url"];
    web.navigationItem.title = @"文章详情";
    [self.navigationController pushViewController:web animated:YES];
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
