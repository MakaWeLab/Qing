//
//  NSOject+MCDownload.h
//  Qing
//
//  Created by Maka on 15/11/23.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MCDownloadOperation.h"

@interface NSObject(MCDownload)

//每个对象只能对应一个url 同时也只能对应一个operation
@property (nonatomic,copy) NSString* downloadURL;

@property (nonatomic,strong) MCDownloadOperation* downloadOperation;

@end
