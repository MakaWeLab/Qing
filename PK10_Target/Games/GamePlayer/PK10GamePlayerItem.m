//
//  PK10GamePlayerItem.m
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10GamePlayerItem.h"

@implementation PK10GamePlayerItem

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PK10GamePlayerItem" owner:self options:nil] firstObject];
}

@end
