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

@property (nonatomic,strong) NSMutableArray* runningOperations;

//每个url对应一串callback
@property (nonatomic,strong) NSMutableDictionary* callbacksDictionary;

+(instancetype)shareManager;

-(MCDownloadOperation*)createOperationForURL:(NSString*)url;

@end
