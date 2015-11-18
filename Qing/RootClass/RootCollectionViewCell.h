//
//  RootCollectionViewCell.h
//  Qing
//
//  Created by Maka on 15/11/18.
//  Copyright © 2015年 maka. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong) id info;

+(CGFloat)heightForInfo:(id)info;

@end
