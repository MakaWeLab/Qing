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

@interface MCGameCountViewController ()

@property (nonatomic,strong) NSMutableArray* dataSource;

@property (nonatomic,strong) NSString* XPathString;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSString* beginString;

@property (nonatomic,strong) NSString* endString;

@property (nonatomic,assign) NSInteger startCount;

@end

@implementation MCGameCountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"PK10TableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"PK10TableViewCell"];
    
    self.navigationItem.title = @"PK10";
    
    @weakify(self);
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self appendData];
    }];
    
    self.dataSource = [NSMutableArray array];
    
    NSString* url = @"";
    self.XPathString = @"//table[@class='tb']//tr";
    self.page = 1;
    self.beginString = @"http://www.bwlc.net/bulletin/trax.html?page=";
    self.endString = @"";
    self.startCount = 50;
    url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,(long)self.page,self.endString];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self firstLoadDataWithUrl:url];
    });
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
    if (self.page > self.startCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }else {
        [self appendData];
    }
}

-(void)refreshLastData
{
    
}

-(void)appendData
{
    @weakify (self);
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
        
        if(self.page < self.startCount)
        {
            [self.dataSource addObjectsFromArray:mArray];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.navigationItem.title = [NSString stringWithFormat:@"%ld/%ld(%lu)",(long)self.page ,(long)self.startCount,(unsigned long)self.dataSource.count];
            });
            @strongify(self);
            [self appendData];
            return;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self.tableView.mj_footer endRefreshing];
            
            NSMutableArray* indexPaths = [NSMutableArray array];
            for (NSInteger i = self.dataSource.count ; i < array.count + self.dataSource.count ; i++) {
                NSIndexPath* indexPath = [NSIndexPath indexPathForRow:i inSection:0];
                [indexPaths addObject:indexPath];
            }
            [self.dataSource addObjectsFromArray:array];
            if (self.page == self.startCount) {
                [self.tableView reloadData];
            }else {
                [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
            }
            
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
    return 30;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    PK10TableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"PK10TableViewCell" forIndexPath:indexPath];
    
    TFHppleElement* element = self.dataSource[indexPath.row];
    
    
    NSArray* tds = [element childrenWithTagName:@"td"];
    
    TFHppleElement* first = [[tds firstObject] firstChild];
    TFHppleElement* second = [[tds objectAtIndex:1] firstChild];
    TFHppleElement* last = [[tds lastObject] firstChild];
    
    cell.flag = [[first content] integerValue];
    cell.numbers = (id)[second content];
    
    return cell;
}

@end
