//
//  UIImageView+MCDownload.h
//  Qing
//
//  Created by Maka on 15/11/23.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView(MCDownload)

@property (nonatomic,strong) NSString* imageUrl;

-(void)downloadImageWithURL:(NSString*)url placeHolderImage:(UIImage*)placeHolder showProgressHUD:(BOOL)isShow;

@end
