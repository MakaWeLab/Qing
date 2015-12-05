//
//  PK10DataModel.m
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10DataModel.h"

@implementation PK10DataModel

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSNumber numberWithInteger:self.flag] forKey:@"flag"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:self.numbers forKey:@"numbers"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        self.flag = [[aDecoder decodeObjectForKey:@"flag"] integerValue];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        self.numbers = [aDecoder decodeObjectForKey:@"numbers"];
    }
    return (self);
    
}


@end
