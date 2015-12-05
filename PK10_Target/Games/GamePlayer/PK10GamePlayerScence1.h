//
//  PK10GamePlayerScence1.h
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PK10GamePlayerRoad.h"

@interface PK10GamePlayerScence1 : UIView

@property (nonatomic,strong) UIImageView* lineImageView;

@property (nonatomic,strong) NSMutableArray* roads;

@property (nonatomic,assign) NSInteger count;

-(instancetype)initWithRoad:(NSInteger)count;

@end
