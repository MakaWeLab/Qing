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
#import "MCDownloadCache.h"
#import "MCDownloadOperationManager.h"
#import "MCDownloadCallBackManager.h"
#import <Masonry.h>
#import <objc/runtime.h>

@implementation UIImageView(MCDownload)

static void* kUIImageViewUrlKey = &kUIImageViewUrlKey;

-(NSString*)imageUrl
{
    return objc_getAssociatedObject(self, kUIImageViewUrlKey);
}

-(void)setImageUrl:(NSString *)imageUrl
{
    objc_setAssociatedObject(self, kUIImageViewUrlKey, imageUrl, OBJC_ASSOCIATION_COPY);
}

-(void)downloadImageWithURL:(NSString *)url placeHolderImage:(UIImage *)placeHolder showProgressHUD:(BOOL)isShow
{
    
    if (!url) {
        return;
    }
    
    NSLog(@"%@ %@,%s",self,[NSThread currentThread],__func__);
    
    //判断对应的图片是不是已经下完，下载完成直接读取。
    NSData* data = [[MCDownloadCache shareCache] dataForKey:url];
    if (data) {
        UIImage* image = [[UIImage alloc]initWithData:data];
        self.image = image;
        return;
    }else {
        self.image = nil;
    }
    
    if (isShow) {
        //        UIView<downloadHUDViewProtocol>* view= [self viewWithTag:10086];
        //        if (!view) {
        //            view = [MCDownloadUtil progressHUDForUIView:self];
        //            view.tag = 10086;
        //            [self addSubview:view];
        //            [view mas_makeConstraints:^(MASConstraintMaker *make) {
        //                make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
        //            }];
        //        }
    }
    
    
    //取消之前的请求
    if (self.imageUrl) {
        [[MCDownloadOperationManager shareInstance] cancelDownloadOperationForUrl:self.imageUrl];
        [[MCDownloadCallBackManager shareInstance] removeCallbackForUrl:self.imageUrl withTag:self];
    }
    
    
    self.imageUrl = url;
    
    if (placeHolder) {
        self.image = placeHolder;
    }
    
    if (url) {
        __weak __typeof(self)wself = self;
        __strong MCDownloadProgressBlock progressBlock = nil;
//        if (isShow) {
//            progressBlock = ^(NSData* receivedData , CGFloat progress){
//                UIView<downloadHUDViewProtocol>* view= [wself viewWithTag:10086];
//                dispatch_main_async_safe(^{
//                    [view setProgress:progress];
//                    [view setNeedsDisplay];
//                });
//            };
//        }
        __strong MCDownloadCompleteBlock completeBlock = ^(BOOL isSuccess , NSData* data){
            NSLog(@"%@ %@,%s",self,[NSThread currentThread],__func__);
            if (!wself) return;
            __weak __typeof(self)wself = self;
            dispatch_main_async_safe(^{
                wself.image = [[UIImage alloc]initWithData:data];
                [wself setNeedsLayout];
            });
        };
        
        
        MCDownloadOperation* operation = [[MCDownloadOperation alloc] initWithUrl:url];
        
        operation.tag = self;
        
        [[MCDownloadCallBackManager shareInstance] addCallbackWithProgressBlock:[progressBlock copy] completeBlock:[completeBlock copy] forUrl:url withTag:self];
        [[MCDownloadOperationManager shareInstance] startDownloadOperation:operation forUrl:url];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [operation start];
        });
    }
}

@end
