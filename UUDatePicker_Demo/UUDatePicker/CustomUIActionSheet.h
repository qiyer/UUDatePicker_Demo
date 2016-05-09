//
//  CustomUIActionSheet.h
//  helpers
//
//  Created by qiye on 16/5/9.
//  Copyright © 2016年 qiye. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomUIActionSheet : UIView

@property(assign)BOOL cannotDissmissSelf;


-(void) setActionView:(UIView *) view;

-(void) showInView:(UIView *) parentView;

-(void) dissmiss;


@end
