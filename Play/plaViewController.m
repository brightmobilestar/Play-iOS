//
//  plaViewController.m
//  Play
//
//  Created by Darcy Allen on 2014-06-05.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaViewController.h"
#import "plaAppDelegate.h"
#import <Foundation/Foundation.h>
#import <FacebookSDK/FacebookSDK.h>
#import "plaEvent.h"
#import "plaEntity.h"
#import "plaHashtagFeedModel.h"
#import "plaUser.h"
#import "plaVisitPlace.h"
#import "plaEventData.h"
#import "plaDB.h"
#import "plaWebServices.h"
#import "INTULocationManager.h"
#import "plaHomeViewController.h"
#import "plaEntityPageViewController.h"
#import "plaEventDetailViewController.h"
#import "PushNotificationManagement.h"

#define isiPhone5  ([[UIScreen mainScreen] bounds].size.height == 568)?TRUE:FALSE
#define isiPhone  (UI_USER_INTERFACE_IDIOM() == 0)?TRUE:FALSE

#define EVENTID_ATTRIBUTE     @"EV_SEVENTID"
#define NAME_ATTRIBUTE         @"EV_SNAME"
#define STARTDATETIME_ATTRIBUTE      @"EV_SSTARTDATETIME"
#define LOCATION_ATTRIBUTE      @"EV_SLOCATION"
#define IMAGE_ATTRIBUTE            @"EV_SIMAGE"

@implementation plaViewController {
}

@synthesize nextToken;
@synthesize iServerBuildNumber;
@synthesize  sInternalBuildVersion;
@synthesize isPossibleVisitPlace;

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) initGlobalData
{
    g_arrayActivityFeedData = [[NSMutableArray alloc] init];
    g_arrayUpcommingEventData = [[NSMutableArray alloc] init];
    g_arraySelectedCategoryEventsData = [[NSMutableArray alloc] init];
    g_arrayUpcommingEventDataOnFB = [[NSMutableArray alloc] init];
    g_arrayUserData = [[NSMutableArray alloc] init];
    g_arrayMailData = [[NSMutableArray alloc] init];
    g_arrayAllEventData = [[NSMutableArray alloc] init];
    g_arrayTemp = [[NSMutableArray alloc] init];
    g_arrayActivityFeeds = [[NSMutableArray alloc] init];
    g_arrayVisitPlaceData = [[NSMutableArray alloc] init];
    g_arrayFBFriendsDta = [[NSMutableArray alloc] init];
    
    g_managePush = [[PushNotificationManagement alloc] init];
    [self getAllCategoryData];
}


-(void)getAllCategoryData
{
    plaEventData* globData = [plaEventData getInstance];
    globData.arrayglobCategories = [[NSMutableArray alloc] init];
    [globData.arrayglobCategories addObject:@"Arts & Culture"];
    [globData.arrayglobCategories addObject:@"Attractions & Things to Do"];
    [globData.arrayglobCategories addObject:@"Comedy"];
    [globData.arrayglobCategories addObject:@"Exhibitions & Conventions"];
    [globData.arrayglobCategories addObject:@"Eats and Drinks"];
    [globData.arrayglobCategories addObject:@"Fashion & Shopping"];
    [globData.arrayglobCategories addObject:@"Festivals"];
    [globData.arrayglobCategories addObject:@"Health and Fitness"];
    [globData.arrayglobCategories addObject:@"Leisure"];
    [globData.arrayglobCategories addObject:@"Meet-Ups"];
    [globData.arrayglobCategories addObject:@"Movies"];
    [globData.arrayglobCategories addObject:@"Nightlife & Concerts"];
    [globData.arrayglobCategories addObject:@"Sports"];
    [globData.arrayglobCategories addObject:@"Travel & Adventure"];
    //[globData.arrayglobCategories addObject:@"Venues & Locations"];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    NSInteger index;
    index = floor((m_scrollViewTutorial.contentOffset.x - 320) / 320 ) + 1;
    
    NSLog(@"Will begin dragging --- %ld", (long)index);
    
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_arrayTblData = [[NSMutableArray alloc] init];
    plaEventData *globEvents = [plaEventData getInstance];
    
    [globEvents startDataLoad];
    
    globEvents.arrayglobDBEvents = [[NSMutableArray alloc] init];
    globEvents.arrayglobDBEntities = [[NSMutableArray alloc] init];
    globEvents.arrayglobDBCreatedEntities = [[NSMutableArray alloc] init];
    globEvents.arrayglobDBCreatedEntitiesStatic = [[NSMutableArray alloc] init];
    globEvents.arrayglobDBCreatedEntitiesStatic1 = [[NSMutableArray alloc] init];
    
    g_controllerView = self;
    globEvents.m_currentController = @"viewController";
    
    [m_scrollViewTutorial setContentSize:CGSizeMake(1280, 568)]; //@"publish_actions", @"manage_pages",
    m_scrollViewTutorial.scrollEnabled = true;
    m_arrayPermisssion = [[NSArray alloc] initWithObjects:@"public_profile", @"email", @"friends_events",@"user_friends ",@"user_friends", @"user_events",@"user_likes",@"manage_friendlists", nil];
    //user_likes:   To get Page Objects that User likes
    
    _intLocationUpdateCount = 0;
    isPossibleVisitPlace = false;
    
    isFristLoad = true;
    [self initGlobalData];
    
    _profilePicture.clipsToBounds = YES;
    [self.profilePicture.layer setCornerRadius:27.0f];
    
    // pin graphic was showing then hiding so force it off here first
	self.imagePin.hidden = YES;

    // to do: if we want a log file, get it open now
    
    // output Version of this app to the console and/or log file
    // to do: move the hardcoded version to global strings resource
    self.sInternalBuildVersion = @"v1.1 alpha 1";
    self.lblVersion.text = self.sInternalBuildVersion;
    self.lblVersion.hidden = NO;   // set this to YES before submitting to the Apple Store !!
    NSLog( @"Play Entertainment Network %@", sInternalBuildVersion );

    self.bStart = NO;

    // set the initial background image
    [self setBackground: YES];
    
    // initially we initiated the Location Services in order to get location here, but later discovered this is too early. leave here commented out as a reminder:
	// [self startTracking];

    // as the app starts we hide the controls until after the user has logged in:
    [self toggleHiddenState: YES];

    // necessary to specify read sions when logging into facebook
    // to do: add @"user_friends" when we need to show their events too
    // If your app asks for more than public_profile, email and user_friends, then it will have to be reviewed by Facebook before it can be made available to the general public.
    
    self.loginButton.readPermissions = m_arrayPermisssion;
    
    //   , @"EDIT_PROFILE", @"CREATE_CONTENT",@"MODERATE_CONTENT",@"CREATE_ADS",@"BASIC_ADMIN"

    self.loginButton.delegate = self;
    

    self.nextToken = nil;
}

- (void)viewWillAppear:(BOOL)animated {
    
    self.loginButton.readPermissions = m_arrayPermisssion;
                        // ,@"administer",@"publish_actions"]   // ,@"user_friends ", @"user_events" @"ADMINISTER", , @"publish_actions"
    
    self.loginButton.delegate = self;
    
    [self.loginButton setReadPermissions: m_arrayPermisssion];
    
    [self startTracking];
    trackPointArray = [[NSMutableArray alloc] init];
    
    // unit test success: NSLog( @"Start screen viewWillAppear()" );
    plaEventData *globEvents = [plaEventData getInstance];
    if ( globEvents.iglobLoggingOut == 20 )
    	{
            exit(0);

        }  // end if we are Logging Out
    
    // set a default location just in case
    globEvents.fglobLatitude = 51.0;
    globEvents.fglobLongitude = -114.0;
    
    [self showTutorialScreen];
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)toggleHiddenState:(BOOL)shouldHide{
    self.lblUsername.hidden = shouldHide;
    self.lblEmail.hidden = shouldHide;
    self.profilePicture.hidden = shouldHide;
    self.btnStart.hidden = shouldHide;
    if (!shouldHide) {
        [self moveScrollView:4];
        //[self performSelector:@selector(readTblData) withObject:nil afterDelay:1.0f];
    }
    self.lblYoureAllSet.hidden = shouldHide;
}

- (IBAction)onBtnStart:(id)sender
{
//    UIStoryboard* storyBoardTemp = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
//    plaHomeViewController* viewControllerHome = (plaHomeViewController*)[storyBoardTemp instantiateViewControllerWithIdentifier:@"plaHomeViewController"];
//    viewControllerHome.m_viewControllerRoot = self;
//    viewControllerHome.m_intTemp = 5;
//    
//    [self presentViewController:viewControllerHome animated:YES completion:nil];
}

- (IBAction)showMessage
{
	/*
	the code that used to work, did the FB and DB events merging, then the Home View Controller would show after that just fine.limit
    Now, this merging code MUST move to the initFrontView of the Home View Controller, and this was necessary after merging the code together from the contract guy and Darcy's code October 19, 2014.
    if ( self.bStart == YES )
    {
    
    // first do the merge
    plaEventData *globEvents = [plaEventData getInstance];
    NSInteger iFBSize = [globEvents.arrayglobFBEvents count];
    
    // unit test successful:  NSLog( @"before Merge, the Size of FB Events array = %d", (int)iFBSize );

    if ( (int)iFBSize > (int)0 )
        {
        // only if there are FB Events for this user, we need to potentially add them to our database
        [self MergeFBandDB];
        }
	*/
    /*
    UIAlertView *helloAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Play Entertainment Network" message:@"The next screen in the next build will show all Events!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    // Display the  Message
    [helloAlert show];

    // go to next screen:
    // unit test successful:  NSLog( @"calling performSegueWithIdentifier starttoevents" );
    // [self performSegueWithIdentifier:@"starttoevents" sender:self];
    }
    */
}

