//
//  PK10DownloadManager.h
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameProtocol.h"
#import <Foundation/Foundation.h>

@interface GameDownloadManager : NSObject<GameProtocol>

@property (nonatomic,assign) NSInteger total;

@property (nonatomic,assign) NSInteger current;

//@property (nonatomic,strong) NSString* XPathString;
//
//@property (nonatomic,assign) NSInteger page;
//
//@property (nonatomic,strong) NSString* beginString;
//
//@property (nonatomic,strong) NSString* endString;
//
//@property (nonatomic,strong) NSString* cacheFileName;

@property (nonatomic,assign) BOOL isDownloading;

@property (nonatomic,strong) NSDictionary* configInfo;

@property (nonatomic,strong) NSThread* downloadThread;

@end
