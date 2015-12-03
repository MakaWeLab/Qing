//
//  PK10TableViewCell.m
//  Qing
//
//  Created by Maka on 1/12/15.
//  Copyright © 2015年 maka. All rights reserved.
//

#import "PK10TableViewCell.h"
#import "UIImageView+MCDownload.h"

@interface PK10TableViewCell()

@property (nonatomic,strong) NSMutableArray* imageViewArray;

@property (weak, nonatomic) IBOutlet UILabel *flagLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

@implementation PK10TableViewCell

- (void)awakeFromNib {
    // Initialization code
    
}

-(void)setTime:(NSString *)time
{
    if (_time == time) {
        return;
    }
    _time = time;
    self.timeLabel.text = time;
}

-(void)setFlag:(NSInteger)flag
{
    if (_flag == flag) {
        return;
    }
    _flag = flag;
    self.flagLabel.text = [NSString stringWithFormat:@"%ld",(long)self.flag];
    self.diffIndex = self.flag%10 == 0 ? 9 : self.flag%10 -1 ;
}

-(void)setNumbers:(NSArray *)numbers
{
    if ([numbers isKindOfClass:[NSString class]]) {
        numbers = [(NSString*)numbers componentsSeparatedByString:@","];
    }
    _numbers = numbers;
    
    if (!self.imageViewArray) {
        self.imageViewArray = [NSMutableArray array];
    }
    
    NSInteger index = 0;
    for (NSNumber* number in numbers) {
        NSInteger i = [number integerValue];
        
        if (self.imageViewArray.count <= index) {
            UIImageView* imageView = [[UIImageView alloc]init];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            [self.containerView addSubview:imageView];
            [self.imageViewArray addObject:imageView];
        }
        
        UIImageView* imageView= self.imageViewArray[index];
        
        CGFloat leftPadding = 5;
        
        CGFloat perWidth = ([UIScreen mainScreen].bounds.size.width - 30 - leftPadding*2) / numbers.count;
        
        CGFloat perHeight = 30;
        
        imageView.bounds = CGRectInset(CGRectMake(0, 0, perWidth, perHeight), 2, 2);
        imageView.center = CGPointMake(leftPadding + perWidth*index + perWidth/2, perHeight/2);
        
        NSString* imageName = [self imageNameFromInteger:i isDiff:[self isDiffForIndex:index]];
        
        imageView.image = [UIImage imageNamed:imageName];
        
        index++;
    }
    
}

-(BOOL)isDiffForIndex:(NSInteger)index
{
    switch (self.type) {
        case PK10RuleViewTypePK10:
        {
            return index == self.diffIndex ? YES : NO;
            break;
        }
        case PK10RuleViewTypePK10_1:
        {
            if (index == 0) {
                return YES;
            }
            return NO;
            break;
        }
        case PK10RuleViewTypePK10_12:
        {
            if (index <2) {
                return YES;
            }
            return NO;
            break;
        }
        case PK10RuleViewTypePK10_123:
        {
            if (index <3) {
                return YES;
            }
            return NO;
            break;
        }
        default:
            break;
    }
}

-(NSString*)imageNameFromInteger:(NSInteger)number isDiff:(BOOL)isdiff
{
    
    if (isdiff) {
        return [NSString stringWithFormat:@"gray_%d",(int)number];
    }
    return [NSString stringWithFormat:@"red_%d",(int)number];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
