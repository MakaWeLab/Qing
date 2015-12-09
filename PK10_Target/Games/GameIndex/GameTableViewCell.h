//
//  GameTableViewCell.h
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

#define TIME_HEIGHT 20

#define NUMBER_HEIGHT 40

@interface GameTableViewCell : UITableViewCell

@property (nonatomic,strong) NSArray* numbers;

@property (nonatomic,strong) NSArray* diffIndexs;

@property (nonatomic,strong) UIColor* diffColor;

@property (nonatomic,strong) UIColor* normalColor;

@end
