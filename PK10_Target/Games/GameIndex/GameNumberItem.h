//
//  GameNumberItem.h
//  Qing
//
//  Created by Maka on 9/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameNumberItem : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *rankLabel;

+(instancetype)instanceFromNib;

@end
