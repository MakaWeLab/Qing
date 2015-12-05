//
//  MCLoginController.m
//  Qing
//
//  Created by Maka on 30/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCLoginController.h"
#import <Masonry.h>
#import "MCCommonLoginView.h"
#import "UIImageView+MCDownload.h"

@interface MCLoginController ()

@property (nonatomic,strong) MCCommonLoginView* loginView;

@end

@implementation MCLoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = NSLocalizedString(@"登录", nil);
    self.loginView = [MCCommonLoginView instanceFromNib];
    self.loginView.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 300);
    self.tableView.tableHeaderView = self.loginView;
    self.tableView.tableFooterView = [UIView new];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction)];
    [self.loginView.verifyImageView addGestureRecognizer:tap];
    
}

-(void)tapAction
{
    //http://www.feiwu28.com/vcode.php
    //http://www.feiwu28.com/login.php
    NSString* url = [NSString stringWithFormat:@"%@?t=%f",@"http://www.feiwu28.com/vcode.php",round(arc4random()*10000) ];
    NSData* htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];

    self.loginView.verifyImageView.image = [[UIImage alloc]initWithData:htmlData];
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
