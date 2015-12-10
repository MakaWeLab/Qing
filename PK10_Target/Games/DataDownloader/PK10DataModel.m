//
//  PK10DataModel.m
//  Qing
//
//  Created by Maka on 3/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10DataModel.h"

@implementation PK10DataModel

@synthesize time,results = numbers,title = flag,index;

-(void) encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:flag forKey:@"flag"];
    [aCoder encodeObject:time forKey:@"time"];
    [aCoder encodeObject:numbers forKey:@"numbers"];
    [aCoder encodeObject:[NSNumber numberWithInteger:index] forKey:@"index"];
}

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self=[super init])
    {
        flag = [aDecoder decodeObjectForKey:@"flag"];
        time = [aDecoder decodeObjectForKey:@"time"];
        numbers = [aDecoder decodeObjectForKey:@"numbers"];
        index = [[aDecoder decodeObjectForKey:@"index"] integerValue];
    }
    return (self);
    
}


@end
