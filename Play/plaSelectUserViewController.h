//
//  plaSelectUserViewController.h
//  Play
//
//  Created by User on 12/26/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface plaSelectUserViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate >
{
    NSMutableArray* m_arrayTableViewData;
    
    NSMutableArray* m_arrayFriendList;
    
    IBOutlet UITableView* m_tableView;
    IBOutlet UISearchBar* m_searchBar;
    IBOutlet UIView* m_viewTableViewBottom;
    
}
@end
