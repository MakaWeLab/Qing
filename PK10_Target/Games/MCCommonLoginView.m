//
//  MCCommonLoginView.m
//  Qing
//
//  Created by Maka on 30/11/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "MCCommonLoginView.h"

@implementation MCCommonLoginView

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"MCCommonLoginView" owner:self options:nil] firstObject];
}

@end
