//
//  TodayViewController.m
//  CalendarWidget
//
//  Created by 张英杰 on 15/7/22.
//  Copyright (c) 2015年 张英杰. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "widgetDayView.h"


#define kScreen_height   [[UIScreen mainScreen] bounds].size.height
#define kScreen_width    [[UIScreen mainScreen] bounds].size.width


@interface TodayViewController () <NCWidgetProviding>
{
    UICollectionView *myCollectView;
    
    NSMutableArray *dataArr;
//    NSMutableArray *classNameArr;
    UIImageView *imageView;
    NSDate* today;
    NSDateComponents *dateTodayComponents;
    NSArray *holidayArr;
    NSArray *workArr;
    NSDateFormatter *dateFormatter;
    BOOL isStartFromOnlinePara;
    int isMondayFirst;
    NSDateComponents * currentMonthComponents;
    
    NSMutableArray *chineseArr;
    
}
@end

static NSCalendar *currentCalendar;

@implementation TodayViewController
@synthesize titleLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.preferredContentSize = CGSizeMake(0, 315);
    imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"毛笔圈"]];
    

    
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc]init];
    }
    [dateFormatter setDateFormat:@"yyyy MM dd"];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    //gqq
    //初始化self.date
    self.date = [NSDate date];

    [self loadDataSource];

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(jumpToApp)];
    [_detailContainerView addGestureRecognizer:tap];

}
-(void)jumpToApp{
    [self.extensionContext openURL:[NSURL URLWithString:@"yourApp://"] completionHandler:^(BOOL success) {
        NSLog(@"open url result:%d",success);
    }];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self configDayViews];
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
//    [self configDayViews];
}

-(void)loadDataSource{
    if (currentCalendar==nil) {
        currentCalendar = [NSCalendar currentCalendar];
    }
    
    dateTodayComponents =[currentCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self.date];
    
    currentMonthComponents = [currentCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:[NSDate date]];
    
    dateTodayComponents.hour = 0;
    dateTodayComponents.minute = 0;
    dateTodayComponents.second = 0;
    today =  [currentCalendar dateFromComponents:dateTodayComponents];
    
    titleLabel.text = [NSString stringWithFormat:@"%ld 年 %ld 月",(long)dateTodayComponents.year,(long)dateTodayComponents.month];
    
    
    currentCalendar.firstWeekday = 2; //2为周一
    
    dateTodayComponents.day = 1;
    //获得当前月的第一天时间
    NSDate* firstDay = [currentCalendar dateFromComponents:dateTodayComponents];
    
    //获得第一天 是周几
    int firstWeekDay = (int)[currentCalendar components:NSCalendarUnitWeekday fromDate:firstDay].weekday;
    int firstDayPosition = (firstWeekDay + 8)%8;
    
    //第一行第一天  跟  当前月第一天    的差距天数
    
    int dayDiff = 1 - firstDayPosition + 1 + isMondayFirst;
    //日历第一个天的日期
    dateTodayComponents.day = dayDiff;
    
    [dataArr removeAllObjects];
    if (dataArr == nil) {
        dataArr = [NSMutableArray arrayWithCapacity:10];
    }
    
//    NSUserDefaults *userDefaults = [[NSUserDefaults alloc] initWithSuiteName:widgetIdentifier];
//    NSMutableDictionary *dic = [userDefaults objectForKey:@"TodayExt"];
    [chineseArr removeAllObjects];
    if (chineseArr == nil) {
        chineseArr = [NSMutableArray arrayWithCapacity:10];
    }
    
    for (int i=0;i<42; i++) {
        //剩下的简单了  将第一行第一天  不断的加一  然后保存起来  就可以获得整个月的 时间集合了
        dateTodayComponents.day = dayDiff;
        NSDate* date = [currentCalendar dateFromComponents:dateTodayComponents];
        if (date) {
            [dataArr addObject:date];
            [chineseArr addObject:[self getChineseDayWithDate:date]];
        }
        dayDiff ++;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    completionHandler(NCUpdateResultNewData);
}
- (UIEdgeInsets)widgetMarginInsetsForProposedMarginInsets:(UIEdgeInsets)defaultMarginInsets
{
    return UIEdgeInsetsZero;
}

-(void)configDayViews{
    BOOL changeFrame = NO;
    for (UIView *view in [_detailContainerView subviews]) {
        [view removeFromSuperview];
    }
    [UIView animateWithDuration:0.25f animations:^{
        _detailContainerView.alpha = 0;
    }];

    for (int i = 0; i < dataArr.count; i++) {
        NSDate *date = [dataArr objectAtIndex:i];
        NSDateComponents* dateComponents = [currentCalendar components:NSCalendarUnitMonth|NSCalendarUnitDay |NSCalendarUnitWeekday fromDate:date];
        if (dateComponents.month != dateTodayComponents.month) {
            continue;
        }
        
        widgetDayView *dayView = [[widgetDayView alloc]initWithFrame:CGRectMake( (i%7)* _detailContainerView.bounds.size.width/7 , (i/7) *50, _detailContainerView.bounds.size.width/7, 50)];
        
        dayView.dayLabel.text = [NSString stringWithFormat:@"%d",(int)dateComponents.day];
        if (chineseArr.count==dataArr.count) {
            dayView.classLabel.text = [chineseArr objectAtIndex:i];
        }
        NSString *currentDateStr = [dateFormatter stringFromDate:date];
        if ([holidayArr containsObject:currentDateStr]) {
//            dayView.tipImage.image = [UIImage imageNamed:@"xiu"];
        }else if ([workArr containsObject:currentDateStr]) {
//            dayView.tipImage.image = [UIImage imageNamed:@"ban"];
        }else{
            [dayView.tipImage removeFromSuperview];
            dayView.tipImage = nil;
        }
        if (dateComponents.weekday==1 || dateComponents.weekday == 7) {
//            NSLog(@"第一天");//就是周首日
            dayView.classLabel.textColor = [UIColor colorWithRed:0.9987 green:0.9438 blue:0.5976 alpha:1.0f];
            dayView.dayLabel.textColor = dayView.classLabel.textColor;
        }
        if (dateComponents.month == currentMonthComponents.month) {
            if ([today isEqualToDate:date]) {
                [dayView addSubview:imageView];
                imageView.center = CGPointMake(CGRectGetWidth(dayView.bounds)/2, CGRectGetHeight(dayView.bounds)/2);
            }

        }
        [_detailContainerView addSubview:dayView];
        if (i/7>=5) {
            changeFrame = YES;
        }
    }
    if (changeFrame) {
        [UIView animateWithDuration:0.1 animations:^{
            self.preferredContentSize = CGSizeMake(0, 365);
            _detailContainerView.bounds = CGRectMake(0, 0, kScreen_width, 50*6);
        }];
    }else{
        [UIView animateWithDuration:0.1 animations:^{
            self.preferredContentSize = CGSizeMake(0, 315);
            _detailContainerView.bounds = CGRectMake(0, 0, kScreen_width, 50*6);
        }];
    }
    [UIView animateWithDuration:0.5f animations:^{
        _detailContainerView.alpha = 1.0f;
    }];

}

- (NSInteger)firstWeekdayInThisMonth:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    [calendar setFirstWeekday:1];//1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
    NSDateComponents *comp = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    [comp setDay:1];
    NSDate *firstDayOfMonthDate = [calendar dateFromComponents:comp];
    
    NSUInteger firstWeekday = [calendar ordinalityOfUnit:NSCalendarUnitWeekday inUnit:NSCalendarUnitWeekOfMonth forDate:firstDayOfMonthDate];
    return firstWeekday - 1;
}

