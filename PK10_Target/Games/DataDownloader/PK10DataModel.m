//
//  PK10DataModel.m
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10DataModel.h"

@implementation PK10DataModel

@synthesize time,results = numbers,title = flag;

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:flag forKey:@"flag"];
    [aCoder encodeObject:self.time forKey:@"time"];
    [aCoder encodeObject:numbers forKey:@"numbers"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        flag = [aDecoder decodeObjectForKey:@"flag"];
        self.time = [aDecoder decodeObjectForKey:@"time"];
        numbers = [aDecoder decodeObjectForKey:@"numbers"];
    }
    return (self);
    
}


@end
