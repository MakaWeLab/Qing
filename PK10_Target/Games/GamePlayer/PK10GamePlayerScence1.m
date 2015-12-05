//
//  PK10GamePlayerScence1.m
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10GamePlayerScence1.h"
#import <Masonry.h>

@implementation PK10GamePlayerScence1

-(instancetype)initWithRoad:(NSInteger)count
{
    if (self = [super init]) {
        self.count = count;
        self.roads = [NSMutableArray array];
        for (NSInteger i = 0 ; i<count; i++) {
            PK10GamePlayerRoad* road = [PK10GamePlayerRoad instanceFromNib];
            [self addSubview:road];
            [road mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.mas_equalTo(0);
                make.width.equalTo(self.mas_width);
                make.height.mas_equalTo(LINE_HEIGHT);
                make.top.mas_equalTo(i*LINE_HEIGHT);
            }];
            [self.roads addObject:road];
        }
    }
    return self;
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
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(1/[UIScreen mainScreen].scale);
    }];
}

@end
