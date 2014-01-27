//
//  CTRoundButton.m
//  ColorTone
//
//  Created by Gregory Wieber on 1/26/14.
//  Copyright (c) 2014 Apposite. All rights reserved.
//

#import "CTRoundButton.h"

@interface CTRoundButton ()

@property (nonatomic, strong) UIView *contentView;

@end

@implementation CTRoundButton

+ (id)buttonWithSize:(CGSize)size color:(UIColor *)color
{
    CGRect frame = CGRectMake(0, 0, size.width, size.height);
    CTRoundButton *button = [[CTRoundButton alloc]initWithFrame:frame];
    CGRect smallerFrame = CGRectInset(frame, 12, 12);
    button.contentView = [[UIView alloc] initWithFrame:smallerFrame];
    button.contentView.backgroundColor = color;
    button.contentView.userInteractionEnabled = NO;
    button.contentView.layer.masksToBounds = YES;
    button.contentView.layer.cornerRadius = CGRectGetMidX(button.contentView.bounds);
    [button addSubview:button.contentView];
    
    return button;
}

- (void)animate
{
    [UIView animateWithDuration:.1 delay:0 usingSpringWithDamping:.3 initialSpringVelocity:0 options:0 animations:^{
        self.layer.transform = CATransform3DMakeScale(1.12, 1.12, 1.12);
    } completion:^(BOOL finished) {
        self.layer.transform = CATransform3DIdentity;
        
    }];

}

@end
