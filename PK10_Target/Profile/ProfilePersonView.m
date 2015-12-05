//
//  ProfilePersonView.m
//  Qing
//
//  Created by chaowualex on 15/12/4.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "ProfilePersonView.h"

@implementation ProfilePersonView

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"ProfilePersonView" owner:self options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.headImageView.layer.cornerRadius = self.headImageView.bounds.size.width/2;
}

@end
