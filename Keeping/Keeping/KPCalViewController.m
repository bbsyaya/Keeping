//
//  KPCalViewController.m
//  Keeping
//
//  Created by 宋 奎熹 on 2017/1/17.
//  Copyright © 2017年 宋 奎熹. All rights reserved.
//

#import "KPCalViewController.h"
#import "UIScrollView+EmptyDataSet.h"
#import "Task.h"
#import "TaskManager.h"
#import "Utilities.h"
#import "DateTools.h"
#import "DateUtil.h"
#import "CardsView.h"
#import "KPCalTaskTableViewCell.h"

@interface KPCalViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@end

@implementation KPCalViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor groupTableViewBackgroundColor];
    self.view = view;
    
    CardsView *cardView = [[CardsView alloc] initWithFrame:CGRectMake(10, 64 + 10, view.frame.size.width -20, 250)];
    cardView.cornerRadius = 10;
    cardView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cardView];
    
    self.calendar = [[FSCalendar alloc] initWithFrame:CGRectMake(5, 5, cardView.frame.size.width - 10, 240)];
    self.calendar.dataSource = self;
    self.calendar.delegate = self;
    self.calendar.backgroundColor = [UIColor whiteColor];
    self.calendar.appearance.headerMinimumDissolvedAlpha = 0;
    self.calendar.appearance.headerDateFormat = @"yyyy 年 MM 月";
    
    self.calendar.appearance.headerTitleColor = [Utilities getColor];
    self.calendar.appearance.weekdayTextColor = [Utilities getColor];

    self.calendar.appearance.todayColor = [UIColor clearColor];
    self.calendar.appearance.titleTodayColor = [UIColor blackColor];
    self.calendar.appearance.selectionColor =  [UIColor clearColor];
    self.calendar.appearance.titleSelectionColor = [UIColor blackColor];
    self.calendar.appearance.todaySelectionColor = [UIColor clearColor];
//    self.calendar.appearance.borderSelectionColor;
    
//    self.calendar.select = NO;
    
    [cardView addSubview:self.calendar];
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(5, 10, 95, 34);
    previousButton.backgroundColor = [UIColor whiteColor];
    previousButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [previousButton setTintColor:[Utilities getColor]];
    UIImage *leftImg = [UIImage imageNamed:@"icon_prev"];
    leftImg = [leftImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [previousButton setImage:leftImg forState:UIControlStateNormal];
    [previousButton addTarget:self action:@selector(previousClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:previousButton];
    self.previousButton = previousButton;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(CGRectGetWidth(cardView.frame)-100, 10, 95, 34);
    nextButton.backgroundColor = [UIColor whiteColor];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [nextButton setTintColor:[Utilities getColor]];
    UIImage *rightImg = [UIImage imageNamed:@"icon_next"];
    rightImg = [rightImg imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [nextButton setImage:rightImg forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextClicked:) forControlEvents:UIControlEventTouchUpInside];
    [cardView addSubview:nextButton];
    self.nextButton = nextButton;
    
    self.taskTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 260 + 64 + 5, view.frame.size.width, view.frame.size.height - 260 - 64 - 44 - 6) style:UITableViewStylePlain];
    self.taskTableView.delegate = self;
    self.taskTableView.dataSource = self;
    self.taskTableView.backgroundColor = [UIColor clearColor];
    
    self.taskTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.taskTableView.emptyDataSetSource = self;
    self.taskTableView.emptyDataSetDelegate = self;
    self.taskTableView.tableHeaderView = [UIView new];
    self.taskTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.frame.size.width, 10)];
    self.taskTableView.tableFooterView.backgroundColor = [UIColor groupTableViewBackgroundColor];

    [self.view addSubview:self.taskTableView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    self.task = NULL;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)loadTasks{
    self.taskArr = [[TaskManager shareInstance] getTasks];
    [self.taskTableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setFont];
    [self loadTasks];
}

- (void)setFont{
    self.calendar.appearance.titleFont = [UIFont fontWithName:[Utilities getFont] size:12.0];
    self.calendar.appearance.headerTitleFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.weekdayFont = [UIFont fontWithName:[Utilities getFont] size:15.0];
    self.calendar.appearance.subtitleFont = [UIFont fontWithName:[Utilities getFont] size:10.0];
}

