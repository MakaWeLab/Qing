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
    }
    //如果没有下载完 判断对应的请求是不是存在
    MCDownloadThreadManager* shareManager = [MCDownloadThreadManager shareManager];
    for (MCDownloadOperation* o in shareManager.runningOperations) {
        if ([o.url isEqualToString:url]) {
            //如果对应的请求正在运行之中 那么置换请求对应的回调函数
            __weak __typeof(self)wself = self;
            NSMutableDictionary* mDic = [NSMutableDictionary dictionary];
            if (isShow) {
                MCDownloadProgressBlock progressBlock = ^(NSData* receivedData , CGFloat progress){
                    
                };
                [mDic setObject:progressBlock forKey:kProgressBlockKey];
            }
            MCDownloadCompleteBlock completeBlock = ^(NSData* data){
                wself.image = [[UIImage alloc]initWithData:data];
                [wself setNeedsLayout];
            };
            [mDic setObject:completeBlock forKey:kCompleteBlockKey];
            
            [shareManager.callbacksDictionary setObject:mDic forKey:url];
            
            self.downloadOperation = o;
            return;
        }
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
        
        MCDownloadOperation* operation = [[MCDownloadThreadManager shareManager] createOperationForURL:url];
        
        self.downloadOperation = operation;
    }
}

@end
