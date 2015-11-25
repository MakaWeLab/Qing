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
static const NSInteger kDefaultCacheMaxCacheSize = 1024 * 1024;
static const NSInteger kDefaultCacheMaxCacheCount = 1024;

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
        self.memoryCache.totalCostLimit = kDefaultCacheMaxCacheSize;
        self.memoryCache.countLimit = kDefaultCacheMaxCacheCount;
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
    NSUInteger cost = data.length;
    [self.memoryCache setObject:data forKey:key cost:cost];
    NSString* path = [self cacheFilePathForKey:key];
    [data writeToFile:path atomically:YES];
}

-(NSData*)dataForKey:(NSString *)key
{
    NSData* data = [self.memoryCache objectForKey:key];
    if (data) {
        return data;
    }
    NSString* path = [self cacheFilePathForKey:key];
    data = [NSData dataWithContentsOfFile:path];
    if (data) {
        [self.memoryCache setObject:data forKey:key];
    }
    return data;
}


#pragma mark - FileOperation
-(NSString*)cachedFileFolderPath
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString* folder = [[paths objectAtIndex:0] stringByAppendingFormat:@"/Caches/MCDownloadFileCache/"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:folder]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return folder;
}

-(NSString*)cacheFilePathForKey:(NSString*)key
{
    NSString* folder = [self cachedFileFolderPath];
    return [NSString stringWithFormat:@"%@%@",folder,[MCDownloadUtil cachedFileNameForKey:key]];
}

@end
