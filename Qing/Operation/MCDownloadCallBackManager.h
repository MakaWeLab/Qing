//
//  MCDownloadCallBackManager.h
//  Qing
//
//  Created by Maka on 27/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"

#define kMCDownloadCallBackProgressKey @"kMCDownloadCallBackProgressKey"

#define kMCDownloadCallBackCompleteKey @"kMCDownloadCallBackCompleteKey"

#define kMCDownloadDictionaryTagKey @"kMCDownloadDictionaryTagKey"

@interface MCDownloadCallBackManager : NSObject

+(instancetype)shareInstance;


//url作为key Dictionary数组作为value

//每个Dictionary包含一串callback

@property (nonatomic,strong) NSMutableDictionary* callbackDic;

//移除标记有指定tag对象的callback
-(void)removeCallbackForUrl:(NSString *)url withTag:(id)tag;

-(NSDictionary*)getCallbackForUrl:(NSString*)url withTag:(id)tag;

//添加一个callBack对象 针对指定的url
-(void)addCallbackWithProgressBlock:(MCDownloadProgressBlock)progressBlock completeBlock:(MCDownloadCompleteBlock)completeBlock forUrl:(NSString*)url withTag:(id)tag;

@end
