//
//  UUDatePicker.m
//  1111
//
//  Created by shake on 14-7-24.
//  Copyright (c) 2014年 uyiuyao. All rights reserved.
//

#import "UUDatePicker.h"
#import "UUDatePicker_DateModel.h"
#import "Utils.h"

#define UUPICKER_MAXDATE 2050
#define UUPICKER_MINDATE 1850

#define UUPICKER_MONTH 12
#define UUPICKER_HOUR 24
#define UUPICKER_MINUTE 60
#define UUPICKER_PERIOD 8

#define UU_GRAY [UIColor redColor];
#define UU_BLACK [UIColor blackColor];

#ifndef isIOS7
#define isIOS7  ([[[UIDevice currentDevice]systemVersion]floatValue] >= 7.0)
#endif

@interface UUDatePicker ()
{
    UIPickerView *myPickerView;
    
    //日期存储数组
    NSMutableArray *yearArray;
    NSMutableArray *monthArray;
    NSMutableArray *dayArray;
    NSMutableArray *hourArray;
    NSMutableArray *minuteArray;
    NSMutableArray *timePeriodArray;
    
    //限制model
    UUDatePicker_DateModel *maxDateModel;
    UUDatePicker_DateModel *minDateModel;
    
    //记录位置
    NSInteger yearIndex;
    NSInteger monthIndex;
    NSInteger dayIndex;
    NSInteger hourIndex;
    NSInteger minuteIndex;
    NSInteger periodIndex;
    NSInteger curPeriodIndex;
    BOOL isPeriodMore;
}

@property (nonatomic, copy) FinishBlock finishBlock;

@end

@implementation UUDatePicker

-(id)initWithframe:(CGRect)frame Delegate:(id<UUDatePickerDelegate>)delegate PickerStyle:(DateStyle)uuDateStyle
{
    self.datePickerStyle = uuDateStyle;
    self.delegate = delegate;
    return [self initWithFrame:frame];
}

- (id)initWithframe:(CGRect)frame PickerStyle:(DateStyle)uuDateStyle didSelected:(FinishBlock)finishBlock
{
    self.datePickerStyle = uuDateStyle;
    self.finishBlock = finishBlock;
    return [self initWithFrame:frame];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =[UIColor whiteColor];
    }
    return self;
}
- (id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor =[UIColor whiteColor];
    }
    return self;
}

#pragma mark - 初始化赋值操作
- (NSMutableArray *)ishave:(id)mutableArray
{
    if (mutableArray)
        [mutableArray removeAllObjects];
    else
        mutableArray = [NSMutableArray array];
    return mutableArray;
}

