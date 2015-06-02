//
//  plaUserViewController.m
//  Play
//
//  Created by User on 12/17/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaUserViewController.h"
#import "plaEventData.h"
#import "plaAppDelegate.h"
#import "AsyncImageView.h"
#import "plaUser.h"
#import "plaWebServices.h"
#import "PushNotificationManagement.h"
#import "plaFeedModel.h"
#import "plaFeedModel.h"

@interface plaUserViewController ()

@end

@implementation plaUserViewController

@synthesize m_imageViewCover, m_imageViewProfile, m_lblUserName;
@synthesize m_btnFriend;
@synthesize m_lblUserNetwork;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [m_imageViewProfile setClipsToBounds:YES];
    m_imageViewProfile.layer.cornerRadius = 45.f;
    
    [self getMainUser];
    
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void) getMainUser
{
    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"userViewController";
    
    // ------- To get default User Info ----------
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            m_defaultUser = userModel;
        }
    }
    
    // ------- To get main User Info
    m_mainUser = [g_arrayUserData objectAtIndex:globData.iglobEventRow];
    
    [m_imageViewProfile setImageURL:[NSURL URLWithString:m_mainUser.USER_PROFILEIMAGE]];
    if (m_mainUser.USER_COVERIMAGE == nil) {
        //[m_imageViewCover setImageURL:[NSURL URLWithString:m_mainUser.USER_COVERIMAGE]];
    } else {
        [m_imageViewCover setImageURL:[NSURL URLWithString:m_mainUser.USER_COVERIMAGE]];
    }
    
    m_lblUserName.text = m_mainUser.USER_NAME;
    
    m_lblUserNetwork.text = m_mainUser.USER_NETWORK;
    
    m_lblUserNetwork.hidden = true;
    
    [self changeFriendBtnState];
}

-(void) changeFriendBtnState
{
    UIImage* image;
    NSString* strTitle;
    plaEventData* globData = [plaEventData getInstance];
    m_viewFriendRequest.hidden = true;
    
    switch (m_mainUser.USER_FRIENDSTATE) {
        case -1:
            image = [UIImage imageNamed:@"user_unfriend.jpg"];
            strTitle = @"";
            break;
            
        case 0:
            image = [UIImage imageNamed:@"user_addfriend.jpg"];
            strTitle = @"Add Friend";
            
            if ([m_defaultUser.USER_FRIENDS containsObject:m_mainUser.USER_ID]) {
                m_viewFriendRequest.hidden = false;
            }
            
            break;
            
        case 1:
            for (int i = 0; i < [g_arrayUserData count]; i ++) {
                plaUser* user = [g_arrayUserData objectAtIndex:i];
                if ([user.USER_ID isEqualToString:globData.sglobUserID]) {
                    if ([user.USER_FRIENDS containsObject:m_mainUser.USER_ID]) {
                        image = [UIImage imageNamed:@"user_friend.jpg"];
                        strTitle = @"Friend";
                        
                        m_lblUserNetwork.hidden = false;
                        
                    } else {
                        image = [UIImage imageNamed:@"user_unfriend.jpg"];
                        strTitle = @"Friend Request Sent";
                    }
                }
            }
            
            break;
            
        default:
            break;
    }
    
    //[m_btnFriend setBackgroundImage:image forState:0];
    [m_btnFriend setTitle:strTitle forState:0];
    
    if ([m_mainUser.USER_ID isEqualToString:globData.sglobUserID]) {
        m_btnFriend.hidden = YES;
    } else {
        m_btnFriend.hidden = NO;
    }
}

-(void) addFriend
{
    plaEventData* globData = [plaEventData getInstance];
    [m_mainUser.USER_FRIENDS addObject:globData.sglobUserID];
    m_mainUser.USER_FRIENDSTATE = 1;
    [self changeFriendBtnState];
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:m_mainUser action:@"update_user"];
    
    [g_managePush sendNotification:m_mainUser.USER_ID message:[NSString stringWithFormat:@"You have recieved a friend request from %@", globData.sglobUsername ]];
}

