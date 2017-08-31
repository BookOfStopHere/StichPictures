//
//  STImageView.h
//  StitchPictures
//
//  Created by yang on 2017/8/23.
//  Copyright © 2017年 yang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface STImageView : UIImageView
{
    BOOL isEdit;
}


@property (nonatomic, strong) UIImageView *w_imageV;

@property (nonatomic, strong) UIButton *del_btn;



- (void)setEdit:(BOOL)isYES;

- (void)setImage:(UIImage *)image withWater:(UIImage *)w_image;

@end
