//
//  UIImageView+MCDownload.m
//  Qing
//
//  Created by Maka on 15/11/23.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "UIImageView+MCDownload.h"
#import "MCDownloadUtil.h"
#import "MCDownloadOperation.h"
#import "NSOject+MCDownload.h"
#import "MCDownloadThreadManager.h"
#import "MCDownloadCache.h"

@implementation UIImageView(MCDownload)

-(void)downloadImageWithURL:(NSString *)url placeHolderImage:(UIImage *)placeHolder showProgressHUD:(BOOL)isShow
{
    if (!url) {
        return;
    }
    
    self.downloadURL = url;
    
    //判断对应的图片是不是已经下完，下载完成直接读取。
    NSData* data = [[MCDownloadCache shareCache] dataForKey:url];
    if (data) {
        UIImage* image = [[UIImage alloc]initWithData:data];
        __weak __typeof(self)wself = self;
        dispatch_main_async_safe(^{
            wself.image = image;
            [wself setNeedsLayout];
        });
        self.downloadOperation = nil;
        return;
    }else {
        self.image = nil;
        [self setNeedsLayout];
    }
    //取消之前的请求
    MCDownloadThreadManager* shareManager = [MCDownloadThreadManager shareManager];
    
    if (self.downloadOperation) {
        [self.downloadOperation cancel];
    }

    if (placeHolder) {
        __weak __typeof(self)wself = self;
        dispatch_main_async_safe(^{
            wself.image = placeHolder;
        });
    }
    
    if (url) {
        __weak __typeof(self)wself = self;
        NSMutableDictionary* mDic = [NSMutableDictionary dictionary];
        MCDownloadProgressBlock progressBlock = nil;
        if (isShow) {
            progressBlock = ^(NSData* receivedData , CGFloat progress){
                
            };
            [mDic setObject:progressBlock forKey:kProgressBlockKey];
        }
        MCDownloadCompleteBlock completeBlock = ^(NSData* data){
            if (!wself) return;
            __weak __typeof(self)wself = self;
            dispatch_main_async_safe(^{
                wself.image = [[UIImage alloc]initWithData:data];
                [wself setNeedsLayout];
            });
        };
        [mDic setObject:completeBlock forKey:kCompleteBlockKey];
        
        [shareManager.callbacksDictionary setObject:mDic forKey:url];
        
        MCDownloadOperation* operation = [[MCDownloadThreadManager shareManager] appendDownloadOperationForURL:url];
        
        self.downloadOperation = operation;
    }
}

@end
