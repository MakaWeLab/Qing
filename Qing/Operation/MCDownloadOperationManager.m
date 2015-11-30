//
//  MCDownloadOperationManager.m
//  Qing
//
//  Created by Maka on 27/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadOperationManager.h"

@implementation MCDownloadOperationManager

+(instancetype)shareInstance
{
    static MCDownloadOperationManager* shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[MCDownloadOperationManager alloc]init];
    });
    return shareManager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.operationDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

-(void)startDownloadOperation:(MCDownloadOperation*)operation forUrl:(NSString*)url
{
    NSLog(@"%@ %@,%s",self,[NSThread currentThread],__func__);
    [self.operationDictionary setObject:operation forKey:url];
}

-(void)cancelDownloadOperationForUrl:(NSString*)url
{
    NSLog(@"%@ %@,%s",self,[NSThread currentThread],__func__);
    [self.operationDictionary removeObjectForKey:url];
}

@end
