//
//  plaFriendsListViewController.m
//  Play
//
//  Created by User on 12/18/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaFriendsListViewController.h"
#import "AsyncImageView/AsyncImageView.h"
#import "plaAppDelegate.h"
#import "plaHomeViewController.h"
#import "plaUser.h"
#import "plaEventData.h"

@interface plaFriendsListViewController ()

@end

@implementation plaFriendsListViewController

@synthesize nibScrollView, tabButton, tabButton2, slidLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_arrayTableData = [[NSMutableArray alloc] init];
    m_arrayTableData2 = [[NSMutableArray alloc] init];
    
    [tabButton setSelected:YES];
    
    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"friendsListViewController";
}

-(void)viewWillAppear:(BOOL)animated
{
    [self getTableViewArray];
    [m_tableView reloadData];
    
    [tabButton setSelected:YES];
    [tabButton2 setSelected:NO];
    
    [self initScrollView];
}

#pragma mark ------- background functios ---------
-(void) getTableViewArray
{
    [m_arrayTableData removeAllObjects];
    [m_arrayTableData2 removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
    
    // ------- To get Main User Info ----------
    plaUser* m_MainUser;
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            m_MainUser = userModel;
        }
    }
    
    // -------- To get Table Data -----------
    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_FRIENDS containsObject:globData.sglobUserID]) {
            if (![m_MainUser.USER_FRIENDS containsObject:userModel.USER_ID]) {
                continue;
            }
            [m_arrayTableData2 addObject:userModel];
            
            NSString* strTempLocation =g_controllerViewHome.m_lblBGNetwork.text;
            NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
            
            if ([userModel.USER_NETWORK isEqualToString:[NSString stringWithFormat:@"%@,%@",[array objectAtIndex:0], [array objectAtIndex:1]]]) {
                [m_arrayTableData addObject:userModel];
            }
        }
    }
}

//-(void)changeFriendCountText
//{
//    plaEventData* globData = [plaEventData getInstance];
//    
//    NSInteger intNetworkFriendCount = 0, intFriendCount = 0;
//    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
//        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
//        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) continue;
//        if ([userModel.USER_NETWORK isEqualToString:[NSString stringWithFormat:@"%@,%@",globData.sglobCity,globData.sglobState]]) {
//            intNetworkFriendCount = intNetworkFriendCount + 1;
//        }
//        if (userModel.USER_FRIENDSTATE == 1) {
//            intFriendCount = intFriendCount + 1;
//        }
//    }
//    m_btnFriendsCount.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld friends are on this network", intNetworkFriendCount, intFriendCount];
//}

- (void)initScrollView {
    
    //设置 tableScrollView
    // a page is the width of the scroll view
    nibScrollView.pagingEnabled = YES;
    nibScrollView.clipsToBounds = NO;
    nibScrollView.contentSize = CGSizeMake(nibScrollView.frame.size.width * 2, nibScrollView.frame.size.height);
    nibScrollView.showsHorizontalScrollIndicator = NO;
    nibScrollView.showsVerticalScrollIndicator = NO;
    nibScrollView.scrollsToTop = NO;
    nibScrollView.delegate = self;
    nibScrollView.scrollEnabled = false;
    
    [nibScrollView setContentOffset:CGPointMake(0, 0)];
    
    //公用
    currentPage = 0;
    pageControl.numberOfPages = 2;
    pageControl.currentPage = 0;
    pageControl.backgroundColor = [UIColor whiteColor];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    CGFloat pageWidth = self.nibScrollView.frame.size.width;
    int page = floor((self.nibScrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    
    pageControl.currentPage = page;
    currentPage = page;
    pageControlUsed = NO;
    [self btnActionShow];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //暂不处理 - 其实左右滑动还有包含开始等等操作，这里不做介绍
}

#pragma mark - tab Button

-(IBAction)onBtnTab:(id)sender
{
    [self couponButtonAction];
}

-(IBAction)onBtnTab2:(id)sender
{
    [self groupbuyButtonAction];
}

- (void) btnActionShow
{
    if (currentPage == 0) {
        [self couponButtonAction];
    }
    else{
        [self groupbuyButtonAction];
    }
}

- (void) couponButtonAction
{
    //[tabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//此时选中
    [tabButton setSelected:YES];
    [tabButton2 setSelected:NO];
    //[tabButton2 setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    slidLabel.frame = CGRectMake(60, 102, 40, 4);
    [nibScrollView setContentOffset:CGPointMake(320*0, 0)];//页面滑动
    
    [UIView commitAnimations];
}

- (void) groupbuyButtonAction
{
    //[tabButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];//此时选中
    //[tabButton2 setTitleColor:[UIColor colorWithRed:(220/255.0) green:(220/255.0) blue:(220/255.0) alpha:1] forState:UIControlStateNormal];//此时未被选中
    [tabButton2 setSelected:YES];
    [tabButton setSelected:NO];
    
    [UIView beginAnimations:nil context:nil];//动画开始
    [UIView setAnimationDuration:0.3];
    
    slidLabel.frame = CGRectMake(220, 102, 40, 4);
    [nibScrollView setContentOffset:CGPointMake(320*1, 0)];
    
    [UIView commitAnimations];
}

#pragma mark ------ delegate tableView --------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == m_tableView) {
        return [m_arrayTableData count];
    }
    else{
        return [m_arrayTableData2 count];
    }
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaUser* userModel;// = [m_arrayTableData objectAtIndex:indexPath.row];
    
    if (tableView == m_tableView) {
        userModel = [m_arrayTableData objectAtIndex:indexPath.row];
    } else {
        userModel = [m_arrayTableData2 objectAtIndex:indexPath.row];
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:1];
    [imageView setImageURL:[NSURL URLWithString:userModel.USER_PROFILEIMAGE]];
    
    UILabel* label = (UILabel*)[cell.contentView viewWithTag:2];
    label.text = userModel.USER_NAME;    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaUser* userModel;// = [m_arrayTableData objectAtIndex:indexPath.row];
    
    if (tableView == m_tableView) {
        userModel = [m_arrayTableData objectAtIndex:indexPath.row];
    } else {
        userModel = [m_arrayTableData2 objectAtIndex:indexPath.row];
    }
    
    NSInteger indexNum = [g_arrayUserData indexOfObject:userModel];
    
    plaEventData* globData = [plaEventData getInstance];
    globData.iglobEventRow = indexNum;
    
    [self performSegueWithIdentifier: @"segueToUserPage" sender:self];
}

//------------------------------------------
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
