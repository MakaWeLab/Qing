//
//  GameTableViewCell.m
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "GameNumberItem.h"
#import "GameTableViewCell.h"


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
    }
    return self;
}

-(void)setNumbers:(NSArray *)numbers
{
    _numbers = numbers;
    
    CGFloat leftPadding = 10;
    
    CGFloat rightPadding = 10;
    
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - leftPadding - rightPadding)/numbers.count;
    
    CGFloat height = width > NUMBER_HEIGHT?NUMBER_HEIGHT:width;
    
    for (NSInteger i = 0; i<numbers.count; i++) {
        GameNumberItem* item = nil;
        if (self.numberItems.count > i) {
            item = self.numberItems[i];
        }else {
            item = [GameNumberItem instanceFromNib];
            [self.numberItems addObject:item];
            [self.contentView addSubview:item];
        }
        CGRect rect = CGRectMake(leftPadding + width*i, 0, height, height);
        item.center = CGPointMake(rect.origin.x + rect.size.width/2, rect.origin.y + rect.size.height/2);
        item.frame = CGRectInset(rect, 2, 2);
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
}

@end
