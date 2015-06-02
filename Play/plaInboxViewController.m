//
//  plaInboxViewController.m
//  Play
//
//  Created by User on 12/24/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaInboxViewController.h"
#import "AsyncImageView/AsyncImageView.h"
#import "plaUser.h"
#import "plaMail.h"
#import "plaInboxDataModel.h"
#import "plaEventData.h"
#import "plaAppDelegate.h"
#import "plaWebServices.h"

@interface plaInboxViewController ()

@end

@implementation plaInboxViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self getTableViewData];
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)getTableViewData
{
    [m_arrayInboxTableData removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"inboxViewController";
    
    // ------- To get Main User Info ----------
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            m_MainUser = userModel;
        }
    }
    
    // ------ To get TableView Data From User -----------
    for (int i = 0; i < [m_MainUser.USER_FRIENDS count]; i ++) {
        NSString* strFriendID = [m_MainUser.USER_FRIENDS objectAtIndex:i];
        if ([strFriendID isEqualToString:@""]) {
            continue;
        }
        for (int j = 0; j < [g_arrayUserData count]; j ++) {
            plaUser* userModel = [g_arrayUserData objectAtIndex:j];
            if ([userModel.USER_ID isEqualToString:strFriendID]) {
                if (![userModel.USER_FRIENDS containsObject:m_MainUser.USER_ID]) {
                    
                    //  [m_arrayInboxTableData addObject:userModel];
                    plaInboxDataModel* modelTemp = [[plaInboxDataModel alloc] init];
                    modelTemp.MAIL_ID = userModel.USER_ID;
                    modelTemp.MAIL_TYPE = @"user";
                    
                    [m_arrayInboxTableData addObject:modelTemp];
                }
            }
        }
    }
    
    // ------ To get TableView Data From User -----------
    for (int i = 0; i < [g_arrayMailData count]; i ++) {
        plaMail* mailModel = [g_arrayMailData objectAtIndex:i];
        
        plaInboxDataModel* inboxModel = [[plaInboxDataModel alloc] init];
        inboxModel.MAIL_ID = mailModel.MAIL_ID;
        inboxModel.MAIL_TYPE = @"mail";
        
        [m_arrayInboxTableData addObject:inboxModel];
    }
    [m_tableViewInbox reloadData];
}

-(void) addFriend:(plaUser*)_user
{
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS addObject:globData.sglobUserID];
    _user.USER_FRIENDSTATE = 1;
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    [self getTableViewData];
}

-(void) removeFriend:(plaUser*)_user
{
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS removeObject:globData.sglobUserID];
    _user.USER_FRIENDSTATE = 0;
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    
    [m_MainUser.USER_FRIENDS removeObject:_user.USER_ID];
    
    [webService backgroundUpdateUser:m_MainUser action:@"update_user"];
    
    
    [self getTableViewData];
}

-(plaUser*)getUserWithMail:(plaInboxDataModel*)_inbox
{
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* user = [g_arrayUserData objectAtIndex:i];
        if ([user.USER_ID isEqualToString:_inbox.MAIL_ID]) {
            return user;
        }
    }
    return nil;
}

-(plaMail*)getMailwithMail:(plaInboxDataModel*)_inbox
{
    for (int i = 0; i < [g_arrayMailData count]; i ++) {
        plaMail* user = [g_arrayMailData objectAtIndex:i];
        if ([user.MAIL_ID isEqualToString:_inbox.MAIL_ID]) {
            return user;
        }
    }
    return nil;
}

#pragma mark -------- delegate -- tableView -----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_arrayInboxTableData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaInboxDataModel* inboxModel = [m_arrayInboxTableData objectAtIndex:indexPath.row];
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    if ([inboxModel.MAIL_TYPE isEqualToString:@"user"]) {
        
        plaUser* userModel = [self getUserWithMail:inboxModel];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UIImageView* imageView = (UIImageView*)[tableView viewWithTag:1];
        [imageView setImageURL:[NSURL URLWithString:userModel.USER_PROFILEIMAGE]];
        
        UILabel* label = (UILabel*)[tableView viewWithTag:2];
        label.text = userModel.USER_NAME;
        
        //UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleFriendRequest:)];
        
        UIButton* button = (UIButton*)[tableView viewWithTag:4];
        NSString* strTemp = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        button.accessibilityValue = strTemp;
        
        strTemp = button.accessibilityValue;
        
        [button addTarget:self action:@selector(handleFriendRequestConfrim:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton* button1 = (UIButton*)[tableView viewWithTag:5];
        strTemp = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
        button1.accessibilityValue = strTemp;
        
        strTemp = button.accessibilityValue;
        [button1 addTarget:self action:@selector(handleFriendRequestDecline:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    } else if ([inboxModel.MAIL_TYPE isEqualToString:@"mail"]) {
        plaMail* mailModel = [self getMailwithMail:inboxModel];
        
        cell = [tableView dequeueReusableCellWithIdentifier:@"Cell_Event" forIndexPath:indexPath];
        UIImageView* imageView = (UIImageView*)[cell viewWithTag:1];
        UILabel* label = (UILabel*)[cell viewWithTag:2];
        
        plaEvent* mailEvent = nil;
        plaUser* mailFromUser = nil;
        for (int i = 0; i < [g_arrayUserData count]; i ++) {
            plaUser* userTemp = [g_arrayUserData objectAtIndex:i];
            if ([userTemp.USER_ID isEqualToString:mailModel.MAIL_FROMUSER]) {
                mailFromUser = userTemp;
            }
        }
        for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
            plaEvent* event = [g_arrayAllEventData objectAtIndex:i];
            if ([event.EV_SEVENTID isEqualToString:mailModel.MAIL_CONTENT]) {
                mailEvent = event;
            }
        }
        
        [imageView setImageURL:[NSURL URLWithString:mailEvent.EV_SIMAGE]];
        [label setText:[NSString stringWithFormat:@"%@ has invited you to %@", mailFromUser.USER_NAME, mailEvent.EV_SNAME]];
    }
    
    return cell;
}

- (void) handleFriendRequestConfrim:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* strTemp = button.accessibilityValue;
    NSInteger intIndex = strTemp.integerValue;
    
    plaInboxDataModel* inboxModel = [m_arrayInboxTableData objectAtIndex:intIndex];
    plaUser* userModel = [self getUserWithMail:inboxModel];
    
    [self addFriend:userModel];
}

- (void) handleFriendRequestDecline:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSString* strTemp = button.accessibilityValue;
    NSInteger intIndex = strTemp.integerValue;
    
    plaInboxDataModel* inboxModel = [m_arrayInboxTableData objectAtIndex:intIndex];
    plaUser* userModel = [self getUserWithMail:inboxModel];
    
    [self removeFriend:userModel];
}

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
