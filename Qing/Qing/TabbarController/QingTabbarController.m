//
//  QingTabbarController.m
//  Qing
//
//  Created by Maka on 15/11/9.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "QingTabbarController.h"
#import <Masonry.h>
#import <ReactiveCocoa.h>

@interface QingTabbarController ()

@property (nonatomic,strong) UITabBar* tabbar;

@end

@implementation QingTabbarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    {
        self.tabbar = [[UITabBar alloc]init];
        [self.view addSubview:self.tabbar];
        [self.tabbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.right.mas_equalTo(0);
            make.height.mas_equalTo(49);
        }];
    }
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
