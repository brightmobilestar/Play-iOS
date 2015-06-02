//
//  plaViewController.h
//  Play
//
//  Created by Darcy Allen on 2014-06-05.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import <CoreLocation/CoreLocation.h>

#define distance_param 3000.0f * 3.0f

@class plaEvent;
@class plaUser;
@class plaHomeViewController;
@class plaEntityPageViewController;
@class plaEventDetailViewController;

@interface plaViewController : UIViewController <FBLoginViewDelegate,  UITableViewDataSource, UITableViewDelegate>{
    // AmazonSimpleDBClient *sdbClient;
    CLLocationManager *lm;
    NSMutableArray *trackPointArray;
    NSString             *nextToken;
    
    BOOL isFristLoad;
    
    NSArray* m_arrayPermisssion;
    
    NSInteger _intLocationUpdateCount;
    NSInteger _currentVisitTime;
    
#pragma mark -------- tutorial -----------------
    
    IBOutlet UIScrollView *m_scrollViewTutorial;
    
    NSMutableArray* m_arrayTblData;
    IBOutlet UITableView* m_tableView;
    IBOutlet UIView *m_viewScrollView5;
    
    UIAlertView* m_messageBox;
    IBOutlet UIView *m_view4_subView;
}

- (IBAction)onBtnTutorial_page1:(id)sender;
- (IBAction)onBtnTutorial_page2:(id)sender;
- (IBAction)onBtnTutorial_page3:(id)sender;
- (IBAction)onBtnTutorial_page4:(id)sender;
- (IBAction)onBtnTutorial_page4_subbtn:(id)sender;

- (IBAction)onBtnTutorial_page5:(id)sender;

-(IBAction)onBtnTutorialLater:(id)sender;
- (IBAction)onBtnFBFriendsInvit:(id)sender;
- (IBAction)onBtnAnotherTime:(id)sender;
-(void)readTblData;

@property (readwrite) BOOL isPossibleVisitPlace;

@property (nonatomic, retain) NSMutableArray *DBEvents;
@property (nonatomic, retain) plaEvent *plaEventDBList;

@property (nonatomic, retain) NSString *nextToken;
@property (weak, nonatomic) IBOutlet UILabel *lblVersion;

@property (weak, nonatomic) IBOutlet FBLoginView *loginButton;

/*
when we attempted a custom facebook button from working source that used xibs. this is here as a developer's reference:
@property (strong, nonatomic) IBOutlet UIButton *buttonLoginLogout;
- (IBAction)buttonClickHandler:(id)sender;
- (void)updateView;
*/

@property (weak, nonatomic) IBOutlet UILabel *lblYoureAllSet;
@property (weak, nonatomic) IBOutlet UILabel *lblWelcome;
@property (weak, nonatomic) IBOutlet UILabel *lblBackgroundWelcome;

@property (weak, nonatomic) IBOutlet UILabel *lblUsername;

@property (weak, nonatomic) IBOutlet UILabel *lblEmail;

@property (weak, nonatomic) IBOutlet FBProfilePictureView *profilePicture;

// @property (weak, nonatomic) IBOutlet UIButton *buttonWelcome;
@property (weak, nonatomic) IBOutlet UIButton *btnStart;

@property (weak, nonatomic) IBOutlet UIImageView *imagePin;

@property BOOL bStart;
@property NSInteger iServerBuildNumber;
@property NSString *sInternalBuildVersion;

#pragma mark ----- background functions --------

- (void)sendRequest;
-(IBAction)showMessage;
-(IBAction)onBtnStart:(id)sender;

-(void)toggleHiddenState:(BOOL)shouldHide;

-(void)setBackground:(BOOL)bFirst;

- (void)startTracking;
- (void)stopTracking;

-(void)getDBEvents;

#pragma mark ----- Graph Api -----------
- (void) makeUploadRequeat:(plaEvent*)_event;

- (NSMutableArray*) makeRequestFromUserLikesEntity; // To get PageObject that user likes
-(void) makeRequestForEventAttendingUsers:(plaEvent*)_event;

- (void) makeRequestForFBEventPhotos:(NSString *)_eventID;
- (void) makeRequestForEventAttendingNum:(plaEvent*)parsedEvent;
- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent sec:(plaHomeViewController*)_rootCtrl;
- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent third:(plaEntityPageViewController*)_rootCtrl;
- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent detailPage:(plaEventDetailViewController*)_controller;
- (void) makeRequestForUserInfo:(NSString*) _userID;
- (void) makeRequestForUserInfoAdd:(plaUser*) _userModel;
- (void) getEntityPageInfo:(NSString*)_entityID;

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations;

#pragma mark ---------- tableview For App Friend Invitation -----------



@end