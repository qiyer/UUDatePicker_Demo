//
//  UUDatePicker_DateModel.h
//  text_datepicker
//
//  Created by qiye on 16/5/9.
//  Copyright © 2016年 qiye. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UUDatePicker_DateModel : NSObject

@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *month;
@property (nonatomic, retain) NSString *day;
@property (nonatomic, retain) NSString *hour;
@property (nonatomic, retain) NSString *minute;

- (id)initWithDate:(NSDate *)date;

@end
