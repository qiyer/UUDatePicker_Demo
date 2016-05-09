
#define RGBAlpha(r, g, b, a)     [UIColor colorWithRed:((r) / 255.0) green:((g) / 255.0) blue:((b) / 255.0) alpha:(a)]
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(NSDateFormatter *) defaultFormate;
+(NSString *) formateDay:(NSDate *) time;
+(NSString *) formateMonth:(NSDate *) time;
+(NSString *) formateMonth2:(NSDate *) time;
+(NSString *) formateDate:(NSDate *) time;
+(NSString *) formateDateNoSS:(NSDate *) time;
+(NSString *) formateDateMMDD:(NSDate *) time;
+(NSString *) formateDateMMDDHHSS:(NSDate *) time;
+(NSString *) formateStrToMMDD:(NSString *) time;
+(NSString *) formateStrToWeek:(NSString *) time;
+(BOOL) compareDay:(NSDate *) time1 other:(NSDate *) time2;
+(NSDate *) parseNSDate:(NSString*) strDate;
+(BOOL) isExpired:(NSDate *) time;

+(UIColor *) colorWithRed:(int) r green:(int) g blue:(int)b;

+(NSString*)dateToString:(NSDate*)date;

+(id) chekcNullClass:(id) obj;

+(NSString*)getUserName:(NSString*)str;
+(BOOL)isPureInt:(NSString*)string;

+(UIView *) createView:(NSString *) xibFileName;

+(BOOL) isValidateEmail:(NSString *)  email;
+(BOOL) isValidateRegion:(NSString *) region;
+(BOOL) isValidatePhoneNumber:(NSString *) phoneNUmber;
+(BOOL) isValidateBankAccount:(NSString *) account;

+(NSMutableDictionary *) getObjectData:(id)obj;

+(NSString *) convertObj2Json:(id) classInstance;

+(NSString *) dictionary2String:(NSDictionary *) dict;

+(NSMutableURLRequest *) createHttpRequest:(NSString *) strurl andMethod:(NSString *) methood;

+(UIImage *) createImageWithColor: (UIColor *) color;

+(UIImage *)reSizeImage:(UIImage *)image toSize:(CGSize)reSize;
+(void)presentViewController:(UIViewController*)model by:(UIViewController*)main;
+(void)dissmissViewController:(UIViewController*)model;

+(NSString*)parseDuration:(long)runtime;
+ (NSAttributedString *)attributeString:(NSArray *)strings attributes:(NSArray *)attributes;
+ (UIViewController*)topViewController:(UIViewController*)rootViewController ;
@end