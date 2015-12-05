//
//  ProfilePersonSettingView.m
//  Qing
//
//  Created by chaowualex on 15/12/4.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "ProfilePersonSettingView.h"

@implementation ProfilePersonSettingView

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"ProfilePersonSettingView" owner:self options:nil] firstObject];
}

@end
