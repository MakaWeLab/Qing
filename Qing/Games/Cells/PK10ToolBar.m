//
//  PK10ToolBar.m
//  Qing
//
//  Created by Maka on 2/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10ToolBar.h"
#import <Masonry.h>

@interface PK10ToolBar ()

@property (nonatomic,strong) UIView* lineView;

@end

@implementation PK10ToolBar

-(instancetype)init
{
    if (self = [super init]) {
        self.ruleView = [PK10RuleView instanceFromNib];
        [self addSubview:self.ruleView];
        [self.ruleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
        
        self.lineView = [[UIView alloc]init];
        self.lineView.backgroundColor = [UIColor whiteColor];
        
    }
    return self;
}

@end
