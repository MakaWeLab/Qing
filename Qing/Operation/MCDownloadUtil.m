//
//  MCDownloadUtil.m
//  Qing
//
//  Created by chaowualex on 15/11/22.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCDownloadUtil.h"
#import <CommonCrypto/CommonCrypto.h>

@interface MCDownloadPieProgressView : UIView<downloadHUDViewProtocol>

@property (nonatomic,assign) CGFloat progress;

@end

@implementation MCDownloadPieProgressView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGFloat xCenter = rect.size.width * 0.5;
    CGFloat yCenter = rect.size.height * 0.5;
    
    
    CGFloat radius = MIN(rect.size.width * 0.5, rect.size.height * 0.5) - 5;
    
    // 背景圆
    [[UIColor colorWithRed:240.0/255 green:240.0/255 blue:240.0/255 alpha:1] set];
    CGFloat w = radius * 2 + 4;
    CGFloat h = w;
    CGFloat x = (rect.size.width - w) * 0.5;
    CGFloat y = (rect.size.height - h) * 0.5;
    CGContextAddEllipseInRect(ctx, CGRectMake(x, y, w, h));
    CGContextFillPath(ctx);
    
    // 进程圆
    [[UIColor colorWithRed:150.0/255 green:150.0/255 blue:150.0/255 alpha:.8] set];
    CGContextMoveToPoint(ctx, xCenter, yCenter);
    CGContextAddLineToPoint(ctx, xCenter, 0);
    CGFloat to = - M_PI * 0.5 + self.progress * M_PI * 2 + 0.001; // 初始值
    CGContextAddArc(ctx, xCenter, yCenter, radius, - M_PI * 0.5, to, 1);
    CGContextClosePath(ctx);
    
    CGContextFillPath(ctx);
}

@end


@implementation MCDownloadUtil

+(UIView<downloadHUDViewProtocol>*)progressHUDForUIView:(UIView *)view
{
    MCDownloadPieProgressView* progressView = [[MCDownloadPieProgressView alloc]initWithFrame:view.bounds];
    return progressView;
}


+ (NSString *)cachedFileNameForKey:(NSString *)key {
    const char *str = [key UTF8String];
    if (str == NULL) {
        str = "";
    }
    unsigned char r[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), r);
    NSString *filename = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
                          r[0], r[1], r[2], r[3], r[4], r[5], r[6], r[7], r[8], r[9], r[10], r[11], r[12], r[13], r[14], r[15]];
    return filename;
}

@end
