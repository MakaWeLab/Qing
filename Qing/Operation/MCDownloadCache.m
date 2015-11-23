//
//  MCDownloadCache.m
//  Qing
//
//  Created by Maka on 23/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//


#import "MCDownloadUtil.h"
#import "MCDownloadCache.h"

static const NSInteger kDefaultCacheMaxCacheAge = 60 * 60 * 24 * 7; // 1 week

@interface AutoPurgeCache : NSCache
@end

@implementation AutoPurgeCache

- (id)init
{
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removeAllObjects) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

@end


@interface MCDownloadCache ()

@property (nonatomic,strong) AutoPurgeCache* memoryCache;

@property (nonatomic,strong) NSMutableArray* finishURLs;

@end

@implementation MCDownloadCache

+(instancetype)shareCache
{
    static id cache =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [MCDownloadCache new];
    });
    return cache;
}

-(instancetype)init
{
    if (self = [super init]) {
        self.memoryCache = [AutoPurgeCache new];
        self.finishURLs = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(clearMemory)
                                                     name:UIApplicationDidReceiveMemoryWarningNotification
                                                   object:nil];
    }
    return self;
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)clearMemory
{
    [self.memoryCache removeAllObjects];
}

-(void)storeData:(NSData *)data forKey:(NSString *)key
{
    if (!data) {
        return;
    }
//    for (NSString* str in self.finishURLs) {
//        if ([str isEqualToString:key]) {
//            return;
//        }
//    }
    
    NSUInteger cost = data.length;
    [self.memoryCache setObject:data forKey:key cost:cost];
    NSString* path = [self cacheFilePathForKey:key];
//    [data writeToFile:path atomically:YES];
    [self.finishURLs addObject:key];
}

-(NSData*)dataForKey:(NSString *)key
{
    NSData* data = [self.memoryCache objectForKey:key];
    if (data) {
        return data;
    }
    NSString* path = [self cacheFilePathForKey:key];
    data = [NSData dataWithContentsOfFile:path];
    return data;
}

#pragma mark - property

- (void)setMaxMemoryCost:(NSUInteger)maxMemoryCost {
    self.memoryCache.totalCostLimit = maxMemoryCost;
}

- (NSUInteger)maxMemoryCost {
    return self.memoryCache.totalCostLimit;
}

- (NSUInteger)maxMemoryCountLimit {
    return self.memoryCache.countLimit;
}

- (void)setMaxMemoryCountLimit:(NSUInteger)maxCountLimit {
    self.memoryCache.countLimit = maxCountLimit;
}

#pragma mark - FileOperation
-(NSString*)cachedFileFolderPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches/MCDownloadFileCache/"];
}

-(NSString*)cacheFilePathForKey:(NSString*)key
{
    NSString* folder = [self cachedFileFolderPath];
    return [NSString stringWithFormat:@"%@%@",folder,[MCDownloadUtil cachedFileNameForKey:key]];
}

@end
