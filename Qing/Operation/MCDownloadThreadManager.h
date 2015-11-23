//
//  MCDownloadThreadManager.h
//  Qing
//
//  Created by Maka on 23/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"

@interface MCDownloadThreadManager : NSObject

@property (nonatomic,strong) NSMutableArray* runningOperations;

+(instancetype)shareManager;

-(MCDownloadOperation*)createOperationForURL:(NSString*)url progress:(MCDownloadProgressBlock)progressBlock completed:(MCDownloadCompleteBlock)completedBlock;

@end
