//
//  MCDownloadOperation.m
//  Qing
//
//  Created by Maka on 15/11/19.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadOperation.h"
#import "UrlOperationManager.h"

@interface MCDownloadOperation ()

@property (nonatomic,strong) NSString* url;

@end

@implementation MCDownloadOperation

-(instancetype)initWithUrl:(NSString *)url callback:(MCDownloadOperationBlock)callback withObject:(id)obj
{
    if (self = [super init]) {
        if (!url) {
            return nil;
        }
        self.url = url;
        [[UrlOperationManager shareInstance] registCallbackForUrlDownloadComplete:url withObject:obj callBack:callback];
    }
    return self;
}

-(void)main
{
    if ([[ UrlOperationManager shareInstance] isDownloadOperationExistForUrl:self.url]) {
        return;
    }
    [[UrlOperationManager shareInstance].allUrls addObject:self.url];
    [[UrlOperationManager shareInstance].keyValueDictionary setObject:self forKey:self.url];
    NSData* data = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:self.url]];
    [[UrlOperationManager shareInstance] downLoadCompleteForUrl:self.url withData:data];
}

@end
