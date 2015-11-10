//
//  RootModuleManager.h
//  Qing
//
//  Created by Maka on 15/11/10.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface RootModuleManager : NSObject

+(UIViewController*)loadModuleWithModuleName:(NSString*)name;

@end
