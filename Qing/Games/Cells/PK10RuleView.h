//
//  PK10RuleView.h
//  Qing
//
//  Created by chaowualex on 15/12/3.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSUInteger {
    PK10RuleViewTypePK10,
    PK10RuleViewTypePK10_1,
    PK10RuleViewTypePK10_12,
    PK10RuleViewTypePK10_123,
} PK10RuleViewType;

@interface PK10RuleView : UIView

@property (weak, nonatomic) IBOutlet UIButton *firstButton;
@property (weak, nonatomic) IBOutlet UIButton *secondButton;
@property (weak, nonatomic) IBOutlet UIButton *thirdButton;
@property (weak, nonatomic) IBOutlet UIButton *fourButton;

@property (nonatomic,assign) PK10RuleViewType type;

+(instancetype)instanceFromNib;

@end
