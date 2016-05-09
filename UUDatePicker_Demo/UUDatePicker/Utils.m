

#import "Utils.h"

#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "sys/utsname.h"

static NSDateFormatter * defaultDateFormate;

@implementation Utils

+(NSDateFormatter *) defaultFormate
{
    if(defaultDateFormate == nil)
    {
        defaultDateFormate = [[NSDateFormatter alloc] init];
        [defaultDateFormate setTimeStyle:NSDateFormatterShortStyle];
        [defaultDateFormate setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

    }
    
    return defaultDateFormate;
}

+(NSString *) formateDay:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy/MM/dd"];
    
    return [dateFormatter stringFromDate:time];
}

+(NSString *) formateStrToMMDD:(NSString *) time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:time];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM-dd"];
    
    return [dateFormatter stringFromDate:date];
}

+(NSString *) formateStrToWeek:(NSString *) time
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:time];
    
    NSArray *weekdays = [NSArray arrayWithObjects: [NSNull null], @"星期天", @"星期一", @"星期二", @"星期三", @"星期四", @"星期五", @"星期六", nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    
    return [weekdays objectAtIndex:theComponents.weekday];
}


+(NSString *) formateMonth:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy年MM月"];
    
    return [dateFormatter stringFromDate:time];
}

+(NSString *) formateMonth2:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyyMM"];
    
    return [dateFormatter stringFromDate:time];
}


+(NSString *) formateDate:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    return [dateFormatter stringFromDate:time];
}

+(NSString *) formateDateNoSS:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    return [dateFormatter stringFromDate:time];
}

+(NSString *) formateDateMMDD:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM月dd日"];
    
    return [dateFormatter stringFromDate:time];
}

+(NSString *) formateDateMMDDHHSS:(NSDate *) time
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"MM月dd日 HH:mm"];
    
    return [dateFormatter stringFromDate:time];
}

+(BOOL) compareDay:(NSDate *) time1 other:(NSDate *) time2
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString * t1 = [dateFormatter stringFromDate:time1];
    NSString * t2 = [dateFormatter stringFromDate:time2];
    return [t1 isEqualToString:t2];
}