-(void)setBackground:(BOOL)bFirst
{
    NSString *sReady = @"Ready";
    NSString *sReady4Inch = @"Ready-568h";
    NSMutableString *sImage = [NSMutableString stringWithString:@"Landing"];
    
    if ( bFirst == NO )
        {
        // set the Image to the correct "Ready" screen
        if(isiPhone)
            {
            if (isiPhone5)
                {
                 sImage = [NSMutableString stringWithString: sReady4Inch ];
                }
            else
                {
                // iphone 3.5 inch screen
                sImage = [NSMutableString stringWithString: sReady];
                 }
            }
        else
             {
                // [ipad]
            }
       }

    // pull in the background image
    // unit test success: NSLog( @"sImage = %@", sImage );
    UIImage *backgroundImage = [UIImage imageNamed:sImage];

    // scale it to the size of the display
    UIGraphicsBeginImageContext(self.view.bounds.size);
    CGRect imagePosition = CGRectMake((self.view.bounds.size.width / 2)  - (backgroundImage.size.width / 2),
                                      (self.view.bounds.size.height / 2) - (backgroundImage.size.height / 2),
                                      backgroundImage.size.width,
                                      backgroundImage.size.height);
    
    [backgroundImage drawInRect:imagePosition];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // apply this to the view
    UIColor *color = [[UIColor alloc] initWithPatternImage: image];
    self.view.backgroundColor = color;
    
    // ARC will free the allocated memory above so there is no memory leaks
}

// ---------  ------------
#pragma mark ----- request the user events to facebook -------
/*
 Leave these comments here to show alternative software development utilizing Facebook
 This function asks for the user's (upcoming) events, and for those events retrieves the name, the start_time and the cover picture.
 It first checks for the existence of the public_profile and user_events permissions
 If the permissions are not present, it requests them
 If/once the permissions are present, it makes the user events request with field expansion for name, start_time and cover picture.
 */


- (void)requestPermission
{
    //[self makeRequestForUserEvents];
    return;
    
    NSArray *permissionsNeeded = m_arrayPermisssion;
    [FBRequestConnection startWithGraphPath:@"/me/permissions"   //manage_pages
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if ( !error )
                              {
                                  
                                  NSArray *requestPermissions = permissionsNeeded;
                                  
                                  [FBSession.activeSession requestNewReadPermissions:requestPermissions
                                                                   completionHandler:^(FBSession *session, NSError *error) {
                                                                       if (!error) {
                                                                           // Permission granted
                                                                           NSLog(@"new permissions %@", [FBSession.activeSession permissions]);
                                                                           // We can request the user information
                                                                           //[self makeRequestForUserEvents];
                                                                       } else {
                                                                           // An error occurred, we need to handle the error
                                                                           NSLog(@"error %@", error.description);
                                                                       }
                                                                   }];
                                  
                                  [self makeRequestForUserEvents];
                                  
                              }  // if no errorfrom facebook connection
                              else
                              {
                                  // An error occurred, we need to handle the error
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

- (IBAction)requestEvents:(id)sender
{

    [self makeRequestForUserEvents];
    
    return;
    
    
    [FBRequestConnection startWithGraphPath:@"/me/permissions"   //manage_pages
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if ( !error )
                              {
                                  NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                                  NSLog(@"current permissions %@", currentPermissions);
                                  
                                  [self makeRequestForUserEvents];
                                  
                              }  // if no error from facebook connection
                              else
                              {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                          }];
}

// only display public events, where "privacy = OPEN;"

-(NSString *)JSONString:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&" withString:@"*-*-*-*-*" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //[s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

- (void) makeUploadRequeat:(plaEvent*)_event
{
//    NSMutableDictionary *postParams = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
//                                       @"Test",@"name",
//                                       @"2015-05-22", @"start_time", nil];
    
    [FBRequestConnection
     startWithGraphPath:[NSString stringWithFormat:@"/%@/declined", _event.EV_SEVENTID]
     parameters:nil
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         if (error) {
             NSLog(@"Error: %@", result);
             
         } else {
             NSLog(@"Success: %@", result);
             
         }
     }];
}


- (NSMutableArray*) makeRequestFromUserLikesEntity // permission: user_likes
{
    NSMutableArray* _array = [[NSMutableArray alloc] init];
    g_controllerViewHome.m_arrayMyLikesEntities = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:@"/me/likes"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              // handle the result /
                              if ( !error )
                              {
                                  // unit test success:
                                  // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
                                  // unit test success:
                                  NSLog( @"makeRequestFromUserLikesEntity:\n");
                                  
                                  // parse out events and add to our data model. first we walk the JSON:
                                  NSDictionary *resultDict = (NSDictionary *)result;
                                  NSArray *eventsArr = [resultDict objectForKey:@"data"];
                                  
                                  // if we need a count for some maximum:
                                  // int iCount;
                                  // iCount = 0;
                                  
                                  for ( NSDictionary *entityObj in eventsArr )
                                  {
                                      
                                      plaEntity *entity = [[plaEntity alloc] init];
                                      entity.EN_SID = [entityObj objectForKey:@"id"];
                                      entity.EN_SNAME = [entityObj objectForKey:@"name"];
                                      entity.EN_SPHONENUMBER = [entityObj objectForKey:@"phone"];
                                      entity.EN_SCATEGORY = [entityObj objectForKey:@"category"];
                                      
                                      //[_array addObject:[entityObj objectForKey:@"id"]];
                                      
                                      [g_controllerViewHome.m_arrayMyLikesEntities addObject:entity]; 
                                      
                                      // add to our global array
                                  }  // end for
                              }  // end if
                              else
                              {
                                  // An error occurred, we need to handle the error
                                  // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                                  NSLog(@"error %@", error.description);
                              }
                              //g_controllerViewHome.m_arrayMyLikesEntities = _array;
                          }];
    
    return _array;
}

-(void) makeRequestForEventAttendingUsers:(plaEvent*)_event
{
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/attending", _event.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              // handle the result /
                              if ( !error )
                              {
                                  // unit test success:
                                  // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
                                  // unit test success:
                                  NSLog( @"makeRequestForEventAttendingUsers:\n");
                                  
                                  // parse out events and add to our data model. first we walk the JSON:
                                  NSDictionary *resultDict = (NSDictionary *)result;
                                  NSArray *eventsArr = [resultDict objectForKey:@"data"];
                                  
                                  //_event.EV_SUSERSNUMBERONFB = [eventsArr count];
                                  
                                  if (_event.EV_SUSERSNUMBERONFB > 900) {
                                
                                  }
                                  _event.EV_SATTENDINGUSERSARRAY = [[NSMutableArray alloc] init];
                                  for ( NSDictionary *entityObj in eventsArr )
                                  {
                                      
                                      plaUser *_user = [[plaUser alloc] init];
                                      _user.USER_ID = [entityObj objectForKey:@"id"];

                                      //[_event.EV_SATTENDINGUSERSARRAY addObject:_user];
                                      NSString* _strUserID = _user.USER_ID;
                                      [_event.EV_SATTENDINGUSERSARRAY addObject:_strUserID];
                                  }
                                  
                                  if ([g_arrayAllEventData count] > 0) {
                                      [g_controllerViewHome getEventsFor3Items];
                                  }
                                  
                              }  // end if
                              else
                              {
                                  // An error occurred, we need to handle the error
                                  NSLog(@"error %@", error.description);
                              }

                          }];
}

- (void)makeRequestForMemberFromFrieldList:(NSString*)_friendListID
{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/members", _friendListID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              NSDictionary *resultDict = (NSDictionary *)result;
                              NSArray *eventsArr = [resultDict objectForKey:@"data"];
                              
                              // unit test:
                              NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
                              

                          }];
}

- (void)makeRequestForUsers
{
    [FBRequestConnection startWithGraphPath:@"/me/friends"
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              ) {
                              /* handle the result */
                              if ( !error )
                              {
                                  // unit test success:
                                  // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
                                  // unit test success:
                                  NSLog( @"makeRequestForUsers:\n");
                                  
                                  // parse out events and add to our data model. first we walk the JSON:
                                  NSDictionary *resultDict = (NSDictionary *)result;
                                  NSArray *eventsArr = [resultDict objectForKey:@"data"];
                                  
                                  // unit test:
                                  NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
                                  
                                  // if we need a count for some maximum:
                                  // int iCount;
                                  // iCount = 0;
                                  
                                  for ( NSDictionary *eventObj in eventsArr )
                                  {
                                      
                                      plaUser* _user = [[plaUser alloc] init];
                                      
                                      _user.USER_ID = [eventObj objectForKey:@"id"];
                                      _user.USER_PROFILEIMAGE = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=true", _user.USER_ID ];
                                      // --------
                                      _user.USER_NAME = [eventObj objectForKey:@"name"];
                                      
                                      [g_arrayFBFriendsDta addObject:_user];
                                      
                                      //[self makeRequestForMemberFromFrieldList:strFrieldListID];
                                      
                                  }
                                  
                                  [self readTblData];
                          }
                          }];
}

- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val =
        [kv[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        params[kv[0]] = val;
    }
    return params;
}
- (IBAction)onBtnSendRequest:(id)sender {
//    [self sendRequest];
}

