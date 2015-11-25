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
        self.callbacksDictionary = [NSMutableDictionary dictionary];
        self.downloadQueue = [[NSOperationQueue alloc]init];
        self.downloadQueue.maxConcurrentOperationCount = 5;
        self.serialQueue = dispatch_queue_create("MCDownloadThreadManagerSerialQueue", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(MCDownloadOperation*)appendDownloadOperationForURL:(NSString *)url
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
//    [self.downloadQueue addOperation:operation];
    
    dispatch_async(self.serialQueue, ^{
        [operation start];
    });
    return operation;
}

@end
