//
//  MCDownloadOperation.h
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^MCDownloadOperationBlock)(NSData* data);

@interface MCDownloadOperation : NSOperation

-(instancetype)initWithUrl:(NSString*)url callback:(MCDownloadOperationBlock)callback withObject:(id)obj;

@end
