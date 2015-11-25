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

@property (nonatomic,strong) NSURLRequest* request;

@property (strong, nonatomic) NSMutableData *mData;

@property (strong, nonatomic) NSURLConnection *connection;

@property (assign,nonatomic) BOOL complete;

@property (assign,nonatomic) BOOL downloading;

@property (strong, atomic) NSThread *thread;

@end

@implementation MCDownloadOperation

-(id)initWithRequestURL:(NSString *)url
{
    if ((self = [super init])) {
        _url = url;
        _response = nil;
        _request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
        _expectedSize = 0;
        _mData = nil;
        _thread = nil;
    }
    return self;
}

-(MCDownloadProgressBlock)getProgressBlock
{
    return [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kProgressBlockKey];
}

-(MCDownloadCompleteBlock)getCompleteBlock
{
    return [[[MCDownloadThreadManager shareManager].callbacksDictionary objectForKey:self.url] objectForKey:kCompleteBlockKey];
}

-(void)main
{
    @synchronized (self) {
        if (self.isCancelled) {
            self.complete = YES;
            [self reset];
            return;
        }
        if (self.connection) {
            [self.connection cancel];
        }
        
        self.downloading = YES;
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        self.thread = [NSThread currentThread];
    }
    
    [self.connection start];
    
    if (self.connection) {
        
        CFRunLoopRun();
        
        if (!self.complete) {
            [self.connection cancel];
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
        }
    }else {
        MCDownloadCompleteBlock completeBlock = [self getCompleteBlock];
        completeBlock(nil);
    }
}

-(void)reset
{
    _connection = nil;
    _mData = nil;
    _thread = nil;
}

-(void)cancel
{
    if (self.complete) return;
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
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    [super cancel];
    if (self.connection) {
        [self.connection cancel];
        // maintain
        if (self.downloading) self.downloading = NO;
        if (!self.complete) self.complete = YES;
    }
    
    [self reset];
}

- (void)done {
    self.complete = YES;
    self.downloading = NO;
    [self reset];
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        self.mData = [[NSMutableData alloc] initWithCapacity:expected];
        self.response = response;
    }
    else {
        [self cancel];
        CFRunLoopStop(CFRunLoopGetCurrent());
        [self done];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mData appendData:data];
    MCDownloadProgressBlock progressBlock = [self getProgressBlock];
    if (progressBlock) {
        progressBlock(self.mData, ((CGFloat)self.mData.length)/self.expectedSize);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    MCDownloadCompleteBlock completionBlock = [self getCompleteBlock];
    
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
    }
    
    [[MCDownloadCache shareCache] storeData:[self.mData copy] forKey:self.url];
    
    if (completionBlock) {
        completionBlock(self.mData);
    }
    [self done];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
    }
    [self done];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        return nil;
    }
    else {
        return cachedResponse;
    }
}

@end
