//
//  MCDownloadUtil.h
//  Qing
//
//  Created by chaowualex on 15/11/22.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define dispatch_main_sync_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_sync(dispatch_get_main_queue(), block);\
}

#define dispatch_main_async_safe(block)\
if ([NSThread isMainThread]) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}


@protocol downloadHUDViewProtocol <NSObject>

-(void)setProgress:(CGFloat)progress;

@end

@interface MCDownloadUtil : NSObject

+(UIView<downloadHUDViewProtocol>*)progressHUDForUIView:(UIView*)view;

//MD5
+ (NSString *)cachedFileNameForKey:(NSString *)key;

@end