- (void)sendRequest
{
    
//    NSMutableDictionary* params =   [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                     
//                                     // Optional parameter for sending request directly to user
//                                     @"292756214257880", @"to",
//                                     // with UID. If not specified, the MFS will be invoked
//                                     //@"292756214257880", @"to",
//                                     
//                                     // Give the action object request information
//                                     @"send", @"action_type",
//                                     
//                                     @"https://developers.facebook.com/docs/sharing/reference/send-dialog", @"link",
//                                     
//                                     @"11223344556677", @"object_id",
//                                     
//                                     nil];
    
    [FBWebDialogs
     presentRequestsDialogModallyWithSession:nil
     message:@"Learn how to make your iOS apps social."
     title:nil
     parameters:nil
     handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
         if (error) {
             // Error launching the dialog or sending the request.
             NSLog(@"Error sending request.");
         } else {
             if (result == FBWebDialogResultDialogNotCompleted) {
                 // User clicked the "x" icon
                 NSLog(@"User canceled request.");
             } else {
                 // Handle the send request callback
                 NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
                 if (![urlParams valueForKey:@"request"]) {
                     // User clicked the Cancel button
                     NSLog(@"User canceled request.");
                 } else {
                     // User clicked the Send button
                     NSString *requestID = [urlParams valueForKey:@"request"];
                     NSLog(@"Request ID: %@", requestID);
                     
                     [self showMessageBox:@"Invatations Sent"];
                 }
             }
         }
     }];
}

- (NSString*)getTodayDate
{
    NSDate *today = [NSDate date];
    NSArray* array = [[today description] componentsSeparatedByString:@" "];
    
    NSString* strToday = [NSString stringWithFormat:@"%@T00:00:00", [array objectAtIndex:0]];
    
    //    return @"2014-11-09T00:00:00";
//    return @"2014-12-12T00:00:00";
    
    return strToday;
}

- (void)makeRequestForUserEvents
{
    
    [self makeRequestForMyAccount];
    
    [self makeRequestForUsers];
    
    NSString* _strToday = [self getTodayDate];
    
    [self readAllAppUser];
    
     [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"me/events/attending?limit=150&since=%@&fields=id,attending_count,name,start_time,end_time,location,source,cover,ticket_uri,owner,url", _strToday]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) //,description
    	{
    	if ( !error )
        	{
            // unit test success:
            // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
            // unit test success:
            NSLog( @"makeRequestForUserEvents:\n");

            // parse out events and add to our data model. first we walk the JSON:
            NSDictionary *resultDict = (NSDictionary *)result;
            NSArray *eventsArr = [resultDict objectForKey:@"data"];
            
            // unit test:
            NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
            
            NSString *sOPEN = @"OPEN";
            NSString *sFBEventPrivacy = @" ";
            BOOL bMatch;

            // if we need a count for some maximum:
            // int iCount;
            // iCount = 0;
            plaEventData *globEvents = [plaEventData getInstance];
            globEvents.arrayglobFBEvents = [[NSMutableArray alloc] init];

            for ( NSDictionary *eventObj in eventsArr )
            {
                sFBEventPrivacy = [eventObj objectForKey:@"privacy"];
                
                bMatch = [ sFBEventPrivacy isEqual:sOPEN ];

                plaEvent *parsedEvent = [[plaEvent alloc] init];
                
                FBGraphObject *coverObj1 = [eventObj objectForKey:@"owner"];
                    
                parsedEvent.EV_SPERSONNAME = [coverObj1 objectForKey:@"name"];
                    
				// then we dig deeper into the JSON asking for the value for each known key
                parsedEvent.EV_SNAME = [self JSONString:[eventObj objectForKey:@"name"]];
                    
                parsedEvent.EV_SENTITYPAGEID = [coverObj1 objectForKey:@"id"];
                parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
                parsedEvent.EV_SENTITY.EN_SID = [coverObj1 objectForKey:@"id"];
                
                parsedEvent.EV_SEVENTID = [eventObj objectForKey:@"id"];
                parsedEvent.EV_SUSERSNUMBERONFB = [[eventObj objectForKey:@"attending_count"] integerValue];
                
                parsedEvent.EV_SSTARTDATETIME = [self JSONString:[eventObj objectForKey:@"start_time"]];                 
                
                parsedEvent.EV_SENDDATE = [self JSONString:[eventObj objectForKey:@"end_time"]];
                parsedEvent.EV_SLOCATION = [eventObj objectForKey:@"location"];
                
                parsedEvent.EV_SDESCRIPTION = [self JSONString:[eventObj objectForKey:@"description"]];
                parsedEvent.EV_SDESCRIPTION1 = [self JSONString:[eventObj objectForKey:@"description"]];
                    
                parsedEvent.EV_STICKETURL = [self JSONString:[eventObj objectForKey:@"ticket_uri"]];//ticket_uri
                parsedEvent.EV_SDESCRIPTION = @"-";
                
                parsedEvent.EV_SATTENDCOUNT = 0;
                    
                    parsedEvent.EV_SUSERID = globEvents.sglobUserID;
                
                    FBGraphObject *coverObj = [eventObj objectForKey:@"cover"];
                    if (coverObj != nil) {
                        parsedEvent.EV_SIMAGE = [self JSONString:[coverObj objectForKey:@"source"]];
                    }
                    
                // replace any nils with "na"
                if ( parsedEvent.EV_SIMAGE == nil )
					{
                    parsedEvent.EV_SIMAGE = EVENT_IMAGE_PLACEHOLDER;
                    }
                if ( parsedEvent.EV_SSTARTDATETIME == nil )
					{
                    parsedEvent.EV_SSTARTDATETIME = EVENT_INFO_PLACEHOLDER;
                    }
                if ( parsedEvent.EV_SLOCATION == nil )
					{
                    parsedEvent.EV_SLOCATION = EVENT_INFO_PLACEHOLDER;
                    }
                    
                    [self makeRequestForUserEvent:parsedEvent];
				// add to our global array
                
                // unit test successful:
                 NSLog( @"in makeRequestForUser() got FB event: %ld ", (long)[globEvents.arrayglobFBEvents count] );
                // iCount++;
            	}  // end for
                
            // unit test success:
            NSInteger iSize = [globEvents.arrayglobFBEvents count];
            // unit test success:
            NSLog( @"FB Parse Num of arrayglobFBEvents = %ld", (long)iSize );

        	}  // end if
        else
           	{
             // An error occurred, we need to handle the error
            // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
            }  // end else
    } ];
}

- (void)makeRequestForMyAccount //
{
    [FBRequestConnection startWithGraphPath:@"me/accounts" //?fields=perms,access_token
                            parameters:nil
                            HTTPMethod:@"GET"
                            completionHandler:^(FBRequestConnection *connection, id result, NSError *error)
    	{
            if ( !error )
            {
                NSDictionary *currentPermissions= [(NSArray *)[result data] objectAtIndex:0];
                NSLog(@"current permissions %@", currentPermissions);

                // unit test success:
                // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
                // unit test success:
                NSLog( @"Facebook My Entities:\n"  );
                
                // parse out events and add to our data model. first we walk the JSON:
                NSDictionary *resultDict = (NSDictionary *)result;
                NSArray *eventsArr = [resultDict objectForKey:@"data"];
                
                // unit test:
                NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
                
                // if we need a count for some maximum:
                // int iCount;
                // iCount = 0;
                plaEventData *globEvents = [plaEventData getInstance];
                globEvents.arrayglobMyEntities = [[NSMutableArray alloc] init];
                
                for ( NSDictionary *eventObj in eventsArr )
                {
                    plaEntity* entity = [[plaEntity alloc] init];
                    entity.EN_SID = [eventObj objectForKey:@"id"];
                    entity.EN_SNAME = [eventObj objectForKey:@"name"];
                    
                    [globEvents.arrayglobMyEntities addObject:entity];
                    
                    [self getEntityPageInfo:entity.EN_SID];
                    // iCount++;
                }  // end for
                
                // unit test success:
                NSInteger iSize = [globEvents.arrayglobFBEvents count];
                // unit test success:
                NSLog( @"FB Parse Num of arrayglobFBEvents = %ld", (long)iSize );
                
            }  // end if
            else
           	{
                // An error occurred, we need to handle the error
                // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
                NSLog(@"error %@", error.description);
            }  // end else
        } ];
}

