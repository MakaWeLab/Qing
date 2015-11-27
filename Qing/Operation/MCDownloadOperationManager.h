//
//  MCDownloadOperationManager.h
//  Qing
//
//  Created by Maka on 27/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"

@interface MCDownloadOperationManager : NSObject

+(instancetype)shareInstance;


//url为key operation为value 一对一
@property (nonatomic,strong) NSMutableDictionary* operationDictionary;

-(void)startDownloadOperation:(MCDownloadOperation*)operation forUrl:(NSString*)url;

-(void)cancelDownloadOperationForUrl:(NSString*)url;

@end
