//
//  PopShowImageView.m
//  Qing
//
//  Created by chaowualex on 15/11/18.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PopShowImageView.h"
#import <UIImageView+WebCache.h>
#import <POP.h>
#import <Masonry.h>
#import <FLAnimatedImage.h>

@interface PopShowImageView ()

@property (nonatomic,weak) UIView* container;

@property (nonatomic,strong) UIView* backView;

@property (weak, nonatomic) IBOutlet FLAnimatedImageView *imageView;

@end

@implementation PopShowImageView

+(instancetype)showPopShowImageViewWithImage:(UIImage *)image
{
    PopShowImageView* popShow = [PopShowImageView instanceFromNib];
    popShow.imageView.image = image;
    
    UIView* container = [[UIView alloc]init];
    popShow.container = container;
    [[UIApplication sharedApplication].keyWindow addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo([UIApplication sharedApplication].keyWindow);
    }];
    
    UIView* backView = [[UIView alloc]init];
    backView.backgroundColor = [UIColor blackColor];
    backView.alpha = 0;
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc]initWithTarget:popShow action:@selector(hide)];
    [popShow.imageView addGestureRecognizer:tap];
    popShow.backView = backView;
    [container addSubview:backView];
    [backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    
    [container addSubview:popShow];
    [popShow mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(container);
    }];
    popShow.transform = CGAffineTransformMakeScale(.1, .1);
    
    [UIView animateWithDuration:.25 animations:^{
        backView.alpha = .5;
        popShow.transform = CGAffineTransformIdentity;
    }];
    
    return popShow;
}

-(void)hide
{
    [UIView animateWithDuration:.25 animations:^{
        self.backView.alpha = 0;
        self.transform = CGAffineTransformMakeScale(.1, .1);
    } completion:^(BOOL finished) {;
        [self.container removeFromSuperview];
    }];
}

-(void)dealloc
{
    
}

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PopShowImageView" owner:self options:nil] firstObject];
}

@end