- (void) getEntityPageInfo:(NSString*)_entityID ///:(plaEvent*)parsedEvent
{
    //    [self getEntityPageProfileImage:_entityID];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,name,cover,location,phone,category,picture", _entityID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"Facebook Entity Page Info:\n"  );
             plaEntity* entity = [[plaEntity alloc] init];
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             NSDictionary *entityObj = resultDict;
             
             entity.EN_SID = [entityObj objectForKey:@"id"];
             entity.EN_SNAME = [entityObj objectForKey:@"name"];
             
             entity.EN_SPHONENUMBER = [entityObj objectForKey:@"phone"];
             entity.EN_SCATEGORY = [entityObj objectForKey:@"category"];
             //NSArray* array = [entityObj objectForKey:@"category_list"];
             //entity.EN_SCATEGORY = [array componentsJoinedByString:@", "];
             
             FBGraphObject *coverObj = [entityObj objectForKey:@"cover"]; /// cover image
             if (coverObj != nil) {
                 entity.EN_SIMAGE = [coverObj objectForKey:@"source"];
             }
             
             coverObj = [entityObj objectForKey:@"location"]; // ---- location info
             if (coverObj != nil) {
                 entity.EN_SSTATE = [coverObj objectForKey:@"state"];
                 entity.EN_SCITY = [coverObj objectForKey:@"city"];
                 entity.EN_SLOCATIONSTR = [coverObj objectForKey:@"hometown"];
                 entity.EN_SLOCATIONSTR = [coverObj objectForKey:@"located_in"];
                 entity.EN_SSTREET = [coverObj objectForKey:@"street"];
                 entity.EN_SADDRESSSTR = [NSString stringWithFormat:@"%@, %@", [coverObj objectForKey:@"street"], [coverObj objectForKey:@"city"]];
                 entity.EN_SLOCATION = [[CLLocation alloc] initWithLatitude:[[coverObj objectForKey:@"latitude"] doubleValue] longitude:[[coverObj objectForKey:@"longitude"] doubleValue]];
                 
                 plaEventData* originLocationInfo = [plaEventData getInstance];
                 
                 int intdistand = [entity.EN_SLOCATION distanceFromLocation:originLocationInfo.sglobLocation];
                 
                 entity.EN_SDISTANCE = [NSString stringWithFormat:@"%.1f", ((float)intdistand) / distance_param];
                 
                 // --------- To insert Entity Full info ----------
                 
                 plaWebServices* webService = [[plaWebServices alloc] init];
                 [webService insertEntityFull:entity];
                 
             }
             coverObj = [entityObj objectForKey:@"picture"];
             coverObj = [coverObj objectForKey:@"data"];
             if (coverObj != nil) {
                 entity.EN_SIMAGEPROFILE = [coverObj objectForKey:@"url"];
             }
             
             plaEventData* globData = [plaEventData getInstance];
             if (![self isContainEntity:entity]) {
                 
                 [globData.arrayglobDBEntities addObject:entity];
                 
                 for (int i = 0; i < [globData.arrayglobDBCreatedEntities count]; i ++) {
                     plaEntity* entity = [globData.arrayglobDBCreatedEntities objectAtIndex:i];
                     [self getEntityFromFBID:entity];
                 }
                 
//                 [g_controllerViewHome.m_tableViewFull reloadData];
                 [g_controllerViewHome refreshTableView];
                 NSLog(@"---entity --- %ld----------------------------------------------", (unsigned long)[globData.arrayglobDBEntities count]);
             }
             
             [g_controllerEntityPage loadEntityData];
         }  // end if
         else
         {
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return ;
}


- (void) getEntityInfo:(NSString*)_entityID ///:(plaEvent*)parsedEvent
{
    //    [self getEntityPageProfileImage:_entityID];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,name,cover,location,phone,category,picture", _entityID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"Facebook Entity Info:\n"  );
             
             plaEntity* entity = [[plaEntity alloc] init];
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             NSDictionary *entityObj = resultDict;
             
             entity.EN_SID = [entityObj objectForKey:@"id"];
             entity.EN_SNAME = [entityObj objectForKey:@"name"];
             
             NSArray* array = [entity.EN_SNAME componentsSeparatedByString:@", "];
             
             entity.EN_SCITY = [array objectAtIndex:0];
             entity.EN_SSTATE = [array objectAtIndex:1];
             
             [g_arrayTemp addObject:entity];
             
         }  // end if
         else
         {
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return ;
}

- (void)getEntityFromFBID:(plaEntity*)_entity
{
    NSString* _fbID = _entity.EN_SFACEBOOKID;
    
    //plaEntity* returnEntity;
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ([entity.EN_SID isEqualToString:_fbID]) {
            
            _entity.EN_SNAME = entity.EN_SNAME;
            _entity.EN_SIMAGE = entity.EN_SIMAGE;
            _entity.EN_SDISTANCE = entity.EN_SDISTANCE;
            _entity.EN_SCITY = entity.EN_SCITY;
            _entity.EN_SIMAGEPROFILE = entity.EN_SIMAGEPROFILE;
            _entity.EN_SADDRESSSTR = entity.EN_SADDRESSSTR;
            _entity.EN_SCATEGORY = entity.EN_SCATEGORY;
            _entity.EN_SLOCATION= entity.EN_SLOCATION;
            _entity.EN_SLOCATIONSTR = entity.EN_SLOCATIONSTR;
            
            break;
        }
    }
    //return returnEntity;
}

- (void) getEntityPageProfileImage:(NSString*)_entityID ///:(plaEvent*)parsedEvent
{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/platform/picture?fields=url"]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"Facebook event Pictures:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             NSDictionary *entityObj = resultDict;
             
             NSString* strTemp = [entityObj objectForKey:@"url"];
             strTemp = strTemp;
             
         }  // end if
         else
         {
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return ;
}

- (void) makeRequestForFBEventPhotos:(NSString *)_eventID
{
    NSMutableArray* _array = [[NSMutableArray alloc] init];
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@/photos", _eventID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
        	{
                // unit test success:
                // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
                // unit test success:
                NSLog( @"Facebook events Photoes:\n");
                
                // parse out events and add to our data model. first we walk the JSON:
                NSDictionary *resultDict = (NSDictionary *)result;
                NSArray *eventsArr = [resultDict objectForKey:@"data"];
                
                // iCount = 0;
                
                for ( NSDictionary *eventObj in eventsArr )
                {
                    plaHashtagFeedModel* _model = [[plaHashtagFeedModel alloc] init];
                    _model.HASHTAG_PHOTOURL = [eventObj objectForKey:@"source"];
                    
                    FBGraphObject *coverObj1 = [eventObj objectForKey:@"from"];
                    
                    _model.HASHTAG_NAME = [coverObj1 objectForKey:@"name"];
                    
                    _model.HASHTAG_DATE = @"";
                    
                    NSString* _str = [eventObj objectForKey:@"created_time"];
                    NSArray* __array = [_str componentsSeparatedByString:@"T"];
                    if ([__array count] > 0) {
                        __array = [[__array objectAtIndex:0] componentsSeparatedByString:@"-"];
                        
                        if ([__array count] > 2) {
                            _model.HASHTAG_DATE = [NSString stringWithFormat:@"%@/%@/%@", [__array objectAtIndex:1], [__array objectAtIndex:2], [__array objectAtIndex:0]];
                        }
                    }
                    // unit test successful:
                    // iCount++;
                    [_array addObject:_model];
                }  // end for
                
                [g_controllerEventDetail getPhotoFeedDtaFromFB:_array];
            }  // end if
         else
         {
             // An error occurred, we need to handle the error
             NSLog(@"error %@", error.description);
         } // end else
     }];
    
    return ;
}

- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent
{
    plaEvent *_parsedEvent;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@", parsedEvent.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"makeRequestForUserEvent - Entity Details:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             //parsedEvent.EV_SNAME = [eventObj objectForKey:@"name"];
             
             parsedEvent.EV_SSTARTDATETIME = [eventObj objectForKey:@"start_time"];
             parsedEvent.EV_SENDDATE = [eventObj objectForKey:@"end_time"];
             parsedEvent.EV_SLOCATION = [eventObj objectForKey:@"location"];
             
             parsedEvent.EV_SDESCRIPTION = [eventObj objectForKey:@"description"];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];//ticket_uri
             
             parsedEvent.EV_SPRIVACY = [eventObj objectForKey:@"privacy"];
             
             NSString* strTemp  = parsedEvent.EV_SPRIVACY;
             
             if (![strTemp isEqualToString:@"OPEN"]) {
                 strTemp = strTemp;
             }
             
             if (parsedEvent.EV_STICKETURL != nil) {
                 //NSString* strTicketURL = @"";
             }
             
             FBGraphObject *coverObj = [eventObj objectForKey:@"venue"];
             if (coverObj != nil) {
                 parsedEvent.EV_SCITY = [coverObj objectForKey:@"city"];
                 parsedEvent.EV_SCOUNTRY = [coverObj objectForKey:@"country"];
                 
                 parsedEvent.EV_SLOCATIONADDRESS = [[CLLocation alloc] initWithLatitude:[[coverObj objectForKey:@"latitude"] doubleValue] longitude:[[coverObj objectForKey:@"longitude"] doubleValue]];
                 
                 plaEventData* originLocationInfo = [plaEventData getInstance];
                 
                 int intdistand = [parsedEvent.EV_SLOCATIONADDRESS distanceFromLocation:originLocationInfo.sglobLocation];
                 
                 parsedEvent.EV_SDISTANCE = ((float)intdistand) / distance_param ;
                 
                 parsedEvent.EV_SSTATE = [coverObj objectForKey:@"state"];
                 parsedEvent.EV_SSTREET = [coverObj objectForKey:@"street"];
                 
                 parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
                 parsedEvent.EV_SENTITYLOCATION.EN_SID = [coverObj objectForKey:@"id"];
                 
                 if ( parsedEvent.EV_SCITY == nil ) {
                     
                     NSString* strID = [coverObj objectForKey:@"id"];
                     //parsedEvent.EV_SLOCATION = strID;
                     
                     [self getEntityInfo:strID];
                }
             }
             
             parsedEvent.EV_SDESCRIPTION = [NSString stringWithFormat:@"%@,%@", parsedEvent.EV_SCITY, parsedEvent.EV_SSTATE];
             
             plaEventData *globEvents = [plaEventData getInstance];
             
             if ([parsedEvent.EV_SPRIVACY isEqualToString:@"OPEN"]) {
                [globEvents.arrayglobFBEvents addObject: parsedEvent];
                 [self makeRequestForEventAttendingUsers:parsedEvent];
             }
             
             NSLog(@"-------------------%ld-----------------------", (unsigned long)[globEvents.arrayglobFBEvents count]);
             
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return _parsedEvent;
}

- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent detailPage:(plaEventDetailViewController*)_controller
{
    
    plaEvent *_parsedEvent;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,cover,name,attending_count,start_time,description,end_time,location,privacy,ticket_uri,venue", parsedEvent.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"makeRequestForUserEvent- Event Details:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             //parsedEvent.EV_SNAME = [eventObj objectForKey:@"name"];
             
             FBGraphObject *coverObj = [eventObj objectForKey:@"cover"];
             if (coverObj != nil) {
                 parsedEvent.EV_SIMAGE = [coverObj objectForKey:@"source"];
             }
             
             parsedEvent.EV_SSTARTDATETIME = [eventObj objectForKey:@"start_time"];
             parsedEvent.EV_SENDDATE = [eventObj objectForKey:@"end_time"];
             parsedEvent.EV_SLOCATION = [eventObj objectForKey:@"location"];
             parsedEvent.EV_STICKETURL =  @"";
             parsedEvent.EV_STICKETURL =  [eventObj objectForKey:@"ticket_uri"];
             
             //https://www.facebook.com/ajax/events/ticket.php?event_id=1579143185675877&source=12&ext=1429847674&hash=ATV0MBo2O8j7_tPE
             
             parsedEvent.EV_SDESCRIPTION = [eventObj objectForKey:@"description"];
             parsedEvent.EV_SUSERSNUMBERONFB = [[eventObj objectForKey:@"attending_count"] integerValue];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];//ticket_uri
             
             parsedEvent.EV_SPRIVACY = [eventObj objectForKey:@"privacy"];
             
             NSString* strTemp  = parsedEvent.EV_SPRIVACY;
             
             if (![strTemp isEqualToString:@"OPEN"]) {
                 strTemp = strTemp;
             }
             
             if (parsedEvent.EV_STICKETURL != nil) {
                 //NSString* strTicketURL = @"";
             }
             
             coverObj = [eventObj objectForKey:@"venue"];
             if (coverObj != nil) {
                 parsedEvent.EV_SCITY = [coverObj objectForKey:@"city"];
                 parsedEvent.EV_SCOUNTRY = [coverObj objectForKey:@"country"];
                 
                 parsedEvent.EV_SLOCATIONADDRESS = [[CLLocation alloc] initWithLatitude:[[coverObj objectForKey:@"latitude"] doubleValue] longitude:[[coverObj objectForKey:@"longitude"] doubleValue]];
                
                 parsedEvent.EV_SSTATE = [coverObj objectForKey:@"state"];
                 parsedEvent.EV_SSTREET = [coverObj objectForKey:@"street"];
                 
                 parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
                 parsedEvent.EV_SENTITYLOCATION.EN_SID = [coverObj objectForKey:@"id"];
                 
                 CLLocation* currentLocation ;
                 CLGeocoder *geocoder = [[CLGeocoder alloc] init];
                 
                 if ([parsedEvent.EV_SCITY isEqualToString:@"(null)"]) {
                     [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
                      {
                          if (!(error))
                          {
                              CLPlacemark *placemark = [placemarks objectAtIndex:0];
                              NSLog(@"\nCurrent Location Detected\n");
                              NSLog(@"placemark %@",placemark);
                              NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
                              //NSString* state = placemark.administrativeArea;
                              NSString *Address = [[NSString alloc]initWithString:locatedAt];
                              NSString *Area = [[NSString alloc]initWithString:placemark.locality];
                              NSString *Country = [[NSString alloc]initWithString:placemark.country];
                              NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
                              
                              NSLog(@"%@",CountryArea);
                              NSLog(@"%@", Address);
                              
                          }
                          else
                          {
                              NSLog(@"Geocode failed with error %@", error);
                              NSLog(@"\nCurrent Location Not Detected\n");
                              //return;
                              //             CountryArea = NULL;
                          }
                          /*---- For more results
                           placemark.region);
                           placemark.country);
                           placemark.locality);
                           placemark.name);
                           placemark.ocean);
                           placemark.postalCode);
                           placemark.subLocality);
                           placemark.location);
                           ------*/
                      }];
                     
                 }
             }
             
//             parsedEvent.EV_SDESCRIPTION = [NSString stringWithFormat:@"%@,%@", parsedEvent.EV_SCITY, parsedEvent.EV_SSTATE];
             
             plaEventData *globEvents = [plaEventData getInstance];
             
             //[_controller loadDataFromFB:parsedEvent];
             [g_controllerViewHome toDetailPage];
             
            NSLog(@"-----*****************----%ld-----****************-----", (unsigned long)[globEvents.arrayglobFBEvents count]);
             
             //                                                 if ([parsedEvent.EV_SSTATE isEqualToString:globEvents.sglobState] && [parsedEvent.EV_SCITY isEqualToString:globEvents.sglobCity]) {
             //                                                     if ([parsedEvent.EV_SSTATE isEqualToString:@"AB"] && [parsedEvent.EV_SCITY isEqualToString:@"Edmonton"]) {
             
             //                                      } else {
             //                                          [_rootCtrl getDBEvents:1];
             //                                      }
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return _parsedEvent;
}

- (void) makeRequestForEventAttendingNum:(plaEvent*)parsedEvent
{
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,ticket_uri,cover,attending_count", parsedEvent.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             //NSLog( @"Facebook events:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             //parsedEvent.EV_SNAME = [eventObj objectForKey:@"name"];
             
             FBGraphObject *coverObj = [eventObj objectForKey:@"cover"];
             if (coverObj != nil) {
                 parsedEvent.EV_SIMAGE = [coverObj objectForKey:@"source"];
             }
             
             parsedEvent.EV_STICKETURL = [self JSONString:[eventObj objectForKey:@"ticket_uri"]];//ticket_uri
             
             parsedEvent.EV_SUSERSNUMBERONFB = [[eventObj objectForKey:@"attending_count"] integerValue];
             //[g_arrayAllEventData addObject:parsedEvent];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];//ticket_uri
             
             [g_controllerViewHome refreshTableView];
             
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return ;
}



- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent sec:(plaHomeViewController*)_rootCtrl
{
    plaEvent *_parsedEvent; //,description
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,attending_count,name,start_time,end_time,location,privacy,ticket_uri,venue", parsedEvent.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"Facebook events:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             //parsedEvent.EV_SNAME = [eventObj objectForKey:@"name"];
             
             parsedEvent.EV_SSTARTDATETIME = [eventObj objectForKey:@"start_time"];
             parsedEvent.EV_SENDDATE = [eventObj objectForKey:@"end_time"];
             parsedEvent.EV_SLOCATION = [eventObj objectForKey:@"location"];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];
             
             parsedEvent.EV_SDESCRIPTION = [eventObj objectForKey:@"description"];
             parsedEvent.EV_SUSERSNUMBERONFB = [[eventObj objectForKey:@"attending_count"] integerValue];
             //parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];//ticket_uri
             
             parsedEvent.EV_SPRIVACY = [eventObj objectForKey:@"privacy"];
             
             NSString* strTemp  = parsedEvent.EV_SPRIVACY;
             
             if (![strTemp isEqualToString:@"OPEN"]) {
                 strTemp = strTemp;
             }
             
             if (parsedEvent.EV_STICKETURL != nil) {
                 //NSString* strTicketURL = @"";
             }
             
             parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
             FBGraphObject *coverObj = [eventObj objectForKey:@"venue"];
             if (coverObj != nil) {
                 parsedEvent.EV_SCITY = [coverObj objectForKey:@"city"];
                 parsedEvent.EV_SCOUNTRY = [coverObj objectForKey:@"country"];
                 
                 parsedEvent.EV_SLOCATIONADDRESS = [[CLLocation alloc] initWithLatitude:[[coverObj objectForKey:@"latitude"] doubleValue] longitude:[[coverObj objectForKey:@"longitude"] doubleValue]];
                 
                 plaEventData* originLocationInfo = [plaEventData getInstance];
                 
                 int intdistand = [parsedEvent.EV_SLOCATIONADDRESS distanceFromLocation:originLocationInfo.sglobLocation];
                 
                 parsedEvent.EV_SDISTANCE = ((float)intdistand) / distance_param ;
                 
                 parsedEvent.EV_SSTATE = [coverObj objectForKey:@"state"];
                 parsedEvent.EV_SSTREET = [coverObj objectForKey:@"street"];
                 
                 parsedEvent.EV_SENTITYLOCATION.EN_SID = [coverObj objectForKey:@"id"];
                 //[self getEntityPageInfo:parsedEvent.EV_SENTITYLOCATION.EN_SID];
             }
             
             [_rootCtrl makeSortingItem:parsedEvent];
             
             plaEventData *globEvents = [plaEventData getInstance];             
             
             if ([parsedEvent.EV_SPRIVACY isEqualToString:@"OPEN"])
                 switch (m_intTableDataType) {
                     case 2:
                         [g_arrayActivityFeedData addObject:parsedEvent];
                         [_rootCtrl refreshTableView];
                         break;
                     case 3:
                         [g_arrayUpcommingEventData addObject:parsedEvent];
                         [_rootCtrl refreshTableView];
                         break;
                         
                     default:
                         if (m_currentCategory > 0) {
                             [g_arraySelectedCategoryEventsData addObject:parsedEvent];
                             [_rootCtrl refreshTableView];
                         } else {
                             if (![self isContainEvent:parsedEvent]) {
                                 
                                 [globEvents.arrayglobDBEvents addObject:parsedEvent];
                                 [_rootCtrl refreshTableView];
                                 
                                 //[_rootCtrl addEventToTableData:parsedEvent];
                                 //[_rootCtrl refreshTableView];
                             }
                         }
                         break;
                 }
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return _parsedEvent;
}