//进行初始化
- (void)drawRect:(CGRect)rect
{
    if (self.frame.size.height<216 || self.frame.size.width<320)
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, [[UIScreen mainScreen] bounds].size.width, 216);

    yearArray   = [self ishave:yearArray];
    monthArray  = [self ishave:monthArray];
    dayArray    = [self ishave:dayArray];
    hourArray   = [self ishave:hourArray];
    minuteArray = [self ishave:minuteArray];
    timePeriodArray = [self ishave:timePeriodArray];
    
    //赋值
    for (int i=0; i<UUPICKER_MINUTE; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (0<i && i<=UUPICKER_MONTH)
            [monthArray addObject:num];
        if (i<UUPICKER_HOUR)
            [hourArray addObject:num];
        [minuteArray addObject:num];
    }
    for (int i=UUPICKER_MINDATE; i<UUPICKER_MAXDATE; i++) {
        NSString *num = [NSString stringWithFormat:@"%d",i];
        [yearArray addObject:num];
    }
    if (!self.isAccompany) {
        timePeriodArray = [NSMutableArray arrayWithObjects:@"07:30-08:30",@"08:30-09:30",@"09:30-10:30",@"10:30-11:30",@"12:30-13:30",@"13:30-14:30",@"14:30-15:30",@"15:30-16:30", nil];
    }else{
        
        timePeriodArray = [NSMutableArray arrayWithObjects:@"07:00",@"07:30",@"08:00",@"08:30",@"09:00",@"09:30",@"10:00",@"10:30",@"11:00",@"11:30",@"12:00",@"12:30",@"13:00",@"13:30",@"14:00",@"14:30",@"15:00",@"15:30",@"16:00",@"16:30",@"17:00",@"17:30",@"18:00", nil];
    }
    if(_isChildren){
        timePeriodArray = [NSMutableArray arrayWithObjects:@"16:30-17:30",@"17:30-18:30",@"18:30-19:30",@"19:30-20:30",@"20:30-21:30",@"21:30-22:30",@"22:30-23:30",nil];
    }
    
    //最大最小限制
    if (self.maxLimitDate) {
        maxDateModel = [[UUDatePicker_DateModel alloc]initWithDate:self.maxLimitDate];
    }else{
        self.maxLimitDate = [self dateFromString:@"204912312359" withFormat:@"yyyyMMddHHmm"];
        maxDateModel = [[UUDatePicker_DateModel alloc]initWithDate:self.maxLimitDate];
    }
    //最小限制
    if (self.minLimitDate) {
        if(self.datePickerStyle == UUDateStyle_TimeQuantum){
            self.minLimitDate = [[NSDate date]dateByAddingTimeInterval:0];
        }
        minDateModel = [[UUDatePicker_DateModel alloc]initWithDate:self.minLimitDate];
    }else{
        self.minLimitDate = [self dateFromString:@"197001010000" withFormat:@"yyyyMMddHHmm"];
        minDateModel = [[UUDatePicker_DateModel alloc]initWithDate:self.minLimitDate];
    }
    
    //获取当前日期，储存当前时间位置
    NSArray *indexArray = [self getNowDate:self.ScrollToDate];
    
    if(self.datePickerStyle == UUDateStyle_TimeQuantum&&minDateModel.hour.intValue >= 15){
        NSNumber* year_ = indexArray[0];
        NSNumber* month_ = indexArray[1];
        NSNumber* day_ = indexArray[2];

        NSDate *date = [self dateFromString:[NSString stringWithFormat:@"%@%@%@%@%@",yearArray[year_.intValue],monthArray[month_.intValue],dayArray[day_.intValue],hourArray[0],minuteArray[0]] withFormat:@"yyyyMMddHHmm"];
        self.minLimitDate = date;
        minDateModel = [[UUDatePicker_DateModel alloc]initWithDate:self.minLimitDate];
    }

    BOOL isAgain = NO;
    if (myPickerView) {
        [myPickerView removeFromSuperview];
        myPickerView = nil;
        isAgain = YES;
    }
    myPickerView = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, self.frame.size.height)];
    myPickerView.showsSelectionIndicator = YES;
    myPickerView.backgroundColor = [UIColor clearColor];
    myPickerView.delegate = self;
    myPickerView.dataSource = self;
    [self addSubview:myPickerView];
    
    //调整为现在的时间
    for (int i=0; i<indexArray.count; i++) {
        [myPickerView selectRow:[indexArray[i] integerValue] inComponent:i animated:NO];
    }
    [self playTheDelegate];
    
    UIButton * cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(0, 0, 60, 40);
    [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self addSubview:cancelButton];
    [cancelButton addTarget:self action:@selector(buttonCancel:) forControlEvents:UIControlEventTouchUpInside];
    UIButton * sureButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    sureButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width - 60, 0, 60, 40);
    [sureButton setTitle:@"确定" forState:UIControlStateNormal];
    [sureButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
    [self addSubview:sureButton];
    [sureButton addTarget:self action:@selector(buttonSure:) forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 调整颜色

-(void)buttonCancel:(id)sender
{
    if (self.finishBlock) {
        self.finishBlock(@"",@"",@"",@"",@"",@"");
    }
    if (_sheet) {
        [_sheet dissmiss];
    }
//     [self removeFromSuperview];
}

-(void)buttonSure:(id)sender
{
    if (_sheet) {
        [_sheet dissmiss];
    }
//     [self removeFromSuperview];
}

//获取当前时间解析及位置
- (NSArray *)getNowDate:(NSDate *)date
{
    NSDate *dateShow;
    if (date) {
        dateShow = date;
    }else{
        dateShow = [NSDate date];
    }
    UUDatePicker_DateModel *model = [[UUDatePicker_DateModel alloc]initWithDate:dateShow];
    
    [self DaysfromYear:[model.year integerValue] andMonth:[model.month integerValue]];
    
    yearIndex = [model.year intValue]-UUPICKER_MINDATE;
    monthIndex = [model.month intValue]-1;
    dayIndex = [model.day intValue]-1;
    hourIndex = [model.hour intValue]-0;
    minuteIndex = [model.minute intValue]-0;
    periodIndex = 0;
    
    NSNumber *year   = [NSNumber numberWithInteger:yearIndex];
    NSNumber *month  = [NSNumber numberWithInteger:monthIndex];
    NSNumber *day    = [NSNumber numberWithInteger:dayIndex];
    NSNumber *hour   = [NSNumber numberWithInteger:hourIndex];
    NSNumber *minute = [NSNumber numberWithInteger:minuteIndex];
    NSNumber *period = [NSNumber numberWithInteger:periodIndex];

    if (self.datePickerStyle == UUDateStyle_YearMonthDayHourMinute)
        return @[year,month,day,hour,minute];
    if (self.datePickerStyle == UUDateStyle_YearMonthDay)
        return @[year,month,day];
    if (self.datePickerStyle == UUDateStyle_MonthDayHourMinute)
        return @[month,day,hour,minute];
    if (self.datePickerStyle == UUDateStyle_HourMinute)
        return @[hour,minute];
    if (self.datePickerStyle == UUDateStyle_TimeQuantum&&_isAccompany){
        if (model.hour.intValue > 17||(model.hour.intValue == 17&&model.minute.intValue>30)) {
            dateShow = [[NSDate date]dateByAddingTimeInterval:60*60*24];
            UUDatePicker_DateModel *model = [[UUDatePicker_DateModel alloc]initWithDate:dateShow];
            [self DaysfromYear:[model.year integerValue] andMonth:[model.month integerValue]];
            yearIndex = [model.year intValue]-UUPICKER_MINDATE;
            monthIndex = [model.month intValue]-1;
            dayIndex = [model.day intValue]-1;
            
            year   = [NSNumber numberWithInteger:yearIndex];
            month  = [NSNumber numberWithInteger:monthIndex];
            day    = [NSNumber numberWithInteger:dayIndex];
            
            isPeriodMore = YES;
            
        }else{
            
            if(model.hour.intValue<6||(model.hour.intValue==6&&model.minute.intValue<31)){
                periodIndex = 0;
            }else if(model.hour.intValue<7){
                periodIndex = 1;
            }else if(model.hour.intValue==7&&model.minute.intValue<30){
                periodIndex = 2;
            }else if(model.hour.intValue<8){
                periodIndex = 3;
            }else if(model.hour.intValue==8&&model.minute.intValue<30){
                periodIndex = 4;
            }else if(model.hour.intValue<9){
                periodIndex = 5;
            }else if(model.hour.intValue==9&&model.minute.intValue<30){
                periodIndex = 6;
            }else if(model.hour.intValue<10){
                periodIndex = 7;
            }else if(model.hour.intValue==10&&model.minute.intValue<30){
                periodIndex = 8;
            }else if(model.hour.intValue<11){
                periodIndex = 9;
            }else if(model.hour.intValue==11&&model.minute.intValue<30){
                periodIndex = 10;
            }else if(model.hour.intValue<12){
                periodIndex = 11;
            }else if(model.hour.intValue==12&&model.minute.intValue<30){
                periodIndex = 12;
            }else if(model.hour.intValue<13){
                periodIndex = 13;
            }else if(model.hour.intValue==13&&model.minute.intValue<30){
                periodIndex = 14;
            }else if(model.hour.intValue<14){
                periodIndex = 15;
            }else if(model.hour.intValue==14&&model.minute.intValue<30){
                periodIndex = 16;
            }else if(model.hour.intValue<15){
                periodIndex = 17;
            }else if(model.hour.intValue==15&&model.minute.intValue<30){
                periodIndex = 18;
            }else if(model.hour.intValue<16){
                periodIndex = 19;
            }else if(model.hour.intValue==16&&model.minute.intValue<30){
                periodIndex = 20;
            }else if(model.hour.intValue<17){
                periodIndex = 21;
            }else if(model.hour.intValue==17&&model.minute.intValue<30){
                periodIndex = 22;
            }

            
            period    = [NSNumber numberWithInteger:periodIndex];
            curPeriodIndex = periodIndex;
            
            isPeriodMore = NO;
            
        }
        return @[year,month,day,period];
    }
    if (self.datePickerStyle == UUDateStyle_TimeQuantum&&_isChildren){
        if (model.hour.intValue > 22) {
            dateShow = [[NSDate date]dateByAddingTimeInterval:60*60*24];
            UUDatePicker_DateModel *model = [[UUDatePicker_DateModel alloc]initWithDate:dateShow];
            [self DaysfromYear:[model.year integerValue] andMonth:[model.month integerValue]];
            yearIndex = [model.year intValue]-UUPICKER_MINDATE;
            monthIndex = [model.month intValue]-1;
            dayIndex = [model.day intValue]-1;
            
            year   = [NSNumber numberWithInteger:yearIndex];
            month  = [NSNumber numberWithInteger:monthIndex];
            day    = [NSNumber numberWithInteger:dayIndex];
            
            isPeriodMore = YES;
            
        }else{
            
            if(model.hour.intValue<16){
                periodIndex = 0;
            }else if(model.hour.intValue<17){
                periodIndex = 1;
            }else if(model.hour.intValue<18){
                periodIndex = 2;
            }else if(model.hour.intValue<19){
                periodIndex = 3;
            }else if(model.hour.intValue<20){
                periodIndex = 4;
            }else if(model.hour.intValue<21){
                periodIndex = 5;
            }else if(model.hour.intValue<22){
                periodIndex = 6;
            }else if(model.hour.intValue<23){
                periodIndex = 7;
            }
            
            
            period    = [NSNumber numberWithInteger:periodIndex];
            curPeriodIndex = periodIndex;
            
            isPeriodMore = NO;
            
        }
        return @[year,month,day,period];
    }
    if (self.datePickerStyle == UUDateStyle_TimeQuantum){
        if (model.hour.intValue > 15||(model.hour.intValue == 15&&model.minute.intValue>1)) {
            dateShow = [[NSDate date]dateByAddingTimeInterval:60*60*24];
            UUDatePicker_DateModel *model = [[UUDatePicker_DateModel alloc]initWithDate:dateShow];
            [self DaysfromYear:[model.year integerValue] andMonth:[model.month integerValue]];
            yearIndex = [model.year intValue]-UUPICKER_MINDATE;
            monthIndex = [model.month intValue]-1;
            dayIndex = [model.day intValue]-1;
            
            year   = [NSNumber numberWithInteger:yearIndex];
            month  = [NSNumber numberWithInteger:monthIndex];
            day    = [NSNumber numberWithInteger:dayIndex];
            
            isPeriodMore = YES;
            
        }else{
            
            if(model.hour.intValue<7){
                periodIndex = 0;
            }else if(model.hour.intValue<8){
                periodIndex = 1;
            }else if(model.hour.intValue<9){
                periodIndex = 2;
            }else if(model.hour.intValue<10){
                periodIndex = 3;
            }else if(model.hour.intValue<12){
                periodIndex = 4;
            }else if(model.hour.intValue<13){
                periodIndex = 5;
            }else if(model.hour.intValue<14){
                periodIndex = 6;
            }else if(model.hour.intValue<15){
                periodIndex = 7;
            }
            
            
            period    = [NSNumber numberWithInteger:periodIndex];
            curPeriodIndex = periodIndex;
            
            isPeriodMore = NO;
            
        }
        return @[year,month,day,period];
    }
    if (self.datePickerStyle == UUDateStyle_TimeQuantum){

    }
    return nil;
}

- (void)creatValuePointXs:(NSArray *)xArr withNames:(NSArray *)names
{
    for (int i=0; i<xArr.count; i++) {
        [self addLabelWithNames:names[i] withPointX:[xArr[i] intValue]];
    }
}

- (void)addLabelWithNames:(NSString *)name withPointX:(NSInteger)point_x
{
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(point_x, 99, 20, 20)];
    label.text = name;
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:18];
    label.textColor = [UIColor blackColor];
    label.layer.shadowColor = [[UIColor whiteColor] CGColor];
    label.layer.shadowOpacity = 0.5;
    label.layer.shadowRadius = 5;
    label.backgroundColor = [UIColor clearColor];
    [self addSubview:label];
}

