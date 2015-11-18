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

@interface PopShowImageView ()

@property (nonatomic,weak) UIView* container;

@property (nonatomic,strong) UIView* backView;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

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
    } completion:^(BOOL finished) {
        [self.container removeFromSuperview];
    }];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    // 动画选项设定
    animation.duration = .25; // 动画持续时间
    animation.repeatCount = 1; // 重复次数
    animation.autoreverses = NO; // 动画结束时执行逆动画
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    // 缩放倍数
    animation.fromValue = [NSNumber numberWithFloat:1]; // 开始时的倍率
    animation.toValue = [NSNumber numberWithFloat:.1]; // 结束时的倍率
    // 添加动画
    [self.layer addAnimation:animation forKey:@"scale-layer"];
    
}

-(void)dealloc
{
    
}

+(instancetype)instanceFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:@"PopShowImageView" owner:self options:nil] firstObject];
}

@end
