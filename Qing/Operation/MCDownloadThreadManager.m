//
//  MCDownloadThreadManager.m
//  Qing
//
//  Created by Maka on 23/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadThreadManager.h"
#import "MCDownloadCache.h"

@implementation MCDownloadThreadManager

+(instancetype)shareManager
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[MCDownloadThreadManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.runningOperations = [NSMutableArray array];
        self.callbacksDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

-(MCDownloadOperation*)createOperationForURL:(NSString *)url
{
    NSData* data = [[MCDownloadCache shareCache] dataForKey:url];
    if ( data ) {
        MCDownloadCompleteBlock completionBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:url] objectForKey:kCompleteBlockKey];
        if (completionBlock) {
            completionBlock(data);
        }
        return nil;
    }
    __block MCDownloadOperation* operation = [[MCDownloadOperation alloc]initWithRequestURL:url];
    MCDownloadThreadManager* shareManager = [MCDownloadThreadManager shareManager];
    @synchronized(shareManager.runningOperations) {
        [shareManager.runningOperations addObject:operation];
    }
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [operation start];
    });
    return operation;
}

@end
