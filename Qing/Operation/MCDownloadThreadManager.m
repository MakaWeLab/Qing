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
    }
    return self;
}

-(MCDownloadOperation*)createOperationForURL:(NSString *)url progress:(MCDownloadProgressBlock)progressBlock completed:(MCDownloadCompleteBlock)completedBlock
{
    NSData* data = [[MCDownloadCache shareCache] dataForKey:url];
    if ( data ) {
        completedBlock(data);
        return nil;
    }
    __block MCDownloadOperation* operation = [[MCDownloadOperation alloc]initWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]] progress:progressBlock completed:completedBlock];
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
