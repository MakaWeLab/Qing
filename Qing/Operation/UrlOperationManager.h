//
//  UrlOperationManager.h
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"

@interface UrlOperationManager : NSObject

@property (nonatomic,strong) NSMutableArray* allUrls;

@property (nonatomic,strong) NSMutableDictionary* keyValueDictionary;

@property (nonatomic,strong) NSMutableDictionary* callbackDictionary;

@property (nonatomic,strong) NSMutableArray* callBackObservers;

@property (nonatomic,strong) NSMutableDictionary* callBackObserverKeyValueDictionary;

+(instancetype)shareInstance;

-(BOOL)isDownloadOperationExistForUrl:(NSString*)url;

-(void)downLoadCompleteForUrl:(NSString*)url withData:(NSData*)data;

-(void)registCallbackForUrlDownloadComplete:(NSString*)url withObject:(id)obj callBack:(MCDownloadOperationBlock)callback;

@end
