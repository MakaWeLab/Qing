//
//  PK10RuleView.m
//  Qing
//
//  Created by chaowualex on 15/12/3.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10RuleView.h"

@interface PK10RuleView()

@property (nonatomic,strong) NSArray* buttons;

@end

@implementation PK10RuleView

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle]loadNibNamed:@"PK10RuleView" owner:self options:nil] firstObject];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.type = PK10RuleViewTypePK10_1;
    self.buttons = [NSArray arrayWithObjects:self.firstButton,self.secondButton,self.thirdButton,self.fourButton, nil];
}

- (IBAction)buttonAction:(id)sender {
    NSInteger tag = [sender tag] -1001;
    
    NSInteger index = 0;
    for (UIButton* btn in self.buttons) {
        if (index == tag) {
            btn.selected = YES;
            self.type = index;
        }else {
            btn.selected = NO;
        }
        index++;
    }
}

@end
