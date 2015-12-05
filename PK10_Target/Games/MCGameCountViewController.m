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
#import <MBProgressHUD.h>
#import "PK10GamePlayer.h"

@interface MCGameCountViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSDateFormatter* dateFormatter;

//@property (nonatomic,strong) PK10GamePlayer* gamePlayer;

@property (nonatomic,strong) PK10DownloadManager* shareManager;



@property (nonatomic,strong) UITableView* tableView;

@property (nonatomic,strong) PK10ToolBar* toolbar;

@property (nonatomic,strong) MBProgressHUD* hud;



@property (nonatomic,strong) dispatch_source_t timer;

@property (nonatomic,strong) dispatch_queue_t queue;

@property (nonatomic,assign) BOOL isPlaying;

@property (nonatomic,assign) BOOL isPersonDriver;

@end

@implementation MCGameCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self switchRightItemPlay:YES];
    self.view.clipsToBounds = YES;
    self.navigationItem.title = @"PK10";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResign) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    
    @weakify(self);
    
    {
        self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.clipsToBounds = YES;
        [self.view addSubview:self.tableView];
        [self.tableView registerNib:[UINib nibWithNibName:@"PK10TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PK10TableViewCell"];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self.shareManager refreshLaterestDatabase];
        }];
        
        self.toolbar = [[PK10ToolBar alloc]init];
        self.toolbar.backgroundColor = [UIColor clearColor];
        self.toolbar.clipsToBounds = YES;
        [self.view addSubview:self.toolbar];
        [self.toolbar.ruleView addObserver:self forKeyPath:@"type" options:NSKeyValueObservingOptionNew context:nil];
        [self.toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.left.right.mas_equalTo(0);
            make.height.mas_equalTo(49);
        }];
        
        
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        self.hud.removeFromSuperViewOnHide = YES;
        self.hud.dimBackground = YES;
        self.hud.mode = MBProgressHUDModeDeterminate;
        [self.view addSubview:self.hud];
    }
    
    
    {
        self.shareManager = [PK10DownloadManager shareInstance];
        self.shareManager.complete = ^(BOOL isSuccess){
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.hud hide:YES];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            });
        };
        
        self.shareManager.progress = ^(NSInteger progress){
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hud.labelText = [NSString stringWithFormat:@"数据初始化中 剩余%ld项",(long)progress];
                self.hud.progress = progress/100.;
                [self.hud show:YES];
                [self.view bringSubviewToFront:self.hud];
            });
        };
        
        self.dateFormatter = [[NSDateFormatter alloc]init];
        [self.dateFormatter setDateFormat:@"mm:ss"];
        
//        self.gamePlayer = [[PK10GamePlayer alloc]initWithLine:10];
//        [self.view addSubview:self.gamePlayer];
//        CGRect rect = self.gamePlayer.bounds;
//        rect.origin.x = -10- rect.size.width;
//        rect.origin.y = 74;
//        self.gamePlayer.frame = rect;
    }
    
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
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationDidResign
{
    if (self.shareManager.dataList.count == 0) {
        [self.shareManager refreshLaterestDatabase];
    }else {
        if (_timer) {
            dispatch_source_cancel(_timer);
        }
        NSDate* date = [NSDate date];
        NSTimeInterval nextFireTime = [self nextFireTimeIntervalWithDate:date];
        [self openTimeropenTimerWithTimeOut:nextFireTime];
    }
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
//    [UIView animateWithDuration:.25 animations:^{
//        self.gamePlayer.frame = CGRectMake(10, 74, self.gamePlayer.bounds.size.width, self.gamePlayer.bounds.size.height);
//    }];
//    self.gamePlayer.leftTime = 200;
//    [self.gamePlayer begin];
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
    
//    [self.gamePlayer stopPlayWithResult:[self.shareManager.dataList.firstObject numbers]];
    
    [self switchRightItemPlay:YES];
//    [UIView animateWithDuration:.25 animations:^{
//        self.gamePlayer.frame = CGRectMake(0-self.gamePlayer.bounds.size.width-10, 74 , self.gamePlayer.bounds.size.width, self.gamePlayer.bounds.size.height);
//    }];
//    [self.tableView.mj_header beginRefreshing];
    
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
