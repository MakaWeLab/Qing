//
//  PK10GamePlayerRoad.m
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10GamePlayerRoad.h"
#import <Masonry.h>

@implementation PK10GamePlayerRoad

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PK10GamePlayerRoad" owner:self options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.lineImageView = [[UIImageView alloc]init];
    
    NSMutableArray* mArray = [NSMutableArray array];
    for (NSInteger i =1 ; i < 8; i++) {
        UIImage* image = [UIImage imageNamed:[NSString stringWithFormat:@"road%d",(int)i]];
        [mArray addObject:image];
    }
    self.lineImageView.animationImages = mArray;
    [self.lineImageView startAnimating];
    [self addSubview:self.lineImageView];
    [self.lineImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(0);
        make.height.mas_equalTo(1/[UIScreen mainScreen].scale);
    }];
}

@end
