//
//  MCGameCountViewController.h
//  Qing
//
//  Created by Maka on 30/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "RootViewController.h"

@interface MCGameIndexViewController : RootViewController

@property (nonatomic,strong) NSString* configName;

+(instancetype)shareInstanceWithConfigName:(NSString*)name;

@property (nonatomic,assign) BOOL cellScrollLock;

@property (nonatomic,assign) BOOL showMask;

@end