#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    int width = [[UIScreen mainScreen] bounds].size.width;
    NSString * x1 = (IS_IPHONE_4_OR_LESS||IS_IPHONE_5)?[NSString stringWithFormat:@"%.1f",width*0.24]:[NSString stringWithFormat:@"%.1f",width*0.28];
    NSString * x2 = [NSString stringWithFormat:@"%.1f",width*0.42];
    NSString * x3 = [NSString stringWithFormat:@"%.1f",width*0.56];
    NSString * x4 = (IS_IPHONE_4_OR_LESS||IS_IPHONE_5)?[NSString stringWithFormat:@"%.1f",width*0.74]:[NSString stringWithFormat:@"%.1f",width*0.71];
    NSString * x5 = (IS_IPHONE_4_OR_LESS||IS_IPHONE_5)?[NSString stringWithFormat:@"%.1f",width*0.92]:[NSString stringWithFormat:@"%.1f",width*0.86];
    
    NSString * x6 = [NSString stringWithFormat:@"%.1f",width*0.42];
    NSString * x7 = [NSString stringWithFormat:@"%.1f",width*0.57];
    NSString * x8 = [NSString stringWithFormat:@"%.1f",width*0.83];
    
    if (self.datePickerStyle == UUDateStyle_YearMonthDayHourMinute){
        if (isIOS7) {

            [self creatValuePointXs:@[x1,x2,x3,x4,x5]
                          withNames:@[@"年",@"月",@"日",@"时",@"分"]];
        }
        return 5;
    }
    if (self.datePickerStyle == UUDateStyle_YearMonthDay){
        if (isIOS7) {
            [self creatValuePointXs:@[x6,x7,x8]
                      withNames:@[@"年",@"月",@"日"]];
            }
        return 3;
    }
    if (self.datePickerStyle == UUDateStyle_MonthDayHourMinute){
        if (isIOS7) {
        [self creatValuePointXs:@[@"90",@"160",@"230",@"285"]
                      withNames:@[@"月",@"日",@"时",@"分"]];
            }
        return 4;
    }
    if (self.datePickerStyle == UUDateStyle_HourMinute){
        if (isIOS7) {
        [self creatValuePointXs:@[@"140",@"245"]
                      withNames:@[@"时",@"分"]];
            }
        return 2;
    }
    if (self.datePickerStyle == UUDateStyle_TimeQuantum){
        if (isIOS7) {
            [self creatValuePointXs:@[x1,x2,x3,x4]
                          withNames:@[@"年",@"月",@"日",@" "]];
        }
        return 4;
    }
    
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if (self.datePickerStyle == UUDateStyle_YearMonthDayHourMinute){
        if (component == 0) return UUPICKER_MAXDATE-UUPICKER_MINDATE;
        if (component == 1) return UUPICKER_MONTH;
        if (component == 2) {
            return [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
        }
        if (component == 3) return UUPICKER_HOUR;
        if (component == 4) return UUPICKER_MINUTE;
    }
    if (self.datePickerStyle == UUDateStyle_YearMonthDay)
    {
        if (component == 0) return UUPICKER_MAXDATE-UUPICKER_MINDATE;
        if (component == 1) return UUPICKER_MONTH;
        if (component == 2){
            return [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
        }
    }
    if (self.datePickerStyle == UUDateStyle_MonthDayHourMinute)
    {
        if (component == 0) return UUPICKER_MONTH;
        if (component == 1){
            return [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
        }
        if (component == 2) return UUPICKER_HOUR;
        if (component == 3) return UUPICKER_MINUTE;
    }
    if (self.datePickerStyle == UUDateStyle_HourMinute)
    {
        if (component == 0) return UUPICKER_HOUR;
        else                return UUPICKER_MINUTE;
    }
    if (self.datePickerStyle == UUDateStyle_TimeQuantum){
        if (component == 0) return UUPICKER_MAXDATE-UUPICKER_MINDATE;
        if (component == 1) return UUPICKER_MONTH;
        if (component == 2) {
            return [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
        }
//        if (component == 3) return UUPICKER_PERIOD;
        if (component == 3) return timePeriodArray.count;
    }
    return 0;
}

#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    switch (self.datePickerStyle) {
        case UUDateStyle_YearMonthDayHourMinute:{
            if (component==0) return 70;
            if (component==1) return 50;
            if (component==2) return 50;
            if (component==3) return 50;
            if (component==4) return 50;
        }
            break;
        case UUDateStyle_YearMonthDay:{
            if (component==0) return 70;
            if (component==1) return 100;
            if (component==2) return 50;
        }
            break;
        case UUDateStyle_MonthDayHourMinute:{
            if (component==0) return 70;
            if (component==1) return 60;
            if (component==2) return 60;
            if (component==3) return 60;
        }
            break;
        case UUDateStyle_HourMinute:{
            if (component==0) return 100;
            if (component==1) return 100;
        }
            break;
            
        case UUDateStyle_TimeQuantum:{
            if (component==0) return 70;
            if (component==1) return 50;
            if (component==2) return 50;
            if (component==3) return 120;
        }
            break;
            
        default:
            break;
    }
    
    return 0;
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (self.datePickerStyle) {
        case UUDateStyle_YearMonthDayHourMinute:{
            
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 3) {
                hourIndex = row;
            }
            if (component == 4) {
                minuteIndex = row;
            }
            if (component == 0 || component == 1 || component == 2){
                [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
                if (dayArray.count-1<dayIndex) {
                    dayIndex = dayArray.count-1;
                }
//                [pickerView reloadComponent:2];
                
            }
        }
            break;
            
            
        case UUDateStyle_YearMonthDay:{
            
            if (component == 0) {
                yearIndex = row;
            }
            if (component == 1) {
                monthIndex = row;
            }
            if (component == 2) {
                dayIndex = row;
            }
            if (component == 0 || component == 1){
                [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
                if (dayArray.count-1<dayIndex) {
                    dayIndex = dayArray.count-1;
                }
//                [pickerView reloadComponent:2];
            }
        }
            break;
            
            
        case UUDateStyle_MonthDayHourMinute:{
            if (component == 1) {
                dayIndex = row;
            }
            if (component == 2) {
                hourIndex = row;
            }
            if (component == 3) {
                minuteIndex = row;
            }
            if (component == 0) {
                monthIndex = row;
                if (dayArray.count-1<dayIndex) {
                    dayIndex = dayArray.count-1;
                }
//                [pickerView reloadComponent:1];
            }
                [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];

        }
            break;
            
            
        case UUDateStyle_HourMinute:{
            if (component == 3) {
                hourIndex = row;
            }
            if (component == 4) {
                minuteIndex = row;
            }
        }
            break;
            
        case UUDateStyle_TimeQuantum:{
            if (component == 0) {
                if (row>yearIndex) {
                    isPeriodMore = YES;
                }
                yearIndex = row;
            }
            if (component == 1) {
                if (row>monthIndex) {
                    isPeriodMore = YES;
                }
                monthIndex = row;
            }
            if (component == 2) {
                if (row>dayIndex) {
                    isPeriodMore = YES;
                }
                dayIndex = row;
            }
            if (component == 3) {
                if (row > periodIndex ) {
                    hourIndex ++;
                    if(hourIndex==24) hourIndex =23;
                }else{
                    hourIndex --;
                }
                periodIndex = row;
            }
            if (component == 0 || component == 1 || component == 2){
                [self DaysfromYear:[yearArray[yearIndex] integerValue] andMonth:[monthArray[monthIndex] integerValue]];
                if (dayArray.count-1<dayIndex) {
                    dayIndex = dayArray.count-1;
                }
                if ([pickerView selectedRowInComponent:2] != dayIndex) {
                    [pickerView selectRow:dayIndex inComponent:2 animated:NO];
                }
                //                [pickerView reloadComponent:2];
                NSLog(@"XXXXXXX:%ld  ,%ld , %ld",(long)yearIndex ,(long)monthIndex,(long)dayIndex);
            }
            
        }
            break;
        default:
            break;
    }

    [pickerView reloadAllComponents];
    
    [self playTheDelegate];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UILabel *customLabel = (UILabel *)view;
    if (!customLabel) {
        customLabel = [[UILabel alloc] init];
        customLabel.textAlignment = NSTextAlignmentCenter;
        [customLabel setFont:[UIFont systemFontOfSize:18]];
    }
    UIColor *textColor = [UIColor blackColor];
    NSString *title;
    
    
    
    switch (self.datePickerStyle) {
        case UUDateStyle_YearMonthDayHourMinute:{
            if (component==0) {
                title = yearArray[row];
                textColor = [self returnYearColorRow:row];
            }
            if (component==1) {
                title = monthArray[row];
                textColor = [self returnMonthColorRow:row];
            }
            if (component==2) {
                if (row >= dayArray.count) {
                    row = dayArray.count -1;
                    title = @"";
                }else{
                    title = dayArray[row];
                    textColor = [self returnDayColorRow:row];
                }
            }
            if (component==3) {
                title = hourArray[row];
                textColor = [self returnHourColorRow:row];
            }
            if (component==4) {
                title = minuteArray[row];
                textColor = [self returnMinuteColorRow:row];
            }
        }
            break;
            
            
        case UUDateStyle_YearMonthDay:{
            if (component==0) {
                title = yearArray[row];
                textColor = [self returnYearColorRow:row];
            }
            if (component==1) {
                title = monthArray[row];
                textColor = [self returnMonthColorRow:row];
            }
            if (component==2) {
                if (row >= dayArray.count) {
                    row = dayArray.count -1;
                    title = @"";
                }else{
                    title = dayArray[row];
                    textColor = [self returnDayColorRow:row];
                }
            }
        }
            break;
            
        case UUDateStyle_MonthDayHourMinute:{
            if (component==0) {
                title = monthArray[row];
                textColor = [self returnMonthColorRow:row];
            }
            if (component==1) {
                if (row >= dayArray.count) {
                    row = dayArray.count -1;
                    title = @"";
                }else{
                    title = dayArray[row];
                    textColor = [self returnDayColorRow:row];
                }
            }
            if (component==2) {
                title = hourArray[row];
                textColor = [self returnHourColorRow:row];
            }
            if (component==3) {
                title = minuteArray[row];
                textColor = [self returnMinuteColorRow:row];
            }
        }
            break;
            
        case UUDateStyle_HourMinute:{
            if (component==0) {
                title = hourArray[row];
                textColor = [self returnHourColorRow:row];
            }
            if (component==1) {
                title = minuteArray[row];
                textColor = [self returnMinuteColorRow:row];
            }
        }
            break;
            
        case UUDateStyle_TimeQuantum:{
            if (component==0) {
                title = yearArray[row];
                textColor = [self returnYearColorRow:row];
            }
            if (component==1) {
                title = monthArray[row];
                textColor = [self returnMonthColorRow:row];
            }
            if (component==2) {
                if (row >= dayArray.count) {
                    row = dayArray.count -1;
                    title = @"";
                }else{
                    title = dayArray[row];
                    textColor = [self returnDayColorRow:row];
                }
            }
            if (component==3) {
                title = timePeriodArray[row];
                textColor = [self returnPeriodColorRow:row];
            }
        }
            break;
        default:
            break;
    }
    customLabel.text = title;
    customLabel.textColor = textColor;
    return customLabel;
}

- (void)getFirstDate
{
    [self playTheDelegate];
}

#pragma mark - 代理回调方法
- (void)playTheDelegate
{
    if(hourIndex<0) hourIndex = 0;
    NSDate *date = [self dateFromString:[NSString stringWithFormat:@"%@%@%@%@%@",yearArray[yearIndex],monthArray[monthIndex],dayArray[dayIndex],hourArray[hourIndex],minuteArray[minuteIndex]] withFormat:@"yyyyMMddHHmm"];
    if ([date compare:self.minLimitDate] == NSOrderedAscending) {
        NSArray *array = [self getNowDate:self.minLimitDate];
        for (int i=0; i<array.count; i++) {
            [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
        }
    }else if ([date compare:self.maxLimitDate] == NSOrderedDescending){
        NSArray *array = [self getNowDate:self.maxLimitDate];
        for (int i=0; i<array.count; i++) {
            [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
        }
    }
    
    int weekIndex =[self formateStrToWeekIndex:[NSString stringWithFormat:@"%@-%@-%@",yearArray[yearIndex],monthArray[monthIndex],dayArray[dayIndex]]];
    if(!_isAccompany&&!_isChildren &&self.datePickerStyle == UUDateStyle_TimeQuantum&&![self isHospitalOpen:weekIndex]){
//        [self makeToast:@"该时段医院未开放挂号！" duration:1.0 position:CSToastPositionCenter style:nil];
//        NSLog(@"该时段医院未开放挂号！");
        return;
    }
    
    if(_isAccompany&&self.datePickerStyle == UUDateStyle_TimeQuantum){
        NSString * timeStr =[NSString stringWithFormat:@"%@%@%@%@",yearArray[yearIndex],monthArray[monthIndex],dayArray[dayIndex],timePeriodArray[periodIndex]];
        NSDate *date = [self date2FromString:timeStr withFormat:@"yyyyMMddHH:mm"];
        NSDate *date2 = [[NSDate date]dateByAddingTimeInterval:1800];;
        if ([date compare:date2] == NSOrderedAscending) {
            NSArray *array = [self getNowDate:nil];
            for (int i=0; i<array.count; i++) {
                [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
            }
        }
    }
    
    if(_isChildren&&self.datePickerStyle == UUDateStyle_TimeQuantum){
        NSMutableArray * times = [NSMutableArray arrayWithObjects:@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23", nil];
        NSString * timeStr =[NSString stringWithFormat:@"%@%@%@%@",yearArray[yearIndex],monthArray[monthIndex],dayArray[dayIndex],times[periodIndex]];
        NSDate *date = [self date2FromString:timeStr withFormat:@"yyyyMMddHH"];
        NSDate *date2 = [[NSDate date]dateByAddingTimeInterval:1800];;
        if ([date compare:date2] == NSOrderedAscending) {
            NSArray *array = [self getNowDate:nil];
            for (int i=0; i<array.count; i++) {
                [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
            }
        }
    }

//    if (self.datePickerStyle == UUDateStyle_TimeQuantum&&_isAdult&&[strWeek isEqualToString:@"星期六"]) {
//        NSArray *array = [self getNowDate:self.minLimitDate];
//        for (int i=0; i<array.count; i++) {
//            [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
//        }
//        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.2f];
//    }
//
//    if (self.datePickerStyle == UUDateStyle_TimeQuantum&&[strWeek isEqualToString:@"星期天"]) {
//        NSArray *array = [self getNowDate:self.minLimitDate];
//        for (int i=0; i<array.count; i++) {
//            [myPickerView selectRow:[array[i] integerValue] inComponent:i animated:YES];
//        }
//        [self performSelector:@selector(delayMethod) withObject:nil afterDelay:0.2f];
//    }
    NSString *strWeekDay = [self getWeekDayWithYear:yearArray[yearIndex] month:monthArray[monthIndex] day:dayArray[dayIndex]];
    if (self.datePickerStyle == UUDateStyle_TimeQuantum) {
        strWeekDay = timePeriodArray[periodIndex];
    }
    
    //block 回调
    if (self.finishBlock) {
        self.finishBlock(yearArray[yearIndex],
                         monthArray[monthIndex],
                         dayArray[dayIndex],
                         hourArray[hourIndex],
                         minuteArray[minuteIndex],
                         strWeekDay);
    }
    //代理回调
    [self.delegate uuDatePicker:self
                           year:yearArray[yearIndex]
                          month:monthArray[monthIndex]
                            day:dayArray[dayIndex]
                           hour:hourArray[hourIndex]
                         minute:minuteArray[minuteIndex]
                        weekDay:strWeekDay];
}

-(int) formateStrToWeekIndex:(NSString *) time
{
    if(time==nil)return 1;
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate * date = [formatter dateFromString:time];
    
    NSArray *weekdays = [[NSArray alloc] initWithObjects:[NSNull class],@"7", @"1",  @"2", @"3",  @"4", @"5",  @"6", nil];  ;
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [calendar setTimeZone: timeZone];
    
    NSCalendarUnit calendarUnit = NSCalendarUnitWeekday;
    NSDateComponents *theComponents = [calendar components:calendarUnit fromDate:date];
    NSString * numStr = [weekdays objectAtIndex:theComponents.weekday];
    return numStr.intValue;
}

-(BOOL)isHospitalOpen:(int) week
{
    if(_openDays&&_openDays.length ==7){
        NSString * day = [_openDays substringWithRange:NSMakeRange(week-1, 1)];
        if(day.intValue == 0){
            return NO;
        }
        if(day.intValue == 1){
            return YES;
        }
        if(day.intValue == 2&&periodIndex<4){
            return YES;
        }
        if(day.intValue == 3&&periodIndex>3){
            return YES;
        }
        return NO;
    }
    return NO;
}

-(void)delayMethod{
    [self drawRect:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)];
}

#pragma mark - 数据处理
//通过日期求星期
- (NSString*)getWeekDayWithYear:(NSString*)year month:(NSString*)month day:(NSString*)day
{
    NSInteger yearInt   = [year integerValue];
    NSInteger monthInt  = [month integerValue];
    NSInteger dayInt    = [day integerValue];
    int c = 20;//世纪
    int y = (int)yearInt -1;//年
    int d = (int)dayInt;
    int m = (int)monthInt;
    int w =(y+(y/4)+(c/4)-2*c+(26*(m+1)/10)+d-1)%7;
    NSString *weekDay = @"";
    switch (w) {
        case 0: weekDay = @"周日";    break;
        case 1: weekDay = @"周一";    break;
        case 2: weekDay = @"周二";    break;
        case 3: weekDay = @"周三";    break;
        case 4: weekDay = @"周四";    break;
        case 5: weekDay = @"周五";    break;
        case 6: weekDay = @"周六";    break;
        default:break;
    }
    return weekDay;
}

//根据string返回date
- (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    return date;
}

- (NSDate *)date2FromString:(NSString *)string withFormat:(NSString *)format {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:format];
    NSDate *date = [inputFormatter dateFromString:string];
    return date;
}

- (NSDate *)dateFromDate:(NSDate *)date1{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    
    NSString* str =  [dateFormatter stringFromDate:date1];
    return [self dateFromString:str withFormat:@"yyyyMMddHHmm"];
}

//通过年月求每月天数
- (NSInteger)DaysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
   
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:
        case 3:
        case 5:
        case 7:
        case 8:
        case 10:
        case 12:{
            [self setdayArray:31];
            return 31;
        }
            break;
        case 4:
        case 6:
        case 9:
        case 11:{
            [self setdayArray:30];
            return 30;
        }
            break;
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
            break;
        default:
            break;
    }
    return 0;
}

//设置每月的天数数组
- (void)setdayArray:(NSInteger)num
{
    [dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}

- (UIColor *)returnYearColorRow:(NSInteger)row
{
    if ([yearArray[row] intValue] < [minDateModel.year intValue] || [yearArray[row] intValue] > [maxDateModel.year intValue]) {
        return  UU_GRAY;
    }else{
        return UU_BLACK;
    }
}
- (UIColor *)returnMonthColorRow:(NSInteger)row
{
    
    if ([yearArray[yearIndex] intValue] < [minDateModel.year intValue] || [yearArray[yearIndex] intValue] > [maxDateModel.year intValue]) {
        return UU_GRAY;
    }else if([yearArray[yearIndex] intValue] > [minDateModel.year intValue] && [yearArray[yearIndex] intValue] < [maxDateModel.year intValue]){
        return UU_BLACK;
    }else if ([minDateModel.year intValue]==[maxDateModel.year intValue]){
        if ([monthArray[row] intValue] >= [minDateModel.month intValue] && [monthArray[row] intValue] <= [maxDateModel.month intValue]) {
            return UU_BLACK;
        }else {
            return UU_GRAY;
        }
    }else if ([yearArray[yearIndex] intValue] == [minDateModel.year intValue]){
        if ([monthArray[row] intValue] >= [minDateModel.month intValue]) {
            return UU_BLACK;
        }else{
            return UU_GRAY;
        }
    }else {
        if ([monthArray[row] intValue] > [maxDateModel.month intValue]) {
            return UU_GRAY;
        }else{
            return UU_BLACK;
        }
    }
}

- (UIColor *)returnPeriodColorRow:(NSInteger)row
{
//    NSString *strWeekDay =[Utils formateStrToWeek:[NSString stringWithFormat:@"%@-%@-%@",yearArray[yearIndex],monthArray[monthIndex],dayArray[dayIndex]]];
//    if(_isAdult&&[strWeekDay isEqualToString:@"星期六"]){
//        return UU_GRAY;
//    }else if ([strWeekDay isEqualToString:@"星期天"]) {
//        return UU_GRAY;
//    }else{
//
//    }
    
    if (isPeriodMore) {
        return UU_BLACK;
    }
    if(curPeriodIndex==0&&row < 0){
        return UU_GRAY;
    }
    if(curPeriodIndex==1&&row < 1){
        return UU_GRAY;
    }
    if(curPeriodIndex==2&&row<2){
        return UU_GRAY;
    }
    if(curPeriodIndex==3&&row<3){
        return UU_GRAY;
    }
    if(curPeriodIndex==4&&row<4){
        return UU_GRAY;
    }
    if(curPeriodIndex==5&&row<5){
        return UU_GRAY;
    }
    if(curPeriodIndex==6&&row<6){
        return UU_GRAY;
    }
    if(curPeriodIndex==7&&row<7){
        return UU_GRAY;
    }
    if(curPeriodIndex==8&&row<8){
        return UU_GRAY;
    }
    if(curPeriodIndex==9&&row<9){
        return UU_GRAY;
    }
    if(curPeriodIndex==10&&row<10){
        return UU_GRAY;
    }
    if(curPeriodIndex==11&&row<11){
        return UU_GRAY;
    }
    if(curPeriodIndex==12&&row<12){
        return UU_GRAY;
    }
    if(curPeriodIndex==13&&row<13){
        return UU_GRAY;
    }
    if(curPeriodIndex==14&&row<14){
        return UU_GRAY;
    }
    if(curPeriodIndex==15&&row<15){
        return UU_GRAY;
    }
    if(curPeriodIndex==16&&row<16){
        return UU_GRAY;
    }
    if(curPeriodIndex==17&&row<17){
        return UU_GRAY;
    }
    if(curPeriodIndex==18&&row<18){
        return UU_GRAY;
    }
    if(curPeriodIndex==19&&row<19){
        return UU_GRAY;
    }
    if(curPeriodIndex==20&&row<20){
        return UU_GRAY;
    }
    if(curPeriodIndex==21&&row<21){
        return UU_GRAY;
    }
    if(curPeriodIndex==22&&row<22){
        return UU_GRAY;
    }
    if(curPeriodIndex==23&&row<23){
        return UU_GRAY;
    }
    return UU_BLACK;
}

- (UIColor *)returnDayColorRow:(NSInteger)row
{
    if ([yearArray[yearIndex] intValue] < [minDateModel.year intValue] || [yearArray[yearIndex] intValue] > [maxDateModel.year intValue]) {
        return UU_GRAY;
    }else if([yearArray[yearIndex] intValue] > [minDateModel.year intValue] && [yearArray[yearIndex] intValue] < [maxDateModel.year intValue]){
        return UU_BLACK;
    }else if ([minDateModel.year intValue]==[maxDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] > [minDateModel.month intValue] && [monthArray[monthIndex] intValue] < [maxDateModel.month intValue]) {
            return UU_BLACK;
        }else if ([minDateModel.month intValue]==[maxDateModel.month intValue]){
            if ([dayArray[row] intValue] >= [minDateModel.day intValue] && [dayArray[row] intValue] <= [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else{
                return UU_GRAY;
            }
        }else {
            return UU_GRAY;
        }
    }else if ([yearArray[yearIndex] intValue] == [minDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] < [minDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [minDateModel.month intValue]){
            if ([dayArray[row] intValue] >= [minDateModel.day intValue]) {
                return UU_BLACK;
            }else {
                return UU_GRAY;
            }
        }else{
            return UU_BLACK;
        }
    }else {
        if ([monthArray[monthIndex] intValue] > [maxDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [maxDateModel.month intValue]){
            if ([dayArray[row] intValue] <= [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else{
                return UU_GRAY;
            }
        }else{
            return UU_BLACK;
        }
    }
}
- (UIColor *)returnHourColorRow:(NSInteger)row
{
    if ([yearArray[yearIndex] intValue] < [minDateModel.year intValue] || [yearArray[yearIndex] intValue] > [maxDateModel.year intValue]) {
        return UU_GRAY;
    }else if([yearArray[yearIndex] intValue] > [minDateModel.year intValue] && [yearArray[yearIndex] intValue] < [maxDateModel.year intValue]){
        return UU_BLACK;
    }else if ([minDateModel.year intValue]==[maxDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] > [minDateModel.month intValue] && [monthArray[monthIndex] intValue] < [maxDateModel.month intValue]) {
            return UU_BLACK;
        }else if ([minDateModel.month intValue]==[maxDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] > [minDateModel.day intValue] && [dayArray[dayIndex] intValue] < [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else if ([minDateModel.day intValue]==[maxDateModel.day intValue]){
                if ([hourArray[row] intValue] >= [minDateModel.hour intValue] && [hourArray[row] intValue] <= [maxDateModel.hour intValue]) {
                    return UU_BLACK;
                }else {
                    return UU_GRAY;
                }
            }else{
                return UU_GRAY;
            }
        }else {
            return UU_GRAY;
        }
    }else if ([yearArray[yearIndex] intValue] == [minDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] < [minDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [minDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] < [minDateModel.day intValue]) {
                return UU_GRAY;
            }else if ([dayArray[dayIndex] intValue] == [minDateModel.day intValue]){
                if ([hourArray[row] intValue] < [minDateModel.hour intValue]) {
                    return UU_GRAY;
                }else{
                    return UU_BLACK;
                }
            }else{
                return UU_BLACK;
            }
        }else{
            return UU_BLACK;
        }
    }else {
        if ([monthArray[monthIndex] intValue] > [maxDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [maxDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] < [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else if ([dayArray[dayIndex] intValue] == [maxDateModel.day intValue]){
                if ([hourArray[row] intValue] > [maxDateModel.hour intValue]) {
                    return UU_GRAY;
                }else{
                    return UU_BLACK;
                }
            }else{
                return UU_BLACK;
            }
        }else{
            return UU_BLACK;
        }
    }
}
- (UIColor *)returnMinuteColorRow:(NSInteger)row
{
    
    if ([yearArray[yearIndex] intValue] < [minDateModel.year intValue] || [yearArray[yearIndex] intValue] > [maxDateModel.year intValue]) {
        return UU_GRAY;
    }else if([yearArray[yearIndex] intValue] > [minDateModel.year intValue] && [yearArray[yearIndex] intValue] < [maxDateModel.year intValue]){
        return UU_BLACK;
    }else if ([minDateModel.year intValue]==[maxDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] > [minDateModel.month intValue] && [monthArray[monthIndex] intValue] < [maxDateModel.month intValue]) {
            return UU_BLACK;
        }else if ([minDateModel.month intValue]==[maxDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] > [minDateModel.day intValue] && [dayArray[dayIndex] intValue] < [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else if ([minDateModel.day intValue]==[maxDateModel.day intValue]){
                if ([hourArray[hourIndex] intValue] > [minDateModel.hour intValue] && [hourArray[hourIndex] intValue] < [maxDateModel.hour intValue]) {
                    return UU_BLACK;
                }else if ([minDateModel.hour intValue]==[maxDateModel.hour intValue]){
                    if ([minuteArray[row] intValue] <= [maxDateModel.minute intValue] &&[minuteArray[row] intValue] >= [minDateModel.minute intValue]) {
                        return UU_BLACK;
                    }else{
                        return UU_GRAY;
                    }
                }else{
                    return UU_GRAY;
                }
            }else{
                return UU_GRAY;
            }
        }else {
            return UU_GRAY;
        }
    }else if ([yearArray[yearIndex] intValue] == [minDateModel.year intValue]){
        if ([monthArray[monthIndex] intValue] < [minDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [minDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] < [minDateModel.day intValue]) {
                return UU_GRAY;
            }else if ([dayArray[dayIndex] intValue] == [minDateModel.day intValue]){
                if ([hourArray[hourIndex] intValue] < [minDateModel.hour intValue]) {
                    return UU_GRAY;
                }else if ([hourArray[hourIndex] intValue] == [minDateModel.hour intValue]){
                    if ([minuteArray[row] intValue] < [minDateModel.minute intValue]) {
                        return UU_GRAY;
                    }else{
                        return UU_BLACK;
                    }
                }else{
                    return UU_BLACK;
                }
            }else{
                return UU_BLACK;
            }
        }else{
            return UU_BLACK;
        }
    }else{
        if ([monthArray[monthIndex] intValue] > [maxDateModel.month intValue]) {
            return UU_GRAY;
        }else if([monthArray[monthIndex] intValue] == [maxDateModel.month intValue]){
            if ([dayArray[dayIndex] intValue] < [maxDateModel.day intValue]) {
                return UU_BLACK;
            }else if ([dayArray[dayIndex] intValue] == [maxDateModel.day intValue]){
                if ([hourArray[hourIndex] intValue] > [maxDateModel.hour intValue]) {
                    return UU_GRAY;
                }else if([hourArray[hourIndex] intValue] == [maxDateModel.hour intValue]){
                    if ([minuteArray[row] intValue] <= [maxDateModel.minute intValue]) {
                        return UU_BLACK;
                    }else{
                        return UU_GRAY;
                    }
                }else{
                    return UU_BLACK;
                }
                
                
            }else{
                return UU_BLACK;
            }
        }else{
            return UU_BLACK;
        }
    }
}
@end
