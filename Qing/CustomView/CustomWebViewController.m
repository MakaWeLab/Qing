//
//  WebViewController.m
//  Qing
//
//  Created by chaowualex on 15/11/18.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "CustomWebViewController.h"
#import <Masonry.h>

@interface CustomWebViewController ()

@property (strong, nonatomic) UIWebView *webView;

@property (strong, nonatomic) UITextField *textField;

@end

@implementation CustomWebViewController

- (void)goWebsite:(id)sender {
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.textField.text]]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout=UIRectEdgeNone;
    
    self.webView = [[UIWebView alloc]init];
    [self.view addSubview:self.webView];
    
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView* view = [[UIView alloc]init];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    self.textField = [[UITextField alloc]init];
    [view addSubview:self.textField];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(view);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:@"前往" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(goWebsite:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.textField);
        make.right.mas_equalTo(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(30);
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
