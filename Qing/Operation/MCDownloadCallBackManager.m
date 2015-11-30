//
//  MCDownloadCallBackManager.m
//  Qing
//
//  Created by Maka on 27/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadCallBackManager.h"

@implementation MCDownloadCallBackManager

+(instancetype)shareInstance
{
    static MCDownloadCallBackManager* shareManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[MCDownloadCallBackManager alloc]init];
    });
    return shareManager;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.callbackDic = [NSMutableDictionary dictionary];
    }
    return self;
}


//移除标记有指定tag对象的callback
-(void)removeCallbackForUrl:(NSString *)url withTag:(id)tag
{
    NSMutableArray* mArray = [self.callbackDic objectForKey:url];
    if (mArray) {
        for (NSDictionary* dic in mArray) {
            id t = [dic objectForKey:kMCDownloadDictionaryTagKey];
            if (t == tag) {
                [mArray removeObject:dic];
                return;
            }
        }
    }
}

-(NSDictionary*)getCallbackForUrl:(NSString *)url withTag:(id)tag
{
    @synchronized(self) {
        NSLog(@"%@,%@,%s",self,[NSThread currentThread],__func__);
        NSMutableArray* mArray = [self.callbackDic objectForKey:url];
        if (mArray) {
            for (NSDictionary* dic in mArray) {
                id t = [dic objectForKey:kMCDownloadDictionaryTagKey];
                if (t == tag) {
                    NSLog(@"%@,%@,%s_finish",self,[NSThread currentThread],__func__);
                    return dic;
                }
            }
        }
        return nil;
    }
}

//添加一个callBack对象 针对指定的url

-(void)addCallbackWithProgressBlock:(MCDownloadProgressBlock)progressBlock completeBlock:(MCDownloadCompleteBlock)completeBlock forUrl:(NSString*)url withTag:(id)tag{
    @synchronized(self) {
        NSLog(@"%@,%@,%s",self,[NSThread currentThread],__func__);
        NSMutableArray* mArray = [self.callbackDic objectForKey:url];
        if (!mArray) {
            mArray = [NSMutableArray array];
            [self.callbackDic setObject:mArray forKey:url];
        }
        NSMutableDictionary* mDic = [NSMutableDictionary dictionary];
        if (tag) {
            [mDic setObject:tag forKey:kMCDownloadDictionaryTagKey];
        }
        if (progressBlock) {
            [mDic setObject:[progressBlock copy] forKey:kMCDownloadCallBackProgressKey];
        }
        if (completeBlock) {
            [mDic setObject:[completeBlock copy] forKey:kMCDownloadCallBackCompleteKey];
        }
        [mArray addObject:mDic];
        NSLog(@"%@,%@,%s_finish",self,[NSThread currentThread],__func__);
    }
}

@end
