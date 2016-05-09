//
//  ViewController.m
//  UUDatePicker_Demo
//
//  Created by qiye on 16/5/9.
//  Copyright © 2016年 qiye. All rights reserved.
//

#import "ViewController.h"
#import "UUDatePicker.h"
#import "CustomUIActionSheet.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *selectLab;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onType1:(id)sender {
    UUDatePicker *datePicker2
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)
                             PickerStyle:1
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 _selectLab.text = [NSString stringWithFormat:@"样式1:  %@年 %@月 %@日",year,month,day];
                                 NSLog(@"样式1: %@",[NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute]);
                             }];
    datePicker2.maxLimitDate = [[NSDate date] dateByAddingTimeInterval:2222];
    CustomUIActionSheet * sheet = [[CustomUIActionSheet alloc] init];
    [sheet setActionView:datePicker2];
    [sheet showInView:self.view];
}

- (IBAction)onType2:(id)sender {
    UUDatePicker *datePicker2
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)
                             PickerStyle:0
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 _selectLab.text = [NSString stringWithFormat:@"样式2: %@年%@月%@日 %@时%@分",year,month,day,hour,minute];
                                 NSLog(@"样式2: %@",[NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute]);
                             }];
    datePicker2.minLimitDate = [[NSDate date] dateByAddingTimeInterval:2222];
    CustomUIActionSheet * sheet = [[CustomUIActionSheet alloc] init];
    [sheet setActionView:datePicker2];
    [sheet showInView:self.view];
}

- (IBAction)onType3:(id)sender {
    UUDatePicker *datePicker2
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)
                             PickerStyle:2
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 _selectLab.text = [NSString stringWithFormat:@"样式3: %@月%@日%@时%@分",month,day,hour,minute];
                                 NSLog(@"样式3: %@",[NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute]);
                             }];
    datePicker2.maxLimitDate = [[NSDate date] dateByAddingTimeInterval:2222];
    CustomUIActionSheet * sheet = [[CustomUIActionSheet alloc] init];
    [sheet setActionView:datePicker2];
    [sheet showInView:self.view];
}

- (IBAction)onType4:(id)sender {
    UUDatePicker *datePicker2
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 200)
                             PickerStyle:4
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 _selectLab.text = [NSString stringWithFormat:@"时间段：  %@-%@-%@ %@",year,month,day,weekDay];
                             }];
    datePicker2.minLimitDate = [[NSDate date]dateByAddingTimeInterval:0];
    CustomUIActionSheet * sheet = [[CustomUIActionSheet alloc] init];
    [sheet setActionView:datePicker2];
    [sheet showInView:self.view];
}
@end
