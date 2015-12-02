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

@interface MCGameCountViewController ()

@property (nonatomic,strong) NSMutableArray* dataSource;

@property (nonatomic,strong) NSString* XPathString;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSString* beginString;

@property (nonatomic,strong) NSString* endString;

@property (nonatomic,strong) NSDateFormatter* dateFormatter;

@property (nonatomic,strong) UIWebView* loadingWebView;

@property (nonatomic,strong) dispatch_source_t timer;

@end

@implementation MCGameCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PK10TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PK10TableViewCell"];
    
    self.navigationItem.title = @"PK10";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidResign) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self appendData];
    }];
    
    self.loadingWebView = [[UIWebView alloc]init];
    self.loadingWebView.scalesPageToFit = YES;
    CGFloat width = [UIScreen mainScreen].bounds.size.width*.8;
    CGFloat height = width*.6;
    self.loadingWebView.frame = CGRectMake(0,0-height - 100, width, height);
    [self.view addSubview:self.loadingWebView];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(webView)];
    
    self.dataSource = [NSMutableArray array];
    
    self.dateFormatter = [[NSDateFormatter alloc]init];
    [self.dateFormatter setDateFormat:@"mm:ss"];
    
    NSString* url = @"";
    self.XPathString = @"//table[@class='tb']//tr";
    self.page = 1;
    self.beginString = @"http://www.bwlc.net/bulletin/trax.html?page=";
    self.endString = @"";
    url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,(long)self.page,self.endString];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        @strongify(self);
        [self firstLoadDataWithUrl:url];
    });
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        [self firstLoadDataWithUrl:url];
    }];
}

-(void)dealloc
{
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
    WebViewController* web = [[WebViewController alloc]init];
    web.hidesBottomBarWhenPushed = YES;
    web.url = @"http://i.api.1396.me/mobile/pk10/";
    [self.navigationController pushViewController:web animated:YES];
}

-(void)firstLoadDataWithUrl:(NSString*)url
{
    [self.dataSource removeAllObjects];
    NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
    NSArray *array = [xpathparser searchWithXPathQuery:self.XPathString];
    NSMutableArray* mArray = [array mutableCopy];
    [mArray removeObjectAtIndex:0];
    array = mArray;
    [self.dataSource addObjectsFromArray:array];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView.mj_header endRefreshing];
        [self.tableView reloadData];
    });
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
    if (time > 0) {
        timeout = time;
    }
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.timer= dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1*NSEC_PER_SEC, 0); //每秒执行
    dispatch_source_set_event_handler(_timer, ^{
        if(timeout==0){ //倒计时结束，关闭
            timeout = 60*4;
            dispatch_async(dispatch_get_main_queue(), ^{
                //设置界面的按钮显示 根据自己需求设置
                @strongify(self);
                self.navigationItem.title = @"开奖中...";
                dispatch_suspend(self.timer);
                [self beginPlay];
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
    [self.loadingWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://i.api.1396.me/mobile/pk10/"]]];
    [UIView animateWithDuration:.25 animations:^{
        self.loadingWebView.frame = CGRectMake(0, 0, self.loadingWebView.bounds.size.width, self.loadingWebView.bounds.size.height);
    }];
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(60 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self endPlay];
    });
}

-(void)endPlay
{
    [UIView animateWithDuration:.25 animations:^{
        self.loadingWebView.frame = CGRectMake(0, 0-self.loadingWebView.bounds.size.height-100, self.loadingWebView.bounds.size.width, self.loadingWebView.bounds.size.height);
    }];
    [self.loadingWebView stopLoading];
    [self.tableView.mj_header beginRefreshing];
    dispatch_resume(self.timer);
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
        m = .5;
    }else {
        m = 6 - minite;
    }
    
    time = m*60 + 60 - [self secondForDateString:dateString];;
    
    return time;
}

-(void)appendData
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.page+=1;
        NSString* url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,(long)self.page,self.endString];
        NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
        NSArray *array = [xpathparser searchWithXPathQuery:self.XPathString];
        if (array.count == 0) {
            [self appendData];
            return;
        }
        
        NSMutableArray* mArray = [array mutableCopy];
        [mArray removeObjectAtIndex:0];
        array = mArray;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_footer endRefreshing];
            
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (NSInteger i = self.dataSource.count ; i < array.count + self.dataSource.count ; i++) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.dataSource addObjectsFromArray:array];
            [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            
        });
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
    return 55;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PK10TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PK10TableViewCell" forIndexPath:indexPath];
    
    TFHppleElement* element = self.dataSource[indexPath.row];
    
    
    NSArray* tds = [element childrenWithTagName:@"td"];
    
    TFHppleElement* first = [[tds firstObject] firstChild];
    TFHppleElement* second = [[tds objectAtIndex:1] firstChild];
    TFHppleElement* last = [[tds lastObject] firstChild];
    
    cell.time = [last content];
    cell.flag = [[first content] integerValue];
    cell.numbers = (id)[second content];
    
    return cell;
}

@end
