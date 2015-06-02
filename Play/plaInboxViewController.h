//
//  plaInboxViewController.h
//  Play
//
//  Created by User on 12/24/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>

@class plaUser;

@interface plaInboxViewController : UIViewController < UITableViewDataSource, UITableViewDelegate >
{
    IBOutlet UITableView* m_tableViewInbox;
    
    NSMutableArray* m_arrayInboxTableData;

    plaUser* m_MainUser;
}

@end
