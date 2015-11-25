//
//  MCDownloadCache.h
//  Qing
//
//  Created by Maka on 23/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface MCDownloadCache : NSObject


+(instancetype)shareCache;


//同时存到内存和硬盘
-(void)storeData:(NSData*)data forKey:(NSString*)key;


//先存内存中读取 如果内存中不存在 那么从硬盘中读取并缓存到内存中
-(NSData*)dataForKey:(NSString*)key;


@end
