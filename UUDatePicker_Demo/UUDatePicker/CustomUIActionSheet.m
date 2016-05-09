//
//  CustomUIActionSheet.m
//  helpers
//
//  Created by qiye on 16/5/9.
//  Copyright © 2016年 qiye. All rights reserved.
//

#import "CustomUIActionSheet.h"

@implementation CustomUIActionSheet {
    
    __strong UIView * actionView;
}



-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet * touchess = [event touchesForView:actionView];
    
    if(touchess == nil && !self.cannotDissmissSelf)
    {
        [self dissmiss];
    }
}


-(void) setActionView:(UIView *) view
{
    actionView = view;
    actionView.userInteractionEnabled = YES;
    [actionView setTranslatesAutoresizingMaskIntoConstraints:NO];
        
    [self addSubview:actionView];
    
    CGRect viewFrame = actionView.frame;
    
    NSLayoutConstraint *viewLeft = [NSLayoutConstraint constraintWithItem:actionView
                                                                attribute:NSLayoutAttributeLeading
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeLeading
                                                               multiplier:1
                                                                 constant:0];
    
    NSLayoutConstraint *viewRight = [NSLayoutConstraint constraintWithItem:actionView
                                                                attribute:NSLayoutAttributeTrailing
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeTrailing
                                                               multiplier:1
                                                                 constant:0];
    
    NSLayoutConstraint *viewBottom = [NSLayoutConstraint constraintWithItem:actionView
                                                               attribute:NSLayoutAttributeBottom
                                                               relatedBy:NSLayoutRelationEqual
                                                                  toItem:self
                                                               attribute:NSLayoutAttributeBottom
                                                              multiplier:1
                                                                constant:0];
    NSLayoutConstraint *viewHeight = [NSLayoutConstraint constraintWithItem:view
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationGreaterThanOrEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1
                                                                   constant:CGRectGetHeight(viewFrame)];
    // 把约束添加到父视图上.
    [self addConstraints:@[viewLeft, viewRight, viewBottom, viewHeight]];
}



-(void) showInView:(UIView *) parentView
{
    CGRect frame = parentView.frame;
    frame.origin.x = frame.origin.y = 0;
    self.frame = frame;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.0f];
    [parentView addSubview:self];
    
    CGRect frame2 = actionView.frame;
    frame2.origin.y = frame.size.height;
    frame2.size.width = self.frame.size.width;
    actionView.frame = frame2;
    [actionView setNeedsLayout];
    
    
    
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.3];//动画持续时间
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];//动画速度
    [UIView setAnimationTransition: UIViewAnimationTransitionNone//类型
                           forView:actionView
                             cache:YES];
    
    //self.alpha = 0.6f;
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5f];
    
    frame2.origin.y = frame.size.height - frame2.size.height;
    actionView.frame = frame2;
    
    [UIView commitAnimations];
}

-(void) dissmiss
{
    [UIView beginAnimations:@"Curl"context:nil];//动画开始
    [UIView setAnimationDuration:0.3];//动画持续时间
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];//动画速度
    [UIView setAnimationTransition: UIViewAnimationTransitionNone//类型
                           forView:actionView
                             cache:YES];
    [UIView setAnimationDelegate:self];//添加委托
    [UIView setAnimationDidStopSelector:@selector(animationDidStop)];// 实现回调
    
    CGRect frame2 = actionView.frame;
    frame2.origin.y = self.frame.size.height;
    actionView.frame = frame2;
    //self.alpha = 0.0f;
    
    [UIView commitAnimations];
}

-(void) animationDidStop
{
    [actionView removeFromSuperview];
    [self removeFromSuperview];
}
@end