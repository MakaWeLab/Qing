//
//  PK10DownloadManager.m
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10DownloadManager.h"
#import "PK10DataModel.h"
#import "TFHpple.h"
#import <ReactiveCocoa.h>

typedef void(^getLaterestCallback)(NSArray* array);

@interface PK10DownloadManager ()

@property (nonatomic,strong) NSString* XPathString;

@property (nonatomic,assign) NSInteger page;

@property (nonatomic,strong) NSString* beginString;

@property (nonatomic,strong) NSString* endString;

@property (nonatomic,assign) NSInteger needDownloadCount;

@end

@implementation PK10DownloadManager

+(NSString*)saveFilePath
{
    NSString* string = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    return [string stringByAppendingString:@"PK10"];
}

+(instancetype)shareInstance
{
    static PK10DownloadManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PK10DownloadManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.dataList = [[NSMutableArray alloc]initWithContentsOfFile:[[self class] saveFilePath]];
        if (!self.dataList) {
            self.dataList = [NSMutableArray array];
            self.XPathString = @"//table[@class='tb']//tr";
            self.page = 1;
            self.beginString = @"http://www.bwlc.net/bulletin/trax.html?page=";
            self.endString = @"";
        }
    }
    return self;
}

-(void)refreshLaterestDataListWithCount:(NSInteger)count
{
    NSInteger laterestFlag = 0;
    if (self.dataList.count > 0) {
        PK10DataModel* model = self.dataList.firstObject;
        laterestFlag = model.flag;
    }
    @weakify(self);
    [self getLaterestDataWithCallback:^(NSArray *array) {
        @strongify(self);
        if (array.count > 0) {
            NSArray* arr = [self parseSourceArray:array];
            PK10DataModel* first = arr.firstObject;
            [self downloadWithSourceFlag:first.flag TargetFlag:laterestFlag];
            [self insertArray:arr];
        }
    }];
}

-(void)downloadWithSourceFlag:(NSInteger)sourceFlag TargetFlag:(NSInteger)targetFlag
{
    NSInteger count = sourceFlag - targetFlag;
    NSInteger number = count/30 + 1;
    if (number > 100) {
        number = 100;
    }
    self.needDownloadCount = number - 1;
    [self appendData];
}
-(void)appendData
{
    if (self.needDownloadCount == 0) {
        return;
    }
    @weakify(self);
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
        
        @strongify(self);
        
        NSArray* arr = [self parseSourceArray:array];
        [self insertArray:arr];
        
        self.needDownloadCount -= 1;
        
        if (self.needDownloadCount > 0) {
            [self appendData];
        }else {
            
        }
        
    });
}

-(void)insertArray:(NSArray*)array
{
    NSInteger beginFlag = 0;
    NSInteger endFlag = 0;
    if (self.dataList.count > 0) {
        PK10DataModel* model = self.dataList.firstObject;
        beginFlag = model.flag;
        model = self.dataList.lastObject;
        endFlag = model.flag;
    }
    
    for (PK10DataModel* model in array) {
        if (model.flag > beginFlag) {
            [self.dataList insertObject:model atIndex:0];
        }else if (model.flag < endFlag) {
            [self.dataList addObject:model];
        }
    }
}

-(NSArray*)parseSourceArray:(NSArray*)sourceArray
{
    NSMutableArray* mArray = [NSMutableArray array];
    for (TFHppleElement* element in sourceArray) {
        
        NSArray* tds = [element childrenWithTagName:@"td"];
        
        TFHppleElement* first = [[tds firstObject] firstChild];
        TFHppleElement* second = [[tds objectAtIndex:1] firstChild];
        TFHppleElement* last = [[tds lastObject] firstChild];
        
        PK10DataModel* model = [[PK10DataModel alloc]init];
        model.time = [last content];
        model.flag = [[first content] integerValue];
        model.numbers = [(NSString*)[second content] componentsSeparatedByString:@","];
        [mArray addObject:model];
    }
    return [mArray copy];
}

#pragma mark - getData

-(void)getLaterestDataWithCallback:(getLaterestCallback)callback
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,self.page,self.endString];
        NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
        TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
        NSArray *array = [xpathparser searchWithXPathQuery:self.XPathString];
        NSMutableArray* mArray = [array mutableCopy];
        [mArray removeObjectAtIndex:0];
        array = mArray;
        callback(array);
    });
}

@end
