//
//  MCGamePlayerViewController.m
//  Qing
//
//  Created by chaowualex on 15/12/6.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10GamePlayer.h"
#import "MCGamePlayerViewController.h"

@interface MCGamePlayerViewController ()

@property (nonatomic,strong) PK10GamePlayer* gamePlayer;


@end

@implementation MCGamePlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gamePlayer = [[PK10GamePlayer alloc]initWithLine:10];
    [self.view addSubview:self.gamePlayer];
    CGRect rect = self.gamePlayer.bounds;
    rect.origin.x = -10- rect.size.width;
    rect.origin.y = 74;
    self.gamePlayer.frame = rect;
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
