//
//  MCDownloadOperation.m
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadOperation.h"
#import "MCDownloadCache.h"
#import "MCDownloadThreadManager.h"

@interface MCDownloadOperation ()

@property (assign, nonatomic) NSInteger expectedSize;

@property (nonatomic,assign,readwrite) BOOL finished;

@property (nonatomic,assign,readwrite) BOOL executing;

@property (nonatomic,strong) NSURLRequest* request;

@property (strong, nonatomic) NSMutableData *mData;

@property (strong, nonatomic) NSURLConnection *connection;

@property (strong, atomic) NSThread *thread;

@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;

@end

@implementation MCDownloadOperation{
    BOOL responseFromCached;
}
@synthesize finished,executing;

-(id)initWithRequestURL:(NSString *)url
{
    if ((self = [super init])) {
        _url = url;
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        _expectedSize = 0;
        _shouldContinueWhenAppEntersBackground = YES;
        responseFromCached = YES;
    }
    return self;
}

- (void)start {
    @synchronized (self) {
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }
        if (self.shouldContinueWhenAppEntersBackground) {
            __weak __typeof__ (self) wself = self;
            UIApplication * app = [UIApplication sharedApplication];
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;
                if (sself) {
                    [sself cancel];
                    [app endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
        self.executing = YES;
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        self.thread = [NSThread currentThread];
    }
    
    [self.connection start];
    
    if (self.connection) {
        
        CFRunLoopRun();
        
        if (!self.isFinished) {
            [self.connection cancel];
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
        }
    }
    
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication sharedApplication];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
}

- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:NO];
        }
        else {
            [self cancelInternal];
        }
    }
}

- (void)cancelInternalAndStop {
    if (self.isFinished) return;
    [self cancelInternal];
    //    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    if (self.isFinished) return;
    [super cancel];
    
    if (self.connection) {
        [self.connection cancel];
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }
    
    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.connection = nil;
    self.mData = nil;
    self.thread = nil;
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        MCDownloadProgressBlock progressBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kProgressBlockKey];
        if (progressBlock) {
            progressBlock(0, expected);
        }
        
        self.mData = [[NSMutableData alloc] initWithCapacity:expected];
        self.response = response;
    }
    else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        //This is the case when server returns '304 Not Modified'. It means that remote image is not changed.
        //In case of 304 we need just cancel the operation and return cached image from the cache.
        if (code == 304) {
            [self cancelInternal];
        } else {
            [self.connection cancel];
        }
        MCDownloadCompleteBlock completedBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kCompleteBlockKey];
        if (completedBlock) {
            completedBlock(nil);
        }
        CFRunLoopStop(CFRunLoopGetCurrent());
        [self done];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mData appendData:data];
    MCDownloadProgressBlock progressBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kProgressBlockKey];
    if (progressBlock) {
        progressBlock(self.mData, ((CGFloat)self.mData.length)/self.expectedSize);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    MCDownloadCompleteBlock completionBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kCompleteBlockKey];
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
    }
    
    if (![[NSURLCache sharedURLCache] cachedResponseForRequest:_request]) {
        responseFromCached = NO;
    }
    
    [[MCDownloadCache shareCache] storeData:[self.mData copy] forKey:self.url];
    
    if (completionBlock) {
        completionBlock(self.mData);
    }
    self.completionBlock = nil;
    [self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
    }
    
    MCDownloadCompleteBlock completedBlock = [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kCompleteBlockKey];
    if (completedBlock) {
        completedBlock(nil);
    }
    
    self.completionBlock = nil;
    [self done];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    responseFromCached = NO; // If this method is called, it means the response wasn't read from cache
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        return nil;
    }
    else {
        return cachedResponse;
    }
}

@end
