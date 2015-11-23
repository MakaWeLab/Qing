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

/**
 * The maximum "total cost" of the in-memory image cache. The cost function is the number of pixels held in memory.
 */
@property (assign, nonatomic) NSUInteger maxMemoryCost;

/**
 * The maximum number of objects the cache should hold.
 */
@property (assign, nonatomic) NSUInteger maxMemoryCountLimit;

/**
 * The maximum length of time to keep an image in the cache, in seconds
 */
@property (assign, nonatomic) NSInteger maxCacheAge;

/**
 * The maximum size of the cache, in bytes.
 */
@property (assign, nonatomic) NSUInteger maxCacheSize;


+(instancetype)shareCache;


//同时存到内存和硬盘
-(void)storeData:(NSData*)data forKey:(NSString*)key;


//先存内存中读取 如果内存中不存在 那么从硬盘中读取并缓存到内存中
-(NSData*)dataForKey:(NSString*)key;

@end
