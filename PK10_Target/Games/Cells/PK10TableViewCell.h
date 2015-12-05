//
//  PK10TableViewCell.h
//  Qing
//
//  Created by Maka on 1/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PK10RuleView.h"

@interface PK10TableViewCell : UITableViewCell

@property (nonatomic,assign) NSInteger diffIndex;

@property (nonatomic,strong) NSArray* numbers;

@property (nonatomic,assign) NSInteger flag;

@property (nonatomic,assign) PK10RuleViewType type;

@property (nonatomic,strong) NSString* time;

@property (weak, nonatomic) IBOutlet UIView *containerView;

@end
