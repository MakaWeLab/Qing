//
//  PK10DownloadManager.m
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "GameDownloadManager.h"
#import "TFHpple.h"
#import <ReactiveCocoa.h>
#import <objc/runtime.h>

typedef void(^getLaterestCallback)(NSArray* array);

@implementation GameDownloadManager

@synthesize dataList,progress,complete;

-(NSString*)cacheFileName
{
    return [self.configInfo objectForKey:@"cacheFileName"];
}

-(NSString*)saveFilePath
{
    NSString* string = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    return [string stringByAppendingString:[self cacheFileName]];
}

+(instancetype)shareInstance
{
    static GameDownloadManager* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[GameDownloadManager alloc]init];
    });
    return manager;
}

-(void)setConfigInfo:(NSDictionary *)configInfo
{
    if (_configInfo == configInfo) {
        return;
    }
    _configInfo = configInfo;
    if (!self.dataList) {
        self.dataList = [NSKeyedUnarchiver unarchiveObjectWithFile:[self saveFilePath]];
        if (!self.dataList) {
            self.dataList = [NSMutableArray array];
        }
    }
}

-(void)refreshLaterestDatabase
{
    if (self.isDownloading) {
        return;
    }
    self.isDownloading = YES;
    if (self.dataList.count == 0) {
        [self firstDownloadDataFromNetWork];
    }else {
        [self downloadLaterestData];
    }
}

-(void)firstDownloadDataFromNetWork
{
    self.total = 100;
    @weakify(self);
    [self getLaterestDataWithCallback:^(NSArray *array) {
        @strongify(self);
        [self insertArrayAtTop:array];
        self.downloadThread = [NSThread currentThread];
        self.current = 1;
        [self appendData];
    }];
}

-(void)downloadLaterestData
{
    @weakify(self);
    NSInteger TargetFlag = [self.dataList.firstObject index];
    [self getLaterestDataWithCallback:^(NSArray *array) {
        @strongify(self);
        [self insertArrayAtTop:array];
        self.downloadThread = [NSThread currentThread];
        NSInteger sourceFlag = [self.dataList.firstObject index];
        self.total = [self getDownloadCountForSourceFlag:sourceFlag TargetFlag:TargetFlag];
        self.current = 1;
        [self appendData];
    }];
}

-(void)insertArrayAtTop:(NSArray*)array
{
    NSArray* results = [self parseSourceArray:array];
    
    NSInteger beginFlag = 0;
    NSInteger endFlag = 0;
    if (self.dataList.count > 0) {
        id<GameDataModelProtocol> model = self.dataList.firstObject;
        beginFlag = model.index;
        model = self.dataList.lastObject;
        endFlag = model.index;
        
        for (NSInteger i = results.count-1; i>=0; i--) {
            id<GameDataModelProtocol> model = results[i];
            if (model.index > beginFlag) {
                [self.dataList insertObject:model atIndex:0];
            }else if (model.index < endFlag) {
                model = results[results.count - i - 1];
                [self.dataList addObject:model];
            }
        }
    }else {
        [self.dataList addObjectsFromArray:results];
    }
    
}

-(NSInteger)getDownloadCountForSourceFlag:(NSInteger)sourceFlag TargetFlag:(NSInteger)targetFlag
{
    NSInteger count = sourceFlag - targetFlag;
    NSInteger number = count/30 + 1;
    if (number > 100) {
        number = 100;
    }
    return number;
}

-(NSString*)beginString
{
    return [self.configInfo objectForKey:@"beginString"];
}

-(NSInteger)page
{
    return [[self.configInfo objectForKey:@"page"] integerValue];
}

-(NSString*)endString
{
    return [self.configInfo objectForKey:@"endString"];
}

-(NSString*)XPathString
{
    return [self.configInfo objectForKey:@"XPathString"];
}

-(void)appendData
{
    if (self.current >= self.total) {
        self.isDownloading = NO;
        if (self.complete) {
            self.complete(YES);
        }
        return;
    }
    NSString* url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,(long)self.current+1,self.endString];
    NSData *htmlData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    TFHpple *xpathparser = [[TFHpple alloc]initWithHTMLData:htmlData];
    NSArray *array = [xpathparser searchWithXPathQuery:self.XPathString];
    if (array.count == 0) {
        self.isDownloading = NO;
        if (self.complete) {
            self.complete(YES);
        }
        return;
    }
    
    NSMutableArray* mArray = [array mutableCopy];
    [mArray removeObjectAtIndex:0];
    array = mArray;
    
    [self insertArrayAtTop:array];
    
    
    self.current += 1;
    if (self.progress) {
        self.progress(self.current/(CGFloat)self.total);
    }
    
    if (self.current < self.total) {
        [self appendData];
    }else {
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dataList];
        [data writeToFile:[self saveFilePath] atomically:YES];
        if (self.complete) {
            self.complete(YES);
        }
    }
}

-(NSString*)modelClassName
{
    return [self.configInfo objectForKey:@"DataModel"];
}

-(NSArray*)parseSourceArray:(NSArray*)sourceArray
{
    NSMutableArray* mArray = [NSMutableArray array];
    for (TFHppleElement* element in sourceArray) {
        
        NSArray* tds = [element childrenWithTagName:@"td"];
        
        TFHppleElement* first = [[tds firstObject] firstChild];
        TFHppleElement* second = [[tds objectAtIndex:1] firstChild];
        TFHppleElement* last = [[tds lastObject] firstChild];
        
        id<GameDataModelProtocol> model = [[NSClassFromString(self.modelClassName) alloc] init];
        model.time = [last content];
        model.title = [first content];
        model.index = [[first content] integerValue];
        model.results = [(NSString*)[second content] componentsSeparatedByString:@","];
        [mArray addObject:model];
    }
    return [mArray copy];
}

#pragma mark - getData

-(void)getLaterestDataWithCallback:(getLaterestCallback)callback
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString* url = [NSString stringWithFormat:@"%@%ld%@",self.beginString,(long)self.page,self.endString];
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
