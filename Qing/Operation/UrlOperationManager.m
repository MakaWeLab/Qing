//
//  UrlOperationManager.m
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "UrlOperationManager.h"

@implementation UrlOperationManager

+(instancetype)shareInstance
{
    static UrlOperationManager* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[UrlOperationManager alloc]init];
    });
    return manager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.allUrls = [NSMutableArray array];
        self.keyValueDictionary = [NSMutableDictionary dictionary];
        self.callbackDictionary = [NSMutableDictionary dictionary];
        self.callBackObservers = [NSMutableArray array];
        self.callBackObserverKeyValueDictionary = [NSMutableDictionary dictionary];
    }
    return self;
}

-(BOOL)isDownloadOperationExistForUrl:(NSString *)url
{
    return [self.allUrls containsObject:url];
}

-(void)downLoadCompleteForUrl:(NSString *)url withData:(NSData *)data
{
    id value = [self.callbackDictionary objectForKey:url];
    if (!value) {
        return;
    }
    if ([value isKindOfClass:[NSArray class]]) {
        for (MCDownloadOperationBlock callback in value) {
            callback(data);
        }
    }
}

-(void)registCallbackForUrlDownloadComplete:(NSString *)url withObject:(id)obj callBack:(MCDownloadOperationBlock)callback
{
    
    if ([self.callBackObservers containsObject:obj]) {
        MCDownloadOperationBlock c = [self.callBackObserverKeyValueDictionary objectForKey:obj];
        NSMutableArray* mArray = [self.callbackDictionary objectForKey:url];
        [mArray removeObject:c];
    }else {
        [self.callBackObservers addObject:obj];
    }
    [self.callBackObserverKeyValueDictionary setObject:callback forKey:obj];
    
    id value = [self.callbackDictionary objectForKey:url];
    NSMutableArray* mArray = value;
    if (!value) {
        mArray = [NSMutableArray array];
    }
    [mArray addObject:callback];
    [self.callbackDictionary setObject:mArray forKey:url];
}

@end
