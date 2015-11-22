//
//  MCDownloadUtil.h
//  Qing
//
//  Created by chaowualex on 15/11/22.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>

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

@interface MCDownloadUtil : NSObject


@end
