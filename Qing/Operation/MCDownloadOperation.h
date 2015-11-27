//
//  MCDownloadOperation.h
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadUtil.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^MCDownloadCompleteBlock)(BOOL isSuccess , NSData* data);

typedef void(^MCDownloadProgressBlock)(NSData* receivedData , CGFloat progress);

@interface MCDownloadOperation : NSOperation

@property (nonatomic,weak) id tag;

@property (nonatomic,strong) NSString* url;

- (id)initWithUrl:(NSString *)url;

@end
