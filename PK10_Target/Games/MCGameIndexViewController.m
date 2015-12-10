//
//  MCGameCountViewController.m
//  Qing
//
//  Created by Maka on 30/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCGameIndexViewController.h"
#import "GameIndex/GameTableViewCell.h"
#import "TFHpple.h"
#import <MJRefresh.h>
#import <ReactiveCocoa.h>
#import "WebViewController.h"
#import <Masonry.h>
#import <MBProgressHUD.h>
#import "GameDownloadManager.h"
#import <KxMenu.h>
#import <objc/runtime.h>

@interface MCGameIndexViewController ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) NSDateFormatter* dateFormatter;

@property (nonatomic,strong) GameDownloadManager* downloadManager;

@property (nonatomic,strong) UITableView* tableView;


@property (nonatomic,strong) MBProgressHUD* hud;


@property (nonatomic,strong) dispatch_source_t timer;

@property (nonatomic,strong) dispatch_queue_t queue;

@end

@implementation MCGameIndexViewController

+(instancetype)shareInstance
{
    static MCGameIndexViewController* shareController;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareController = [[self alloc]init];
    });
    return shareController;
}

-(void)rightItemAction
{
    for(UIView* view in self.view.subviews) {
        NSString* str = [NSString stringWithCString:object_getClassName(view) encoding:NSUTF8StringEncoding];
        if ([str isEqualToString:@"KxMenuOverlay"]) {
            [KxMenu dismissMenu];
            return;
        }
    }
    CGRect rect = self.navigationController.navigationBar.frame;
    rect.origin.x = rect.size.width - 50;
    rect.size.width = 50;
    [KxMenu showMenuInView:self.view
                  fromRect:rect
                 menuItems:@[
                             [KxMenuItem menuItem:@"PK10"
                                            image:nil
                                           target:self
                                           action:@selector(itemChooseAction:)],
                             [KxMenuItem menuItem:@"PK10冠军"
                                            image:nil
                                           target:self
                                           action:@selector(itemChooseAction:)],
                             [KxMenuItem menuItem:@"PK10冠亚军"
                                            image:nil
                                           target:self
                                           action:@selector(itemChooseAction:)],
                             [KxMenuItem menuItem:@"PK10冠亚季军"
                                            image:nil
                                           target:self
                                           action:@selector(itemChooseAction:)],
                             ]];
}

-(void)itemChooseAction:(KxMenuItem*)item
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.clipsToBounds = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResign) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    UIBarButtonItem* rightItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_dropdown"] style:UIBarButtonItemStyleBordered target:self action:@selector(rightItemAction)];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    @weakify(self);
    
    {
        self.tableView = [[UITableView alloc]initWithFrame:self.view.bounds];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.clipsToBounds = YES;
        [self.view addSubview:self.tableView];
        [self.tableView registerClass:[GameTableViewCell class] forCellReuseIdentifier:@"GameTableViewCell"];
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
        self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self.downloadManager refreshLaterestDatabase];
        }];
        
        self.hud = [[MBProgressHUD alloc] initWithView:self.view];
        self.hud.removeFromSuperViewOnHide = YES;
        self.hud.dimBackground = YES;
        self.hud.mode = MBProgressHUDModeDeterminate;
        [self.view addSubview:self.hud];
    }
    
    
    {
        self.downloadManager = [GameDownloadManager shareInstance];
        NSString* path = [[NSBundle mainBundle] pathForResource:@"PK10" ofType:@"plist"];
        self.downloadManager.configInfo = [NSDictionary dictionaryWithContentsOfFile:path];
        self.downloadManager.complete = ^(BOOL isSuccess){
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                if (!self.timer) {
                    [self applicationDidResign];
                }
                
                [self.hud hide:YES];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            });
        };
        
        self.downloadManager.progress = ^(CGFloat progress){
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.hud.labelText = [NSString stringWithFormat:@"加载历史记录..."];
                self.hud.progress = progress;
                [self.hud show:YES];
                [self.view bringSubviewToFront:self.hud];
            });
        };
        
        self.dateFormatter = [[NSDateFormatter alloc]init];
        [self.dateFormatter setDateFormat:@"mm:ss"];
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
    if (_timer) {
        dispatch_source_cancel(_timer);
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)applicationDidResign
{
    if (self.downloadManager.dataList.count == 0) {
        [self.downloadManager refreshLaterestDatabase];
    }else {
        if (_timer) {
            dispatch_source_cancel(_timer);
        }
        NSDate* date = [NSDate date];
        NSTimeInterval nextFireTime = [self nextFireTimeIntervalWithDate:date];
        [self openTimerWithTimeOut:nextFireTime];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self applicationDidResign];
}

-(void)openTimerWithTimeOut:(NSTimeInterval)time{
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
                [self.tableView.mj_header beginRefreshing];
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
    
    CGFloat m = 0;
    
    if (minite>8) {
        m = 12 - minite;
    }else if (minite <3){
        m = 2 - minite;
    }else if (minite == 3 || minite == 8){
        m = 4;
    }else {
        m = 7 - minite;
    }
    
    time = m*60 + 60 - [self secondForDateString:dateString];
    
    return time;
}

#pragma mark - UITableViewDataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.downloadManager.dataList.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NUMBER_HEIGHT;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"GameTableViewCell" forIndexPath:indexPath];
    
    id<GameDataModelProtocol> model = self.downloadManager.dataList[indexPath.row];
    cell.diffIndexs = @[@0,@1];
    
    cell.numbers = [model results];
    
    
    return cell;
}

@end