+(NSDate *) parseNSDate:(NSString*) strDate
{
    if(strDate == nil || [strDate isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [format setTimeZone: [NSTimeZone timeZoneWithName:@"GMT"]];
    NSDate * date =[format dateFromString:strDate];
    
    return date;
}

+(BOOL) isExpired:(NSDate *) time{
//    return [time compare:[NSDate date]] <= 0 && !;
    return [[NSCalendar currentCalendar] compareDate:time toDate:[NSDate date] toUnitGranularity:NSCalendarUnitDay] < 0;
}


+(UIColor *) colorWithRed:(int) r green:(int) g blue:(int)b
{
    return [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0f];
}

+(NSString*)dateToString:(NSDate*)date
{
    return [NSString stringWithFormat:@"%@",date ];
}

+(NSString*)getUserName:(NSString*)str
{
    if([Utils isPureInt:str]&&str.length==11){
        return [NSString stringWithFormat:@"%@****",  [str substringToIndex:7]];;
    }
    return str;
}

+(BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

+(id) chekcNullClass:(id) obj
{
    if([obj isKindOfClass: [NSNull class]]) {
        return nil;
    } else {
        return obj;
    }
}


+(UIView *) createView:(NSString *) xibFileName
{
    NSArray* nibView =  [[NSBundle mainBundle] loadNibNamed:xibFileName owner:self options:nil];
    return [nibView lastObject];
}

+(BOOL)isValidateEmail:(NSString *)email
{
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}

+(BOOL)isValidatePhoneNumber:(NSString *) phoneNUmber
{
//    NSString *regex =  @"^(\\d{3,4}-)\\d{7,8}$";
    NSString *regex =  @"^\\d{10,11}$";

    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", regex];
    return [emailTest evaluateWithObject:phoneNUmber];
}
+(BOOL)isValidateRegion:(NSString *) region{
    if([region length] != 2){
        return NO;
    }
    NSString *regex =  @"^[A-Za-z]+$";
    
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES%@", regex];
    return [emailTest evaluateWithObject:region];
}
+(BOOL) isValidateBankAccount:(NSString *) account
{
    //TODO::
    return YES;
}

+(void) getObjectData:(id)obj andClass:(Class) class andDic:(NSMutableDictionary *) dic
{
    unsigned int propsCount;
    
    objc_property_t * props = class_copyPropertyList(class, &propsCount);
    
    for(int i = 0;i < propsCount; i++)
    {
        
        objc_property_t prop = props[i];
        
        NSString * propName = [NSString stringWithUTF8String:property_getName(prop)];
        
        id value = [obj valueForKey:propName];
        
        if(value == nil)
        {
            value = [NSNull null];
        }
        else
        {
            value = [self getObjectInternal:value];
        }
        
        [dic setObject:value forKey:propName];
    }

}

+ (NSMutableDictionary*)getObjectData:(id)obj
{
    
    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
    
    [self getObjectData:obj andClass:[obj class] andDic:dic];
    
    if([[obj class] superclass] != [NSObject class])
    {
        [self getObjectData:obj andClass:[[obj class] superclass] andDic:dic];
    }
    
    
    return dic;
}

+(id)getObjectInternal:(id)obj
{
    
    if([obj isKindOfClass:[NSString class]]
       || [obj isKindOfClass:[NSNumber class]]
       || [obj isKindOfClass:[NSNull class]])
    {
        return  obj;
    }
    
    if( [obj isKindOfClass:[NSDate class]])
    {
        NSDate * date = (NSDate *) obj;
        return [[Utils defaultFormate] stringFromDate:date];
    }
    
    if([obj isKindOfClass:[NSArray class]])
    {
        
        NSArray * objarr = obj;
        
        NSMutableArray * arr = [NSMutableArray arrayWithCapacity:objarr.count];
        
        for(int i = 0;i < objarr.count; i++)
        {
            [arr setObject:[self getObjectInternal:[objarr objectAtIndex:i]] atIndexedSubscript:i];
        }
        
        return arr;
    }
    
    if([obj isKindOfClass:[NSDictionary class]])
    {
        
        NSDictionary * objdic = obj;
        
        NSMutableDictionary * dic = [NSMutableDictionary dictionaryWithCapacity:[objdic count]];
        
        for(NSString *key in objdic.allKeys)
        {
            [dic setObject:[self getObjectInternal:[objdic objectForKey:key]] forKey:key];
        }     
        
        return dic;
    } 
    
    return [self getObjectData:obj];
}


+ (NSString *) convertObj2Json:(id) classInstance
{
    
    Class clazz = [classInstance class];
    u_int count;
    
    objc_property_t * properties = class_copyPropertyList(clazz, &count);
    NSMutableArray* propertyArray = [NSMutableArray arrayWithCapacity:count];
    NSMutableArray* valueArray = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count ; i++)
    {
        objc_property_t prop=properties[i];
        const char* propertyName = property_getName(prop);
        [propertyArray addObject:[NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding]];
        
        //TODO::
        id value = nil; //objc_msgSend(classInstance, NSSelectorFromString([NSString stringWithUTF8String:propertyName]));
        if(value ==nil)
            [valueArray addObject:@""];
        else {
            [valueArray addObject:value];
        }
    }
    
    free(properties);
    
    NSDictionary* dtoDic = [NSDictionary dictionaryWithObjects:valueArray forKeys:propertyArray];
    
    return [Utils dictionary2String:dtoDic];
}

+(NSString *) dictionary2String:(NSDictionary *) dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:&error];
    NSString *json =[[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return json;
}



+(NSMutableURLRequest *) createHttpRequest:(NSString *) strurl andMethod:(NSString *) methood
{
    NSURL * url = [NSURL URLWithString:[strurl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    [request setHTTPMethod:methood];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    return request;
}


+(UIImage *) createImageWithColor: (UIColor *) color
{
    CGRect rect=CGRectMake(0.0f, 0.0f, 2.0f, 2.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize
{
    UIGraphicsBeginImageContext(CGSizeMake(reSize.width, reSize.height));
    [image drawInRect:CGRectMake(0, 0, reSize.width, reSize.height)];
    UIImage *reSizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return reSizeImage;
    
}


+(void)presentViewController:(UIViewController*)model by:(UIViewController*)main{
    CATransition *animation = [CATransition animation];
    
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.subtype = kCATransitionFromRight;
    [main.view.window.layer addAnimation:animation forKey:nil];
    [main presentViewController:model animated:NO completion:nil];
}
+(void)dissmissViewController:(UIViewController*)model{
    CATransition *animation = [CATransition animation];
    
    animation.duration = 0.3;
    animation.type = kCATransitionPush;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.subtype = kCATransitionFromLeft;
    [model.view.window.layer addAnimation:animation forKey:nil];
    [model dismissViewControllerAnimated:NO completion:nil];
}

+(NSString*)parseDuration:(long)runtime{
    int hour = (int)runtime/3600;
    int minute = (runtime%3600 / 60);
    int second = (runtime%3600 % 60);
    NSMutableString * string = [NSMutableString stringWithString:@""];
    if (hour > 0) {
        [string appendString:[NSString stringWithFormat:@"%dhrs",hour]];
    }
    if (minute > 0) {
        if (hour > 0) {
            [string appendString:@" "];
        }
        [string appendString:[NSString stringWithFormat:@"%dmin",minute]];
    }
    if (hour <= 0) {
        if (minute > 0) {
            [string appendString:@" "];
        }
        [string appendString:[NSString stringWithFormat:@"%dsec",second]];
    }
    
    return string;
}

+ (NSAttributedString *)attributeString:(NSArray *)strings attributes:(NSArray *)attributes
{
    NSString *concate = [NSString string];
    NSMutableArray *ranges = [NSMutableArray array];
    CGFloat offset = 0;
    for (NSInteger i = 0; i < strings.count; i++) {
        NSString *str = strings[i];
        concate = [concate stringByAppendingString:str];
        NSRange range = NSMakeRange(offset, str.length);
        [ranges addObject:NSStringFromRange(range)];
        offset += str.length;
    }
    
    NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:concate];
    NSInteger count = MIN(ranges.count, attributes.count);
    for (NSInteger i = 0; i < count; i++) {
        NSRange range = NSRangeFromString(ranges[i]);
        [attributeString setAttributes:attributes[i] range:range];
    }
    return attributeString;
}

+ (UIViewController*)topViewController:(UIViewController*)rootViewController {
    if (rootViewController == nil) {
        rootViewController = [[[UIApplication sharedApplication] keyWindow] rootViewController];
    }
    [[[UIApplication sharedApplication] keyWindow] rootViewController];
    if ([rootViewController isKindOfClass:[UITabBarController class]]) {
        UITabBarController* tabBarController = (UITabBarController*)rootViewController;
        return [self topViewController:tabBarController.selectedViewController];
    } else if ([rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController* navigationController = (UINavigationController*)rootViewController;
        return [self topViewController:navigationController.visibleViewController];
    } else if (rootViewController.presentedViewController) {
        UIViewController* presentedViewController = rootViewController.presentedViewController;
        return [self topViewController:presentedViewController];
    } else {
        return rootViewController;
    }
    
}
@end
