//
//  ProfilePersonView.h
//  Qing
//
//  Created by chaowualex on 15/12/4.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfilePersonView : UIView

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;

+(instancetype)instanceFromNib;

@end
