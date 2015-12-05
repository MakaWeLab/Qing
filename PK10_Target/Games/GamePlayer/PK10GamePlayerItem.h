//
//  PK10GamePlayerItem.h
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PK10GamePlayerItem : UIView

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,assign) CGFloat speed;

@property (nonatomic,assign) CGFloat finishX;

+(instancetype)instanceFromNib;

@end
