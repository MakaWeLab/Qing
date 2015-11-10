//
//  PlantShareManager.m
//  Qing
//
//  Created by Maka on 15/11/10.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PlantShareManager.h"

@implementation PlantShareManager

+(instancetype)shareInstance
{
    static PlantShareManager* shareManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareManager = [[PlantShareManager alloc] init];
    });
    return shareManager;
}

@end
