//
//  GameTableViewCell.m
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "GameNumberItem.h"
#import "GameTableViewCell.h"
#import <Masonry.h>

@interface GameTableViewCell()

@property (nonatomic,strong) NSMutableArray* numberItems;

@end

@implementation GameTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.numberItems = [NSMutableArray array];
        self.diffColor = [UIColor blackColor];
        self.normalColor = [UIColor orangeColor];
        self.contentScrollView = [[UIScrollView alloc]init];
        self.contentScrollView.alwaysBounceVertical = NO;
        self.contentScrollView.showsVerticalScrollIndicator = NO;
        [self.contentView addSubview:self.contentScrollView];
        [self.contentScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        self.timeLabel = [[UILabel alloc]init];
        self.timeLabel.backgroundColor = [UIColor redColor];
        self.timeLabel.font = [UIFont systemFontOfSize:13];
        self.timeLabel.textColor = [UIColor whiteColor];
        [self.contentView addSubview:self.timeLabel];
        [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2);
            make.centerX.equalTo(self.contentView);
        }];
        
        self.titleLabel = [[UILabel alloc]init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.font = [UIFont systemFontOfSize:13];
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(2);
            make.left.equalTo(self.timeLabel.mas_right).with.offset(5);
        }];
    }
    return self;
}

+(CGFloat)heightForMutableLine:(NSInteger)number
{
    NSInteger count =( [UIScreen mainScreen].bounds.size.width - 2 - 2) /  NUMBER_HEIGHT;
    NSInteger c = number;
    count -= 1;
    c -= 1;
    NSInteger line = c%count==0?c/count+1:c/count+1;
    
    return line*NUMBER_HEIGHT + TITLE_HEIGHT;
}

-(void)setNumbers:(NSArray *)numbers
{
    _numbers = numbers;
    
    CGFloat leftPadding = 2;
    
    CGFloat rightPadding = 2;
    
    CGFloat width = NUMBER_HEIGHT;
    
    CGFloat height = NUMBER_HEIGHT;
    
    GameNumberItem* item = nil;
    NSInteger line = 0;
    NSInteger row = 0;
    for (NSInteger i = 0; i<numbers.count; i++,row++) {
        if (self.numberItems.count > i) {
            item = self.numberItems[i];
        }else {
            item = [GameNumberItem instanceFromNib];
            [self.numberItems addObject:item];
            [self.contentScrollView addSubview:item];
        }
        
        CGRect rect = CGRectMake(leftPadding + width*row, line* NUMBER_HEIGHT + TITLE_HEIGHT, height, height);
        if (self.mutableLine) {
            if (rect.origin.x+rect.size.width+rightPadding > [UIScreen mainScreen].bounds.size.width) {
                line+=1;
                row = 1;
                rect = CGRectMake(leftPadding + width*row, line* NUMBER_HEIGHT + TITLE_HEIGHT, height, height);
            }
        }
        item.frame = CGRectInset(rect, 2, 2);
        
        item.rankLabel.text = [NSString stringWithFormat:@"%ld",(long)i+1];
        if (i+1<5||i+1>numbers.count-3||(i+1)%2==0) {
            item.rankLabel.superview.hidden = YES;
        }else {
            item.rankLabel.superview.hidden = NO;
        }

        id n = numbers[i];
        if ([n isKindOfClass:[NSString class]]) {
            item.numberLabel.text = n;
        }else if ([n isKindOfClass:[NSNumber class]]) {
            item.numberLabel.text = [NSString stringWithFormat:@"%ld",(long)[n integerValue]];
        }
        
        item.backView.backgroundColor = self.normalColor;
        for (NSNumber* num in self.diffIndexs) {
            if ([num integerValue] == i) {
                item.backView.backgroundColor = self.diffColor;
                break;
            }
        }
    }
    self.contentScrollView.contentSize = CGSizeMake(item.frame.origin.x + item.frame.size.width + rightPadding, NUMBER_HEIGHT-1);
//    if (self.contentScrollView.contentSize.width < self.contentScrollView.frame.size.width) {
//        CGFloat inset = self.contentScrollView.frame.size.width - self.contentScrollView.contentSize.width;
//        self.contentScrollView.contentInset = UIEdgeInsetsMake(0, inset/2, 0, 0);
//    }
}

@end
