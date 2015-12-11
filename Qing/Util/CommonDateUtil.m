//
//  CommonDateUtil.m
//  Qing
//
//  Created by Maka on 11/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "CommonDateUtil.h"

@implementation CommonDateUtil

+(NSDateFormatter*)dateFormatterForString:(NSString *)string
{
    static NSMutableDictionary* mDictionary;
    if (!mDictionary) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            mDictionary = [NSMutableDictionary dictionary];
        });
    }
    NSDateFormatter* formatter = [mDictionary objectForKey:string];
    if (!formatter) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:string];
        [formatter setTimeZone:[NSTimeZone systemTimeZone]];
        [mDictionary setObject:formatter forKey:string];
    }
    return formatter;
}

@end
