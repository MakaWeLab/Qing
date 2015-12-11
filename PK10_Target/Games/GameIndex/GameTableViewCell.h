//
//  GameTableViewCell.h
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIME_HEIGHT 20

#define NUMBER_HEIGHT 35

#define TITLE_HEIGHT 20

@interface GameTableViewCell : UITableViewCell

@property (nonatomic,strong) UIScrollView* contentScrollView;

@property (nonatomic,strong) NSArray* numbers;

@property (nonatomic,strong) NSArray* diffIndexs;

@property (nonatomic,strong) UIColor* diffColor;

@property (nonatomic,strong) UIColor* normalColor;

@property (nonatomic,strong) UILabel* titleLabel;

@property (nonatomic,strong) UILabel* timeLabel;

@property (nonatomic,assign) BOOL mutableLine;

+(CGFloat)heightForMutableLine:(NSInteger)number;

@end
