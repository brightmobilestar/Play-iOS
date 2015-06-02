//
//  plaSelectUserViewController.m
//  Play
//
//  Created by User on 12/26/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaSelectUserViewController.h"
#import "plaUser.h"
#import "plaMail.h"
#import "plaEvent.h"
#import "plaEventData.h"
#import "plaAppDelegate.h"
#import "AsyncImageView.h"
#import "plaEventDetailViewController.h"
#import "plaWebServices.h"
#import "PushNotificationManagement.h"

@interface plaSelectUserViewController ()

@end

@implementation plaSelectUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    m_arrayTableViewData = [[NSMutableArray alloc] init];
    m_arrayFriendList = [[NSMutableArray alloc] init];

    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"selectUserViewController";
}

- (void) viewWillAppear:(BOOL)animated
{
    [self getFriendsData];
    [self getUserInvitedState];
}

#pragma mark ------ background functions ------------------------
-(void) getFriendsData
{
    [m_arrayFriendList removeAllObjects];
    
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
            [m_arrayFriendList addObject:userModel];
        }
    }

    if ([m_arrayFriendList count] == 0) {
        m_viewTableViewBottom.hidden = false;
    } else {
        m_viewTableViewBottom.hidden = true;
    }
}

-(void) getUserInvitedState
{
    for (int i = 0; i < [m_arrayFriendList count]; i ++) {
        plaUser* userModel = [m_arrayFriendList objectAtIndex:i];
        for (int j = 0; j < [g_arrayMailData count]; j ++) {
            plaMail* mailModel = [g_arrayMailData objectAtIndex:j];
            if ([mailModel.MAIL_TOUSER isEqualToString:userModel.USER_ID] && [mailModel.MAIL_CONTENT isEqualToString:g_controllerEventDetail.m_parsedEvent.EV_SEVENTID]) {
                userModel.USER_INVITEDSTATE = 2;
            } else {
                userModel.USER_INVITEDSTATE = 0;
            }
        }
    }
}

-(void) sendInvite
{
    NSInteger today = [NSDate timeIntervalSinceReferenceDate];
    
    plaWebServices* service = [[plaWebServices alloc] init];
    plaEventData* globData = [plaEventData getInstance];
    for (NSInteger i = 0; i < [m_arrayTableViewData count]; i ++) {
        plaUser* toUser = [m_arrayTableViewData objectAtIndex:i];
        toUser.USER_INVITEDSTATE = 2;
        
        plaMail* newMail = [[plaMail alloc] init];
        newMail.MAIL_ID = [NSString stringWithFormat:@"%ld", (long)today + i];
        newMail.MAIL_FROMUSER = globData.sglobUserID;
        newMail.MAIL_TOUSER = toUser.USER_ID;
        newMail.MAIL_TYPE = @"eventInvite";
        newMail.MAIL_ACTIVESTATUS = @"false";
        newMail.MAIL_CONTENT = g_controllerEventDetail.m_parsedEvent.EV_SEVENTID;
        
        [g_managePush sendNotification:toUser.USER_ID message:[NSString stringWithFormat:@"%@ has invited you to %@.", globData.sglobUsername, g_controllerEventDetail.m_parsedEvent.EV_SNAME ]];
        
        [service backgroundInsertMail:newMail];
    }
    
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Invitations Sent" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

-(void) getCurrentInvitedUsers
{
    [m_arrayTableViewData removeAllObjects];
    for (NSInteger i = 0; i < [m_arrayFriendList count]; i ++) {
        plaUser* userModel = [m_arrayFriendList objectAtIndex:i];
        if ( userModel.USER_INVITEDSTATE == 1 ) {
            [m_arrayTableViewData addObject:userModel];
        }
    }
}

#pragma mark ------ delegate ----------- controll event --------------
-(IBAction)onBack:(id)sender
{
    [self sendInvite];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ------ deleagate ---------- search bar -------------
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
    
}

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    plaEventData* globData = [plaEventData getInstance];
    [m_arrayTableViewData removeAllObjects];
    for (NSInteger i = 0; i < [m_arrayFriendList count]; i ++) {
        plaUser* userModel = [m_arrayFriendList objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            continue;
        }
        if ([[userModel.USER_NAME uppercaseString] containsString:[searchBar.text uppercaseString]]) {
            [m_arrayTableViewData addObject:userModel];
        }
    }
    
    [m_tableView reloadData];
}

//- (BOOL)searchBar:(UISearchBar *)searchBar shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text NS_AVAILABLE_IOS(3_0); // called before text changes

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar                     // called when keyboard search button pressed
{
    [m_searchBar resignFirstResponder];
    //m_tableViewOmniSearch.hidden = true;
}
//- (void)searchBarBookmarkButtonClicked:(UISearchBar *)searchBar;                   // called when bookmark button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar                     // called when cancel button pressed
{
    [m_searchBar resignFirstResponder];
    m_searchBar.text = @"";
    
    [self getCurrentInvitedUsers];
    [m_tableView reloadData];
}

#pragma mark ----- delegate ------- tableView ----------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_arrayTableViewData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaUser* userModel = [m_arrayTableViewData objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView* imageView = (UIImageView*)[cell viewWithTag:1];
    [imageView setImageURL:[NSURL URLWithString:userModel.USER_PROFILEIMAGE]];
    
    UILabel* label = (UILabel*)[tableView viewWithTag:2];
    [label setText:userModel.USER_NAME];
    
    if (userModel.USER_INVITEDSTATE == 2) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
        
        imageView = (UIImageView*)[tableView viewWithTag:10];
        imageView.hidden = false;
        
        label = (UILabel*)[tableView viewWithTag:3];
        label.hidden = false;
    } else {
        imageView = (UIImageView*)[tableView viewWithTag:10];
        imageView.hidden = true;
        
        label = (UILabel*)[tableView viewWithTag:3];
        label.hidden = true;
    }
    if (userModel.USER_INVITEDSTATE == 1) {
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else if(userModel.USER_INVITEDSTATE == 0) {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    plaUser* userModel = [m_arrayTableViewData objectAtIndex:indexPath.row];
    if (userModel.USER_INVITEDSTATE < 2) {
        if (userModel.USER_INVITEDSTATE == 0) {
            userModel.USER_INVITEDSTATE = 1;
        } else if (userModel.USER_INVITEDSTATE == 1) {
            userModel.USER_INVITEDSTATE = 0;
        }
    }
    [self searchBarCancelButtonClicked:m_searchBar];
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
