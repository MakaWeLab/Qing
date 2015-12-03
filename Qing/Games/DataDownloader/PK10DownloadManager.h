//
//  PK10DownloadManager.h
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PK10DownloadManager : NSObject

@property (nonatomic,strong) NSMutableArray* dataList;

+(instancetype)shareInstance;

-(void)refreshLaterestDataListWithCount:(NSInteger)count;

-(void)checkAndDownloadNewData;

@end