//set方法
-(void)setDate:(NSDate *)date{
    _date = date;
    titleLabel.text = [NSString stringWithFormat:@"%ld 年 %ld月",(long)[self year:date],(long)[self month:date]];

}
//获取某个月有多少天
-(NSInteger)getNumberOfDaysInMonth:(NSDate *)date{
    self.date = date;
    NSCalendar * calendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSRange  range = [calendar rangeOfUnit: NSCalendarUnitDay  inUnit:NSCalendarUnitMonth forDate:self.date];
    return range.length;
 
}
//月份
- (NSInteger)month:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components month];
}

//年份
- (NSInteger)year:(NSDate *)date{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
    return [components year];
}
//进入上个月的按钮点击方法
- (IBAction)intoLastMonth:(id)sender {
    self.date = [self lastMonth:self.date];
    [self loadDataSource];
    imageView.hidden = NO;
//    [self lastMonthAnimation];
//    [self lastMonthAnotherAnimation];
    [self configDayViews];
}
-(void)lastMonthAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    self.detailContainerView.center = CGPointMake(200, 300);
    [UIView setAnimationTransition:    UIViewAnimationTransitionFlipFromLeft forView:self.detailContainerView cache:YES];
    [UIView commitAnimations];
}
-(void)lastMonthAnotherAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    self.detailContainerView.center = CGPointMake(200, 300);
    [UIView setAnimationTransition:    UIViewAnimationTransitionCurlUp forView:self.detailContainerView cache:YES];
    [UIView commitAnimations];
}
//上个月的时间
-(NSDate *)lastMonth:(NSDate *)date{
    NSDateComponents * dateComponents = [[NSDateComponents alloc]init];
    dateComponents.month = -1;
    NSDate * newDate = [[NSCalendar currentCalendar]dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}
//进入下个月的按钮点击方法
- (IBAction)intoNextMonth:(id)sender {
    self.date = [self nextMonth:self.date];
    [self loadDataSource];
    imageView.hidden = NO;
    [self configDayViews];
}
-(void)nextMonthAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    self.detailContainerView.center = CGPointMake(200, 300);
    [UIView setAnimationTransition:    UIViewAnimationTransitionFlipFromRight forView:self.detailContainerView cache:YES];
    [UIView commitAnimations];

}
-(void)nextMonthAnotherAnimation{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1.0];
    [UIView setAnimationDelegate:self];
    self.detailContainerView.center = CGPointMake(200, 300);
    [UIView setAnimationTransition:    UIViewAnimationTransitionCurlDown forView:self.detailContainerView cache:YES];
    [UIView commitAnimations];
}
//下个月的时间
-(NSDate *)nextMonth:(NSDate *)date{
    NSDateComponents * dateComponents = [[NSDateComponents alloc]init];
    dateComponents.month = +1;
    NSDate * newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:date options:0];
    return newDate;
}

-(NSString*)getChineseDayWithDate:(NSDate *)date{
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    static NSCalendar *localeCalendar;
    if (localeCalendar==nil) {
        localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    }
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    NSString *m_str = [chineseDays objectAtIndex:localeComp.day-1];
    
    return m_str;
}

@end
