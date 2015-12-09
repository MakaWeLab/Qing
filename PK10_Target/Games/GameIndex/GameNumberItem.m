//
//  GameNumberItem.m
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "GameNumberItem.h"

@implementation GameNumberItem

-(void)awakeFromNib
{
    [super awakeFromNib];
}

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"GameNumberItem" owner:self options:nil] firstObject];
}

@end
