//
//  GameProtocol.h
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#ifndef GameProtocol_h
#define GameProtocol_h
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^GameDownloadManagerProgress)(CGFloat progress);

typedef void(^GameDownloadManagerComplete)(BOOL isSuccess);

@protocol GameProtocol <NSObject>

@property (nonatomic,strong) NSMutableArray* dataList;

@property (nonatomic,copy) GameDownloadManagerProgress progress;

@property (nonatomic,copy) GameDownloadManagerComplete complete;

+(instancetype)shareInstance;

-(void)refreshLaterestDatabase;

@end

@protocol GameDataModelProtocol <NSObject,NSCoding>

@property (nonatomic,strong) NSString* title;

@property (nonatomic,strong) NSString* time;

@property (nonatomic,strong) NSArray* results;

@end

#endif /* GameProtocol_h */