- (void) makeRequestForUserInfo:(NSString*) _userID
{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,name,cover", _userID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
    {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"makeRequestForUserInfo:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             
             plaUser* modelTempUser = [[plaUser alloc] init];
             modelTempUser.USER_ID = [eventObj objectForKey:@"id"];
             modelTempUser.USER_NAME = [eventObj objectForKey:@"name"];
             
             modelTempUser.USER_PROFILEIMAGE = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=true", modelTempUser.USER_ID ];
             
             FBGraphObject *coverObj = [eventObj objectForKey:@"cover"];
             if (coverObj != nil) {
                 modelTempUser.USER_COVERIMAGE = [coverObj objectForKey:@"source"];
             }
             
             [g_arrayUserData addObject:modelTempUser];
//             ------------------------
            
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
}

- (void) makeRequestForUserInfoAdd:(plaUser*) _userModel
{
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,name,cover", _userModel.USER_ID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"makeRequestForUserInfoAdd:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             
             _userModel.USER_ID = [eventObj objectForKey:@"id"];
             _userModel.USER_NAME = [eventObj objectForKey:@"name"];
             
             _userModel.USER_PROFILEIMAGE = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=true", _userModel.USER_ID ];
             
             FBGraphObject *coverObj = [eventObj objectForKey:@"cover"];
             if (coverObj != nil) {
                 _userModel.USER_COVERIMAGE = [coverObj objectForKey:@"source"];
             }
             
             //[g_arrayUserData addObject:modelTempUser];
             [self readTblData];
             //             ------------------------
             
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
}

- (plaEvent*) makeRequestForUserEvent:(plaEvent*)parsedEvent third:(plaEntityPageViewController*)_rootCtrl
{
    plaEvent *_parsedEvent;
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"/%@?fields=id,name,attending_count,start_time,description,end_time,location,privacy,ticket_uri,venue", parsedEvent.EV_SEVENTID]
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(
                                              FBRequestConnection *connection,
                                              id result,
                                              NSError *error
                                              )
     {
         /* handle the result */
         //                              plaEvent *parsedEvent = [[plaEvent alloc] init];
         if ( !error )
         {
             // unit test success:
             // NSLog(@"Facebook events: %@ \n\nand then parsing them: ", result );
             // unit test success:
             NSLog( @"makeRequestForUserEvent:\n"  );
             
             // parse out events and add to our data model. first we walk the JSON:
             NSDictionary *resultDict = (NSDictionary *)result;
             NSArray *eventsArr = [resultDict objectForKey:@"data"];
             
             // unit test:
             NSLog( @"eventsArr is = %@, size = %d", [eventsArr description], (int)eventsArr.count  );
             
             // if we need a count for some maximum:
             // int iCount;
             // iCount = 0;
             NSDictionary *eventObj = resultDict;
             //parsedEvent.EV_SNAME = [eventObj objectForKey:@"name"];
             
             parsedEvent.EV_SSTARTDATETIME = [eventObj objectForKey:@"start_time"];
             parsedEvent.EV_SENDDATE = [eventObj objectForKey:@"end_time"];
             parsedEvent.EV_SLOCATION = [eventObj objectForKey:@"location"];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"tikcet_uri"];
             
             parsedEvent.EV_SDESCRIPTION = [eventObj objectForKey:@"description"];
             parsedEvent.EV_SUSERSNUMBERONFB = [[eventObj objectForKey:@"attending_count"] integerValue];
             parsedEvent.EV_STICKETURL = [eventObj objectForKey:@"ticket_uri"];//ticket_uri
             
             parsedEvent.EV_SPRIVACY = [eventObj objectForKey:@"privacy"];
             
             NSString* strTemp  = parsedEvent.EV_SPRIVACY;
             
             if (![strTemp isEqualToString:@"OPEN"]) {
                 strTemp = strTemp;
             }

             
             if (parsedEvent.EV_STICKETURL != nil) {
                 //NSString* strTicketURL = @"";
             }
             
             parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
             FBGraphObject *coverObj = [eventObj objectForKey:@"venue"];
             if (coverObj != nil) {
                 parsedEvent.EV_SCITY = [coverObj objectForKey:@"city"];
                 parsedEvent.EV_SCOUNTRY = [coverObj objectForKey:@"country"];
                 
                 parsedEvent.EV_SLOCATIONADDRESS = [[CLLocation alloc] initWithLatitude:[[coverObj objectForKey:@"latitude"] doubleValue] longitude:[[coverObj objectForKey:@"longitude"] doubleValue]];
                 
                 plaEventData* originLocationInfo = [plaEventData getInstance];
                 
                 int intdistand = [parsedEvent.EV_SLOCATIONADDRESS distanceFromLocation:originLocationInfo.sglobLocation];
                 
                 parsedEvent.EV_SDISTANCE = ((float)intdistand) / distance_param ;
                 
                 parsedEvent.EV_SSTATE = [coverObj objectForKey:@"state"];
                 parsedEvent.EV_SSTREET = [coverObj objectForKey:@"street"];
                 
                 parsedEvent.EV_SENTITYLOCATION.EN_SID = [coverObj objectForKey:@"id"];
                 //[self getEntityPageInfo:parsedEvent.EV_SENTITYLOCATION.EN_SID];
             }
             
             if ([parsedEvent.EV_SPRIVACY isEqualToString:@"OPEN"])
             {
                 [_rootCtrl makeSortingItem:parsedEvent];
                 
                 [_rootCtrl addEventToTableData:parsedEvent];
                 [_rootCtrl refreshTableView];
                 
             }
         }  // end if
         else
         {
             // An error occurred, we need to handle the error
             // Check out our error handling guide: https://developers.facebook.com/docs/ios/errors/
             NSLog(@"error %@", error.description);
         }  // end else
     }];
    
    return _parsedEvent;
}


- (BOOL)isContainEvent:(plaEvent*)_event
{
    plaEventData *globEvents = [plaEventData getInstance];
    
    for (int i = 0; i < [globEvents.arrayglobDBEvents count]; i ++) {
        plaEvent* event = [globEvents.arrayglobDBEvents objectAtIndex:i];
        if ([_event.EV_SEVENTID isEqualToString:event.EV_SEVENTID]) {
            return true;
        }
    }
    return false;
}

- (BOOL)isContainEntity:(plaEntity*)_entity
{
    plaEventData *globEvents = [plaEventData getInstance];
    
    for (int i = 0; i < [globEvents.arrayglobDBEntities count]; i ++) {
        plaEntity* entity = [globEvents.arrayglobDBEntities objectAtIndex:i];
        if ([_entity.EN_SID isEqualToString:entity.EN_SID]) {
            
            [globEvents.arrayglobDBEntities removeObjectAtIndex:i];
            
            [globEvents.arrayglobDBEntities addObject:_entity];
            return true;
            
        }
    }
    //[globEvents.arrayglobDBEntities addObject:_entity];
    return false;
}

// ---------------- Facebook Delegate functions ----------------------
#pragma mark -- facebook delegate functions
-(void)loginViewShowingLoggedInUser:(FBLoginView *)loginView{
    [self setBackground: NO];
    
    // when this turned into the start button:
    // [self.buttonWelcome setTitle: @"   Start" forState: UIControlStateNormal];
    // but now we have a new Start button at the bottom:
    // self.buttonWelcome.hidden = YES;
    self.lblWelcome.hidden = YES;
    self.lblBackgroundWelcome.hidden = YES;

    [self toggleHiddenState:NO];
    // self.loginButton.hidden = YES;

    // from original code that uses an internal server to do all the data structure merging and db calls, but we don't need to do this anymore:
    // [user registerUser];

	// Get all Events from this person's Facebook account that just logged in
    [self requestEvents: self ];

    // Get all Events from our database
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
    dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        });

    [self getDBEvents];

	// update the internal alpha information now that we know the server build number
    NSString *sOut = [NSString stringWithFormat:@"%@ sbn %d", self.sInternalBuildVersion,  (int)self.iServerBuildNumber ];
    self.lblVersion.text = sOut;
    [self.view setNeedsDisplay];

    dispatch_async(dispatch_get_main_queue(), ^{
            
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        });

    // then show the Start button
    self.bStart = YES;
    self.btnStart.hidden = NO;
    });

}

-(void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)userSignedIn{
    //[self requestPermission];
    
    if (isFristLoad) {
        isFristLoad = false;
        [self requestPermission];
    }
    
    // unit test success: NSLog(@"userSignedIn = %@", userSignedIn );
    self.profilePicture.profileID = userSignedIn.objectID;
    
    // now store the URL to this image into our inmemDB
    
    NSString *sID = self.profilePicture.profileID;
    NSString *imageUrl=[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?redirect=true", sID ];

    self.lblUsername.text = userSignedIn.name;
    //NSString* str = userSignedIn.name;
    self.loginButton.hidden = YES;
    
    plaEventData *globEvents = [plaEventData getInstance];
    globEvents.sglobUserID = sID;
    globEvents.sglobUsername = userSignedIn.name;
    // unit test success: globEvents.sglobEmailAddress = @"emailaddress@domain.com";
        globEvents.sglobEmailAddress = [userSignedIn objectForKey: @"email" ];
    globEvents.sglobFBProfileImageURL = imageUrl;

    // we decided later, that don't want to show the user's FB email on the Start screen
    self.lblEmail.text = @"";
    CLLocation* curentLocatio = [[CLLocation alloc] initWithLatitude:(double)globEvents.fglobLatitude longitude:(double)globEvents.fglobLongitude];
    [self findTheCityandStateorProvince:curentLocatio];
    [self startLocationRequest:nil];
    
    self.imagePin.hidden = NO;
    
    [self insertUser];
}

-(void) insertUser
{
    plaEventData *globData = [plaEventData getInstance];
    
    plaUser* userModel = [[plaUser alloc] init];
    userModel.USER_ID = globData.sglobUserID;
    userModel.USER_NETWORK = [NSString stringWithFormat:@"%@,%@", globData.sglobCity, globData.sglobState];
    userModel.USER_FRIENDS = [[NSMutableArray alloc] init];
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundInsertUser:userModel];
}

