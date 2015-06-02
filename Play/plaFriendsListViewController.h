//
//  plaFriendsListViewController.h
//  Play
//
//  Created by User on 12/18/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface plaFriendsListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    NSMutableArray* m_arrayTableData;
    NSMutableArray* m_arrayTableData2;
    
    IBOutlet UITableView* m_tableView;
    IBOutlet UITableView* m_tableView2;
    
    UIPageControl *pageControl;
    int currentPage;
    BOOL pageControlUsed;
}

@property (retain, nonatomic) IBOutlet UIButton *tabButton;
@property (retain, nonatomic) IBOutlet UIButton *tabButton2;
@property (retain, nonatomic) IBOutlet UILabel *slidLabel;//用于指示作用
@property (retain, nonatomic) IBOutlet UIScrollView *nibScrollView;

@end
