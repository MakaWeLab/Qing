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
#import <Masonry.h>


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
    
    if (isShow) {
        UIView<downloadHUDViewProtocol>* view= [self viewWithTag:10086];
        if (!view) {
            view = [MCDownloadUtil downloadHUDViewForUIView:self];
            view.tag = 10086;
            [self addSubview:view];
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
            }];
        }
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
                UIView<downloadHUDViewProtocol>* view= [wself viewWithTag:10086];
                dispatch_main_async_safe(^{
                    [view setProgress:.5];
                    [view setNeedsDisplay];
                });
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