-(void) removeFriend
{
    [self declineFriend:m_mainUser];
    [self insertActivityFeed:@"delete"];
//    plaEventData* globData = [plaEventData getInstance];
//    [m_mainUser.USER_FRIENDS removeObject:globData.sglobUserID];
//    m_mainUser.USER_FRIENDSTATE = 0;
//    [self changeFriendBtnState];
//    
//    plaWebServices* webService = [[plaWebServices alloc] init];
//    [webService backgroundUpdateUser:m_mainUser];
}

-(void) confirmFriend:(plaUser*)_user
{
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS addObject:globData.sglobUserID];
    _user.USER_FRIENDSTATE = 1;
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    [g_managePush sendNotification:_user.USER_ID message:[NSString stringWithFormat:@"%@ has confirmed your friend request.", globData.sglobUsername ]];
    
    [self changeFriendBtnState];
    
    [self insertActivityFeed:@"insert"];
}

-(void) declineFriend:(plaUser*)_user
{
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS removeObject:globData.sglobUserID];
    _user.USER_FRIENDSTATE = 0;
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    [g_managePush sendNotification:_user.USER_ID message:[NSString stringWithFormat:@"%@ has declined your friend request.", globData.sglobUsername ]];
    
    [m_defaultUser.USER_FRIENDS removeObject:_user.USER_ID];
    
    [webService backgroundUpdateUser:m_defaultUser action:@"update_user"];
    
    [self changeFriendBtnState];
}

- (void) insertActivityFeed:(NSString*)_action
{
    plaEventData* globEvents = [plaEventData getInstance];
    plaFeedModel* _feedModel = [[plaFeedModel alloc] init];
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    
    _feedModel.FEED_ID = [NSString stringWithFormat:@"%ld", (long)today];
    _feedModel.FEED_USER = globEvents.sglobUserID;
    _feedModel.FEED_CONTENT = m_mainUser.USER_ID;
    _feedModel.FEED_ACTION = @"Friend";
    
    plaWebServices* webServices = [[plaWebServices alloc] init];
    
    if ([_action isEqualToString:@"insert"]) {
        [webServices backgroundInsertFeed:_feedModel];
    } else {
        [webServices backgroundDeleteFeed:_feedModel];
    }
    
    // --------
    _feedModel = [[plaFeedModel alloc] init];
    today = [[NSDate date] timeIntervalSince1970] + 1;
    
    _feedModel.FEED_ID = [NSString stringWithFormat:@"%ld", (long)today];
    _feedModel.FEED_USER = m_mainUser.USER_ID;
    _feedModel.FEED_CONTENT = globEvents.sglobUserID;
    _feedModel.FEED_ACTION = @"Friend";
    
    if ([_action isEqualToString:@"insert"]) {
        [webServices backgroundInsertFeed:_feedModel];
    } else {
        [webServices backgroundDeleteFeed:_feedModel];
    }
    
}

#pragma mark ---- delegate
- (IBAction)onBtnBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBtnFriend:(id)sender
{
    UIActionSheet* actionSheet;
    UIButton* button = (UIButton*)sender;
    switch (m_mainUser.USER_FRIENDSTATE) {
        case -1: //
            
            break;
        case 0: // request friend state
//            [self addFriend];
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Send Friend Request" otherButtonTitles:nil];
            actionSheet.tag = 0;
            [actionSheet showInView:self.view];
            break;
        case 1: // friend state
            if ([button.titleLabel.text isEqualToString:@"Friend Request Sent"]) {
                return;
            }
            actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Remove Friend" otherButtonTitles: nil];
            actionSheet.tag = 1;
            [actionSheet showInView:self.view];
            break;
            
        default:
            break;
    }
}

- (IBAction)onBtnConfirm:(id)sender {
    [self confirmFriend:m_mainUser];
}

- (IBAction)onBtnDecline:(id)sender {
    [self declineFriend:m_mainUser];
}

#pragma mark ----------- delegate -------  actionsheet ----------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 0) { // send request friend
        switch (buttonIndex) {
            case 0:
                [self addFriend];
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
    } else if (actionSheet.tag == 1) { // remove Friend state
        switch (buttonIndex) {
            case 0:
                [self removeFriend];
                break;
            case 1:
                
                break;
                
            default:
                break;
        }
    }
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
