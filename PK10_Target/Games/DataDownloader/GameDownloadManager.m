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

typedef void(^getLaterestCallback)(NSArray* array);

@implementation GameDownloadManager

@synthesize dataList,progress,complete;

-(NSString*)saveFilePath
{
    NSString* string = [NSSearchPathForDirectoriesInDomains(NSDocumentationDirectory, NSUserDomainMask, YES) firstObject];
    return [string stringByAppendingString:self.cacheFileName];
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

-(instancetype)init
{
    if (self = [super init]) {
        self.dataList = [NSKeyedUnarchiver unarchiveObjectWithFile:[[self class] saveFilePath]];
        if (!self.dataList) {
            self.dataList = [NSMutableArray array];
        }
    }
    return self;
}

-(void)setCacheFileName:(NSString *)cacheFileName
{
    _cacheFileName = cacheFileName;
    if (!self.serialQueue) {
        self.serialQueue = dispatch_queue_create([cacheFileName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
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
}

-(void)downloadLaterestData
{
    @weakify(self);
    NSInteger TargetFlag = [[self.dataList.firstObject title] integerValue];
    [self getLaterestDataWithCallback:^(NSArray *array) {
        @strongify(self);
        NSInteger sourceFlag = [[array.firstObject title] integerValue];
        self.total = [self getDownloadCountForSourceFlag:sourceFlag TargetFlag:TargetFlag];
        
    }];
}

-(NSInteger)getDownloadCountForSourceFlag:(NSInteger)sourceFlag TargetFlag:(NSInteger)targetFlag
{
    NSInteger count = sourceFlag - targetFlag;
    NSInteger number = count/30 + 1;
    if (number > 100) {
        number = 100;
    }
    return number-1;
}

-(void)appendData
{
    if (self.total == 0) {
        if (self.complete) {
            self.complete(YES);
        }
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
        
        
        self.current += 1;
        if (self.progress) {
            self.progress(self.current/(CGFloat)self.total);
        }
        
        if (self.current < self.total) {
            [self appendData];
        }else {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.dataList];
            [data writeToFile:[[self class] saveFilePath] atomically:YES];
            if (self.complete) {
                self.complete(YES);
            }
        }
        
    });
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
