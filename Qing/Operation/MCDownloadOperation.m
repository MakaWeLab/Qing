//
//  MCDownloadOperation.m
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadOperation.h"
#import "MCDownloadCache.h"
#import "MCDownloadCallBackManager.h"

@interface MCDownloadOperation ()

@property (assign, nonatomic) NSInteger expectedSize;

@property (strong, nonatomic) NSMutableData *mData;

@property (strong, nonatomic) NSURLConnection *connection;


@end

@implementation MCDownloadOperation

-(id)initWithUrl:(NSString *)url
{
    if ((self = [super init])) {
        self.url = url;
    }
    return self;
}

-(MCDownloadProgressBlock)progressBlock
{
    return [[[MCDownloadCallBackManager shareInstance] getCallbackForUrl:self.url withTag:self.tag] objectForKey:kMCDownloadCallBackProgressKey];
}

-(MCDownloadCompleteBlock)completeBlock
{
    return [[[MCDownloadCallBackManager shareInstance] getCallbackForUrl:self.url withTag:self.tag] objectForKey:kMCDownloadCallBackCompleteKey];
}

-(void)main
{
    self.connection = [NSURLConnection connectionWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]] delegate:self];
    [self.connection start];
    
    if (self.connection) {
        
        CFRunLoopRun();

    }else {
        MCDownloadCompleteBlock completeBlock = [self completeBlock];
        completeBlock(NO,nil);
    }
}

-(void)cancel
{
    [super cancel];
    if (self.connection) {
        [self.connection cancel];
    }
}

#pragma mark NSURLConnection (delegate)

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        self.mData = [[NSMutableData alloc] initWithCapacity:expected];
    }
    else {
        [self cancel];
        CFRunLoopStop(CFRunLoopGetCurrent());
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.mData appendData:data];
    MCDownloadProgressBlock progressBlock = [self progressBlock];
    if (progressBlock) {
        progressBlock(self.mData, ((CGFloat)self.mData.length)/self.expectedSize);
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    MCDownloadCompleteBlock completionBlock = [self completeBlock];
    
    [[MCDownloadCache shareCache] storeData:[self.mData copy] forKey:self.url];
    
    if (completionBlock) {
        completionBlock(YES,self.mData);
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    MCDownloadCompleteBlock completionBlock = [self completeBlock];
    
    if (completionBlock) {
        completionBlock(NO,nil);
    }
}

@end
