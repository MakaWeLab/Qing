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
    if ([self.downloadURL isEqualToString:url] && ![self.downloadOperation isCancelled]) {
        return;
    }
    self.downloadURL = url;
    dispatch_main_async_safe(^{
        self.image = placeHolder;
    });
    
    if (url) {
        __weak __typeof(self)wself = self;
        MCDownloadOperation* operation = [[MCDownloadThreadManager shareManager] createOperationForURL:url progress:^(NSData *receivedData, CGFloat progress) {
            
        } completed:^(NSData *data) {
            if (!wself) return;
            dispatch_main_sync_safe(^{
                [[MCDownloadCache shareCache] storeData:data forKey:url];
                UIImage* image = [[UIImage alloc]initWithData:data];
                wself.image = image;
                [self setNeedsLayout];
            });
        }];
        
        self.downloadOperation = operation;
    }
}

@end
