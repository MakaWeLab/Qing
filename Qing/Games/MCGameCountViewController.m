//
//  MCGameCountViewController.m
//  Qing
//
//  Created by Maka on 30/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCGameCountViewController.h"
#import "PK10TableViewCell.h"
#import "TFHpple.h"
#import <MJRefresh.h>
#import <ReactiveCocoa.h>
#import "WebViewController.h"
#import <Masonry.h>
#import "PK10DataModel.h"
#import "PK10ToolBar.h"
#import "PK10DownloadManager.h"
#import "PK10RuleView.h"

@interface MCGameCountViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) NSString* XPathString;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSString* beginString;

@property (nonatomic,strong) NSString* endString;

@property (nonatomic,strong) NSDateFormatter* dateFormatter;

@property (nonatomic,strong) UIWebView* loadingWebView;

@property (nonatomic,strong) dispatch_source_t timer;

@property (nonatomic,strong) dispatch_queue_t queue;

@property (nonatomic,assign) BOOL isPlaying;

@property (nonatomic,assign) BOOL isPersonDriver;

@property (nonatomic,strong) PK10DownloadManager* shareManager;

@property (nonatomic,strong) PK10ToolBar* toolbar;

@end

@implementation MCGameCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.shareManager = [PK10DownloadManager shareInstance];
    
    self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.view addSubview:self.tableView];
    self.view.clipsToBounds = YES;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    [self.tableView registerNib:[UINib nibWithNibName:@"PK10TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PK10TableViewCell"];
    self.navigationItem.title = @"PK10";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResign) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    self.loadingWebView = [[UIWebView alloc]init];
    self.loadingWebView.scalesPageToFit = YES;
    CGFloat width = [UIScreen mainScreen].bounds.size.width*.8;
    CGFloat height = width*.6;
    self.loadingWebView.frame = CGRectMake(0-width-50,74, width, height);
    [self.view addSubview:self.loadingWebView];
    
    [self switchRightItemPlay:YES];
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"mm:ss"];
    
    @weakify(self);
    self.shareManager.complete = ^(BOOL isSuccess){
        @strongify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        });
    };
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self.shareManager refreshLaterestDatabase];
    }];
    
    self.toolbar = [[PK10ToolBar alloc]init];
    self.toolbar.frame = CGRectMake(0, self.view.bounds.size.height - 50, self.view.bounds.size.width, 50);
    [self.view addSubview:self.toolbar];
    
    [self.toolbar.ruleView addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"type"]) {
        [self.tableView reloadData];
    }
}

-(void)dealloc
{
    [self.toolbar.ruleView removeObserver:self forKeyPath:@"type"];
    [self.loadingWebView stopLoading];
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationDidResign
{
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    NSDate* date = [NSDate date];
    NSTimeInterval nextFireTime = [self nextFireTimeIntervalWithDate:date];
    [self openTimeropenTimerWithTimeOut:nextFireTime];
}

-(void)webView
{
    if (self.isPlaying) {
        [self endPlay];
    }else {
        self.isPersonDriver = YES;
        [self beginPlay];
    }
}

-(void)switchRightItemPlay:(BOOL)play
{
    UIBarButtonItem* rightItem = nil;
    self.isPlaying = !play;
    if (play) {
        rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(webView)];
    }else {
        rightItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(webView)];
    }
    
    self.navigationItem.rightBarButtonItem = rightItem;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)refreshLastData
{
    [self.tableView.mj_header beginRefreshing];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self applicationDidResign];
}

-(void)openTimeropenTimerWithTimeOut:(NSTimeInterval)time{
    @weakify(self);
    __block int timeout=0; //倒计时时间
    timeout = time;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.queue = queue;
    self.timer= dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout==0){ //倒计时结束，关闭
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                @strongify(self);
                self.navigationItem.title = @"开奖中...";
                dispatch_suspend(self.queue);
                self.isPersonDriver = NO;
                [self beginPlay];
                timeout = [self nextFireTimeIntervalWithDate:[NSDate date]];
            });
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                @strongify(self);
                self.navigationItem.title = [NSString stringWithFormat:@"%d秒后刷新",timeout];
            });
            timeout-=1;
        }
    });
    dispatch_resume(_timer);
    
}

-(void)beginPlay
{
    if (self.isPlaying) {
        [self.loadingWebView reload];
        @weakify(self);
        if (!self.isPersonDriver) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                @strongify(self);
                if (!self.isPersonDriver) {
                    [self endPlay];
                }
            });
        }
        return;
    }
    
    [self switchRightItemPlay:NO];
    [self.loadingWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://i.api.1396.me/mobile/pk10/"]]];
    [UIView animateWithDuration:.25 animations:^{
        self.loadingWebView.frame = CGRectMake(10, 74, self.loadingWebView.bounds.size.width, self.loadingWebView.bounds.size.height);
    }];
    @weakify(self);
    if (!self.isPersonDriver) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            if (!self.isPersonDriver) {
                [self endPlay];
            }
        });
    }
}

-(void)endPlay
{
    if (!self.isPlaying) {
        return;
    }
    
    [self switchRightItemPlay:YES];
    [UIView animateWithDuration:.25 animations:^{
        self.loadingWebView.frame = CGRectMake(0-self.loadingWebView.bounds.size.width-50, 74 , self.loadingWebView.bounds.size.width, self.loadingWebView.bounds.size.height);
    }];
    [self.loadingWebView stopLoading];
    [self.tableView.mj_header beginRefreshing];
    
    dispatch_resume(self.queue);
}

-(NSInteger)timeNumberForDateString:(NSString*)dateString
{
    NSInteger minite = [self miniteForDateString:dateString];
    NSInteger second = [self secondForDateString:dateString];
    return minite*100+second;
}

-(NSInteger)miniteForDateString:(NSString*)dateString
{
    NSArray* array = [dateString componentsSeparatedByString:@":"];
    return [array.firstObject integerValue];
}

-(NSInteger)secondForDateString:(NSString*)dateString
{
    NSArray* array = [dateString componentsSeparatedByString:@":"];
    return [array.lastObject integerValue];
}

-(NSTimeInterval)nextFireTimeIntervalWithDate:(NSDate*)date
{
    NSTimeInterval time = 0;
    
    NSString* dateString = [self.dateFormatter stringFromDate:date];
    
    NSInteger minite = [self miniteForDateString:dateString];
    
    minite = minite%10;
    
    NSInteger m = 0;
    
    if (minite>7) {
        m = 11 - minite;
    }else if (minite <2){
        m = 1 - minite;
    }else if (minite == 2 || minite == 7){
        if (self.isPlaying) {
            m = 4;
        }else {
            return 5;
        }
    }else {
        m = 6 - minite;
    }
    
    time = m*60 + 60 - [self secondForDateString:dateString];;
    
    return time;
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.shareManager.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PK10TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PK10TableViewCell" forIndexPath:indexPath];
    
    PK10DataModel* model = self.shareManager.dataList[indexPath.row];
    
    cell.type = self.toolbar.ruleView.type;
    cell.time = model.time;
    cell.flag = model.flag;
    cell.numbers = model.numbers;
    
    return cell;
}

@end
