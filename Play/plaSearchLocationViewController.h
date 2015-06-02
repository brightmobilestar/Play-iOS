//
//  plaSearchLocationViewController.h
//  Play
//
//  Created by User on 11/23/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface plaSearchLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableArray* m_arrayTableData;
    
    IBOutlet UISearchBar* m_searchBar;
    IBOutlet UITableView* m_tableView;

    IBOutlet UILabel *m_lblAddNew;
}

-(IBAction)onBtnBack:(id)sender;

@end
