//
//  PK10DownloadManager.h
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^PK10DownloadManagerProgress)(CGFloat progress);

typedef void(^PK10DownloadManagerComplete)(BOOL isSuccess);

@interface PK10DownloadManager : NSObject

@property (nonatomic,strong) NSMutableArray* dataList;

@property (nonatomic,copy) PK10DownloadManagerProgress progress;

@property (nonatomic,copy) PK10DownloadManagerComplete complete;

+(instancetype)shareInstance;

-(void)refreshLaterestDatabase;

@end