-(void) updateUser
{
    plaEventData *globData = [plaEventData getInstance];
    
    plaUser* userModel = [[plaUser alloc] init];
    userModel.USER_ID = globData.sglobUserID;
    NSString* strTemp = [NSString stringWithFormat:@"%@,%@", globData.sglobCity, globData.sglobState];
    
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* user = [g_arrayUserData objectAtIndex:i];
        if ([user.USER_ID isEqualToString:globData.sglobUserID] && (![strTemp isEqualToString:user.USER_NETWORK])) {
            userModel.USER_FRIENDS = user.USER_FRIENDS;
            
            userModel.USER_NETWORK = [NSString stringWithFormat:@"%@,%@", globData.sglobCity, globData.sglobState];
            
            if ([userModel.USER_NETWORK isEqualToString:@"(null),(null)"]) continue;
            
            plaWebServices* webService = [[plaWebServices alloc] init];
            [webService backgroundUpdateUser:userModel action:@"update_network"];
        }
    }
    
    //[g_controllerViewHome changeFriendCountText];
    
    if (![globData isEnableVPNotification]) {
        return;
    }
    
}

-(void) updateVisitPlace
{
    plaEventData* globData = [plaEventData getInstance];
    
    if (![globData isEnableVPNotification]) {
        return;
    }
    
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
        
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        
        if ([entity.EN_SNAME isEqualToString:@"(null)"] || entity.EN_SLOCATION == nil) {
            continue;
        }
        
        int intdistand = [entity.EN_SLOCATION distanceFromLocation:globData.sglobLocation];
        entity.EN_SDISTANCE = [NSString stringWithFormat:@"%.1f", ((float)intdistand) / distance_param];
        
        if ( (intdistand < 11) && (entity.EN_SLOCATION != nil) ) {
            entity.m_intStayTime = entity.m_intStayTime + 1;
            [self isVisited:entity];
        } else {
            entity.m_intStayTime = 0;
        }
    }
}

-(void) isVisited:(plaEntity*)_entity
{
    plaEventData* globData = [plaEventData getInstance];
    
    NSInteger isVisted = false;
    
    for (int i = 0; i < [g_arrayVisitPlaceData count]; i ++) {
        plaVisitPlace* _vplace = [g_arrayVisitPlaceData objectAtIndex:i];
        if ([_vplace.VP_PLACE isEqualToString:_entity.EN_SID] && [_vplace.VP_USER isEqualToString:globData.sglobUserID]) { // visited place
            
            isVisted = true;
            NSInteger intOldVisitDateTime = [_vplace.VP_DATETIME integerValue];
            
            if ( [self getTodayDateTime] - intOldVisitDateTime > 24 * 3600) {
                _vplace.VP_DATETIME = [NSString stringWithFormat:@"%ld", (long)intOldVisitDateTime];
                
                [self visitPlaceNotification:_vplace action:@"update"];
                [self sendNotification:_entity];
                
                if (_entity.m_intStayTime > 250) {
                    
                    _entity.m_intStayTime = 0;
                }
                
                return;
            } else {
                return;
            }
            
        }
    }
    
    if (!isVisted) {
        plaVisitPlace* visitPlace = [[plaVisitPlace alloc] init];
        visitPlace.VP_ID = [NSString stringWithFormat:@"%ld", (long)[self getTodayDateTime]];
        visitPlace.VP_USER = globData.sglobUserID;
        visitPlace.VP_PLACE = _entity.EN_SID;
        visitPlace.VP_DATETIME = visitPlace.VP_ID;
        
        [self visitPlaceNotification:visitPlace action:@"insert"];
        [self sendNotification:_entity];
    }
}

-(void) visitPlaceNotification:(plaVisitPlace*)_visitPlace action:(NSString*)_action
{
    [g_arrayVisitPlaceData addObject:_visitPlace];
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    
    [webService backgroundReadVisitPlaceAll];
    [webService sendVisitPlaceData:_visitPlace action:_action];
}

-(NSInteger)getTodayDateTime
{
    NSTimeInterval milSec = [[NSDate date] timeIntervalSince1970];
    NSInteger intDate = milSec;
    
    return intDate;
}

//-(void)
- (void) sendNotification:(plaEntity*)_entity
{
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate date]; //[self getRemindDate:0];
    
    NSInteger _intCount = [self calculateEventNumber:_entity];
    
    notification.alertBody = [NSString stringWithFormat:@"Welcome to %@! There are %ld upcoming events here!", _entity.EN_SNAME, (long)_intCount ];
    notification.alertAction = @"View";
    notification.soundName = @"2015_best_sound.mp3";
    notification.applicationIconBadgeNumber ++;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (NSDate*)getRemindDate:(NSInteger)_beforeDate
{
    NSTimeInterval milSec = [[NSDate date] timeIntervalSince1970];
    
    if (_currentVisitTime == milSec || _currentVisitTime > milSec) {
        _currentVisitTime = _currentVisitTime + 1;
        milSec = _currentVisitTime;
    } else {
        _currentVisitTime = milSec;
    }
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970: milSec];
    
    return date;
}

-(NSInteger) calculateEventNumber:(plaEntity*)_entity
{
    NSString* strTodayDate = [self getTodayDate];
    // ------- To compose _arrayData from g_arrayAllEventData
    
    NSInteger intCount = 0;
    for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
        plaEvent* _event = [g_arrayAllEventData objectAtIndex:i];
        
        if ([_event.EV_SSTARTDATETIME compare:strTodayDate] != NSOrderedDescending)  continue;
        
        if ([_event.EV_SENTITY.EN_SID isEqualToString:_entity.EN_SID] || [_event.EV_SENTITYLOCATION.EN_SID isEqualToString:_entity.EN_SID]) {
            intCount = intCount + 1;
        }
    }
    return intCount;
}

-(void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView{
    [self setBackground: YES];
    // [self.buttonWelcome setTitle: @"   Welcome to Play" forState: UIControlStateNormal];
    [self toggleHiddenState:YES];
    self.imagePin.hidden = YES;
    self.loginButton.hidden = NO;
    
    self.bStart = NO;
}

-(void)loginView:(FBLoginView *)loginView handleError:(NSError *)error{
    NSLog(@"%@", [error localizedDescription]);
}

// -------------------- Location Services --------------------
#pragma mark --- location services ---------
- (void)startTracking {
    // unit test success: NSLog( @"location services initiated" );
    //start location manager
//    lm = [[CLLocationManager alloc] init];
//    lm.delegate = self;
//    lm.desiredAccuracy = kCLLocationAccuracyKilometer;    // kCLLocationAccuracyBest;
//    lm.distanceFilter = kCLDistanceFilterNone;
//    [lm startUpdatingLocation];
    
    [self startLocationRequest:nil];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {

    //get the latest location
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Notification!" message:@"GeoLocation" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
    CLLocation *currentLocation = [locations lastObject];
    
    //store latest location in stored track array;
    [trackPointArray addObject:currentLocation];
    
    plaEventData *globEvents = [plaEventData getInstance];
    globEvents.fglobLatitude = currentLocation.coordinate.latitude;
    globEvents.fglobLongitude = currentLocation.coordinate.longitude;
    globEvents.sglobLocation = [[CLLocation alloc] initWithLatitude:globEvents.fglobLatitude longitude:globEvents.fglobLongitude];
    
    if (_intLocationUpdateCount == 0 ) {
        
        NSLog(@"---------update location--------");
        
        _intLocationUpdateCount = _intLocationUpdateCount + 1;
        
        [self updateUser];
        
        if (isPossibleVisitPlace) {
            [self updateVisitPlace];
        }
        
        // find the city and state or province
        [self findTheCityandStateorProvince:currentLocation];
        
    } else if (_intLocationUpdateCount > 10) {
        _intLocationUpdateCount = 0;
    } else {
        _intLocationUpdateCount = _intLocationUpdateCount + 1;
    }
}

- (void) findTheCityandStateorProvince:(CLLocation*)currentLocation
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation: currentLocation  completionHandler:^(NSArray *placemarks, NSError *error)
     {
         // unit test success: NSLog( @"didUpdateLocations reverseGeocodeLocation" );
         
         if ( error == nil && [placemarks count] > 0 )
         {
             // unit test success: NSLog( @"didUpdateLocations placemarks=%@, error=%@",  placemarks, error );
             
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             self.lblEmail.text = [NSString stringWithFormat:@"%@, %@",
                                   placemark.locality,
                                   placemark.administrativeArea];
             
             plaEventData *globEvents = [plaEventData getInstance];
             
             //NSString* strTemp = globEvents.sglobCity;
             
             globEvents.sglobCityLocation = self.lblEmail.text;
             globEvents.sglobState = placemark.administrativeArea; // sicago
             globEvents.sglobCity = placemark.locality; // CA
             globEvents.sglobCountry = placemark.country;
             globEvents.sglobLocation = [[CLLocation alloc] initWithLatitude:globEvents.fglobLatitude longitude:globEvents.fglobLongitude];
             
             [self updateUser];
//             if (![strTemp isEqualToString:globEvents.sglobCity]) {
//             }
         }
         else
         {
             NSLog(@"%@", error.debugDescription);
         }
     }];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
//    UIAlertView *errorAlert = [[UIAlertView alloc]
//                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//    [errorAlert show];
}

