//
//  PK10GamePlayerRoad.h
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>


#define LINE_HEIGHT 22
#define LINE_WIDTH 280

@interface PK10GamePlayerRoad : UIView

@property (nonatomic,strong) UIImageView* lineImageView;

+(instancetype)instanceFromNib;

@end
