//
//  PK10GamePlayer.h
//  Qing
//
//  Created by Maka on 4/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PK10GamePlayer : UIView

@property (nonatomic,assign) NSInteger line;

@property (nonatomic,assign) int leftTime;

-(instancetype)initWithLine:(NSInteger)line;

-(void)begin;

-(void)stopPlayWithResult:(NSArray*)result;

@end