- (BOOL)canFixPunch:(NSDate *)date{
    if([[NSDate date] isEarlierThanOrEqualTo:date]){
        return NO;
    }
    if(self.task.endDate != NULL && [self.task.endDate isEarlierThan:date]){
        return NO;
    }else{
        return ![self.task.punchDateArr containsObject:[DateUtil transformDate:date]] && [self.task.reminderDays containsObject:@(date.weekday)] && [self.task.addDate isEarlierThanOrEqualTo:date];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.taskArr count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if([self.task isEqual:self.taskArr[indexPath.row]]){
        self.task = NULL;
    }else{
        self.task = self.taskArr[indexPath.row];
    }
    
    [self.calendar reloadInputViews];
    [self.calendar reloadData];
    
    [self.taskTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 70.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"KPCalTaskTableViewCell";
    UINib *nib = [UINib nibWithNibName:@"KPCalTaskTableViewCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:cellIdentifier];
    KPCalTaskTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    [cell setFont];
    
    Task *t = self.taskArr[indexPath.row];
    
    if([t isEqual:self.task]){
        [cell setIsSelected:YES];
    }else{
        [cell setIsSelected:NO];
    }
    
    [cell.taskNameLabel setText:t.name];
    
    //进度
    int totalPunchNum = [[TaskManager shareInstance] totalPunchNumberOfTask:t];
    int punchNum = (int)[t.punchDateArr count];
    [cell.punchDaysLabel setText:[NSString stringWithFormat:@"已完成 %d 天, 计划完成 %d 天, 完成率 %.1f%%", punchNum, totalPunchNum, totalPunchNum == 0 ? 0 : ((float)punchNum / (float)totalPunchNum * 100.0)]];
    
    return cell;
}

#pragma mark - DZNEmpty Delegate

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"没有任务";
    
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName: [Utilities getColor],
                                 NSFontAttributeName:[UIFont fontWithName:[Utilities getFont] size:20.0]
                                 };
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - FSCalendar Delegate

- (void)calendar:(FSCalendar *)calendar didSelectDate:(NSDate *)date{
    [calendar deselectDate:date];
    if([self canFixPunch:date]){
        UIAlertController *alertController =
        [UIAlertController alertControllerWithTitle:@"补打卡"
                                            message:[NSString stringWithFormat:@"这个日期您可以为 %@ 补打卡", self.task.name]
                                     preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"好的"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction *action){
                                                             [[TaskManager shareInstance] punchForTaskWithID:@(self.task.id) onDate:date];
                                                             
                                                             self.task = NULL;
                                                             [self.calendar reloadData];
                                                             [self.calendar reloadInputViews];
                                                             
                                                             [self loadTasks];
                                                             
                                                         }];
        [alertController addAction:cancelAction];
        [alertController addAction:okAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}

- (void)previousClicked:(id)sender{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *previousMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:-1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:previousMonth animated:YES];
}

- (void)nextClicked:(id)sender{
    NSDate *currentMonth = self.calendar.currentPage;
    NSDate *nextMonth = [self.gregorian dateByAddingUnit:NSCalendarUnitMonth value:1 toDate:currentMonth options:0];
    [self.calendar setCurrentPage:nextMonth animated:YES];
}

- (NSString *)calendar:(FSCalendar *)calendar titleForDate:(NSDate *)date{
    if ([self.gregorian isDateInToday:date]) {
        return @"今";
    }
    return nil;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance fillDefaultColorForDate:(nonnull NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [Utilities getColor];
        }
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance titleDefaultColorForDate:(NSDate *)date{
    if(self.task != NULL){
        //打了卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [UIColor whiteColor];
        }
    }
    return appearance.borderDefaultColor;
}

- (UIColor *)calendar:(FSCalendar *)calendar appearance:(FSCalendarAppearance *)appearance borderDefaultColorForDate:(NSDate *)date{
    
    if(self.task != NULL){
        //未来应该打卡的日子、打了卡的日子、没打卡的日子
        if([self.task.punchDateArr containsObject:[DateUtil transformDate:date]]){
            return [Utilities getColor];
        }
        if([self.task.addDate isEarlierThanOrEqualTo:date] && [self.task.reminderDays containsObject:@(date.weekday)]){
            if([[NSDate date] isEarlierThanOrEqualTo:date]){
                if(self.task.endDate == NULL){
                    return [Utilities getColor];
                }else{
                    if([self.task.endDate isLaterThanOrEqualTo:date]){
                        return [Utilities getColor];
                    }else{
                        return [UIColor clearColor];
                    }
                }
            }else{
                return [UIColor redColor];
            }
        }
    }
    
    return appearance.borderDefaultColor;
}

- (NSInteger)calendar:(FSCalendar *)calendar numberOfEventsForDate:(NSDate *)date{
    if(self.task != NULL){
        //创建日期
        return [self.task.addDate isEqualToDate:date]
                    || (self.task.endDate != NULL && [self.task.endDate isEqualToDate:date]);
    }else{
        return 0;
    }
}

@end
