//
//  plaSeachNetworkViewController.h
//  Play
//
//  Created by User on 12/15/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SPGooglePlacesAutocompleteQuery;

@interface plaSeachNetworkViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate >
{
    IBOutlet UITableView* m_tableView;
    IBOutlet UISearchBar* searchBar;
    
    NSMutableArray* m_arrayTableData;
    
    
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    
    BOOL shouldBeginEditing;
}

@end
