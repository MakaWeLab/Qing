//
//  PK10DataModel.h
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PK10DataModel : NSObject<NSCoding>

@property (nonatomic,assign) NSInteger flag;

@property (nonatomic,strong) NSString* time;

@property (nonatomic,strong) NSArray* numbers;

@end
