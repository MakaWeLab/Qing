//
//  NSOject+MCDownload.m
//  Qing
//
//  Created by Maka on 15/11/23.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "NSOject+MCDownload.h"
#import <objc/runtime.h>

@implementation NSObject(MCDownload)

static const void* kNSObjectMCDownload = &kNSObjectMCDownload;

static const void* kNSObjectMCDownloadOperation = &kNSObjectMCDownloadOperation;

-(NSString*)downloadURL
{
    return objc_getAssociatedObject(self, kNSObjectMCDownload);
}

-(void)setDownloadURL:(NSString *)downloadURL
{
    if (self.downloadURL == downloadURL) {
        return;
    }
    objc_setAssociatedObject(self, kNSObjectMCDownload, downloadURL, OBJC_ASSOCIATION_COPY);
}

-(MCDownloadOperation*)downloadOperation
{
    return objc_getAssociatedObject(self, kNSObjectMCDownloadOperation);
}

-(void)setDownloadOperation:(MCDownloadOperation *)downloadOperation
{
    if (self.downloadOperation ==downloadOperation) {
        return;
    }
    objc_setAssociatedObject(self, kNSObjectMCDownloadOperation, downloadOperation, OBJC_ASSOCIATION_RETAIN);
}

@end
