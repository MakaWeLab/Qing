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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)queryDataListFromRemote
{
    NSString* html = @"http://bj.poms.baidupcs.com/file/7b3ef5411519bc626bb7ff90a3ba0ce7?bkt=p3-14007b3ef5411519bc626bb7ff90a3ba0ce7f173df160000000003d4&fid=4163859255-250528-636768946320946&time=1449296186&sign=FDTAXGERLBH-DCb740ccc5511e5e8fedcff06b081203-EVOIfKmFrYbWK%2BgCYqEO5JBmKU4%3D&to=bb&fm=Nan,B,G,tt&sta_dx=0&sta_cs=0&sta_ft=plist&sta_ct=0&fm2=Nanjing02,B,G,tt&newver=1&newfm=1&secfm=1&flow_ver=3&pkey=14007b3ef5411519bc626bb7ff90a3ba0ce7f173df160000000003d4&sl=72089678&expires=8h&rt=sh&r=629343053&mlogid=7852968148049863353&vuk=4163859255&vbdid=2827256518&fin=dataList.plist&fn=dataList.plist&slt=pm&uta=0&rtype=1&iv=0&isw=0&dp-logid=7852968148049863353&dp-callid=0.1.1";
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:html]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
        if (data) {
            NSDictionary* dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];
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
    cell.textLabel.font = [UIFont systemFontOfSize:13];
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
