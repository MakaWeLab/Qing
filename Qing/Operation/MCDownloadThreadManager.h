//
//  MCDownloadThreadManager.h
//  Qing
//
//  Created by Maka on 23/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"


#define kProgressBlockKey @"kProgressBlockKey"

#define kCompleteBlockKey @"kCompleteBlockKey"

@interface MCDownloadThreadManager : NSObject

//下载任务队列 为了防止并发请求产生太多子线程
@property (nonatomic,strong) NSOperationQueue* downloadQueue;

//单线程执行队列
@property (nonatomic,strong) dispatch_queue_t serialQueue;

//每个url对应一串callback
@property (nonatomic,strong) NSMutableDictionary* callbacksDictionary;

+(instancetype)shareManager;

-(MCDownloadOperation*)appendDownloadOperationForURL:(NSString*)url;

@end