- (void)stopTracking {
    //lm = [[CLLocationManager alloc] init];
    [lm stopUpdatingLocation];
    lm = nil;
}

- (IBAction)startLocationRequest:(id)sender
{
    INTULocationAccuracy desiredAccuracy = INTULocationAccuracyCity;
    NSTimeInterval timeout = 10.0;
    
    //__weak __typeof(self) weakSelf = self;
    
    INTULocationManager *locMgr = [INTULocationManager sharedInstance];
    [locMgr requestLocationWithDesiredAccuracy:desiredAccuracy
                                       timeout:timeout
                          delayUntilAuthorized:YES
                                         block:^(CLLocation *currentLocation, INTULocationAccuracy achievedAccuracy, INTULocationStatus status) {
                                             //__typeof(weakSelf) strongSelf = weakSelf;
                                             
                                             if (status == INTULocationStatusSuccess) {
                                                 
                                                 // ------- get current location ----------
                                                 plaEventData *globEvents = [plaEventData getInstance];
                                                 globEvents.fglobLatitude = currentLocation.coordinate.latitude;
                                                 globEvents.fglobLongitude = currentLocation.coordinate.longitude;
                                                 
                                                 [self findTheCityandStateorProvince:currentLocation];
                                                                                                  
                                             }
                                             else if (status == INTULocationStatusTimedOut) {
                                                 // You may wish to inspect achievedAccuracy here to see if it is acceptable, if you plan to use currentLocation
                                                 //                                                                          strongSelf.statusLabel.text = [NSString stringWithFormat:@"Location request timed out. Current Location:\n%@", currentLocation];
                                             } else {
                                                 // An error occurred
                                                 if (status == INTULocationStatusServicesNotDetermined) {
                                                     //                                                                              strongSelf.statusLabel.text = @"Error: User has not responded to the permissions alert.";
                                                 } else if (status == INTULocationStatusServicesDenied) {
                                                     //                                                                              strongSelf.statusLabel.text = @"Error: User has denied this app permissions to access device location.";
                                                 } else if (status == INTULocationStatusServicesRestricted) {
                                                     //                                                                              strongSelf.statusLabel.text = @"Error: User is restricted from using location services by a usage policy.";
                                                 } else if (status == INTULocationStatusServicesDisabled) {
                                                     //                                                                              strongSelf.statusLabel.text = @"Error: Location services are turned off for all apps on this device.";
                                                 } else {
                                                     //                                                                              strongSelf.statusLabel.text = @"An unknown error occurred.\n(Are you using iOS Simulator with location set to 'None'?)";
                                                 }
                                             }
                                             
                                             //                                                                      strongSelf.locationRequestID = NSNotFound;
                                         }];
}

// ---------------------------- Database ------------------------------

/**
 * INSERT a row with a unique FaceBook Event ID
 *
 * EV_SEVENTID is the unique Item key
 *
 * EV_SNAME
 * EV_SSTARTDATETIME
 * EV_SLOCATION
 * EV_SIMAGE
*/

-(void)getDBEvents
{
    // unit test successful:
    // NSLog( @"Here at getDBEvents()");
    
    // instantiate the cpws module for calling our own Web Services:
//    plaWebServices *webServ = [[plaWebServices alloc] init];
//
//    // the following call adds DB events right into our in-mem DB
//    NSInteger iResult = webServ.backgroundReadEvents;
//    self.iServerBuildNumber = iResult;
//    return;
}

#pragma mark -------- Tutorial ---------------
-(void)showTutorialScreen
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    NSString* strStatus = [prefs objectForKey:@"tutorial"];
    
    if (strStatus == nil) {
        m_scrollViewTutorial.hidden = false;
    } else {
        m_scrollViewTutorial.hidden = true; //false;//
    }
}

-(void)readAllAppUser
{
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundReadUserAll];
}

-(void)readTblData
{
    [m_arrayTblData removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
    
    // ------- To get Main User Info ----------
    plaUser* m_MainUser;
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            m_MainUser = userModel;
        }
    }
    
    NSMutableArray* _arrayAppFriends = [[NSMutableArray alloc] init];
    // -------- To get Table Data -----------
    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_FRIENDS containsObject:globData.sglobUserID]) {
            if (![m_MainUser.USER_FRIENDS containsObject:userModel.USER_ID]) {
                continue;
            }
            [_arrayAppFriends addObject:userModel]; // Friend list
            
        }
    }
    
    for (int i = 0; i < [g_arrayFBFriendsDta count]; i ++) {
        
        plaUser* _user = [g_arrayFBFriendsDta objectAtIndex:i];
        if ([self isContainsUserInArray:_user _array:_arrayAppFriends]) {
            continue;
        }
        
        [m_arrayTblData addObject:_user];
    }
    
    [m_tableView reloadData];
}

-(BOOL) isContainsUserInArray:(plaUser*)_mainUser _array:(NSMutableArray*)_array
{
    for (int i = 0; i < [_array count]; i ++) {
        plaUser* _user = [_array objectAtIndex:i];
        
        if ([_user.USER_ID isEqualToString:_mainUser.USER_ID]) {
            return true;
        }
    }
    
    return false;
}

-(void)moveScrollView:(NSInteger)_index
{
    if (_index > 3) {
        m_scrollViewTutorial.scrollEnabled = false;
//        m_scrollViewTutorial.center = CGPointMake(m_scrollViewTutorial.center.x - 320, m_scrollViewTutorial.center.y);
        m_viewScrollView5.hidden = false;
    }
    CGRect frame;
    frame.origin.x = m_scrollViewTutorial.frame.size.width * _index;
    frame.origin.y = 0;
    frame.size = m_scrollViewTutorial.frame.size;
    [m_scrollViewTutorial scrollRectToVisible:frame animated:YES];
}

- (IBAction)onBtnTutorial_page1:(id)sender {
    [self moveScrollView:1];
}

- (IBAction)onBtnTutorial_page2:(id)sender {
    [self moveScrollView:2];
}

- (IBAction)onBtnTutorial_page3:(id)sender {
    [self moveScrollView:3];
}

- (IBAction)onBtnTutorial_page4:(id)sender {
    //[self moveScrollView:4];
    m_view4_subView.hidden = false;
}

- (IBAction)onBtnTutorial_page4_subbtn:(id)sender {
    m_view4_subView.hidden = true;
}

- (IBAction)onBtnTutorial_page5:(id)sender {
    [self moveScrollView:5];
    
    [self readTblData];
}

- (IBAction)onBtnTutorial_page6:(id)sender {
}

-(IBAction)onBtnTutorialLater:(id)sender
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    [prefs setObject:@"Start" forKey:@"tutorial"];
    
    m_scrollViewTutorial.hidden = true;
    [self moveScrollView:0];
}

- (IBAction)onBtnFBFriendsInvit:(id)sender {
    [self sendRequest];
}

- (IBAction)onBtnAnotherTime:(id)sender {
    for (int i = 0; i < [m_arrayTblData count]; i ++) {
        plaUser* _user = [m_arrayTblData objectAtIndex:i];
        if (_user._isChecked) {
            [self addFriend:_user];
        }
    }
    
    [self onBtnTutorialLater:nil];
    
    m_scrollViewTutorial.hidden = true;
    [self moveScrollView:0];

}

-(void) addFriend:(plaUser*)_user
{
    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* __user = [g_arrayUserData objectAtIndex:i];
        if ([__user.USER_ID isEqualToString:_user.USER_ID]) {
            _user = __user;
        }
    }
    
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS addObject:globData.sglobUserID];
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    [g_managePush sendNotification:_user.USER_ID message:[NSString stringWithFormat:@"You have recieved a friend request from %@", globData.sglobUsername ]];
}

// ---------------- tableView ----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [m_arrayTblData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* _cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    plaUser* _user = [m_arrayTblData objectAtIndex:indexPath.row];
    if (_user._isChecked) {
        [_cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [_cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    UIImageView* _imageview = (UIImageView*)[_cell viewWithTag:1];
    [_imageview setImageURL:[NSURL URLWithString:_user.USER_PROFILEIMAGE]];
    
    UILabel* _lbl = (UILabel*)[_cell viewWithTag:2];
    _lbl.text = _user.USER_NAME;
    
    return _cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaUser* _user = [m_arrayTblData objectAtIndex:indexPath.row];
    if (_user._isChecked) {
        _user._isChecked = false;
    } else {
        _user._isChecked = true;
    }
    [m_tableView reloadData];
}

//------------- Message Box ------------
-(void)showMessageBox:(NSString*)_message
{
    m_messageBox = [[UIAlertView alloc] initWithTitle:_message message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles: nil];
    [m_messageBox show];
    
    [self performSelector:@selector(hideMessageBox) withObject:nil afterDelay:2.0f];
}

-(void)hideMessageBox
{
   [m_messageBox dismissWithClickedButtonIndex:0 animated:YES];
}

@end
