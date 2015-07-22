//
//  TodayViewController.m
//  CalendarWidget
//
//  Created by 张英杰 on 15/7/22.
//  Copyright (c) 2015年 张英杰. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>
#import "ZYJCollectionViewCell.h"

#define kScreen_height   [[UIScreen mainScreen] bounds].size.height
#define kScreen_width    [[UIScreen mainScreen] bounds].size.width

@interface TodayViewController () <NCWidgetProviding,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource>
{
    UICollectionView *myCollectView;
    
    NSMutableArray *dataArr;
    
}
@end

static NSCalendar *currentCalendar;

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.preferredContentSize = CGSizeMake(0, 335);
    NSArray *weekArr = [NSArray arrayWithObjects:@"日",@"一",@"二",@"三",@"四",@"五",@"六", nil];
    for (int i = 0; i< 7; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, kScreen_width/7, 20)];
        label.center = CGPointMake(kScreen_width/14 *(2*i + 1)-1 , 10);
        label.text = [weekArr objectAtIndex:i];
        label.textColor = [UIColor whiteColor];
        if ([label.text isEqualToString:@"六"]||[label.text isEqualToString:@"日"]) {
            label.textColor = [UIColor orangeColor];
        }
        label.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:label];
    }
    
    
    [self loadDataSource];
    [self configCollectionView];
}
-(void)loadDataSource{
    if (currentCalendar==nil) {
        currentCalendar = [NSCalendar currentCalendar];
    }
    NSDateComponents *dateComponents = [currentCalendar components:NSCalendarUnitYear|NSCalendarUnitMonth fromDate:[NSDate date]];
    //获得当前月的第一天时间
    NSDate* firstDay =  [currentCalendar dateFromComponents:dateComponents];
    dateComponents.day = 1;
    
    //获得第一天 是周几
    int firstWeekDay = (int)[currentCalendar components:NSCalendarUnitWeekday fromDate:firstDay].weekday;
    int firstDayPosition = (firstWeekDay + 8)%8;
    
    //第一行第一天  跟  当前月第一天    的差距天数
    int dayDiff = 1 - firstDayPosition + 1;
    
    [dataArr removeAllObjects];
    if (dataArr == nil) {
        dataArr = [NSMutableArray arrayWithCapacity:10];
    }
    for (int i=0;i<42; i++) {
        //剩下的简单了  将第一行第一天  不断的加一  然后保存起来  就可以获得整个月的 时间集合了
        dateComponents.day = dayDiff;
        NSDate* date = [currentCalendar dateFromComponents:dateComponents];
        [dataArr addObject:date];
        dayDiff ++;
    }
    
}
-(void)configCollectionView{
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc]init];
    
    if (kScreen_width==320) {
        //iPhone5
        flowLayout.itemSize = CGSizeMake(45, 50);
    }else if(kScreen_width ==414){
        //iPhone 6PLUS
        flowLayout.itemSize = CGSizeMake(58, 50);
    }else{
        //iPhone 6   375
        flowLayout.itemSize = CGSizeMake(53, 50);
    }
    
    flowLayout.minimumInteritemSpacing = 1.0f;
    flowLayout.minimumLineSpacing = 1.0f;
    

    myCollectView = [[UICollectionView alloc]initWithFrame:CGRectMake(0.0f, 30.0f, self.view.frame.size.width,305.0f) collectionViewLayout:flowLayout];
    myCollectView.tag = 10000;
    
    myCollectView.backgroundColor = [UIColor clearColor];
    myCollectView.delegate = self;
    myCollectView.dataSource = self;
    myCollectView.clipsToBounds = YES;
    
    [myCollectView registerNib:[UINib nibWithNibName:@"ZYJCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:@"ZYJCell"];
    
    
    myCollectView.showsVerticalScrollIndicator = NO;
    myCollectView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:myCollectView];
    
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
#pragma mark - collectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return dataArr.count;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * CellIdentifier = @"ZYJCell";
    ZYJCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDate *date = [dataArr objectAtIndex:indexPath.row];
    NSDateComponents* dateComponents = [currentCalendar components:NSCalendarUnitDay fromDate:date];
    cell.label1.text = [NSString stringWithFormat:@"%d",(int)dateComponents.day];
    
    cell.label2.text = [self getChineseDayWithDate:date];
    //    _chineseCal.text = [CalenderTool getChineseDayWithDate:date];
    cell.label3.hidden = YES;
    if(indexPath.row % 7 == 0 || (indexPath.row+1) % 7 == 0){
        cell.label1.textColor = [UIColor orangeColor];
        cell.label2.textColor = [UIColor orangeColor];
        cell.label3.textColor = [UIColor orangeColor];
    }
    
    return cell;
    
}

-(NSString*)getChineseDayWithDate:(NSDate *)date{
    
    NSArray *chineseDays=[NSArray arrayWithObjects:
                          @"初一", @"初二", @"初三", @"初四", @"初五", @"初六", @"初七", @"初八", @"初九", @"初十",
                          @"十一", @"十二", @"十三", @"十四", @"十五", @"十六", @"十七", @"十八", @"十九", @"二十",
                          @"廿一", @"廿二", @"廿三", @"廿四", @"廿五", @"廿六", @"廿七", @"廿八", @"廿九", @"三十",  nil];
    
    NSCalendar *localeCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierChinese];
    
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay;
    
    NSDateComponents *localeComp = [localeCalendar components:unitFlags fromDate:date];
    
    NSString *m_str = [chineseDays objectAtIndex:localeComp.day-1];
    return m_str;
}


@end
