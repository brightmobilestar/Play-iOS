
//  plaHomeViewController.m
//  Play
//
//  Created by Darcy Allen on 2014-06-20.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaHomeViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "plaAppDelegate.h"
#import "plaEvent.h"
#import "plaEntity.h"
#import "plaUser.h"
#import "plaMail.h"
#import "plaInboxDataModel.h"
#import "plaOmniSearchDataModel.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "plaActivityFeedModel.h"
#import "plaEventData.h"
#import "UIImageView+WebCache.h"
#import "plaDB.h"
#import "plaHomeTableViewCell.h"
#import "plaWebServices.h"
#import "UIImage+animatedGIF.h"
#import <FacebookSDK/FacebookSDK.h>
#import "plaViewController.h"
#import "AsyncImageView.h"
#import "plaMapViewController.h"
#import "plaCreateEventViewController.h"
#import "PushNotificationManagement.h"
#import "plaFeedModel.h"

// for the left menu
@interface plaHomeViewController ()
// for the left menu
// @property (nonatomic, strong) ECSlidingViewController *slidingViewController;
@end

@implementation plaHomeViewController
{
    // an instance variable for holding our table data
    NSMutableArray *eventNames;
    NSMutableArray *eventImages;
    NSMutableArray *eventDates;
    NSMutableArray *eventLocations;
    NSMutableArray* eventAttendAcounts;
}

@synthesize iSizeOfDBArray;
@synthesize m_viewControllerRoot;
@synthesize m_intTemp;
@synthesize mapView, mapViewFullScreen;
@synthesize m_imageViewBackscreen;
@synthesize m_lblInboxCount;

@synthesize m_textFieldWhere;
@synthesize m_createWhereEntity;
@synthesize m_textFieldArtists;
@synthesize m_createArtistEntity;
@synthesize m_intCreateField;
@synthesize m_createHostedByEntity;
@synthesize m_createBtnCheck;

@synthesize m_arrayTableViewArtistData;
@synthesize m_intCurrentSelectedArtist;
@synthesize m_tableViewFull;
@synthesize m_lblBGLocation;
@synthesize m_btnBGLocation;
@synthesize m_lblBGNetwork;
@synthesize m_btnLoadMoreForNetwork;

@synthesize m_arrayMeAttendingEvents;
@synthesize m_arrayMyLikesEntities;
@synthesize m_arrayPopularEvents;
@synthesize m_arraySugestedEvents;
/*
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
 {
 self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
 if (self) {
 // Custom initialization
 }
 return self;
 }
 */

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    fbHandler = [[FBHandler alloc] init];
    
    m_lblScroll1.hidden = YES;
    [m_ScrollViewFBQuestion setContentSize:CGSizeMake(272, 450)];
    
    m_gesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture5 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture6 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture7 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    m_gesture8 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapScrollImages:)];
    
    m_arrayMyLikesEntities = [[NSMutableArray alloc] init];
    m_arraySugestedEvents = [[NSMutableArray alloc] init];
    m_arrayMeAttendingEvents = [[NSMutableArray alloc] init];
    m_arrayPopularEvents = [[NSMutableArray alloc] init];
    m_arrayTemp = [[NSMutableArray alloc] init];
    m_arrayTopEvents = [[NSMutableArray alloc] init];
    m_arrayDataForMap = [[NSMutableArray alloc] init];
    // unit test success: NSLog(@"Home View started");
    
    m_intTableDataType = 1;
    m_intOriginTablePositionY = m_tableViewFull.center.y;
    m_strCurrentCategory = @"";
    _doneLoading = false;
    g_controllerViewHome = self;
    m_viewCreateView.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
    m_viewCreateView.layer.borderWidth = 2.f;
    m_viewSelectCategory.layer.borderColor = (__bridge CGColorRef)([UIColor darkGrayColor]);
    m_viewSelectCategory.layer.borderWidth = 2.f;
    
    m_arrayGlobalTableViewData = [[NSMutableArray alloc] init];
    m_arrayOmniSearchData = [[NSMutableArray alloc] init];
    m_arrayInboxTableData = [[NSMutableArray alloc] init];
    m_arrayFriendUser = [[NSMutableArray alloc] init];
    
    // ---- test gif image -------------
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"dribbble" withExtension:@"gif"];
    m_activityViewLoading.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    
    UIStoryboard* storyBoard = [UIStoryboard storyboardWithName:@"Main_iPhone" bundle:nil];
    mapViewFullScreenCtrl = (plaMapViewController*)[storyBoard instantiateViewControllerWithIdentifier:@"plaMapViewController"];
    [self.view addSubview:mapViewFullScreenCtrl.view];
    mapViewFullScreenCtrl.homeViewController = self;
    mapViewFullScreenCtrl.view.hidden = true;
    // ----- end test -----
    // this is wierd: the following call was trapped and executed BEFORE the Start button was able to do any of the DB and FB merging!!
    m_arrayTableViewArtistData = [[NSMutableArray alloc] init];
    
    UITapGestureRecognizer* gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showHomeScreen)];
    
    [m_imageViewBackscreen addGestureRecognizer:gesture];
    
    m_intLocationState = false;
    
    plaEventData* globData = [plaEventData getInstance];
    
    globData.m_currentController = @"homeViewController";
    //    m_lblBGLocation.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobState];
    //    if ([globData.sglobState isEqualToString:@"(null)"]) {
    //        m_lblBGLocation.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobCity];
    //    }
    
    m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobState];
    
    if ([globData.sglobState isEqualToString:@"(null)"]) {
        m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobCity];
    }
    
    [self initDataForLocationSearchInOmni];
    [self installDeviceonParse];
    
    // -------------- Set Title ----------------
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    
    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
    
    intIsFirstLoading = false;
}

- (void)viewWillAppear:(BOOL)animated
{
    
}

- (void)viewDidAppear:(BOOL)animated
{    
    [self willAppearFunction];
    
    //    [self performSelector:@selector(setPossibleVisitPlace) withObject:nil afterDelay:10.0f];
    
    if (m_intCurrentViewStatus == 3) {
        return;
    }
    
    [self sortoutDBArray];
    [self initBackView];
    
    plaEventData *globEvents = [plaEventData getInstance];
    
    if (!_doneLoading) { // load data from FB
        [self initFrontView];
        [self loadDataFromDB];
    } else {
        //m_arrayGlobalTableViewData = globEvents.arrayglobDBEvents;
        
        //        [m_tableViewFull reloadData];
        if ([globEvents.arrayglobDBEvents count] == 0) {
            [self loadDataFromDB];
        } else {
            
        }
        
        if (m_tableViewOmniSearch.hidden == false) {
            [self refreshTableView];
            [m_tableViewOmniSearch reloadData];
        }
    }
    
    self.iSizeOfDBArray = (NSInteger)0;
    
    if ( m_intTableDataType != 1 && m_intTableDataType != 10 ) { // tableview type are: 'explore', 'my upcomming event', 'activity event' states
        //        [self hideMapView];
        [self performSelector:@selector(hideMapView) withObject:nil afterDelay:0.01f];
    }
    
    m_viewMapView.hidden = false;
    m_searchBar.hidden = false;
    
    
    m_tableViewFull.center = CGPointMake(160, 315);
    
    // ------------------------------- map view --------------
    CLLocationCoordinate2D poiCoodinates;
    poiCoodinates.latitude = globEvents.fglobLatitude;
    poiCoodinates.longitude = globEvents.fglobLongitude;
    
    MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(poiCoodinates, 750, 750);
    
    [self.mapView setRegion:viewRegion animated:YES];
    //[self.mapViewFullScreen setRegion:viewRegion animated:YES];
    
    // ------------------------------- to control headerView: ---- slider functioin -------
    panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [m_viewFloatingSectionTitle addGestureRecognizer:panGesture];
    [m_viewFloatGestreView addGestureRecognizer:panGesture];
    
    UIPanGestureRecognizer* panGesture1 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
    [m_viewFloatGestureHeaderView addGestureRecognizer:panGesture1];
    
    isRemoved = false;
    
    [m_tableViewFull reloadData];
    
    if (m_timer != nil) {
        [m_timer invalidate];
        m_timer = nil;
    }
    
    m_timer = [NSTimer scheduledTimerWithTimeInterval:10.0f target:self selector:@selector(onTimer:) userInfo:nil repeats:true];
    
    [self performSelector:@selector(setPossibleVisitPlace) withObject:nil afterDelay:20.0f];
    
    [self showFeedBackScreen];
    
    //[self performSelector:@selector(readAllEntityFullInfoToFile) withObject:nil afterDelay:1000];
    
    [self performSelector:@selector(readAllEntityFullInfoToFile) withObject:nil afterDelay:70];
}

- (void)readAllEntityFullInfoToFile
{
    plaWebServices* service = [[plaWebServices alloc] init];
    [service readEntityFull];
    
    [[plaEventData getInstance] endDataLoad];
}

#pragma mark --- delegate -- background functions ------
- (void) willAppearFunction
{
    if ( _doneLoading )
        [self changeFriendCountText];
    
    plaEventData* globData = [plaEventData getInstance];
    globData.sglobControllerIndex = 1;
    
    m_imageViewBackscreen.hidden = YES;
    m_viewCreateView.hidden = YES;
    m_createscrollView.contentSize = CGSizeMake(272, 850);
    
    if (m_intCurrentViewStatus == 3) {
        m_tableViewArtists.editing = YES;
        [m_tableViewArtists reloadData];
        [self presentCreateEventView];
    }
    
    if (m_intTableDataType == 6) {
        [self getInboxTableViewData];
    }
    
    //[self changeFriendCountText];
    if ([globData isEnableVPNotification]) {
        m_switchVPNotification.on = true;
    } else {
        m_switchVPNotification.on = false;
    }

}

- (void) setPossibleVisitPlace
{
    g_controllerView.isPossibleVisitPlace = true;
}

- (BOOL) isContainLikedEntity:(plaEvent*)_event
{
    for (int i = 0; i < [m_arrayMyLikesEntities count]; i ++) {
        plaEntity* _entity = [m_arrayMyLikesEntities objectAtIndex:i];
        if ([_event.EV_SENTITY.EN_SID isEqualToString:_entity.EN_SID] || [_event.EV_SENTITYLOCATION.EN_SID isEqualToString:_entity.EN_SID]) {
            return true;
        }
    }
    return false;
}

- (void) getEventsFor3Items
{
    [m_arrayPopularEvents removeAllObjects];
    [m_arraySugestedEvents removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
    NSString* _strCurrentCategory; // Current Category
    if (m_currentCategory == 0) {
        _strCurrentCategory = @"";
    } else if (m_currentCategory > 0) {
        _strCurrentCategory = [globData.arrayglobCategories objectAtIndex:m_currentCategory - 1];
    }
    
    NSArray* _sortedArray;
    NSString* strToday = [self getTodayDate];
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    NSString* location = [NSString stringWithFormat:@"%@,%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    
    // To get Sugested Events
    for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
        plaEvent* _event = [g_arrayAllEventData objectAtIndex:i];
        if ([self isContainLikedEntity:_event]) {
            if ([_event.EV_SLOCATION containsString:@"(null)"] || [_event.EV_SDESCRIPTION1 containsString:@"(null)"]) continue;
            if ([_event.EV_SSTARTDATETIME compare:strToday] == NSOrderedAscending) // Date filter
                continue;
            //if ((![_event.EV_SCATEGORY isEqualToString:_strCurrentCategory]) && (![_strCurrentCategory isEqualToString:@""])) continue;
            
            if ([_event.EV_SDESCRIPTION1 isEqualToString:location] && ([_event.EV_SCATEGORY isEqualToString:m_strCurrentCategory] || [m_strCurrentCategory isEqualToString:@""]))
                [m_arraySugestedEvents addObject:_event];
        }
    }
    [self cleanerTableDataArray:m_arraySugestedEvents];
    
    _sortedArray = [m_arraySugestedEvents sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        NSInteger floatItem1 = p1.EV_SUSERSNUMBERONFB;
        NSInteger floatItem2 = p2.EV_SUSERSNUMBERONFB;
        
        if (floatItem1 > floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 < floatItem2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    m_arraySugestedEvents = [[NSMutableArray alloc] initWithArray:_sortedArray];
    
    //To get You Attending Eevents
    _sortedArray = [globData.arrayglobFBEvents sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        NSInteger floatItem1 = p1.EV_SUSERSNUMBERONFB;
        NSInteger floatItem2 = p2.EV_SUSERSNUMBERONFB;
        
        if (floatItem1 > floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 < floatItem2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    globData.arrayglobFBEvents = [[NSMutableArray alloc] initWithArray:_sortedArray];
    
    for (NSInteger i = [globData.arrayglobFBEvents count] - 1; i > -1 ; i --) {
        plaEvent* _event = [globData.arrayglobFBEvents objectAtIndex:i];
        
        if ([_event.EV_SSTARTDATETIME compare:strToday] == NSOrderedAscending)
            [globData.arrayglobFBEvents removeObject:_event];
    }
    
    //To get Friend attending count
    //    NSMutableArray* _arrayFriendUsers = [globData getFriendList];
    //    for (NSInteger i = 0; i < [g_arrayAllEventData count]; i ++) {
    //        plaEvent* _event = [g_arrayAllEventData objectAtIndex:i];
    //        _event.EV_SFRIENDNUMBERONFB = 0;
    //        for (NSInteger j = 0; j < [_arrayFriendUsers count]; j ++) {
    //            plaUser* _user = [_arrayFriendUsers objectAtIndex:j];
    //            if ([_event.EV_SATTENDINGUSERSARRAY containsObject:_user.USER_ID]) {
    //                _event.EV_SFRIENDNUMBERONFB = _event.EV_SFRIENDNUMBERONFB + 1;
    //            }
    //        }
    //    }
    
    //To get Popular Events
    _sortedArray = [g_arrayAllEventData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        NSInteger floatItem1 = p1.EV_SUSERSNUMBERONFB;
        NSInteger floatItem2 = p2.EV_SUSERSNUMBERONFB;
        
        if (floatItem1 > floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 < floatItem2) {
            return NSOrderedDescending;
        }
        return NSOrderedSame;
    }];
    m_arrayPopularEvents = [[NSMutableArray alloc] initWithArray:_sortedArray];
    
    for (NSInteger i = [m_arrayPopularEvents count] - 1; i > -1 ; i --) {
        plaEvent* _event = [m_arrayPopularEvents objectAtIndex:i];
        
        if ((![_event.EV_SCATEGORY isEqualToString:m_strCurrentCategory]) && (![m_strCurrentCategory isEqualToString:@""])) {
            [m_arrayPopularEvents removeObject:_event];
            continue;
        }
        
        if ([_event.EV_SSTARTDATETIME compare:strToday] == NSOrderedAscending ) // || [_event.EV_SCATEGORY isEqualToString:m_strCurrentCategory]
        {
            [m_arrayPopularEvents removeObject:_event];
            continue;
        }
        
        if (![_event.EV_SDESCRIPTION1 isEqualToString:location]) [m_arrayPopularEvents removeObject:_event];
    }
    
    //if(m_intTableDataType == 1 || m_intTableDataType == 10) {
    [self loadScrollViewTopEvents:[[NSMutableArray alloc] init]];
    //}
    [m_tableViewFull reloadData];
}

-(void)initDataForLocationSearchInOmni
{
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
    searchQuery.radius = 100.0;
    searchQuery.types = 1;
}

-(void)installDeviceonParse
{
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    plaEventData* globData = [plaEventData getInstance];
    if (globData.sglobUserID != nil) {
        currentInstallation[@"user_id"] = globData.sglobUserID;
    }
    currentInstallation.channels = @[@"global"];
    
    [currentInstallation saveInBackground];
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

- (void)sendRequest {
    // Display the requests dialog
    
    //    [FBWebDialogs presentDialogModallyWithSession:nil dialog:@"" parameters:nil handler:^(FBWebDialogResult result, NSURL *resultURL, NSError *error) {
    //        if (error) {
    //            // Error launching the dialog or sending the request.
    //            NSLog(@"Error sending request.");
    //        } else {
    //            if (result == FBWebDialogResultDialogNotCompleted) {
    //                // User clicked the "x" icon
    //                NSLog(@"User canceled request.");
    //            } else {
    //                // Handle the send request callback
    //                NSDictionary *urlParams = [self parseURLParams:[resultURL query]];
    //                if (![urlParams valueForKey:@"request"]) {
    //                    // User clicked the Cancel button
    //                    NSLog(@"User canceled request.");
    //                } else {
    //                    // User clicked the Send button
    //                    NSString *requestID = [urlParams valueForKey:@"request"];
    //                    NSLog(@"Request ID: %@", requestID);
    //                }
    //            }
    //        }
    //    }];
    //
    //    return;
    
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
                 }
             }
         }
     }];
}

-(void)onTimer:(NSTimer*)timer
{
    [self calInboxBadgetNum];
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundReadUserAllChange];
    [webService backgroundReadMailAll];
}

-(void) showHomeScreen
{
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    
    [self dismissCreateEventView];
    
    if (m_intTableDataType == 10) {
        m_intTableDataType = intTemp_m_intTableDataType;
    }
    
    m_imageViewBackscreen.hidden = YES;
    m_viewSelectCategory.hidden = YES;
    
    //    m_intTableDataType = 1;
    
    [UIView commitAnimations];
    
    [m_tableViewFull reloadData];
}

- (void) sortoutDBArray
{
    plaEventData* globData = [plaEventData getInstance];
    for (NSInteger i = [globData.arrayglobDBEvents count]-1; i > -1 ; i --) {
        plaEvent* event = [globData.arrayglobDBEvents objectAtIndex:i];
        if ([event.EV_SEVENTID isEqualToString:@"temp"]) {
            [globData.arrayglobDBEvents removeObjectAtIndex:i];
        }
    }
}

- (void) loadDataFromDB
{
    m_buttonLoadMore.hidden = YES;
    m_buttonLoadMore.userInteractionEnabled = false;
    [m_activityViewLoading setHidden:false];
    
    [self performSelector:@selector(loadData_FromDB) withObject:nil afterDelay:0.1];
}

- (void)getLocationDataFromEntityData:(plaEvent*)parsedEvent
{
    plaEventData* globData = [plaEventData getInstance];
    
    for (NSInteger j = 0; j < [globData.arrayglobDBEntities count]; j ++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:j];
        if ([parsedEvent.EV_SENTITYLOCATION.EN_SID isEqualToString:entity.EN_SID]) {
            parsedEvent.EV_SLOCATION = entity.EN_SNAME;
            parsedEvent.EV_SADDRESS = entity.EN_SLOCATIONSTR;
            
            int intdistand = [entity.EN_SLOCATION distanceFromLocation:globData.sglobLocation];
            
            parsedEvent.EV_SDISTANCE = (float)intdistand / distance_param;
            //[NSString stringWithFormat:@"%.1f", ((float)intdistand) / distance_paramf];
            
            break;
        }
    }
}

- (void)getLocationDataFromEntity:(plaEntity*)entity
{
    plaEventData* globData = [plaEventData getInstance];

            int intdistand = [entity.EN_SLOCATION distanceFromLocation:globData.sglobLocation];
            
            entity.EN_SDISTANCE = [NSString stringWithFormat:@"%.1f", ((float)intdistand) / distance_param];

}


- (void)clearEventArray
{
    for (NSInteger i = [g_arrayAllEventData count] - 1; i > -1; i --) {
        plaEvent* _event = [g_arrayAllEventData objectAtIndex:i];
        if ([self isContainLikedEntity:_event]) {
            if ([_event.EV_SLOCATION containsString:@"(null)"] || [_event.EV_SDESCRIPTION1 containsString:@"(null)"])
            {
                [g_arrayAllEventData removeObject:_event];
            }
            
        }
    }
}

- (void)refreshTableView
{
    [self findNearestPlace];
    
    [self clearEventArray];
    
    if (m_intTableDataType == 6) {
        //[self getInboxTableViewData];
        return;
    }
    
    plaEventData *globEvents = [plaEventData getInstance];
    
    if (m_intTableDataType == 5) {
        m_arrayTableViewData = globEvents.arrayglobMyEntities;
        [m_tableViewFull reloadData];
        return;
    }
    
    if (m_intTableDataType == 10 && [globEvents.arrayglobCategories count] == m_currentCategory) {
        m_arrayTableViewData = globEvents.arrayglobDBEntities;
        [m_tableViewFull reloadData];
        return;
    }
    
    
    
    m_tableViewInbox.hidden = true;
    
    NSArray *sortedArray;
    
    if (m_intTableDataType == 2) {
        [self getFriendCount];
        m_arrayTableViewData = g_arrayActivityFeedData;
        //        sortedArray = [m_arrayTableViewData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        //
        //            return [p1.EV_SSTARTDATETIME compare:p2.EV_SSTARTDATETIME];
        //
        //        }];
        //        m_arrayTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
        [m_tableViewFull reloadData];
        return;
    } else if(m_intTableDataType == 3) {
        m_arrayTableViewData = g_arrayUpcommingEventData;
    } else {
        if (m_currentCategory != 0) {
            [m_arrayGlobalTableViewData removeAllObjects];
//                        NSString* strCategory = [globEvents.arrayglobCategories objectAtIndex:m_currentCategory - 1];
                        for (NSInteger i = 0; i < [g_arrayAllEventData count]; i ++) {
                            plaEvent* event = [g_arrayAllEventData objectAtIndex:i];
                            
                            if ([event.EV_SSTARTDATETIME compare:[self getTodayDate]] == NSOrderedAscending)
                                continue;
                            
                            if ([event.EV_SCATEGORY isEqualToString:m_strCurrentCategory] || [m_strCurrentCategory isEqualToString:@""]) {
                                [m_arrayGlobalTableViewData addObject:event];
                            }
                        }
            //m_arrayGlobalTableViewData = g_arraySelectedCategoryEventsData;
        } else  {
            m_arrayGlobalTableViewData = globEvents.arrayglobDBEvents;
        }
        
        //[self getLocationDataFromEntityData];
        
        // -------  sorting array - m_arrayGlobalTableViewData
        sortedArray = [m_arrayGlobalTableViewData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
            
            return [p1.EV_SSORTINGITEM compare:p2.EV_SSORTINGITEM];
            
        }];
        m_arrayGlobalTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
        m_arrayTableViewData = m_arrayGlobalTableViewData;
    }
    
    for (int i = 0; i < [m_arrayTableViewData count]; i ++) {
        plaEvent* event = [m_arrayTableViewData objectAtIndex:i];
        [self makeSortingItem:event];
    }
    
    // -------  sorting array - m_arrayGlobalTableViewData
    sortedArray = [m_arrayTableViewData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        return [p1.EV_SSORTINGITEM compare:p2.EV_SSORTINGITEM];
        
    }];
    
    //[self loadScrollViewTopEvents:m_arrayTableViewData];
    m_arrayTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    [self cleanerTableDataArray:m_arrayTableViewData];
    
    //    if (m_intTableDataType == 5) {
    //        m_arrayTableViewData = globEvents.arrayglobMyEntities;
    //    }
    if(m_intTableDataType == 1 || m_intTableDataType == 10) {
        [self loadScrollViewTopEvents:m_arrayTableViewData];
    }
    
    //    if (m_intTableDataType == 10 && [globEvents.arrayglobCategories count] == m_currentCategory) {
    //        m_arrayTableViewData = globEvents.arrayglobDBEntities;
    //    }
    
    [m_tableViewFull reloadData];
}

- (void) findNearestPlace
{
    int mindistance = 1000000000;
    
    plaEventData* globData = [plaEventData getInstance];
    
    NSMutableArray * tempArray = [[NSMutableArray alloc] init];
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ( [entity.EN_SCITY isEqualToString:[array objectAtIndex:0]] && [entity.EN_SSTATE isEqualToString:[array objectAtIndex:1]] ) {
            [tempArray addObject:entity];
        }
    }
    
    globData.sglobNearestEntity = nil;
    
    for (int i = 0; i < [tempArray count]; i ++) {
        plaEntity* _entity = [tempArray objectAtIndex:i];
        int intdistand = [_entity.EN_SLOCATION distanceFromLocation:globData.sglobLocation];
        
        if (mindistance > intdistand && _entity.EN_SADDRESSSTR != nil && (![_entity.EN_SADDRESSSTR containsString:@"(null)"])) { // && (_entity.EN_SNETWORK
            globData.sglobNearestEntity = _entity;
            mindistance = intdistand;
        }
    }
}

-(void) onTapScrollImages:(UITapGestureRecognizer*)sender
{
    UIImageView* imageView = (UIImageView*)sender.view;
    plaEventData *globData = [plaEventData getInstance];
    //-----------------------------------------------------------
    
    if (m_currentCategory == 100) { // Top Entities
        globData.iglobEventRow = 0;
        
        plaEntity* entity = [m_arrayTemp objectAtIndex:imageView.tag];
        
        plaEvent* parsedEvent = [[plaEvent alloc] init];
        parsedEvent.EV_SEVENTID = @"temp";
        parsedEvent.EV_SPERSONNAME = entity.EN_SNAME;
        parsedEvent.EV_SENTITYSTATE = 1;
        parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
        parsedEvent.EV_SENTITY.EN_SID = entity.EN_SID;
        
        //            g_arrayTemp = globData.arrayglobMyEntities;
        g_arrayTemp = [[NSMutableArray alloc] init];
        [g_arrayTemp addObject:parsedEvent];
        
        [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
    } else {
        
        globData.iglobEventRow = imageView.tag;
        
        g_arrayTemp = m_arrayTemp; //g_arraySelectedCategoryEventsData;
        
        plaEvent* _event = [m_arrayTemp objectAtIndex:imageView.tag];
        
        [self getDataFromFB:_event];
    }
    
    //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
}

-(void)loadScrollViewTopEvents:(NSMutableArray*)__arrayData
{
    [m_arrayTemp removeAllObjects];
    //[self getEventsFor3Items];
    NSMutableArray* _arrayData = [[NSMutableArray alloc] init];
    
    plaEventData* globData = [plaEventData getInstance];
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    NSString* location = [NSString stringWithFormat:@"%@,%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    
    NSString* strToday = [self getTodayDate];
    if (m_activityViewLoading.hidden) {
        m_viewLoadingText.hidden = YES;
    }
    
    for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
        plaEvent* _event = [g_arrayAllEventData objectAtIndex:i];
        
        if ([_event.EV_SSTARTDATETIME compare:strToday] == NSOrderedAscending)
            continue;
        
        if ([_event.EV_SDESCRIPTION1 isEqualToString:location]) { //m_lblBGNetwork.text
            _event.m_strEventType = [NSString stringWithFormat:@"   Top Events in %@", [array objectAtIndex:0]]; // Top 5 Events
            if ([m_strCurrentCategory isEqualToString:@""]) {
                [_arrayData addObject:_event];
            } else if ([_event.EV_SCATEGORY isEqualToString:m_strCurrentCategory]) {
                [_arrayData addObject:_event];
            }
        }
    }
    
    // -------  sorting array - m_arrayGlobalTableViewData
    NSArray *_sortedArray = [_arrayData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        //        NSString* item1 = [NSString stringWithFormat:@"%ld", (long)p1.EV_SATTENDCOUNT];
        
        NSInteger floatItem1 = p1.EV_SATTENDCOUNT;
        NSInteger floatItem2 = p2.EV_SATTENDCOUNT;
        
        if (floatItem1 > floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 < floatItem2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    m_arrayTopEvents = [[NSMutableArray alloc] initWithArray:_sortedArray];
    
    m_arrayTemp = [[NSMutableArray alloc] initWithArray:_sortedArray]; // So far Top 5 Events
    
    
    // To get Event for Items:(Susgested, Attending, Popular)
    //------- Popular
    if ([m_arrayPopularEvents count] > 0) {
        plaEvent* _event = [m_arrayPopularEvents objectAtIndex:0];
        _event.m_strEventType = @"   Popular Event"; // popular event
        [m_arrayTemp insertObject:_event atIndex:0];
    }
    // ------ You are attending
    if ([globData.arrayglobFBEvents count] > 0) {
        plaEvent* _event = [globData.arrayglobFBEvents objectAtIndex:0];
        _event.m_strEventType = @"   You are Attending";
        [m_arrayTemp insertObject:_event atIndex:0];
    }
    
    //if ([_event.EV_SDESCRIPTION1 isEqualToString:location])
    NSInteger _intCount = 0;
    while ([globData.arrayglobFBEvents count] > _intCount) {
        plaEvent* _event = [globData.arrayglobFBEvents objectAtIndex:_intCount];
        
        _intCount = _intCount + 1;
        
        if ([_event.EV_SDESCRIPTION1 isEqualToString:location]) {
            _event.m_strEventType = @"   You are Attending";
            [m_arrayTemp insertObject:_event atIndex:0];
            break;
        }
    }
    // ------ Sugested For You
    if ([m_arraySugestedEvents count] > 0) {
        plaEvent* _event = [m_arraySugestedEvents objectAtIndex:0];
        _event.m_strEventType = @"   Suggested For You";
        [m_arrayTemp insertObject:_event atIndex:0];
    }
    
    m_imageViewScroll1.hidden = true;
    m_lblScroll1.hidden = true;
    m_lblType1.hidden = true;
    if ([m_arrayTemp count] > 0) {
        plaEvent* event1 = [m_arrayTemp objectAtIndex:0];
        
        if (![event1.EV_SNAME isEqualToString:m_lblScroll1.text]) {
            m_lblType1.text = event1.m_strEventType;
            event1.EV_SIMAGE = [self JSONString:event1.EV_SIMAGE];
            [m_imageViewScroll1 setImageURL:[NSURL URLWithString:event1.EV_SIMAGE]];
            m_imageViewScroll1.tag = 0;//[event1.EV_SEVENTID integerValue];
            
            [m_imageViewScroll1 addGestureRecognizer:m_gesture1];
            m_lblScroll1.text = [NSString stringWithFormat:@"     %@     ", event1.EV_SNAME];
        }
        
        m_imageViewScroll1.hidden = false;
        m_lblScroll1.hidden = false;
        m_lblType1.hidden = false;
        
        if (!intIsFirstLoading) {
            intIsFirstLoading = true;
            //[self onBtnExplore:nil];
            
            [self performSelector:@selector(onBtnExplore:) withObject:nil afterDelay:5.0f];
        }
    }
    
    if ([m_arrayTemp count] > 1) {
        plaEvent* event2 = [m_arrayTemp objectAtIndex:1];
        if (![event2.EV_SNAME isEqualToString:m_lblScroll2.text]) {
            m_lblType2.text = event2.m_strEventType;
            [m_imageViewScroll2 setImageURL:[NSURL URLWithString:event2.EV_SIMAGE]];
            m_imageViewScroll2.tag = 1;//[event2.EV_SEVENTID integerValue];
            
            [m_imageViewScroll2 addGestureRecognizer:m_gesture2];
            m_lblScroll2.text = [NSString stringWithFormat:@"     %@     ", event2.EV_SNAME];
        }
    }
    
    if ([m_arrayTemp count] > 2) {
        plaEvent* event3 = [m_arrayTemp objectAtIndex:2];
        
        if (![event3.EV_SNAME isEqualToString:m_lblScroll3.text]) {
            m_lblType3.text = event3.m_strEventType;
            [m_imageViewScroll3 setImageURL:[NSURL URLWithString:event3.EV_SIMAGE]];
            m_imageViewScroll3.tag = 2;//[event3.EV_SEVENTID integerValue];
            
            [m_imageViewScroll3 addGestureRecognizer:m_gesture3];
            if ([event3.m_strEventType containsString:@"Top events in"] || [event3.m_strEventType containsString:@"Suggested "]) {
                m_lblType3.text = @"   Popular Event";
            } else if ([event3.m_strEventType containsString:@"Top events in"]) {
                m_lblType3.text = @"   Popular Event";
            }
            
            m_lblScroll3.text = [NSString stringWithFormat:@"     %@     ", event3.EV_SNAME];
        }
        
    }
    
    if ([m_arrayTemp count] > 3) {
        plaEvent* event4 = [m_arrayTemp objectAtIndex:3];
        
        if (![event4.EV_SNAME isEqualToString:m_lblScroll4.text]) {
            //m_lblType4.text = event4.m_strEventType;
            [m_imageViewScroll4 setImageURL:[NSURL URLWithString:event4.EV_SIMAGE]];
            m_imageViewScroll4.tag = 3;//[event4.EV_SEVENTID integerValue];
            
            [m_imageViewScroll4 addGestureRecognizer:m_gesture4];
            m_lblScroll4.text = [NSString stringWithFormat:@"     %@     ", event4.EV_SNAME];
            m_lblType4.text = [NSString stringWithFormat:@"     Top Events in %@     ", [array objectAtIndex:0]];
        }
        
    }
    
    if ([m_arrayTemp count] > 4) {
        plaEvent* event5 = [m_arrayTemp objectAtIndex:4];
        
        if (![event5.EV_SNAME isEqualToString:m_lblScroll5.text]) {
            //m_lblType5.text = event5.m_strEventType;
            [m_imageViewScroll5 setImageURL:[NSURL URLWithString:event5.EV_SIMAGE]];
            m_imageViewScroll5.tag = 4;//[event4.EV_SEVENTID integerValue];
            
            [m_imageViewScroll5 addGestureRecognizer:m_gesture5];
            m_lblScroll5.text = [NSString stringWithFormat:@"     %@     ", event5.EV_SNAME];
            m_lblType5.text = [NSString stringWithFormat:@"     Top Events in %@     ", [array objectAtIndex:0]];
        }
        
    }
    
    if ([m_arrayTemp count] > 5) {
        plaEvent* event6 = [m_arrayTemp objectAtIndex:5];
        
        if (![event6.EV_SNAME isEqualToString:m_lblScroll6.text]) {
            //m_lblType6.text = event6.m_strEventType;
            [m_imageViewScroll6 setImageURL:[NSURL URLWithString:event6.EV_SIMAGE]];
            m_imageViewScroll6.tag = 5;//[event4.EV_SEVENTID integerValue];
            
            [m_imageViewScroll6 addGestureRecognizer:m_gesture6];
            m_lblScroll6.text = [NSString stringWithFormat:@"     %@     ", event6.EV_SNAME];
            m_lblType6.text = [NSString stringWithFormat:@"     Top Events in %@     ", [array objectAtIndex:0]];
        }
    }
    
    if ([m_arrayTemp count] > 6) {
        plaEvent* event7 = [m_arrayTemp objectAtIndex:6];
        
        if (![event7.EV_SNAME isEqualToString:m_lblScroll7.text]) {
            //m_lblType7.text = event7.m_strEventType;
            [m_imageViewScroll7 setImageURL:[NSURL URLWithString:event7.EV_SIMAGE]];
            m_imageViewScroll7.tag = 6;//[event4.EV_SEVENTID integerValue];
            
            [m_imageViewScroll7 addGestureRecognizer:m_gesture7];
            m_lblScroll7.text = [NSString stringWithFormat:@"     %@     ", event7.EV_SNAME];
            m_lblType7.text = [NSString stringWithFormat:@"     Top Events in %@     ", [array objectAtIndex:0]];
        }
    }
    
    if ([m_arrayTemp count] > 7) {
        plaEvent* event8 = [m_arrayTemp objectAtIndex:7];
        
        if (![event8.EV_SNAME isEqualToString:m_lblScroll8.text]) {
            //m_lblType8.text = event8.m_strEventType;
            [m_imageViewScroll8 setImageURL:[NSURL URLWithString:event8.EV_SIMAGE]];
            m_imageViewScroll8.tag = 7;//[event4.EV_SEVENTID integerValue];
            
            [m_imageViewScroll8 addGestureRecognizer:m_gesture8];
            m_lblScroll8.text = [NSString stringWithFormat:@"     %@     ", event8.EV_SNAME];
            m_lblType8.text = [NSString stringWithFormat:@"     Top Events in %@     ", [array objectAtIndex:0]];
        }
    }
    
    if ([m_arrayTemp count] > 7) {
        [m_scrollViewTopEvents setContentSize:CGSizeMake(320 * 8, 216)];
    } else {
        [m_scrollViewTopEvents setContentSize:CGSizeMake(320 * [m_arrayTemp count], 216)];
    }
}

-(NSString *)JSONString:(NSString *)aString {
    if (aString == nil) {
        return @"";
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    
    [s replaceOccurrencesOfString:@"*-*-*-*-*" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    
    return [NSString stringWithString:s];
}

-(void)loadScrollViewTopEntities:(NSMutableArray*)_arrayData
{
    //    NSString* location = [NSString stringWithFormat:@"%@,%@", [self replaceWhitesSpace:globData.sglobCity], [self replaceWhitesSpace:globData.sglobState]];
    
    for (NSInteger i = [_arrayData count] - 1; i > -1; i --) {
        plaEntity* _entity = [_arrayData objectAtIndex:i];
        
        if ([_entity.EN_SADDRESSSTR containsString:@"(null)"]) {
            [_arrayData removeObjectAtIndex:i];
        }
    }
    
    NSString* strTodayDate = [self getTodayDate];
    // ------- To compose _arrayData from g_arrayAllEventData
    // m_intTableDataType == 1 || m_intTableDataType == 10
    for (int i = 0; i < [_arrayData count]; i ++) {
        plaEntity* _entity = [_arrayData objectAtIndex:i];
        _entity.m_intEventsCount = 0;
        for (int j = 0; j < [g_arrayAllEventData count]; j ++) {
            plaEvent* _event = [g_arrayAllEventData objectAtIndex:j];
            
            if ([_event.EV_SSTARTDATETIME compare:strTodayDate] != NSOrderedDescending)  continue;
            
            if ([_event.EV_SENTITYPAGEID isEqualToString:_entity.EN_SID] || [_event.EV_SENTITYLOCATION.EN_SID isEqualToString:_entity.EN_SID]) {
                _entity.m_intEventsCount = _entity.m_intEventsCount + 1;
            }
        }
    }
    
    // -------  sorting array - m_arrayGlobalTableViewData
    NSArray *sortedArray = [_arrayData sortedArrayUsingComparator:^NSComparisonResult(plaEntity *p1, plaEntity *p2){
        
        NSInteger floatItem1 = p1.m_intEventsCount;
        NSInteger floatItem2 = p2.m_intEventsCount;
        
        if (floatItem1 > floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 < floatItem2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
        
    }];
    
    m_arrayTemp = [[NSMutableArray alloc] initWithArray:sortedArray];
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    m_lblScroll1.hidden = YES;
    m_lblType1.hidden = true;
    if ([sortedArray count] > 0) {
        plaEntity* event1 = [sortedArray objectAtIndex:0];
        [m_imageViewScroll1 setImageURL:[NSURL URLWithString:event1.EN_SIMAGE]];
        m_imageViewScroll1.tag = 0;//[event1.EV_SEVENTID integerValue];
        m_lblType1.text = [NSString stringWithFormat:@"     Top Places in %@     ", [array objectAtIndex:0]];
        
        //        [m_imageViewScroll1 removeGestureRecognizer:m_gesture];
        [m_imageViewScroll1 addGestureRecognizer:m_gesture1];
        m_lblScroll1.text = event1.EN_SNAME;
        m_lblScroll1.hidden = NO;
        m_lblType1.hidden = false;
    }
    
    if ([sortedArray count] > 1) {
        plaEntity* event2 = [sortedArray objectAtIndex:1];
        [m_imageViewScroll2 setImageURL:[NSURL URLWithString:event2.EN_SIMAGE]];
        m_lblType2.text = [NSString stringWithFormat:@"     Top Places in %@     ", [array objectAtIndex:0]];
        m_imageViewScroll2.tag = 1;//[event2.EV_SEVENTID integerValue];
        
        //        [m_imageViewScroll2 removeGestureRecognizer:m_gesture];
        [m_imageViewScroll2 addGestureRecognizer:m_gesture2];
        m_lblScroll2.text = event2.EN_SNAME;
    }
    
    if ([sortedArray count] > 2) {
        plaEntity* event3 = [sortedArray objectAtIndex:2];
        [m_imageViewScroll3 setImageURL:[NSURL URLWithString:event3.EN_SIMAGE]];
        m_lblType3.text = [NSString stringWithFormat:@"     Top Places in %@     ", [array objectAtIndex:0]];
        m_imageViewScroll3.tag = 2;//[event3.EV_SEVENTID integerValue];
        
        //[m_imageViewScroll3 removeGestureRecognizer:m_gesture];
        [m_imageViewScroll3 addGestureRecognizer:m_gesture3];
        m_lblScroll3.text = event3.EN_SNAME;
    }
    
    if ([sortedArray count] > 3) {
        plaEntity* event4 = [sortedArray objectAtIndex:3];
        [m_imageViewScroll4 setImageURL:[NSURL URLWithString:event4.EN_SIMAGE]];
        m_lblType4.text = [NSString stringWithFormat:@"     Top Places in %@     ", [array objectAtIndex:0]];
        m_imageViewScroll4.tag = 3;//[event4.EV_SEVENTID integerValue];
        
        //[m_imageViewScroll4 removeGestureRecognizer:m_gesture];
        [m_imageViewScroll4 addGestureRecognizer:m_gesture4];
        m_lblScroll4.text = event4.EN_SNAME;
    }
    
    if ([sortedArray count] > 4) {
        plaEntity* event5 = [sortedArray objectAtIndex:4];
        [m_imageViewScroll5 setImageURL:[NSURL URLWithString:event5.EN_SIMAGE]];
        m_lblType5.text = [NSString stringWithFormat:@"     Top Places in %@     ", [array objectAtIndex:0]];
        m_imageViewScroll5.tag = 4;//[event4.EV_SEVENTID integerValue];
        
        //[m_imageViewScroll5 removeGestureRecognizer:m_gesture];
        [m_imageViewScroll5 addGestureRecognizer:m_gesture5];
        m_lblScroll5.text = event5.EN_SNAME;
    }
    
    if ([sortedArray count] > 4) {
        [m_scrollViewTopEvents setContentSize:CGSizeMake(320 * 5, 216)];
    } else {
        [m_scrollViewTopEvents setContentSize:CGSizeMake(320 * [sortedArray count], 216)];
    }
    
    
    //    // -------  sorting array - m_arrayGlobalTableViewData
    //    sortedArray = [_arrayData sortedArrayUsingComparator:^NSComparisonResult(plaEntity *p1, plaEntity *p2){
    //
    //        float floatItem1 = [p1.EN_SDISTANCE floatValue];
    //        float floatItem2 = [p2.EN_SDISTANCE floatValue];
    //
    //        if (floatItem1 < floatItem2) {
    //            return NSOrderedAscending;
    //        } else if (floatItem1 > floatItem2) {
    //            return NSOrderedDescending;
    //        }
    //
    //        return NSOrderedSame;
    //
    //    }];
    //
    //    m_arrayGlobalTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
}

-(void) sortEntityByDistance:(NSMutableArray*)_arrayData
{
    NSArray *sortedArray = [_arrayData sortedArrayUsingComparator:^NSComparisonResult(plaEntity *p1, plaEntity *p2){
        
        float floatItem1 = [p1.EN_SDISTANCE floatValue];
        float floatItem2 = [p2.EN_SDISTANCE floatValue];
        
        if (floatItem1 < floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 > floatItem2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
        
    }];
    
    m_arrayTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
}

-(void)cleanerTableDataArray:(NSMutableArray*)_array
{
    for (NSInteger i = [_array count] - 1; i > -1; i --) {
        plaEvent * entity = [_array objectAtIndex:i];
        
        for (NSInteger j = 0; j < i; j ++) {
            plaEvent* entity1 = [_array objectAtIndex:j];
            if ([[entity.EV_SNAME uppercaseString] isEqualToString:[entity1.EV_SNAME uppercaseString]]) {
                [_array removeObjectAtIndex:i];
                break;
            }
        }
    }
}

-(void)cleanerOmniTableDataArray
{
    for (NSInteger i = [m_arrayOmniSearchData count] - 1; i > -1; i --) {
        plaOmniSearchDataModel * entity = [m_arrayOmniSearchData objectAtIndex:i];
        
        for (NSInteger j = 0; j < i; j ++) {
            plaOmniSearchDataModel* entity1 = [m_arrayOmniSearchData objectAtIndex:j];
            if ([[entity.OMNI_NAME uppercaseString] isEqualToString:[entity1.OMNI_NAME uppercaseString]]) {
                [m_arrayOmniSearchData removeObjectAtIndex:i];
                break;
            }
        }
    }
}

-(void)addEventToTableData:(plaEvent*)_eventData
{
    [m_arrayGlobalTableViewData addObject:_eventData];
    //    if (_eventData.EV_SEVENTSTATE == -1) {
    //        [g_arrayActivityFeedData addObject:_eventData];
    //    } else if (_eventData.EV_SEVENTSTATE == 1) {
    //        [g_arrayUpcommingEventData addObject:_eventData];
    //    }
}

-(void)hideLoadingActivityView
{
    m_buttonLoadMore.hidden = false;
    m_buttonLoadMore.userInteractionEnabled = true;
    [m_activityViewLoading setHidden:true];
}

- (void)calEventAttendFriendCount:(plaEvent*)_eventModel
{
    _eventModel.EV_SATTENDCOUNT = [_eventModel.EV_SUPCOMMINGUSERARRAY count];
    if (_eventModel.EV_SATTENDCOUNT > 0) {
        NSString* strTemp = [_eventModel.EV_SUPCOMMINGUSERARRAY objectAtIndex:0];
        if ([strTemp isEqualToString:@""]) {
            _eventModel.EV_SATTENDCOUNT = _eventModel.EV_SATTENDCOUNT - 1;
        }
    }
    NSInteger intAttendFriendCount = 0;
    for (int i = 0 ; i < [_eventModel.EV_SUPCOMMINGUSERARRAY count]; i ++) {
        NSString* strTemp = [_eventModel.EV_SUPCOMMINGUSERARRAY objectAtIndex:i];
        for (int j = 0; j < [g_arrayUserData count]; j ++) {
            plaUser* userTemp = [g_arrayUserData objectAtIndex:j];
            if ( [strTemp isEqualToString:userTemp.USER_ID] && [self isFriend:userTemp] ) {
                intAttendFriendCount = intAttendFriendCount + 1;
                break;
            }
        }
    }
    _eventModel.EV_SATTENDFRIENDCOUNT = intAttendFriendCount;
}

-(void)changeFriendCountText
{
    plaEventData* globData = [plaEventData getInstance];
    
    NSInteger intNetworkFriendCount = 0, intFriendCount = 0;
    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) continue;
        
        if ([self isFriend:userModel]) {
            
            intFriendCount = intFriendCount + 1;
            
            NSString* strTempLocation =m_lblBGNetwork.text;
            NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
            
            if ([userModel.USER_NETWORK isEqualToString:[NSString stringWithFormat:@"%@,%@",  [array objectAtIndex:0], [array objectAtIndex:1]]])
                //            if ([userModel.USER_NETWORK isEqualToString:[NSString stringWithFormat:@"%@,%@",globData.sglobCity,globData.sglobState]])
            {
                intNetworkFriendCount = intNetworkFriendCount + 1;
            }
        }
    }
    m_btnFriendsCount.titleLabel.text = [NSString stringWithFormat:@"%ld/%ld friends are on this network", (long)intNetworkFriendCount, (long)intFriendCount];
    
    [m_btnFriendsCount setTitle:[NSString stringWithFormat:@"%ld/%ld friends are on this network", (long)intNetworkFriendCount, (long)intFriendCount] forState:UIControlStateNormal];
}

- (NSInteger) calInboxBadgetNum
{
    NSInteger inboxBadgeNum = 0;
    plaUser* _mainUser;
    
    plaEventData* globData = [plaEventData getInstance];
    // ------- To get Main User Info ----------
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            _mainUser = userModel;
        }
    }
    
    // ------ To get From User Friend Data -----------
    for (int i = 0; i < [_mainUser.USER_FRIENDS count]; i ++) {
        NSString* strFriendID = [_mainUser.USER_FRIENDS objectAtIndex:i];
        if ([strFriendID isEqualToString:@""]) {
            continue;
        }
        for (int j = 0; j < [g_arrayUserData count]; j ++) {
            plaUser* userModel = [g_arrayUserData objectAtIndex:j];
            if ([userModel.USER_ID isEqualToString:strFriendID]) {
                if (![userModel.USER_FRIENDS containsObject:_mainUser.USER_ID]) {
                    inboxBadgeNum = inboxBadgeNum + 1;
                }
            }
        }
    }
    
    // ------ To get From User Friend Data -----------
    for (int i = 0; i < [g_arrayMailData count]; i ++) {
        plaMail* mail = [g_arrayMailData objectAtIndex:i];
        if ([mail.MAIL_ACTIVESTATUS isEqualToString:@"false"] && [mail.MAIL_TOUSER isEqualToString:globData.sglobUserID]) {
            inboxBadgeNum = inboxBadgeNum + 1;
        }
    }
    
    //m_lblInboxCount.text = [NSString stringWithFormat:@"%ld", (long)inboxBadgeNum];
    [self setText:[NSString stringWithFormat:@"%ld", (long)inboxBadgeNum] withExistingAttributesInLabel:m_lblInboxCount];
    
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:inboxBadgeNum];
    
    if (inboxBadgeNum == 0) {
        m_lblInboxCount.hidden = true;
    } else {
        m_lblInboxCount.hidden = false;
    }
    
    return inboxBadgeNum;
}

- (void)setText:(NSString *)text withExistingAttributesInLabel:(UILabel *)label {
    
    // Check label has existing text
    if ([label.attributedText length]) {
        
        // Extract attributes
        NSDictionary *attributes = [(NSAttributedString *)label.attributedText attributesAtIndex:0 effectiveRange:NULL];
        
        // Set new text with extracted attributes
        label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
        
    }
}

-(BOOL)isFriend:(plaUser*)_userModel
{
    plaEventData* globData = [plaEventData getInstance];
    // ------- To get Main User Info ----------
    plaUser* _mainUser;
    for (int i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([userModel.USER_ID isEqualToString:globData.sglobUserID]) {
            _mainUser = userModel;
        }
    }
    
    // -------- To get Table Data -----------
    if ([_userModel.USER_FRIENDS containsObject:_mainUser.USER_ID] && [_mainUser.USER_FRIENDS containsObject:_userModel.USER_ID]) {
        return true;
    }
    
    return false;
}

- (void)getInboxTableViewData
{
    [m_arrayInboxTableData removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
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
    
    // ------ To get TableView Data From Mail -----------
    for (int i = 0; i < [g_arrayMailData count]; i ++) {
        plaMail* mailModel = [g_arrayMailData objectAtIndex:i];
        
        if (![mailModel.MAIL_TOUSER isEqualToString:globData.sglobUserID]) {
            continue;
        }
        
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
    
    [g_managePush sendNotification:_user.USER_ID message:[NSString stringWithFormat:@"%@ has confirmed your friend request.", globData.sglobUsername ]];
    
    [self getInboxTableViewData];
    
    m_tempUser = _user;
    [self insertActivityFeed:@"insert"];
}

-(void) removeFriend:(plaUser*)_user
{
    plaEventData* globData = [plaEventData getInstance];
    [_user.USER_FRIENDS removeObject:globData.sglobUserID];
    _user.USER_FRIENDSTATE = 0;
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    [webService backgroundUpdateUser:_user action:@"update_user"];
    
    [g_managePush sendNotification:_user.USER_ID message:[NSString stringWithFormat:@"%@ has declined your friend request.", globData.sglobUsername ]];
    
    [m_MainUser.USER_FRIENDS removeObject:_user.USER_ID];
    
    [webService backgroundUpdateUser:m_MainUser action:@"update_user"];
    
    
    [self getInboxTableViewData];
    
    //[self insertActivityFeed:@"delete"];
}

- (void) insertActivityFeed:(NSString*)_action
{
    plaEventData* globEvents = [plaEventData getInstance];
    plaFeedModel* _feedModel = [[plaFeedModel alloc] init];
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    
    _feedModel.FEED_ID = [NSString stringWithFormat:@"%ld", (long)today];
    _feedModel.FEED_USER = globEvents.sglobUserID;
    _feedModel.FEED_CONTENT = m_tempUser.USER_ID;
    _feedModel.FEED_ACTION = @"Friend";
    
    plaWebServices* webServices = [[plaWebServices alloc] init];
    
    if ([_action isEqualToString:@"insert"]) {
        [webServices backgroundInsertFeed:_feedModel];
    } else {
        [webServices backgroundInsertFeed:_feedModel];
    }
    
    // -----------
    
    _feedModel = [[plaFeedModel alloc] init];
    today = [[NSDate date] timeIntervalSince1970] + 1;
    
    _feedModel.FEED_ID = [NSString stringWithFormat:@"%ld", (long)today];
    _feedModel.FEED_USER = m_tempUser.USER_ID;
    _feedModel.FEED_CONTENT = globEvents.sglobUserID;
    _feedModel.FEED_ACTION = @"Friend";
    
    if ([_action isEqualToString:@"insert"]) {
        [webServices backgroundInsertFeed:_feedModel];
    } else {
        [webServices backgroundInsertFeed:_feedModel];
    }
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

#pragma mark ---- MapView marker -----
-(void)addMarkerToMapView
{
    mapViewFullScreenCtrl.delegate = self;
    //mapViewFullScreenCtrl.homeViewController = self;
    [mapViewFullScreenCtrl.view setFrame:self.view.bounds];
    [mapViewFullScreenCtrl resetAnnitations:m_arrayDataForMap];
}

#pragma mark ---- get DBEvents -------
- (void) loadData_FromDB
{
    [self getDBEvents:10];
    
    [self refreshTableView];
}

-(void)getDBEvents:(NSInteger)_count
{
    // unit test successful:
    // NSLog( @"Here at getDBEvents()");
    
    // instantiate the cpws module for calling our own Web Services:
    plaWebServices *webServ = [[plaWebServices alloc] init];
    
    // the following call adds DB events right into our in-mem DB
    plaEventData *globEvents = [plaEventData getInstance];
    
    intDataCount = [globEvents.arrayglobDBEvents count];
    
    [webServ backgroundReadEvents:intDataCount sec:_count third:self.m_viewControllerRoot fourth:self];
    
    //    [webServ backgroundReadEvents];
    return;
}

#pragma mark --- background View --------

- (void) initBackView
{
    plaEventData *globEvents = [plaEventData getInstance];
    //    globEvents.sglobUsername = userSignedIn.name;
    //    globEvents.sglobEmailAddress = [userSignedIn objectForKey: @"email" ];
    //    globEvents.sglobFBProfileImageURL = imageUrl;
    m_imageviewBGPicture.clipsToBounds = true;
    [m_imageviewBGPicture.layer setCornerRadius:27.0f];
    
    NSData* imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:globEvents.sglobFBProfileImageURL]];
    UIImage* imageTemp = [UIImage imageWithData:imageData];
    
    [m_imageviewBGPicture setImage:imageTemp];
    
    [m_lblBGName setText:globEvents.sglobUsername];
    //[m_lblBGNetwork setText:globEvents.sglobCityLocation];
}

- (IBAction)onBtnNetwork:(id)sender
{
    UIActionSheet* actionsheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Change Networks" otherButtonTitles: nil];
    actionsheet.tag = -1;
    [actionsheet showInView:self.view];
    
    plaEventData* globData = [plaEventData getInstance];
    m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobState];
    if ([globData.sglobState isEqualToString:@"(null)"]) {
        m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobCity];
    }
}

- (IBAction)onBtnFriendsCount:(id)sender
{
    [self performSegueWithIdentifier: @"segueToFriendsList" sender:self];
}

- (IBAction)onBtnExplore:(id)sender
{
    m_tableViewInbox.hidden = true;
    
    m_currentCategory = 0; // To get all events
    
    m_intTableDataType = 1;
    intTemp_m_intTableDataType = m_intTableDataType;
    
    m_btnCategory.hidden = false;
    m_btnCategoryBG.hidden = false;
    
    m_viewMapView.hidden = false;
    m_searchBar.center = CGPointMake(160, 22);
    
    m_btnLocateMe.hidden = false;
    m_btnLocateMeBack.hidden = false;
    m_searchBar.hidden = false;
    mapView.hidden = false;
    
    [m_tableViewFull setFrame:CGRectMake(0, 64, 320, 504) ];
    //m_tableViewFull.center = CGPointMake(160, 315);  // 315 - tableview original position_y
    
    //[self refreshTableView];
    m_currentCategory = 0;
    [self dismissViewSelectCategory];
    
    [self frontCoverFromBack];
    
    m_activityViewLoading.hidden = true;
    m_buttonLoadMore.hidden = NO;
    if (m_activityViewLoading.hidden) {
        m_viewLoadingText.hidden = YES;
    }
    
    [self findNearestPlace];
}

- (IBAction)onBtnActivityFeed:(id)sender
{
    m_tableViewInbox.hidden = true;
    
    [self hideMapView];
    [self setSectionTitleForActivityFeed];
    
    m_currentCategory = 0;
    m_intTableDataType = 2;
    
    plaWebServices* webServices = [[plaWebServices alloc] init];
    [webServices backgroundReadFeedAll];
    
    [self performSelector:@selector(tableViewReload) withObject:nil afterDelay:0.01f];
    [self frontCoverFromBack];
    
    m_btnCategory.hidden = YES;
    m_btnCategoryBG.hidden = true;
    
    //[self performSelector:@selector(resetTableDatatype) withObject:nil afterDelay:30.f];
}

- (void) resetTableDatatype
{
    m_intTableDataType = 12;
}

- (IBAction)onBtnUpcommingEvent:(id)sender
{
    m_tableViewInbox.hidden = true;
    
    [self hideMapView];
    [self setSectionTitleForMyUpcomingEvents];
    
    m_currentCategory = 0;
    m_intTableDataType = 3;
    [self getArrayUpcommingData];
    
    //[self refreshTableView];
    [self performSelector:@selector(tableViewReload) withObject:nil afterDelay:0.01f];
    [self frontCoverFromBack];
    
    m_btnCategory.hidden = YES;
    m_btnCategoryBG.hidden = true;
    
    [m_tableViewFull reloadData];
}

- (IBAction)onBtnSetting:(id)sender {
    
    m_intTableDataType = 7;
    
    [self setSectionTitleForSetting];
    
    [self frontCoverFromBack];
    m_viewSettingPage.hidden = false;
    
    m_btnCategory.hidden = YES;
    m_btnCategoryBG.hidden = true;
}


- (IBAction)onBtnTapHereToViewPlaces:(id)sender {
    if ([m_lblSelectCategoryEvents.text isEqualToString:@"Events"]) {  // Places -- Venues and Places
        m_currentCategory = 100; //
        [self dismissViewSelectCategory];
        //        [m_tableViewSelectCategory reloadData];
        
        m_btnSelectCategoryTapHereToView.titleLabel.text = @"TAP HERE TO VIEW EVENTS";
        m_lblSelectCategoryEvents.text = @"Places";
    } else { // Events
        
        m_currentCategory = 99;
        //        [self getAllCategoryDataForPlaces];
        //        [m_tableViewSelectCategory reloadData];
        
        m_imageViewBackscreen.hidden = YES;
        m_viewSelectCategory.hidden = YES;
        [self onBtnExplore:nil];
        
        m_btnSelectCategoryTapHereToView.titleLabel.text = @"TAP HERE TO VIEW PLACES";
        m_lblSelectCategoryEvents.text = @"Events";
    }
}

-(void)dismissViewSelectCategory
{
    m_intTableDataType = intTemp_m_intTableDataType;
    
    m_imageViewBackscreen.hidden = true;
    m_viewSelectCategory.hidden = true;
    //m_activityViewLoading.hidden = false;
    //m_buttonLoadMore.hidden = true;
    
    //[self hideMapView];
    m_btnCategory.hidden = false;
    m_btnCategoryBG.hidden = false;
    
    plaEventData* globData = [plaEventData getInstance];
    if (m_currentCategory == 100) {  /// Venues & Location
        
        /////////////////////////////////////////////////////////////////==============================================////////////////////////////////////
        
        m_arrayTableViewData = [[NSMutableArray alloc] init];
        NSString* strTempLocation =m_lblBGNetwork.text;
        NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
        for (int i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
            plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
            if ( [entity.EN_SCITY isEqualToString:[array objectAtIndex:0]] && [entity.EN_SSTATE isEqualToString:[array objectAtIndex:1]] ) {
                [m_arrayTableViewData addObject:entity];
            }
        }
        [self loadScrollViewTopEntities:m_arrayTableViewData];
        [self sortEntityByDistance:m_arrayTableViewData];
        m_activityViewLoading.hidden = true;
        m_buttonLoadMore.hidden = false;
        [m_tableViewFull reloadData];
    } else {
        [self getArraySelectedCategoryEventsData];
        //[self performSelector:@selector(getArraySelectedCategoryEventsData) withObject:nil afterDelay:0.5f];
    }
}

- (IBAction)onBtnCreateEvent:(id)sender
{
    //    eventpic.jpg
    m_imageCreateEventPhoto = [UIImage imageNamed:@"eventpic.jpg"];
    m_strCreateEventPhoto = @"eventpic.jpg";
    //m_intTableDataType = 4;
    [m_pickerAdmins reloadAllComponents];
    [self presentCreateEventView];
    
    [self frontCoverFromBack];
}

- (IBAction)onBtnMyEntities:(id)sender
{
    m_tableViewInbox.hidden = true;
    
    m_currentCategory = 0;
    m_intTableDataType = 5;
    
    [self getArrayMyEntitiesData];
    
    [self refreshTableView];
    [self performSelector:@selector(tableViewReload) withObject:nil afterDelay:0.301f];
    
    [self frontCoverFromBack];
    
    m_btnCategory.hidden = YES;
    m_btnCategoryBG.hidden = true;
}

- (IBAction)onBtnInbox:(id)sender
{
    m_tableViewInbox.hidden = false;
    
    m_currentCategory = 0;
    m_intTableDataType = 6;
    
    //[self getInboxTableViewData];
    
    //[self refreshTableView];
    [self performSelector:@selector(getInboxTableViewData) withObject:nil afterDelay:0.301f];
    
    [self frontCoverFromBack];
    
    m_btnCategory.hidden = YES;
    m_btnCategoryBG.hidden = true;
}

- (void)getArrayMyEntitiesData
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobMyEntities count]; i ++) {
        plaEntity* entityTemp1 = [globData.arrayglobMyEntities objectAtIndex:i];
        for (int j = 0; j < [globData.arrayglobDBEntities count]; j ++) {
            plaEntity* entityTemp2 = [globData.arrayglobDBEntities objectAtIndex:j];
            if ([entityTemp1.EN_SID isEqualToString:entityTemp2.EN_SID]) {
                //                entityTemp1 = entityTemp2;
                [array addObject:entityTemp2];
                break;
            }
        }
    }
    globData.arrayglobMyEntities = array;
}

- (void)getArrayActivityFeedData
{
    //    plaEventData* globData = [plaEventData getInstance];
    //
    //    g_arrayActivityFeedData = [[NSMutableArray alloc] init];
    //    for (int i = 0; i < [globData.arrayglobDBEvents count]; i ++) {
    //        plaEvent* event = [globData.arrayglobDBEvents objectAtIndex:i];
    //        if (event.EV_SEVENTSTATE != 0) { //== -1
    //            [g_arrayActivityFeedData addObject:event];
    //        }
    //    }
    
    
    // To get g_arrayActivityFeedData
    [g_arrayActivityFeedData removeAllObjects];
    plaWebServices* webServ = [[plaWebServices alloc] init];
    
    [webServ backgroundReadEvents:0 sec:100000 third:self.m_viewControllerRoot fourth:self];
}

- (void)getArrayUpcommingData
{
    // To get g_arrayUpcommingEventData
    [g_arrayUpcommingEventData removeAllObjects];
    plaWebServices* webServ = [[plaWebServices alloc] init];
    
    [webServ backgroundReadEvents:0 sec:100000 third:self.m_viewControllerRoot fourth:self];
    
}

- (void)getArraySelectedCategoryEventsData
{
    plaEventData* globData = [plaEventData getInstance];
    
    if (m_currentCategory == 0) {
        m_strCurrentCategory = @"";
    } else if (m_currentCategory > 0) {
        m_strCurrentCategory = [globData.arrayglobCategories objectAtIndex:m_currentCategory - 1];
    }
    
    [self getEventsFor3Items];
    [self loadScrollViewTopEvents:nil];
    
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    NSString* location = [NSString stringWithFormat:@"%@,%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    
    // To get Events list with Current category
    [m_arrayGlobalTableViewData removeAllObjects];
    
    for (NSInteger i = 0; i < [g_arrayAllEventData count]; i ++) {
        plaEvent* event = [g_arrayAllEventData objectAtIndex:i];
        
        if ([event.EV_SSTARTDATETIME compare:[self getTodayDate]] == NSOrderedAscending)
            continue;
        
        if (([event.EV_SDESCRIPTION1 isEqualToString:location]) && ([event.EV_SCATEGORY isEqualToString:m_strCurrentCategory] || [m_strCurrentCategory isEqualToString:@""])) {
            [m_arrayGlobalTableViewData addObject:event];
        }
    }
    
    m_arrayTableViewData = m_arrayGlobalTableViewData;
    //[self refreshTableView];
    
    [m_tableViewFull reloadData];
}

- (void) tableViewReload
{
    [self hideMapView];
}

- (void) hideMapView
{
    //return;
    
    [m_tableViewFull setFrame:CGRectMake(0, 64, 320, 504 + 260) ];
    
    if (m_intTableDataType == 2 || m_intTableDataType == 3 || m_intTableDataType == 5) {
        m_btnCategory.hidden = YES;
        m_btnCategoryBG.hidden = true;
    }else {
        
    }
    //m_viewMapView.hidden = true;
    m_searchBar.center = CGPointMake(160, 217);
    m_btnLocateMeBack.hidden = YES;
    m_btnLocateMe.hidden = YES;
    mapView.hidden = YES;

    m_tableViewFull.center = CGPointMake(160, m_intOriginTablePositionY - 130);
    
    m_activityViewLoading.hidden = true;
    m_buttonLoadMore.hidden = YES;
    if (m_activityViewLoading.hidden) {
        m_viewLoadingText.hidden = YES;
    }
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark ---  front View ----------
- (IBAction)onBtnLocateMe:(id)sender
{
    plaEventData* globData = [plaEventData getInstance];
    CLLocationCoordinate2D coornitation = globData.sglobLocation.coordinate;
    [self.mapView setCenterCoordinate:coornitation animated:YES];
}

- (IBAction)onBtnLoadMore:(id)sender
{
    [self loadDataFromDB];
}

- (void) initFrontView
{
    _doneLoading = YES;
    
    NSInteger iCompared;
    NSInteger iSame;
    NSString *sTempImage = EVENT_IMAGE_NONE;
    
    // ------------------------------------------ top of code move --------------------------------------------
    // as of October 19 code merging, we realized that we had to move the process execution of FB and DB merging to HERE, from the plaViewController showMessage() function:
    
    plaEventData *globEvents = [plaEventData getInstance];
    NSInteger iFBSize = [globEvents.arrayglobFBEvents count];
    
    // unit test successful:
    NSLog( @"before Merge, the Size of FB Events array = %d", (int)iFBSize );
    
    //    if ( (int)iFBSize > (int)0 )
    //        {
    // only if there are FB Events for this user, we need to potentially add them to our database
    [self MergeFBandDB];
    //        }
    // ------------------------------------------ bottom of code move --------------------------------------------
    
    iSame = 0;   // for checking string comparisons
    
    NSInteger iSize = [globEvents.arrayglobDBEvents count];
    // unit test success:
    
    if ( iSize < 1 )
    {
        eventNames = [NSMutableArray arrayWithObjects: @"no events", nil ];
        eventImages = [NSMutableArray arrayWithObjects: @"eventpic.jpg", nil ];
        eventDates = [NSMutableArray arrayWithObjects: @" ", nil ];
        eventLocations = [NSMutableArray arrayWithObjects: @" ", nil ];
        eventAttendAcounts = [NSMutableArray arrayWithObjects:@" ", nil];
    }
    else
    {
        int iObj;
        plaEvent *parsedEvent = [[plaEvent alloc] init];
        eventNames = [[NSMutableArray alloc] init];
        eventImages = [[NSMutableArray alloc] init];
        eventDates = [[NSMutableArray alloc] init];
        eventLocations = [[NSMutableArray alloc] init];
        eventAttendAcounts = [[NSMutableArray alloc] init];
        for ( iObj = 0; iObj < iSize; iObj++ )
        {
            // pump the FB events into the screen events
            parsedEvent = [globEvents.arrayglobDBEvents objectAtIndex: iObj];
            // unit test success: NSLog( @"parsedEvent = %@ \n", parsedEvent );
            
            // unit test success: NSLog( @"event to screen = %@ \n", parsedEvent.EV_SNAME );
            if ( parsedEvent.EV_SNAME == nil )
            {
                [ eventNames addObject: @"event" ];
            }
            else
            {
                [ eventNames addObject:parsedEvent.EV_SNAME ];
            }
            
            // unit test success: NSLog( @"image to screen = %@ \n", parsedEvent.EV_SIMAGE );
            if ( parsedEvent.EV_SIMAGE == nil )
            {
                [ eventImages addObject: EVENT_IMAGE_PLACEHOLDER ];
            }
            else
            {
                iCompared = [ parsedEvent.EV_SIMAGE localizedCompare:sTempImage ];
                if ( iCompared != iSame )
                {
                    [ eventImages addObject:parsedEvent.EV_SIMAGE ];
                }
                else
                {
                    [ eventImages addObject: EVENT_IMAGE_PLACEHOLDER ];
                }
            }
            
            if ( parsedEvent.EV_SSTARTDATETIME == nil )
            {
                [ eventDates addObject: @" " ];
            }
            else
            {
                [ eventDates addObject:parsedEvent.EV_SSTARTDATETIME ];
            }
            
            if ( parsedEvent.EV_SLOCATION == nil )
            {
                [ eventLocations addObject: @" " ];
            }
            else
            {
                [ eventLocations addObject:parsedEvent.EV_SLOCATION ];
            }
            
            [ eventAttendAcounts addObject:[NSString stringWithFormat:@"%ld", (long)parsedEvent.EV_SATTENDCOUNT]];
            
        }  // end for
    }  // end else there is 1 or more events to show
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

- (NSString*)getTodayDate
{
    NSDate *today = [NSDate date];
    NSArray* array = [[today description] componentsSeparatedByString:@" "];
    
    NSString* strToday = [NSString stringWithFormat:@"%@T00:00:00", [array objectAtIndex:0]];
    
    //    return @"2014-11-09T00:00:00";
    //    return @"2014-12-12T00:00:00";
    return strToday;
}

#pragma mark ------ deleagate ---------- search bar -------------
//- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar                      // return NO to not become first responder
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar                     // called when text starts editing
{
    m_tableViewOmniSearch.hidden = false;
    [self frontCoverFromBack];
}

//- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar;                        // return NO to not resign first responder
//- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar;                       // called when text ends editing

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSInteger)indexRow{
    return [searchResultPlaces objectAtIndex:indexRow];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    NSString* strTodayDate = [self getTodayDate];
    
    [m_arrayOmniSearchData removeAllObjects];
    intTemp_m_btnLoadMoreForNetworkTag = 1;
    
    searchQuery.input = searchBar.text;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            searchResultPlaces = places;
            for (int i = 0; i < [searchResultPlaces count]; i ++) {
                plaOmniSearchDataModel* omniModel = [[plaOmniSearchDataModel alloc] init];
                omniModel.OMNI_ID = [self placeAtIndexPath:i].identifier;
                omniModel.OMNI_NAME = [self placeAtIndexPath:i].name;
                omniModel.OMNI_IMAGE = @"";
                omniModel.OMNI_TYPE = @"network";
                
                [m_arrayOmniSearchData insertObject:omniModel atIndex:i];
            }
            
            [m_tableViewOmniSearch reloadData];
        }
    }];
    // To get Users
    for (NSInteger i = 0; i < [g_arrayUserData count]; i ++) {
        plaUser* userModel = [g_arrayUserData objectAtIndex:i];
        if ([[userModel.USER_NAME uppercaseString] containsString:[searchBar.text uppercaseString]]) {
            plaOmniSearchDataModel* omniModel = [[plaOmniSearchDataModel alloc] init];
            omniModel.OMNI_ID = userModel.USER_ID;
            omniModel.OMNI_NAME = userModel.USER_NAME;
            omniModel.OMNI_IMAGE = userModel.USER_PROFILEIMAGE;
            omniModel.OMNI_TYPE = @"user";
            
            [m_arrayOmniSearchData addObject:omniModel];
        }
    }
    // To get Entity
    plaEventData* globData = [plaEventData getInstance];
    for (NSInteger i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
        plaEntity* userModel = [globData.arrayglobDBEntities objectAtIndex:i];
        
        NSString* _strSearchData = searchBar.text;
        if ([[userModel.EN_SNAME uppercaseString] containsString:[_strSearchData uppercaseString]]) {
            plaOmniSearchDataModel* omniModel = [[plaOmniSearchDataModel alloc] init];
            omniModel.OMNI_ID = userModel.EN_SID;
            omniModel.OMNI_NAME = userModel.EN_SNAME;
            omniModel.OMNI_IMAGE = userModel.EN_SIMAGEPROFILE;
            omniModel.OMNI_CATEGORY = userModel.EN_SCATEGORY;
            omniModel.OMNI_TYPE = @"entity";
            
            if ([userModel.EN_SADDRESSSTR containsString:@"(null),(null)"] || [userModel.EN_SLOCATIONSTR isEqualToString:@"(null)"]) continue;
            
            [m_arrayOmniSearchData addObject:omniModel];
        }
    }
    // To get events
    [m_arrayGlobalTableViewData removeAllObjects];
    for (NSInteger i = 0; i < [g_arrayAllEventData count]; i ++) { //
        plaEvent* userModel = [g_arrayAllEventData objectAtIndex:i];
        if ([[userModel.EV_SNAME uppercaseString] containsString:[searchBar.text uppercaseString]]) {
            plaOmniSearchDataModel* omniModel = [[plaOmniSearchDataModel alloc] init];
            omniModel.OMNI_ID = userModel.EV_SEVENTID;
            omniModel.OMNI_NAME = userModel.EV_SNAME;
            omniModel.OMNI_IMAGE = userModel.EV_SIMAGE;
            omniModel.OMNI_TYPE = @"event";
            
            omniModel.OMNI_LOCATION = userModel.EV_SLOCATION;
            omniModel.OMNI_CITY = userModel.EV_SDESCRIPTION1;//[NSString stringWithFormat:@"%@, %@", userModel.EV_SCITY, userModel.EV_SSTATE];
            
            if ([userModel.EV_SSTARTDATETIME compare:strTodayDate] == NSOrderedAscending)  continue;
            
            if ([userModel.EV_SLOCATION containsString:@"(null)"] || [userModel.EV_SDESCRIPTION1 containsString:@"(null)"]) {
                
            } else {
                [m_arrayOmniSearchData addObject:omniModel];
            }
            
            //[m_arrayGlobalTableViewData addObject:userModel];
        }
    }
    
    [self cleanerOmniTableDataArray];
    
    //    [m_tableViewOmniSearch reloadData];
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
    m_tableViewOmniSearch.hidden = true;
    [m_arrayOmniSearchData removeAllObjects];
    [m_tableViewOmniSearch reloadData];
}

-(void) getFriendCount
{
    [m_arrayFriendUser removeAllObjects];
    plaEventData* globData = [plaEventData getInstance];
    
    // ------- To get Main User Info ----------
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
            [m_arrayFriendUser addObject:userModel];
        }
    }
}

-(void)toDetailPage
{
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
}

-(void)getDataFromFB:(plaEvent*)_event
{
    if ([_event.EV_SEVENTID containsString:@"db"]) {
        [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
    } else {
//        [self toDetailPage];
        [g_controllerView makeRequestForUserEvent:_event detailPage:g_controllerEventDetail];
        
    }
}

-(void)sendToDetailPage:(plaEvent*)_model
{
    plaEventData *globData = [plaEventData getInstance];
    
    if (m_intTableDataType != 1) {
        
        NSUInteger intTemp = [globData.arrayglobDBEvents indexOfObject:_model];
        
        globData.iglobEventRow = intTemp;
    } else {
        
        NSUInteger intTemp = [globData.arrayglobDBEvents indexOfObject:_model];
        
        globData.iglobEventRow = intTemp;
    }
    
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
}

// each row of the table launches its detail screen of its Event

-(NSIndexPath*) getTopCellNum {
    NSIndexPath* _topCell;
    NSArray *indexes = [m_tableViewFull indexPathsForVisibleRows];
    
    indexes = [indexes sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *p1, NSIndexPath *p2){
        
        NSInteger floatItem1 = p1.row;
        NSInteger floatItem2 = p2.row;
        
        if (floatItem1 < floatItem2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    _topCell = [indexes objectAtIndex:0];
    
    return _topCell;
}

-(NSIndexPath*) getBottomCellNum {
    NSIndexPath* _topCell;
    NSArray *indexes = [m_tableViewFull indexPathsForVisibleRows];
    
    indexes = [indexes sortedArrayUsingComparator:^NSComparisonResult(NSIndexPath *p1, NSIndexPath *p2){
        
        NSInteger floatItem1 = p1.row;
        NSInteger floatItem2 = p2.row;
        
        if (floatItem1 < floatItem2) {
            return NSOrderedAscending;
        }
        return NSOrderedSame;
    }];
    _topCell = [indexes objectAtIndex:[indexes count] - 1];
    
    return _topCell;
}

#pragma mark ------- delegate ----- tableview scrolling event -----------------
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    
    
    [self hideAllFBQuestionTextFlds];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSInteger index = 0;
    
    CGFloat cellHeight = 250;
    
    index = floor((m_tableViewFull.contentOffset.y - 260) / cellHeight ) + 1;
    
    NSInteger __intTbleViewContentSize = m_tableViewFull.contentSize.height;
    __intTbleViewContentSize = __intTbleViewContentSize ;
    
    
    //NSLog(@"table cell position --- %ld", (long)m_tableViewFull.contentOffset.y);
    
    NSIndexPath* _topIndex = [self getTopCellNum];
    NSIndexPath* _bottomIndex = [self getBottomCellNum];
    intTemp_bottomIndex = _bottomIndex.row;
    
    //NSLog(@"---------------========%ld======", (long)__intTbleViewContentSize);

    if (m_intTableDataType != 1) {
        return;
    }
    if ( m_currentCategory == 100 && m_currentCategory > 0 ) {
        m_viewLoadMore.hidden = true;
        return;
        
    } else {
        
    }
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    if (m_tableViewFull.contentOffset.y < 10) {
        
        m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
        return;
    }
    
    if (m_intTableDataType == 1 || m_intTableDataType == 10) {
        switch (_topIndex.section) {
            case 0:
                m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
                break;
                
            case 1:
                m_lblFloatingSectionTitle.text = @"Suggested For You";
                break;
                
            case 2:
                m_lblFloatingSectionTitle.text = @"Popular Events on Facebook";
                break;
                
            case 3:
                m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"Top Events in %@ %@", [array objectAtIndex:0], m_strCurrentCategory];
                break;
                
            case 4:
                m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"All Events in %@ %@", [array objectAtIndex:0], m_strCurrentCategory];
                
                if (__intTbleViewContentSize + 60 < m_tableViewFull.contentOffset.y + 504 && __intTbleViewContentSize > 1000) {
                    
                    [self onBtnLoadMore:nil];
                }
                
                break;
                
            default:
                break;
        }
    }
    
    if (_bottomIndex.section == 0 && _bottomIndex.row == 0) {
        //[self setSectionTitle];
    } else {

    }
    
    if (m_tableViewFull.contentOffset.y < 200) {
        if (m_intTableDataType == 1 || m_intTableDataType == 10) {
            switch (_topIndex.section) {
                case 2:
                    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@ %@", [array objectAtIndex:0], m_strCurrentCategory];
                    break;
                    
                case 3:
                    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@ %@", [array objectAtIndex:0], m_strCurrentCategory];
                    break;
                    
                default:
                    break;
            }
        }
    }
}

- (void)filterEntitiesByDistance:(NSMutableArray*)_array
{
    //    m_arrayTableViewData
    
    NSArray* _sortedArray = [_array sortedArrayUsingComparator:^NSComparisonResult(plaEntity *p1, plaEntity *p2){
        
        float floatItem1 = [p1.EN_SDISTANCE floatValue];
        float floatItem2 = [p2.EN_SDISTANCE floatValue];
        
        if (floatItem1 < floatItem2) {
            return NSOrderedAscending;
        } else if (floatItem1 > floatItem2) {
            return NSOrderedDescending;
        }
        
        return NSOrderedSame;
    }];
    
    m_arrayTableViewData = [[NSMutableArray alloc] initWithArray:_sortedArray];
}

#pragma mark -------delegate --------------------  tableview  -----------------
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) { // tableview for creating artists when creating event.
        return;
    }
    NSInteger intNum = indexPath.row;
    
    if (intBeforCellNum > [m_arrayGlobalTableViewData count] - 2 && intBeforCellNum > intNum) {
        intNum = intNum;
        if (m_intTableDataType == 1) {
            //[self onBtnLoadMore:nil];
        }
    }
    intBeforCellNum = intNum;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //////////////////////////////////a/
    isTableDataEmpty = false;
    
    plaEventData* globData = [plaEventData getInstance];
    if (tableView.tag == 1) { // tableview for creating artists when creating event.
        //        if ([m_arrayTableViewArtistData count] == 0 && m_activityViewLoading.hidden) {
        //            isTableDataEmpty = true;
        //            return 1;
        //        }
        return [m_arrayTableViewArtistData count];
    } else if(tableView.tag == 10) { // selectCategory tableview
        if (m_currentCategory == 100) {
            return 1;
        } else
        return [globData.arrayglobCategories count] + 1;
    } else if(tableView.tag == 141218) {
        
        NSInteger _intCountSection = 0;
        NSString* _strTemp;
        switch (section) {
            case 0:
                _strTemp = @"network";
                break;
                
            case 1:
                _strTemp = @"user";
                break;
                
            case 2:
                _strTemp = @"entity";
                break;
                
            case 3:
                _strTemp = @"event";
                if ([m_arrayOmniSearchData count] == 0) {
                    return 1;
                }
                break;
                
            default:
                return 0;
                break;
        }
        plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
        for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
            model = [m_arrayOmniSearchData objectAtIndex:i];
            if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                _intCountSection = _intCountSection + 1;
            }
        }
        
        if (section == 0 && _intCountSection > 0) {
            if (intTemp_m_btnLoadMoreForNetworkTag > _intCountSection) {
                return _intCountSection;
            } else {
                return intTemp_m_btnLoadMoreForNetworkTag + 1;
            }
        }
        
        if (_intCountSection > 5) {
            return 5;
        }
        
        return _intCountSection;
    } else if(tableView.tag == 141227) {
        if ([m_arrayInboxTableData count] == 0 && m_activityViewLoading.hidden) {
            isTableDataEmpty = true;
            return 1;
        }
        return [m_arrayInboxTableData count];
    }
    
    switch (m_intTableDataType) {
        case 1:
            if (m_currentCategory == 100) {
                if ([m_arrayTableViewData count] == 0 && m_activityViewLoading.hidden) {
                    isTableDataEmpty = true;
                    return 1;
                }
                [self filterEntitiesByDistance:m_arrayTableViewData];
                m_arrayDataForMap = m_arrayTableViewData;
                return [m_arrayTableViewData count];
            }
            m_arrayDataForMap = m_arrayGlobalTableViewData;
            [m_arrayGlobalTableViewData count];
            break;
        case 2:
            //return ([m_arrayTableViewData count] + [m_arrayFriendUser count]);
            m_arrayDataForMap = g_arrayActivityFeeds;
            return [g_arrayActivityFeeds count] > 1 ? [g_arrayActivityFeeds count] : 1;
            break;
        case 3:
            m_arrayTableViewData = g_arrayUpcommingEventData;
            m_arrayDataForMap = m_arrayTableViewData;
            if ([m_arrayTableViewData count] == 0) {
                
                int i = 0 ;
                i = i;
                
            } else {
                int i = 0 ;
                i = i;
            }
            return [m_arrayTableViewData count] > 1 ? [m_arrayTableViewData count] : 1;
            break;
            
        case 5:
            m_arrayDataForMap = m_arrayTableViewData;
            return [m_arrayTableViewData count] > 1 ? [m_arrayTableViewData count] : 1;
            break;
            
        case 10:
            if (m_currentCategory == 100) {
                if ([m_arrayTableViewData count] == 0 && m_activityViewLoading.hidden) {
                    isTableDataEmpty = true;
                    return 1;
                }
                [self filterEntitiesByDistance:m_arrayTableViewData];
                m_arrayDataForMap = m_arrayTableViewData;
                return [m_arrayTableViewData count];
            }
            
            break;
            
        default:
            break;
    }
    
    //    if ([m_arrayGlobalTableViewData count] == 0 && m_activityViewLoading.hidden && m_intCurrentViewStatus != 3) {
    //        isTableDataEmpty = true;
    //        return 1;
    //    }
    
    if (tableView.tag == 0) {
        
        NSInteger intNum;
        
        switch (section) {
            case 0: // Around You
                
                if (globData.sglobNearestEntity != nil) {
                    intNum = 2;
                } else {
                    intNum = 0;
                }
                
                break;
                
            case 1: // Susgested Event
                intNum = [m_arraySugestedEvents count];
                if (intNum > 5) {
                    intNum = 5;
                }
                
                break;
                
            case 2: // Popular Events
                intNum = [m_arrayPopularEvents count];
                if (intNum > 5) {
                    intNum = 5;
                }
                break;
                
            case 3: // Top 5 events (5-10)
                intNum = [m_arrayTopEvents count]; //m_arrayTableViewData
                if (intNum > 8) {
                    intNum = 8;
                }
                //                    else if (intNum < 1) {
                //                    intNum = 0;
                //                }
                break;
                
            case 4: // All Events
                intNum = [m_arrayTableViewData count];
                if (intNum == 0 ) {
                    intNum = 1;
                }
                break;
                
            default:
                break;
        }
        
        
        m_arrayDataForMap = m_arrayGlobalTableViewData;
        
        return intNum;
    }
    
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    
    if (tableView.tag == 141218) {
        
        NSInteger _intCountSection = 0;
        NSString* _strTemp;
        switch (section) {
            case 0:
                _strTemp = @"network";
                break;
                
            case 1:
                _strTemp = @"user";
                break;
                
            case 2:
                _strTemp = @"entity";
                break;
                
            case 3:
                _strTemp = @"event";
                break;
                
            default:
                break;
        }
        plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
        for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
            model = [m_arrayOmniSearchData objectAtIndex:i];
            if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                _intCountSection = _intCountSection + 1;
            }
        }
        
        if (_intCountSection == 0) {
            return 0.01f;
        }
        
        if (section == 0) {
            return 30;
        } else {
            return 20;
        }
    }
    
    plaEventData* globData = [plaEventData getInstance];
    
    if (tableView.tag == 0) {
        NSInteger intNum = 0;
        
        if (m_intTableDataType != 1) {
            return 0.01;
        }
        
        if ( m_currentCategory == 100 && m_currentCategory > 0 )
        {
            return 0.0001;
        }
        
        switch (section) {
            case 0: // Susgested Event
                if (globData.sglobNearestEntity != nil) {
                    intNum = 1;
                } else {
                    intNum = 0;
                }
                
                break;
                
            case 1: // Susgested Event
                intNum = [m_arraySugestedEvents count];
                if (intNum > 5) {
                    intNum = 5;
                }
                break;
                
            case 2: // Popular Events
                intNum = [m_arrayPopularEvents count];
                if (intNum > 5) {
                    intNum = 5;
                }
                break;
                
            case 3: // Top 5 events (5-10)
                intNum = [m_arrayTableViewData count];
                if (intNum > 8) {
                    intNum = 8;
                }
                
                break;
                
            case 4: // All Events
                intNum = [m_arrayTableViewData count] + 1;
                break;
                
            default:
                break;
        }
        
        if (intNum == 0) {
            return 0.01;
        } else if (intNum > 0)
        {
            if (section == 0) {
                return 40;
            } else {
                return 40;
            }
        }
    }
    return 0.01;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    if (tableView.tag == 141218) {
        return 4;
    } else if(tableView.tag == 0) {
        
        if (m_intTableDataType != 1) {
            return 1;
        }
        
        if ([m_arrayGlobalTableViewData count] == 0 && (!m_activityViewLoading.hidden)) {
            isTableDataEmpty = true;
            return 0;
        } else {
            if ( m_currentCategory == 100 && m_currentCategory > 0 ) {
                m_viewLoadMore.hidden = true;
                return 1;
            } else {
                //m_viewLoadMore.hidden;
                return 5;
            }
        }
    }
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    //NSString* strTempLocation =m_lblBGNetwork.text;
    //NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    if (tableView.tag == 141218) {
        
        NSInteger _intCountSection = 0;
        NSString* _strTemp;
        switch (section) {
            case 0:
                _strTemp = @"network";
                break;
                
            case 1:
                _strTemp = @"user";
                break;
                
            case 2:
                _strTemp = @"entity";
                break;
                
            case 3:
                _strTemp = @"event";
                break;
                
            default:
                break;
        }
        plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
        for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
            model = [m_arrayOmniSearchData objectAtIndex:i];
            if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                _intCountSection = _intCountSection + 1;
            }
        }
        
        if (_intCountSection == 0) {
            return @"";
        }
        
        switch (section) {
            case 0:
                return @"  NETWORKS";
                break;
                
            case 1:
                return @"  PEOPLE";
                break;
                
            case 2:
                return @"  ENTITIES";
                break;
                
            case 3:
                return @"  EVENTS";
                break;
                
            default:
                break;
        }
    } else if (tableView.tag == 0)
        switch (section) {
            case 0:
                return @"";
                break;
                
            case 1:
                return @"";
                break;
                
            case 2:
                return @"";
                
            case 3:
                return @"";
                break;
                
            default:
                break;
                
        }
    return @"";
}

-(UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if (tableView.tag != 0) {
        //m_lblFloatingSectionTitle.text = @"";
        return nil;
    }

    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    static NSString *CellIdentifier;
    if (section == 0) {
        CellIdentifier = @"CellSection0Header";
    } else  {
        CellIdentifier = @"CellSection0Header";
    }
    UITableViewCell *headerView = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (headerView == nil){
        [NSException raise:@"headerView == nil.." format:@"No cells with matching CellIdentifier loaded from your storyboard"];
    }
    UILabel* _lblSectionHeader = (UILabel*)[headerView viewWithTag:1];
    switch (section) {
        case 0:
            _lblSectionHeader.text = @"Around You";
            break;
            
        case 1:
            _lblSectionHeader.text = @"Suggested For You";
            break;
            
        case 2:
            _lblSectionHeader.text = @"Popular Events on Facebook";
            break;
            
        case 3:
            _lblSectionHeader.text = [NSString stringWithFormat:@"Top Events in %@", [array objectAtIndex:0]];
            break;
            
        case 4:
            _lblSectionHeader.text = @"All Events";
            break;
            
        default:
            break;
    }
    
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[self changeFriendCountText];
    
    //[self setSectionTitle];
    
    if (isTableDataEmpty && tableView.tag != 141218) {
        
        m_viewLoadMore.hidden = true;
        //m_scrollViewTopEvents.hidden = true;
        
        UITableViewCell* cellNoResult ;
        cellNoResult = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
        
        cellNoResult.userInteractionEnabled = false;
        
        return cellNoResult;
    } else {
        //m_viewLoadMore.hidden;
        //m_scrollViewTopEvents.hidden = false;
    }
    
    if (tableView.tag == 1) { // --------  tableview for creating artists when creating event. --------
        UITableViewCell* cell_artist = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UITableViewCell* cell;
        
        if ([m_arrayTableViewArtistData count] == 0) {
            cell = [[UITableViewCell alloc] init];
            cell.userInteractionEnabled = false;
            cell.hidden = true;
            return cell;
        }
        plaEntity* tempArtist = [m_arrayTableViewArtistData objectAtIndex:indexPath.row];
        UIImageView* imageView = (UIImageView*)[cell_artist.contentView viewWithTag:10];
        
        [imageView setImageURL:[NSURL URLWithString:tempArtist.EN_SIMAGE]];
        
        if ([m_arrayTableViewArtistData count] > 3) {
            m_viewArtistAdd.hidden = YES;
        } else if ([m_arrayTableViewArtistData count] < 4) {
            m_viewArtistAdd.hidden = NO;
        }
        
        return cell_artist;
    } else
        if(tableView.tag == 10) { // --------  selectCategory tableView --------
            
            plaEventData* globData = [plaEventData getInstance];
            
            //        UITableViewCell* cell;
            //
            //        if ([globData.arrayglobCategories count] == 0) {
            //            cell = [[UITableViewCell alloc] init];
            //            return cell;
            //        }
            
            UITableViewCell* cell_category = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell10" forIndexPath:indexPath];
            
            NSString* strCategory ;
            if (indexPath.row == 0) {
                if ([m_lblSelectCategoryEvents.text isEqualToString:@"Events"]) {
                    strCategory = @"All Events";
                } else {
                    strCategory = @"Categories Coming Soon";
                }
                
            } else {
                strCategory = [globData.arrayglobCategories objectAtIndex:indexPath.row - 1];
                
            }
            UILabel* label =  (UILabel*)[cell_category.contentView viewWithTag:1];
            label.text = strCategory;
            //
            return cell_category;
        } else
            if(tableView.tag == 141218) { // --------  Omni search  tableView --------
                UITableViewCell* cell;
                
                if ([m_arrayOmniSearchData count] == 0) {
                    cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
                    cell.userInteractionEnabled = false;
//                    cell.hidden = true;
                    return cell;
                }
                
                NSInteger _intStartSection = 0;
                NSString* _strTemp;
                switch (indexPath.section) {
                    case 0:
                        _strTemp = @"network";
                        break;
                        
                    case 1:
                        _strTemp = @"user";
                        break;
                        
                    case 2:
                        _strTemp = @"entity";
                        break;
                        
                    case 3:
                        _strTemp = @"event";
                        break;
                        
                    default:
                        break;
                }
                plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
                for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
                    model = [m_arrayOmniSearchData objectAtIndex:i];
                    if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                        _intStartSection = i;
                        break;
                    }
                }
                
                if (indexPath.section == 0) {
                    NSInteger _intCountSection = 0;
                    plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
                    for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
                        model = [m_arrayOmniSearchData objectAtIndex:i];
                        if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                            _intCountSection = _intCountSection + 1;
                        }
                    }
                    
                    NSInteger _intTemp = 0;
                    if (intTemp_m_btnLoadMoreForNetworkTag > _intCountSection) {
                        _intTemp = _intCountSection;
                    } else {
                        _intTemp = intTemp_m_btnLoadMoreForNetworkTag;
                    }
                    
                    if (_intTemp == indexPath.row && (!(intTemp_m_btnLoadMoreForNetworkTag > _intCountSection))) {
                        
                        cell = [tableView dequeueReusableCellWithIdentifier:@"LoadMore" forIndexPath:indexPath];
                        return cell;
                    }
                }
                
                model = [m_arrayOmniSearchData objectAtIndex:indexPath.row + _intStartSection];
                
                
                if([model.OMNI_TYPE isEqualToString:@"event"]) {
                    cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellEvent" forIndexPath:indexPath];
                    
                    UILabel* label = (UILabel*)[cell.contentView viewWithTag:103];
                    label.text = model.OMNI_LOCATION;
                    
                    label = (UILabel*)[cell.contentView viewWithTag:104];
                    label.text = model.OMNI_CITY;
                }
                else if ([model.OMNI_TYPE isEqualToString:@"user"]) //CellEntity
                {
                    cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellUser" forIndexPath:indexPath];
                }
                else if ([model.OMNI_TYPE isEqualToString:@"entity"]) //CellEventiy
                {
                    cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellEntity" forIndexPath:indexPath];
                    UILabel* label = (UILabel*)[cell.contentView viewWithTag:103];
                    label.text = model.OMNI_CATEGORY;
                } else if ([model.OMNI_TYPE isEqualToString:@"network"]) //CellNetwork
                {
                    UITableViewCell* cell1 = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNetwork" forIndexPath:indexPath];
                    UILabel* label = (UILabel*)[cell1.contentView viewWithTag:1];
                    label.text = model.OMNI_NAME;
                    
                    return cell1;
                }
                
                UIImageView* imageView = (UIImageView*)[cell.contentView viewWithTag:101];
                [imageView setImageURL:[NSURL URLWithString:model.OMNI_IMAGE]];
                
                UILabel* label = (UILabel*)[cell.contentView viewWithTag:102];
                label.text = model.OMNI_NAME;
                
                return cell;
            } else
                if (tableView.tag == 141227) {// --------  inbox tableView  --------
                    
                    UITableViewCell* cell = nil;
                    
                    if ([m_arrayInboxTableData count] == 0) {
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    
                    if ([m_arrayInboxTableData count] == 0) {
                        UITableViewCell* cellNoResult ;
                        cellNoResult = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
                        
                        cellNoResult.userInteractionEnabled = false;
                        
                        return cellNoResult;
                    }
                    
                    plaInboxDataModel* inboxModel = [m_arrayInboxTableData objectAtIndex:indexPath.row];
                    
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
                        
                        UITableViewCell* cell1 = [tableView dequeueReusableCellWithIdentifier:@"Cell_Event" forIndexPath:indexPath];
                        UIImageView* imageView = (UIImageView*)[cell1 viewWithTag:1];
                        UILabel* label = (UILabel*)[cell1 viewWithTag:2];
                        
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
                        
                        NSMutableAttributedString *text =
                        [[NSMutableAttributedString alloc]
                         initWithAttributedString: label.attributedText];
                        
                        [text addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor darkTextColor]
                                     range:NSMakeRange(0, mailFromUser.USER_NAME.length)];
                        
                        [text addAttribute:NSForegroundColorAttributeName
                                     value:[UIColor darkTextColor]
                                     range:NSMakeRange([NSString stringWithFormat:@"%@ has invited you to ", mailFromUser.USER_NAME].length, mailEvent.EV_SNAME.length)];
                        
                        [label setAttributedText: text];
                        
                        imageView = (UIImageView*)[tableView viewWithTag:3];
                        if (![mailModel.MAIL_ACTIVESTATUS isEqualToString:@"false"]) {
                            imageView.hidden = true;
                        } else {
                            imageView.hidden = false;
                        }
                        
                        return cell1;
                    }
                    
                    return cell;
                }
    
    // ---------- tableview for frontend ---------
    
    m_activityViewLoading.hidden = true;
    m_buttonLoadMore.hidden = false;
    m_viewLoadingText.hidden = YES;
    
    plaEventData* globData = [plaEventData getInstance];
    plaHomeTableViewCell* cell_1;// = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
//    if (m_intTableDataType == 5 ) {
//        plaEntity* entity = [m_arrayTableViewData objectAtIndex:indexPath.row];
//        [cell1.m_imageView0 setImageURL:[NSURL URLWithString:entity.EN_SIMAGEPROFILE] ];
//        cell1.m_lblState.text = entity.EN_SNAME;
//    }
    
    
    if ( (m_currentCategory == 100 && m_currentCategory > 0) || (m_intTableDataType == 5) ) // Table For Entity
    {
        UITableViewCell* cell = nil;
        
        if ([m_arrayTableViewData count] == 0) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
            return cell;
        }
        
        plaEntity* entity = [m_arrayTableViewData objectAtIndex:indexPath.row];
        
        [self setSectionTitleForPlace];
        
        plaHomeTableViewCell* cell1 = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        
        // To set image
        
        NSString* __strTemp = entity.EN_SIMAGE;
        UIImage* __image = [UIImage imageNamed:@"eventpic.jpg"];
        
        if (__strTemp == nil) {
            [cell1.m_imageView0 setImage:__image];
        } else {
            [cell1.m_imageView0 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE]];
        }
        
        [self getLocationDataFromEntity:entity];
        
        cell1.m_lblText1.text = entity.EN_SNAME;
        
        cell1.m_lblText2.text = entity.EN_SCATEGORY;
        
        [self getLocationDataFromEntityData:nil];
        
        cell1.m_lblText3.text = [NSString stringWithFormat:@"%@ km", entity.EN_SDISTANCE];
        
        cell1.m_lalDistance.text = [NSString stringWithFormat:@" %@ km", entity.EN_SDISTANCE];
        
        cell1.m_lblTextAttendCount.text = entity.EN_SADDRESSSTR;
        
        return cell1;
    } else { // Table For Event
        
        ////[self setSectionTitle];
        
        if (indexPath.section == 3) {
            
            if ([m_arrayGlobalTableViewData count] > 0) {
            } else {
                UITableViewCell* cellNoResult ;
                cellNoResult = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
                
                cellNoResult.userInteractionEnabled = false;
                m_viewLoadMore.hidden = true;
                
                return cellNoResult;
            }
            
        }
        
        
        plaEvent* tempEvent;
        
        if (m_intTableDataType == 2) { // new -------- attending ----------- //  -----------
            
            UITableViewCell* cell = nil;
            
            if ([g_arrayActivityFeeds count] == 0) {
                cell = [[UITableViewCell alloc] init];
                cell.userInteractionEnabled = false;
                cell.hidden = true;
                return cell;
            }
            
            plaHomeTableViewCell* cell1 = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell_Activity" forIndexPath:indexPath];
            
            UIImageView* _imageViewActivity = cell1.m_imageView1;  // (UIImageView*)[cell viewWithTag:1];
            UILabel* _lblActivity = cell1.m_lblText1;  // (UILabel*)[cell viewWithTag:2];
            
            plaFeedModel* _feedModel = [g_arrayActivityFeeds objectAtIndex:indexPath.row];
            if ([_feedModel.FEED_ACTION isEqualToString:@"Friend"]) {
                plaUser* userModel;
                for (int i = 0; i < [g_arrayUserData count]; i ++) {
                    plaUser* __model = [g_arrayUserData objectAtIndex:i];
                    if ([__model.USER_ID isEqualToString:_feedModel.FEED_CONTENT]) {
                        userModel = __model;
                        break;
                    }
                }
                
                tempEvent.EV_SEVENTSTATE = 0;
                _lblActivity.text = [NSString stringWithFormat:@"%@ is now friends with %@.", globData.sglobUsername, userModel.USER_NAME];
                
                [_imageViewActivity setImageURL:[NSURL URLWithString:userModel.USER_PROFILEIMAGE]];
                
                
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: _lblActivity.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange(0, globData.sglobUsername.length)];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange([NSString stringWithFormat:@"%@ is now friends with ", globData.sglobUsername].length, userModel.USER_NAME.length)];
                
                [_lblActivity setAttributedText: text];
                
            } else {
                for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
                    plaEvent* __model = [g_arrayAllEventData objectAtIndex:i];
                    if ([__model.EV_SEVENTID isEqualToString:_feedModel.FEED_CONTENT]) {
                        tempEvent = __model;
                        if ([_feedModel.FEED_ACTION isEqualToString:@"Attend"]) {
                            tempEvent.EV_SEVENTSTATE = 1;
                        } else {
                            tempEvent.EV_SEVENTSTATE = -1;
                        }
                        break;
                    }
                }
            }
            
            if (tempEvent.EV_SIMAGE != nil && ![tempEvent.EV_SIMAGE isEqualToString:@""]) {
                [_imageViewActivity setImageURL:[NSURL URLWithString:tempEvent.EV_SIMAGE] ];
            }
            
            if (tempEvent.EV_SEVENTSTATE == 1) { // activity feed
                _lblActivity.text = [NSString stringWithFormat:@"%@ is attending %@", globData.sglobUsername, tempEvent.EV_SNAME];
                
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: _lblActivity.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange(0, globData.sglobUsername.length)];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange([NSString stringWithFormat:@"%@ is attending ", globData.sglobUsername].length, tempEvent.EV_SNAME.length)];
                
                [_lblActivity setAttributedText: text];
                
            } else if(tempEvent.EV_SEVENTSTATE == -1) { // upcomming data
                _lblActivity.text = [NSString stringWithFormat:@"%@ is no longer attending %@", globData.sglobUsername, tempEvent.EV_SNAME];
                
                NSMutableAttributedString *text =
                [[NSMutableAttributedString alloc]
                 initWithAttributedString: _lblActivity.attributedText];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange(0, globData.sglobUsername.length)];
                
                [text addAttribute:NSForegroundColorAttributeName
                             value:[UIColor darkTextColor]
                             range:NSMakeRange([NSString stringWithFormat:@"%@ is no longer attending ", globData.sglobUsername].length, tempEvent.EV_SNAME.length)];
                
                [_lblActivity setAttributedText: text];
            }
            
            return cell1;
            
        }
        
        if (m_intTableDataType == 3) {
            
            if ([m_arrayTableViewData count] == 0) {
                UITableViewCell* cellNoResult ;
                cellNoResult = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
                
                cellNoResult.userInteractionEnabled = false;
                
                return cellNoResult;
            }
        }
        
        if (m_intTableDataType == 1 || m_currentCategory != 0 || m_intTableDataType == 10) {
            if (indexPath.section == 0) {
                
                if (indexPath.row == 1) {
                    UITableViewCell* Cell_ViewMore ;
                    Cell_ViewMore = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell_ViewMore" forIndexPath:indexPath];
                    
                    return Cell_ViewMore;
                }
                
                plaEntity* entity = globData.sglobNearestEntity;
                
                plaHomeTableViewCell* cell1 = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
                
                // To set image
                
                NSString* __strTemp = entity.EN_SIMAGE;
                UIImage* __image = [UIImage imageNamed:@"eventpic.jpg"];
                
                if (__strTemp == nil) {
                    [cell1.m_imageView0 setImage:__image];
                } else {
                    [cell1.m_imageView0 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE]];
                }
                
                [self getLocationDataFromEntity:entity];
                
                cell1.m_lblText1.text = entity.EN_SNAME;
                
                cell1.m_lblText2.text = entity.EN_SCATEGORY;
                
                [self getLocationDataFromEntityData:nil];
                
                cell1.m_lblText3.text = [NSString stringWithFormat:@"%@ km", entity.EN_SDISTANCE];
                
                cell1.m_lalDistance.text = [NSString stringWithFormat:@" %@ km", entity.EN_SDISTANCE];
                
                cell1.m_lblTextAttendCount.text = entity.EN_SADDRESSSTR;
                
                return cell1;
                
            }
        }
        
        plaHomeTableViewCell* cell1 = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        UIView* viewUser = (UIView*)[cell1 viewWithTag:19];
        viewUser.hidden = true;
        UIImageView* imageViewFriend1 = (UIImageView*)[cell1 viewWithTag:10];
        UIImageView* imageViewFriend2 = (UIImageView*)[cell1 viewWithTag:11];
        
        if (m_intTableDataType == 1 || m_currentCategory != 0 || m_intTableDataType == 10) {
            UITableViewCell* cell;
            switch (indexPath.section) {
                case 0: // Susgested Event
                    if ([m_arraySugestedEvents count] == 0) {
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    tempEvent = [m_arraySugestedEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 1: // Susgested Event
                    if ([m_arraySugestedEvents count] == 0) {
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    tempEvent = [m_arraySugestedEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 2: // Popular Events
                    if ([m_arrayPopularEvents count] == 0) {
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    tempEvent = [m_arrayPopularEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 3: // Top 5 events (5-10)
                    //                    if ([m_arrayGlobalTableViewData count] > 5) {
                    //                        tempEvent = [m_arrayGlobalTableViewData objectAtIndex:indexPath.row + 5];
                    //                    } else  {
                    //                        tempEvent = [m_arrayGlobalTableViewData objectAtIndex:indexPath.row];
                    //                    }
                    if ([m_arrayTopEvents count] == 0) { //m_arrayTableViewData
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    tempEvent = [m_arrayTopEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 4: // All Events
                    
                    if ([m_arrayGlobalTableViewData count] > 0) {
                        tempEvent = [m_arrayTableViewData objectAtIndex:indexPath.row];
                        //m_viewLoadingText.hidden = false;
                    } else {
                        [cell1 setFrame:CGRectMake(0, 0, 0, 0)];
                        UITableViewCell* cellNoResult ;
                        cellNoResult = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
                        m_viewLoadingText.hidden = true;
                        
                        cellNoResult.userInteractionEnabled = false;
                        
                        return cellNoResult;
                    }
                    
                    break;
                    
                default:
                    break;
            }
            //tempEvent = [m_arrayGlobalTableViewData objectAtIndex:indexPath.row];
            cell1.m_viewCover.hidden = YES;
            if (m_currentCategory == 0) {
                [self hideLoadingActivityView];
            }
        } else {
            if (m_intTableDataType == 2) {
                
                UITableViewCell* cell = nil;
                
                if ([g_arrayActivityFeeds count] == 0) {
                    cell = [[UITableViewCell alloc] init];
                    cell.userInteractionEnabled = false;
                    return cell;
                }
                
                plaFeedModel* _feedModel = [g_arrayActivityFeeds objectAtIndex:indexPath.row];
                if ([_feedModel.FEED_ACTION isEqualToString:@"Friend"]) {
                    plaUser* userModel;
                    for (int i = 0; i < [g_arrayUserData count]; i ++) {
                        plaUser* __model = [g_arrayUserData objectAtIndex:i];
                        if ([__model.USER_ID isEqualToString:_feedModel.FEED_CONTENT]) {
                            userModel = __model;
                            break;
                        }
                    }
                    
                    cell1.m_lblState.text = [NSString stringWithFormat:@"%@ & %@ are now friends.", globData.sglobUsername, userModel.USER_NAME];
                    [imageViewFriend1 setImageURL:[NSURL URLWithString:globData.sglobFBProfileImageURL]];
                    [imageViewFriend2 setImageURL:[NSURL URLWithString:userModel.USER_PROFILEIMAGE]];
                    cell1.m_viewCover.hidden = NO;
                    imageViewFriend1.hidden = NO;
                    imageViewFriend2.hidden = NO;
                    viewUser.hidden = false;
                    
                    [cell1.m_imageView0 setImage:nil];
                    [cell1.m_imageView0 setBackgroundColor:[UIColor colorWithRed:154.0f/255.0f green:154.0f/255.0f blue:108.0f/255.0f alpha:1.0f]];
                    
                    //return cell1;
                } else {
                    for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
                        plaEvent* __model = [g_arrayAllEventData objectAtIndex:i];
                        if ([__model.EV_SEVENTID isEqualToString:_feedModel.FEED_CONTENT]) {
                            tempEvent = __model;
                            if ([_feedModel.FEED_ACTION isEqualToString:@"Attend"]) {
                                tempEvent.EV_SEVENTSTATE = 1;
                            } else {
                                tempEvent.EV_SEVENTSTATE = -1;
                            }
                            break;
                        }
                    }
                }
                
            } else
                if (m_intTableDataType != 5) {
                    
                    UITableViewCell* cell = nil;
                    
                    if ([m_arrayTableViewData count] == 0) {
                        cell = [[UITableViewCell alloc] init];
                        cell.userInteractionEnabled = false;
                        cell.hidden = true;
                        return cell;
                    }
                    
                    tempEvent = [m_arrayTableViewData objectAtIndex:indexPath.row];
                }
            
            cell1.m_viewCover.hidden = NO;
            if (m_intTableDataType == 3) {
                cell1.m_viewCover.hidden = YES;
            }
            cell1.m_lblState.text = globData.sglobUsername;
            
            if (tempEvent.EV_SEVENTSTATE == 1) { // activity feed
                cell1.m_lblState.text = [NSString stringWithFormat:@"%@ is attending %@", globData.sglobUsername, tempEvent.EV_SNAME];
            } else if(tempEvent.EV_SEVENTSTATE == -1) { // upcomming data
                cell1.m_lblState.text = [NSString stringWithFormat:@"%@  is no longer attending %@", globData.sglobUsername, tempEvent.EV_SNAME];
            }
        }
        
        if (tempEvent.EV_SIMAGE != nil || ![tempEvent.EV_SIMAGE isEqualToString:@""]) {
            [cell1.m_imageView0 setImageURL:[NSURL URLWithString:tempEvent.EV_SIMAGE] ];
        }
        
        //UIImage* imageTemp = [self loadImage:tempEvent.EV_SIMAGE];
        //[cell1.m_imageView1 setImage: imageTemp];
        
        [cell1.m_lblText1 setText:tempEvent.EV_SNAME];
        [cell1.m_lblText2 setText:tempEvent.EV_SLOCATION];
        
        [self getLocationDataFromEntityData:tempEvent];
        [cell1.m_lalDistance setText:[NSString stringWithFormat:@"%.1f km", tempEvent.EV_SDISTANCE]];
        
        //	[cell1.m_lblText3 setText:[eventDates objectAtIndex:indexPath.row]];
        [cell1.m_lblText3 setText: [globData convertDateType:tempEvent.EV_SSTARTDATETIME]];
        [cell1.m_lblWeekday setText: [globData getWeekday:tempEvent.EV_SSTARTDATETIME]];
        NSString* _strDay = [globData getDay:tempEvent.EV_SSTARTDATETIME];
        _strDay = [NSString stringWithFormat:@"%ld", (long)[_strDay integerValue]];
        [cell1.m_lblDay setText: _strDay];
        [cell1.m_lblMonth setText: [globData getMonth:tempEvent.EV_SSTARTDATETIME]];
        
        [self calEventAttendFriendCount:tempEvent];
        [cell1.m_lblTextAttendCount setText:[NSString stringWithFormat:@"%ld", (long)tempEvent.EV_SATTENDCOUNT] ];
        
        [cell1.m_lblAttendFriendCount setText:[NSString stringWithFormat:@"%ld", (long)tempEvent.EV_SATTENDFRIENDCOUNT]];
        
        //        if (indexPath.section == 1) {
        //            [cell1.m_lblAttendFriendCount setText:[NSString stringWithFormat:@"%ld", (long)tempEvent.EV_SUSERSNUMBERONFB]];
        //        }
        
        if (m_intTableDataType == 5 ) {
            plaEntity* entity = [m_arrayTableViewData objectAtIndex:indexPath.row];
            [cell1.m_imageView0 setImageURL:[NSURL URLWithString:entity.EN_SIMAGEPROFILE] ];
            cell1.m_lblState.text = entity.EN_SNAME;
        }
        
        return cell1;
    }
    
    return cell_1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (tableView.tag) {
        case 0:
            if (m_intTableDataType == 2) {
                return 98;
            }
            if ((m_intTableDataType == 1 || m_currentCategory != 0 || m_intTableDataType == 10) && (m_currentCategory != 100))
            {
                if (indexPath.section == 0 && indexPath.row == 1) {
                    return 42;
                }
            }
            return 250;
            break;
            
        case 141218:
            return 79;
            break;
            
        case 141227:
            return 126;
            break;
            
        case 10:
            return 44;
            break;
            
        case 1:
            return 54;
            break;
            
        default:
            break;
    }
    
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (tableView.tag == 1) { // tableview for creating artists when creating event.
        m_intCurrentSelectedArtist = indexPath.row;
        plaEntity* tempArtist = [m_arrayTableViewArtistData objectAtIndex:indexPath.row];
        m_createArtistEntity = tempArtist;
        [self goSearchPageForArtists];
        return;
    } else if (tableView.tag == 10) { // tableView for selecting Category
        m_currentCategory = indexPath.row;
        
        if ([m_lblSelectCategoryEvents.text isEqualToString:@"Events"]) { // Places
            if (indexPath.row == 0) {
                m_imageViewBackscreen.hidden = YES;
                m_viewSelectCategory.hidden = YES;
                //[self onBtnExplore:nil];
            } else{
                //[self dismissViewSelectCategory];
            }
            [self dismissViewSelectCategory];
        } else {
            
        }
        return;
    }
    else if (tableView.tag == 141218) { // ----------- Omni Search ----------------
        plaEventData* globData = [plaEventData getInstance];
        
        NSInteger _intStartSection = 0;
        NSString* _strTemp;
        switch (indexPath.section) {
            case 0:
                _strTemp = @"network";
                break;
                
            case 1:
                _strTemp = @"user";
                break;
                
            case 2:
                _strTemp = @"entity";
                break;
                
            case 3:
                _strTemp = @"event";
                break;
                
            default:
                break;
        }
        plaOmniSearchDataModel* model;// = [m_arrayOmniSearchData objectAtIndex:indexPath.row];
        for (int i = 0; i < [m_arrayOmniSearchData count]; i ++) {
            model = [m_arrayOmniSearchData objectAtIndex:i];
            if ([model.OMNI_TYPE isEqualToString:_strTemp]) {
                _intStartSection = i;
                break;
            }
        }
        model = [m_arrayOmniSearchData objectAtIndex:indexPath.row + _intStartSection];
        
        if ([model.OMNI_TYPE isEqualToString:@"user"]) {
            
            for (int i = 0; i < [g_arrayUserData count]; i ++) {
                plaUser* userModel = [g_arrayUserData objectAtIndex:i];
                if ([model.OMNI_ID isEqualToString:userModel.USER_ID]) {
                    globData.iglobEventRow = i;
                    break;
                }
            }
            
            [self performSegueWithIdentifier: @"segueToUserPage" sender:self];
            
        } else if([model.OMNI_TYPE isEqualToString:@"entity"]) {
            
            for (int i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
                plaEntity* userModel = [globData.arrayglobDBEntities objectAtIndex:i];
                if ([model.OMNI_ID isEqualToString:userModel.EN_SID]) {
                    
                    plaEvent* parsedEvent = [[plaEvent alloc] init];
                    parsedEvent.EV_SEVENTID = @"temp";
                    parsedEvent.EV_SPERSONNAME = userModel.EN_SNAME;
                    parsedEvent.EV_SENTITYSTATE = 1;
                    parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
                    parsedEvent.EV_SENTITY.EN_SID = userModel.EN_SID;
                    
                    //            g_arrayTemp = globData.arrayglobMyEntities;
                    globData.iglobEventRow = 0;
                    g_arrayTemp = [[NSMutableArray alloc] init];
                    [g_arrayTemp addObject:parsedEvent];
                    
                    break;
                }
            }
            
            [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
        }
        else if ([model.OMNI_TYPE isEqualToString:@"event"]) {
            
            for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
                plaEvent* userModel = [g_arrayAllEventData objectAtIndex:i];
                if ([model.OMNI_ID isEqualToString:userModel.EV_SEVENTID]) {
                    
                    //                        plaEvent* parsedEvent = userModel;
                    //                        m_eventTemp = userModel;
                    
                    globData.iglobEventRow = 0;
                    g_arrayTemp = [[NSMutableArray alloc] init];
                    [g_arrayTemp addObject:userModel];
                    
                    [self performSelector:@selector(getDataFromFB:) withObject:userModel afterDelay:0.5f];
                    
                    break;
                }
            }
            //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
        }
        else if ([model.OMNI_TYPE isEqualToString:@"network"]) { //
            m_strTemp = @"";
            NSString* _strItem = [NSString stringWithFormat:@"%@", model.OMNI_NAME];
            
            m_strTemp = _strItem;
            
            UIActionSheet* actionsheet = [[UIActionSheet alloc] initWithTitle:@"Change Network" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:_strItem otherButtonTitles: nil];
            actionsheet.tag = -11;
            [actionsheet showInView:self.view];
        }
        
        return;
    }
    else if (tableView.tag == 141227) { // inbox tableview
        
        plaInboxDataModel* inboxModel = [m_arrayInboxTableData objectAtIndex:indexPath.row];
        
        if ([inboxModel.MAIL_TYPE isEqualToString:@"user"]) {
            
        } else if ([inboxModel.MAIL_TYPE isEqualToString:@"mail"]) {
            plaMail* mailModel = [self getMailwithMail:inboxModel];
            
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
            
            plaEventData *globData = [plaEventData getInstance];
            
            globData.iglobEventRow = 0;
            
            if (g_arrayTemp == nil) {
                g_arrayTemp = [[NSMutableArray alloc] init];
            } else {
                [g_arrayTemp removeAllObjects];
            }
            [g_arrayTemp addObject:mailEvent];
            
            [self getDataFromFB: mailEvent];
            //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
            
            // update Mail active status
            mailModel.MAIL_ACTIVESTATUS = @"true";
            plaWebServices* webService = [[plaWebServices alloc] init];
            [webService backgroundUpdateMail:mailModel];
        }
        
        return;
    }
    
    //----------------------------------------------------------------------------------
    
    plaEventData *globData = [plaEventData getInstance];
    globData.nsipEventRow = indexPath;
    globData.iglobEventRow = indexPath.row;
    
    plaEntity* entity;
    plaFeedModel* _feedModel;
    plaEvent* tempEvent = [[plaEvent alloc] init];
    plaEvent *parsedEvent = [[plaEvent alloc] init];
    switch (m_intTableDataType) {
        case 10:
            
            if (m_currentCategory > 0) {
                globData.iglobEventRow = indexPath.row;
                
                if (m_currentCategory == 100) {
                    
                    globData.iglobEventRow = 0;
                    
                    plaEntity* entity = [m_arrayTableViewData objectAtIndex:indexPath.row];
                    
                    plaEvent* parsedEvent = [[plaEvent alloc] init];
                    parsedEvent.EV_SEVENTID = @"temp";
                    parsedEvent.EV_SPERSONNAME = entity.EN_SNAME;
                    parsedEvent.EV_SENTITYSTATE = 1;
                    parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
                    parsedEvent.EV_SENTITY.EN_SID = entity.EN_SID;
                    
                    //            g_arrayTemp = globData.arrayglobMyEntities;
                    g_arrayTemp = [[NSMutableArray alloc] init];
                    [g_arrayTemp addObject:parsedEvent];
                    
                    [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
                    
                    break;
                }
                
                g_arrayTemp = m_arrayGlobalTableViewData; //g_arraySelectedCategoryEventsData;
            } else {
                globData.iglobEventRow = indexPath.row;
                
                g_arrayTemp = m_arrayGlobalTableViewData; //globData.arrayglobDBEvents;
            }
            
            [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
            
            break;
            
        case 1:
            globData.iglobEventRow = 0;
            
            if (m_currentCategory > 0) {
                globData.iglobEventRow = indexPath.row;
                
                if (m_currentCategory == 100) {
                    
                    globData.iglobEventRow = 0;
                    
                    parsedEvent = [[plaEvent alloc] init];
                    plaEntity* entity = [m_arrayTableViewData objectAtIndex:indexPath.row];
                    
                    plaEvent* parsedEvent = [[plaEvent alloc] init];
                    parsedEvent.EV_SEVENTID = @"temp";
                    parsedEvent.EV_SPERSONNAME = entity.EN_SNAME;
                    parsedEvent.EV_SENTITYSTATE = 1;
                    parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
                    parsedEvent.EV_SENTITY.EN_SID = entity.EN_SID;
                    
                    //            g_arrayTemp = globData.arrayglobMyEntities;
                    g_arrayTemp = [[NSMutableArray alloc] init];
                    [g_arrayTemp addObject:parsedEvent];
                    
                    [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
                    
                    break;
                }
            }
            
            switch (indexPath.section) {
                case 0: // Nearest Entity
                    
                    
                    globData.iglobEventRow = 0;
                    
                    parsedEvent = [[plaEvent alloc] init];
                    
                    parsedEvent.EV_SEVENTID = @"temp";
                    parsedEvent.EV_SPERSONNAME = globData.sglobNearestEntity.EN_SNAME;
                    parsedEvent.EV_SENTITYSTATE = 1;
                    parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
                    parsedEvent.EV_SENTITY.EN_SID = globData.sglobNearestEntity.EN_SID;
                    
                    //            g_arrayTemp = globData.arrayglobMyEntities;
                    g_arrayTemp = [[NSMutableArray alloc] init];
                    [g_arrayTemp addObject:parsedEvent];
                    
                    [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
                    break;
                    
                case 1: // Susgested Event
                    tempEvent = [m_arraySugestedEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 2: // Popular Events
                    tempEvent = [m_arrayPopularEvents objectAtIndex:indexPath.row];
                    break;
                    
                case 3: // Top 5 events (5-10)
                    tempEvent = [m_arrayTopEvents objectAtIndex:indexPath.row]; //
                    break;
                    
                case 4: // All Events
                    tempEvent = [m_arrayTableViewData objectAtIndex:indexPath.row]; //[m_arrayGlobalTableViewData objectAtIndex:indexPath.row];
                    break;
                    
                default:
                    break;
            }
            
            [g_arrayTemp removeAllObjects];
            [g_arrayTemp addObject:tempEvent];
            //g_arrayTemp = m_arrayTableViewData; //g_arrayActivityFeedData;
            
            [self performSelector:@selector(getDataFromFB:) withObject:tempEvent afterDelay:0.5f];
            
            //            [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
            
            break;
            
        case 2:
            
            
            //            if (indexPath.row < [m_arrayFriendUser count]) {
            //                plaUser* userModel = [m_arrayFriendUser objectAtIndex:indexPath.row];
            //
            //                globData.iglobEventRow = [g_arrayUserData indexOfObject:userModel];
            //
            //                [self performSegueWithIdentifier: @"segueToUserPage" sender:self];
            //            } else {
            //                globData.iglobEventRow = indexPath.row - [m_arrayFriendUser count];
            //
            //                g_arrayTemp = m_arrayTableViewData; //g_arrayActivityFeedData;
            //
            //                [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
            //            }
            
            _feedModel = [g_arrayActivityFeeds objectAtIndex:indexPath.row];
            if ([_feedModel.FEED_ACTION isEqualToString:@"Friend"]) {
                for (int i = 0; i < [g_arrayUserData count]; i ++) {
                    plaUser* __model = [g_arrayUserData objectAtIndex:i];
                    if ([__model.USER_ID isEqualToString:_feedModel.FEED_CONTENT]) {
                        globData.iglobEventRow = i;
                        [self performSegueWithIdentifier: @"segueToUserPage" sender:self];
                        break;
                    }
                }
                
                
            } else {
                for (int i = 0; i < [g_arrayAllEventData count]; i ++) {
                    plaEvent* __model = [g_arrayAllEventData objectAtIndex:i];
                    if ([__model.EV_SEVENTID isEqualToString:_feedModel.FEED_CONTENT]) {
                        
                        //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
                        
                        globData.iglobEventRow = 0;
                        g_arrayTemp = [[NSMutableArray alloc] init];
                        [g_arrayTemp addObject:__model];
                        
                        [self getDataFromFB:__model];
                        
                        break;
                    }
                }
            }
            
            break;
            
        case 3:
            globData.iglobEventRow = indexPath.row;
            
            g_arrayTemp = m_arrayTableViewData; //g_arrayUpcommingEventData;
            
            [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
            
            break;
            
        case 4: //
            
            break;
            
        case 5: // --- My Upcoming------
            globData.iglobEventRow = 0;
            
            entity = [globData.arrayglobMyEntities objectAtIndex:indexPath.row];
            
            parsedEvent.EV_SEVENTID = @"temp";
            parsedEvent.EV_SPERSONNAME = entity.EN_SNAME;
            parsedEvent.EV_SENTITYSTATE = 1;
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = entity.EN_SID;
            
            //            g_arrayTemp = globData.arrayglobMyEntities;
            g_arrayTemp = [[NSMutableArray alloc] init];
            [g_arrayTemp addObject:parsedEvent];
            
            [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
            
            break;
            
        default:
            break;
    }
    
}

-(void)tableView:(__unused UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // unit test success:  NSLog( @"calling segueToEventDetail" );
    plaEventData *globData = [plaEventData getInstance];
    globData.nsipEventRow = indexPath;
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self ];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [m_arrayTableViewArtistData removeObjectAtIndex:indexPath.row];
        // Event when deleting tableviewcell
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    [m_tableViewArtists reloadData];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    [m_tableViewArtists exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:newIndexPath.row];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Event when moving tableviewcell
    
    [m_arrayTableViewArtistData exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}
#pragma mark ----- To make sorting item -------
- (void)makeSortingItem:(plaEvent*)_model
{
    NSString* sortDistance, *sortDate, *sortAttendCount; //
    sortDistance = [NSString stringWithFormat:@"%f", _model.EV_SDISTANCE];
    if ([_model.EV_SSTARTDATETIME isEqualToString:@""]) {
        sortDate = @"0000-00-00";
    }
    NSArray* arrayTemp = [_model.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
    sortDate = (NSString*)[arrayTemp objectAtIndex:0];
    arrayTemp = [sortDate componentsSeparatedByString:@"-"];
    sortAttendCount = [NSString stringWithFormat:@"%ld", (long)(100000 - _model.EV_SATTENDCOUNT - 1)];
    
    // sorting order ------- distance, sortDate, sortAttendCount
    _model.EV_SSORTINGITEM = [NSString stringWithFormat:@"%@%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2], sortAttendCount];
}

#pragma mark ---- load, save image in local

- (UIImage*)loadImage:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: name ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

/*
 when our left slider menu has the Logout and Exit button at the bottom, incorpoate this function:
 -(IBAction)select:(id)sender
 {
 UIAlertView *alert = [[UIAlertView alloc]
 initWithTitle:@"Logout"
 message:@"Do you want to log out and exit?"
 delegate:self
 cancelButtonTitle:@"No"
 otherButtonTitles:@"Yes",nil];
 [alert show];
 }
 */

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
        {
            //this is the "Cancel"-Button
            //do nothing
        }
            break;
            
        case 1:
        {
            //this is the "OK"-Button
            // logout
            plaEventData *globEvents = [plaEventData getInstance];
            globEvents.iglobLoggingOut = 20;  // 20 means logging out
            [self dismissViewControllerAnimated:YES completion:NULL ];
        }
            break;
            
        default:
            break;
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handlePanGesture:(UIPanGestureRecognizer *)sender
{
    //[self searchBarCancelButtonClicked:m_searchBar];
    m_searchBar.text = @"";
    m_tableViewOmniSearch.hidden = true;
    [m_arrayOmniSearchData removeAllObjects];
    
    //[self setSectionTitle];
    
    switch (sender.state) {
        case UIGestureRecognizerStateBegan:
            
            pointFirst = [sender locationInView:self.view];
            break;
            
        case UIGestureRecognizerStateChanged:
            
            pointSecond = [sender locationInView:self.view];
            
            int disX = pointSecond.x - pointFirst.x;
            
            if (!isRemoved) {
                isRemoved = false;
                m_viewFront.center = CGPointMake(160 + disX, 568 / 2);
            } else {
                isRemoved = true;
                m_viewFront.center = CGPointMake(160 + 236 + disX, 568 / 2);
            }
            
            break;
            
        case UIGestureRecognizerStateCancelled:
            
            [self selectState];
            break;
            
        case UIGestureRecognizerStateEnded:
            
            [self selectState];
            break;
            
        case UIGestureRecognizerStateFailed:
            
            break;
            
        default:
            break;
    }
}

- (void) selectState
{
    if (!isRemoved) {
        [self frontRemove];
    } else {
        [self frontCover];
    }
}

- (void) frontCoverFromBack
{
    m_viewSettingPage.hidden = YES;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    
    isRemoved = false;
    [m_arrayOmniSearchData removeAllObjects];
    [m_tableViewOmniSearch reloadData];
    
    m_viewFront.center = CGPointMake(160 ,568 / 2);
    
    m_viewFloatGestreView.hidden = true;
    
    [UIView commitAnimations];
    
    [self setSectionTitle];
}

- (void) frontCover
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    
    if (pointSecond.x - pointFirst.x > 0) {
        isRemoved = true;
        m_viewFront.center = CGPointMake(160 + 236,568 / 2);
        
        m_viewFloatGestreView.hidden = false;
    } else {
        isRemoved = false;
        [m_arrayOmniSearchData removeAllObjects];
        [m_tableViewOmniSearch reloadData];
        [self setSectionTitle];
        m_viewFront.center = CGPointMake(160 ,568 / 2);
        
        m_viewFloatGestreView.hidden = true;
    }
    
    [UIView commitAnimations];
}

- (void) frontRemove
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3f];
    
    if (fabs(m_viewFront.center.x - 160) * 2 > fabs(m_viewFront.center.x - 420)) {
        isRemoved = true;
        m_viewFront.center = CGPointMake(160 + 236,568 / 2);
        
        m_viewFloatGestreView.hidden = false;
    } else {
        isRemoved = false;
        [m_arrayOmniSearchData removeAllObjects];
        [m_tableViewOmniSearch reloadData];
        [self setSectionTitle];
        m_viewFront.center = CGPointMake(160 ,568 / 2);
        
        m_viewFloatGestreView.hidden = true;
    }
    
    [UIView commitAnimations];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction) OpenMenu:(id)sender
{
    //[self searchBarCancelButtonClicked:m_searchBar];

    [m_searchBar resignFirstResponder];
    m_searchBar.text = @"";
    m_tableViewOmniSearch.hidden = true;
//    [m_arrayOmniSearchData removeAllObjects];
//    [m_tableViewOmniSearch reloadData];
    
    [self move];
}

- (void)move
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.5f];
    [UIView setAnimationDelay:0.1f];
    
    if (m_viewFront.center.x < 300) {
        isRemoved = true;
        m_viewFront.center = CGPointMake(160 + 236,568 / 2);
        
        m_viewFloatGestreView.hidden = false;
    } else {
        isRemoved = false;
        [m_arrayOmniSearchData removeAllObjects];
        [m_tableViewOmniSearch reloadData];
        [self setSectionTitle];
        m_viewFront.center = CGPointMake(160 ,568 / 2);
        
        m_viewFloatGestreView.hidden = true;
    }
    
    [UIView commitAnimations];
}

- (IBAction)onBtnCategory:(id)sender
{
    //m_lblSelectCategoryEvents.text isEqualToString:@"Event"
    if ([m_lblSelectCategoryEvents.text isEqualToString:@"Events"]) {  // Places -- Venues and Places
        
        [m_tableViewSelectCategory reloadData];
        
    } else { // Events
        [self getAllCategoryDataForPlaces];
        [m_tableViewSelectCategory reloadData];
        
    }
    
    
    [self searchBarCancelButtonClicked:m_searchBar];
    
    [self presentViewSelectCategory];
    
}

- (IBAction)returnedHomeFromSegue:(UIStoryboardSegue *)segue
{
    ;  // unit test successful:  NSLog(@"Returned from menu view");
}

- (IBAction)returnedHomeFromSearchNetwork:(UIStoryboardSegue *)sender
{
    
}

-(void)MergeFBandDB
{
    // Merge them in-mem here and INSERT any Event ID that is not in our DB yet
    
    // for each new Event ID from Facebook, not already in the DB list, add it to our DB
    int iObj;
    NSInteger iResult;
    
    plaEventData *globEvents = [plaEventData getInstance];
    NSInteger iFBSize = [globEvents.arrayglobFBEvents count];
    self.iSizeOfDBArray = [globEvents.arrayglobDBEvents count];
    // unit test successful:
    NSLog( @"Size of DB Events array = %d", (int)self.iSizeOfDBArray );
    
    // unit test successful:
    NSLog( @"Size of FB Events array = %d", (int)iFBSize );
    
    // these are arrays of NSIntegers with the same values: 0 = do nothing, 10 = add to db, 20 = update db
    // with the same object indexes that match the data, so that we can make the same affects to the local arrayglobDBEvents that is shown on this client.
    // This has to be done after the first globarray loop comparisons.
    
    //NSMutableArray *arrayIntFBAction = [[NSMutableArray alloc] initWithCapacity: (int)iFBSize ];
    
    // iterate through FB events
    [self readAllEvents];
    plaEvent *fbEvent = [[plaEvent alloc] init];
    for ( iObj = 0; iObj < (int)iFBSize; iObj++ )
    {
        fbEvent = [globEvents.arrayglobFBEvents objectAtIndex: iObj];
        iResult = [self isFBEventInDB: fbEvent];
        // unit test successful:  NSLog( @"iResult MERGE_ACTION = %d ", (int)iResult );
        if ( ![self isEventInDB:fbEvent] )
        {
            // INSERT to DB
            // unit test successful:  NSLog( @"fbEvent %@ inserting to DB", fbEvent.EV_SNAME );
            [ self addPlayEvent: fbEvent ];
        }
        else {
            //[self updatePlayEvent:fbEvent ];
        }
        // mark for insert or update or to do nothing depending on what the return value was
        //        [arrayIntFBAction addObject:[NSNumber numberWithInt: (int)iResult ] ];
    }  // end for
    
    return;
}

/**
 * isFBEventInDB()
 * input: a single FB Event object
 * processing: if no DB Events then return 10 right away
 *      else loop through all DB Events comparing ID first, if no match then return 10
 *      if there is an ID match, compare remaining fields and if any are different then return 20
 * output: 0 = caller should do nothing with this FB event because it is already in our DB and nothing has changed
 *      10 = caller needs to INSERT this FB into our DB because it is not in the DB yet
 *      20 = caller needs to UPDATE this Event in the DB because something has changed.
 */

-(void)readAllEvents
{
    NSMutableArray* array = [g_controllerView makeRequestFromUserLikesEntity];
    array = array;
    
    //        m_arrayEventIDListInDB = [[NSMutableArray alloc] init];
    plaWebServices *webServ = [[plaWebServices alloc] init];
    m_arrayEventIDListInDB = [webServ backgroundReadEventsAll];
}

-(BOOL)isEventInDB:(plaEvent *)FBPlayEvent
{
    
    if ([m_arrayEventIDListInDB containsObject:FBPlayEvent.EV_SEVENTID]) {
        return true;
    }
    return false;
}

-(NSInteger)isFBEventInDB:(plaEvent *)FBPlayEvent
{
    NSInteger iReturn;
    
    // unit test successful:  NSLog( @"isFBEventInDB checking %@ ", FBPlayEvent.EV_SNAME );
    
    iReturn = MERGE_ACTION_INSERT;
    if ( (int)self.iSizeOfDBArray > (int)0 )
    {
        plaEventData *globEvents = [plaEventData getInstance];
        int iObj;
        NSInteger iSame;
        NSInteger iCompared;
        iSame = 0;
        plaEvent *dbEvent = [[plaEvent alloc] init];
        for ( iObj = 0; iObj < self.iSizeOfDBArray; iObj++ )
        {
            dbEvent = [globEvents.arrayglobDBEvents objectAtIndex: iObj];
            if ( [ dbEvent.EV_SEVENTID isEqualToString:FBPlayEvent.EV_SEVENTID ] )
            {
                // Event already exists. if any other field is different return 20, otherwise return 0
                iCompared = [ dbEvent.EV_SNAME localizedCompare:FBPlayEvent.EV_SNAME ];
                if ( iCompared != iSame )
                {
                    return( MERGE_ACTION_UPDATE );
                }
                iCompared = [ dbEvent.EV_SSTARTDATETIME localizedCompare:FBPlayEvent.EV_SSTARTDATETIME ];
                if ( iCompared != iSame )
                {
                    return( MERGE_ACTION_UPDATE );
                }
                iCompared = [ dbEvent.EV_SLOCATION localizedCompare:FBPlayEvent.EV_SLOCATION ];
                if ( iCompared != iSame )
                {
                    return( MERGE_ACTION_UPDATE );
                }
                iCompared = [ dbEvent.EV_SIMAGE localizedCompare:FBPlayEvent.EV_SIMAGE ];
                if ( iCompared != iSame )
                {
                    return( MERGE_ACTION_UPDATE );
                }
                // since all the fields are the same, we do nothing with this FB Event by returning 0
                return( MERGE_ACTION_NOCHANGE );
            }  // end if there is a Match
        }  // end for loop
    }  // end else there are DB events
    return( iReturn );
}

-(void)addPlayEvent:(plaEvent *)thePlayEvent
{
    // unit test successful:  NSLog( @"in addPlayEvent()" );
    
    // instantiate our custom Web Services object and call the background Insert Event command:
    plaWebServices *webServ = [[plaWebServices alloc] init];
    //    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent.EV_SEVENTID withName:thePlayEvent.EV_SNAME  atDate:thePlayEvent.EV_SSTARTDATETIME atLoc:thePlayEvent.EV_SLOCATION withImg:thePlayEvent.EV_SIMAGE ];
    //    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent];
    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent];
    NSLog( @"iResult = %d", (int)iResult );
}

-(void)updatePlayEvent:(plaEvent *)thePlayEvent
{
    // unit test successful:  NSLog( @"in addPlayEvent()" );
    
    // instantiate our custom Web Services object and call the background Insert Event command:
    plaWebServices *webServ = [[plaWebServices alloc] init];
    //    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent.EV_SEVENTID withName:thePlayEvent.EV_SNAME  atDate:thePlayEvent.EV_SSTARTDATETIME atLoc:thePlayEvent.EV_SLOCATION withImg:thePlayEvent.EV_SIMAGE ];
    //    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent];
    NSInteger iResult = [webServ backgroundUpdateEvent:thePlayEvent];
    NSLog( @"iResult = %d", (int)iResult );
}

#pragma mark ------- delegate -------- Setting page -------
- (IBAction)onBtnLogout:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onBtnPrivacyPolicy:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.playentertainmentnetwork.com/privacy/"]];
}

- (IBAction)onBtnTermsOfService:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.playentertainmentnetwork.com/terms/"]];
}

- (IBAction)onBtnContacts:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.playentertainmentnetwork.com/contact/"]];
}

- (IBAction)onBtnSwithVisitPlace:(id)sender {
    
    plaEventData* globData = [plaEventData getInstance];
    
    UISwitch* _btnSwitch = (UISwitch*)sender;
    if (_btnSwitch.on) {
        [globData setEnableVPNotification:true];
    } else {
        [globData setEnableVPNotification:false];
    }
}

#pragma mark ------- delegate -------- Create View -------
-(IBAction)onBtnAddArtist:(id)sender // to click 'add artist button'
{
    m_createArtistEntity = nil;
    m_intCurrentSelectedArtist = [m_arrayTableViewArtistData count];
    [self goSearchPageForArtists];
}

-(IBAction)onBtnCancel:(id)sender
{
    [g_controllerView makeUploadRequeat:nil];
    [self dismissCreateEventView];
}

-(IBAction)onBtnSave:(id)sender
{
    if ( [m_textFieldEventName.text isEqualToString:@""] ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Event Name' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldWhere.text isEqualToString:@""]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Where' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldStartDate.text isEqualToString:@""] || [m_textFieldStartTime.text isEqualToString:@""] ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Start Date' and 'Start Time' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldAdmins.text isEqualToString:@""]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Hosted By' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self saveEventData];
    
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
    
    [self dismissCreateEventView];
}

-(IBAction)onBtnCancelField:(id)sender
{
    [self cancelChange];
}

-(IBAction)onBtnSaveField:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSInteger intSelectedRow;
    plaEntity* entity;
    NSString* strCategoryData;
    
    plaEventData* globData = [plaEventData getInstance];
    
    
    if (button.tag == 3) {
        intSelectedRow = [m_pickerCategory selectedRowInComponent:0];
        strCategoryData = [globData.arrayglobCategories objectAtIndex:intSelectedRow];
    } else {
        intSelectedRow = [m_pickerAdmins selectedRowInComponent:0];
        entity = [globData.arrayglobMyEntities objectAtIndex:intSelectedRow];
    }
    
    switch (button.tag) {
        case 0: // filed ---- start date
            [self saveStartDate];
            break;
            
        case 1: // filed ----- start time
            [self saveStartTime];
            break;
            
        case 2: // filed ------ hostedby(Admins)
            
            m_createHostedByEntity = entity;
            [m_textFieldAdmins setText:entity.EN_SNAME];
            
            break;
            
        case 3: // filed ------ hostedby(Admins)
            
            [m_textFieldCategory setText:strCategoryData];
            
            break;
            
        default:
            break;
    }
    [self saveChange];
}

- (IBAction)onBtnViewAllEntity:(id)sender {
    m_currentCategory = 100; //
    [self dismissViewSelectCategory];
    //        [m_tableViewSelectCategory reloadData];
    
    m_btnSelectCategoryTapHereToView.titleLabel.text = @"TAP HERE TO VIEW EVENTS";
    m_lblSelectCategoryEvents.text = @"Places";
}

-(IBAction)onChangePicture:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Pictures" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    [actionSheet showInView:self.view];
}

- (IBAction)onBtnCheck:(id)sender {
    UIImage* image;
    if (m_createBtnCheck.tag == 0) {
        m_createBtnCheck.tag = 1;
        image = [UIImage imageNamed:@"btn_check.jpg"];
    } else {
        m_createBtnCheck.tag = 0;
        image = [UIImage imageNamed:@"white_BG.png"];
    }
    [m_createBtnCheck setBackgroundImage:image forState:0];
}

#pragma mark --------Create View--------- backgournd functions -------------
- (void)setNetworkFromLocationInfo:(NSString*)strTemp
{
    plaEventData* globData = [plaEventData getInstance];
    
    NSArray* arrayTemp = [strTemp componentsSeparatedByString:@", "];
    if ([arrayTemp count] == 3) {
        globData.sglobCity = [arrayTemp objectAtIndex:0];
        globData.sglobState = [arrayTemp objectAtIndex:1];
    } else if ([arrayTemp count] == 2) {
        globData.sglobCity = [arrayTemp objectAtIndex:0];
        globData.sglobState = @"(null)";
    }
    
    g_controllerViewHome.m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobState];
    
    if ([globData.sglobState isEqualToString:@"(null)"]) {
        g_controllerViewHome.m_lblBGNetwork.text = [NSString stringWithFormat:@"%@, %@", globData.sglobCity, globData.sglobCity];
    }
    
    [self changeFriendCountText];
    //[self setSectionTitle];
    
    [self getEventsFor3Items];
    [globData.arrayglobDBEvents removeAllObjects];
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    if (m_tableViewFull.contentOffset.y < 10) {
        
        m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@", [array objectAtIndex:0]];
        return;
    }
}

-(void)setSectionTitle
{
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@ %@", [array objectAtIndex:0], m_strCurrentCategory]; //m_strCurrentCategory
    
    if (m_intTableDataType == 1) {
        m_viewLoadMore.hidden = false;
    } else if (m_intTableDataType == 2) {
        [self setSectionTitleForActivityFeed];
        m_viewLoadMore.hidden = true;
    } else if (m_intTableDataType == 3) {
        [self setSectionTitleForMyUpcomingEvents];
        m_viewLoadMore.hidden = true;
    } else if (m_intTableDataType == 5) {
        [self setSectionTitleForMyEntities];
        m_viewLoadMore.hidden = true;
    } else if (m_intTableDataType == 6) {
        [self setSectionTitleForInbox];
        m_viewLoadMore.hidden = true;
    } else if (m_intTableDataType == 7) {
        [self setSectionTitleForSetting];
        m_viewLoadMore.hidden = true;
    }
}

-(void)setSectionTitle1
{
    return;
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"%@ %@", [array objectAtIndex:0], m_strCurrentCategory]; //m_strCurrentCategory
    
    if (m_intTableDataType == 2) {
        [self setSectionTitleForActivityFeed];
        m_viewLoadMore.hidden = true;
    } else if (m_intTableDataType == 3) {
        [self setSectionTitleForMyUpcomingEvents];
        //m_viewLoadMore.hidden;
    } else if (m_intTableDataType == 5) {
        [self setSectionTitleForMyEntities];
        //m_viewLoadMore.hidden;
    } else if (m_intTableDataType == 6) {
        [self setSectionTitleForInbox];
        //m_viewLoadMore.hidden;
    }
}

-(void)setSectionTitleForPlace
{
    
    NSString* strTempLocation =m_lblBGNetwork.text;
    NSArray* array = [strTempLocation componentsSeparatedByString:@", "];
    
    if (m_intTableDataType == 5) {
        return;
    }
    
    m_lblFloatingSectionTitle.text = [NSString stringWithFormat:@"Places in %@ %@", [array objectAtIndex:0], m_strCurrentCategory];
}

-(void)setSectionTitleForMyUpcomingEvents
{
    m_lblFloatingSectionTitle.text = @"Events I am Attending";
}

-(void)setSectionTitleForActivityFeed
{
    m_lblFloatingSectionTitle.text = @"Activity Feed";
}

-(void)setSectionTitleForMyEntities
{
    m_lblFloatingSectionTitle.text = @"My Entities";
}

-(void)setSectionTitleForInbox
{
    m_lblFloatingSectionTitle.text = @"Inbox";
}

-(void)setSectionTitleForSetting
{
    m_lblFloatingSectionTitle.text = @"Settings";
}

-(void)getAllCategoryDataForPlaces
{
    //[globData.arrayglobCategories addObject:@"Venues & Locations"];
}

-(void)saveEventData
{
    if (g_arrayTemp == nil) {
        g_arrayTemp = [[NSMutableArray alloc] init];
    }
    
    plaEventData *globEvents = [plaEventData getInstance];
    
    globEvents.iglobEventRow = [g_arrayTemp count];
    
    plaEvent* event = [[plaEvent alloc] init];
    
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    event.EV_SEVENTID = [NSString stringWithFormat:@"db%ld", (long)today];
    
    event.EV_SNAME = m_textFieldEventName.text;
    
    event.EV_SLOCATION = m_textFieldWhere.text;
    event.EV_SENTITYLOCATION = m_createWhereEntity;
    
    event.EV_SIMAGE = m_createArtistEntity.EN_SIMAGEPROFILE;
    event.EV_STICKETURL = m_textFieldTicketsURL.text;
    
    NSDate* startTime = [m_pickerStartTime date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"HH:mm"];
    NSString* strstartTime = [dateFromat stringFromDate:startTime];
    if ([m_textFieldStartTime.text isEqualToString:@""]) {
        strstartTime = @"";
    }
    
    event.EV_SSTARTDATETIME = [NSString stringWithFormat:@"%@T%@:00", m_textFieldStartDate.text, strstartTime];
    
    event.EV_SPERSONNAME = m_createHostedByEntity.EN_SNAME;
    event.EV_SENTITY = m_createHostedByEntity;
    
    event.EV_SDESCRIPTION = m_textViewDescription.text;
    //event.EV_SDESCRIPTION1 = m_textViewDescription.text;
    
    [self uploadCoverImage];
    event.EV_SIMAGE =  [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/images/%@", m_strCreateEventPhoto];
    
    event.EV_SENTITYLOCATION = m_createWhereEntity;
    event.EV_SSTREET = m_createWhereEntity.EN_SSTREET;
    event.EV_SCITY = m_createWhereEntity.EN_SCITY;
    
    event.EV_SARRAYARTISTS = m_arrayTableViewArtistData;
    
    NSString* strArtistIDs = @"";
    for (int i = 0; i < [event.EV_SARRAYARTISTS count]; i ++) {
        plaEntity* entity = [event.EV_SARRAYARTISTS objectAtIndex:i];
        if (i == 0) {
            strArtistIDs = entity.EN_SID;
        } else {
            strArtistIDs = [NSString stringWithFormat:@"%@***%@",strArtistIDs, entity.EN_SID];
        }
    }
    
    event.EV_SENTITY = m_createHostedByEntity;
    event.EV_SENTITYARTIST = [[plaEntity alloc] init];
    event.EV_SENTITYARTIST.EN_SID = m_createArtistEntity.EN_SID;
    
    event.EV_SENTITYARTISTID = strArtistIDs;
    
    //NSIndexPath *nsipEvent = globEvents.nsipEventRow;
    globEvents.iglobEventRow = [g_arrayTemp count];
    [g_arrayTemp addObject:event];
    [globEvents.arrayglobDBEvents addObject:event];
    [g_arrayAllEventData addObject:event];
    
    // --------------------------------------------- to save event to DB ---------------------------------------
    //    event.EV_SDESCRIPTION = [NSString stringWithFormat:@"%@,%@", event.EV_SENTITYLOCATION.EN_SCITY, event.EV_SENTITYLOCATION.EN_SSTATE];
    plaWebServices *webServ = [[plaWebServices alloc] init];
    [webServ backgroundInsertEvent:event];
}

-(void)uploadCoverImage
{
    plaWebServices* webService = [[plaWebServices alloc] init];
    
    [webService uploadImage:m_imageCreateEventPhoto name:m_strCreateEventPhoto];
}

-(void)saveStartDate
{
    //NSString* strTemp = [m_pickerStartDate description];
    NSDate* startDate = [m_pickerStartDate date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"yyyy-MM-dd"];
    NSString* strstartDate = [dateFromat stringFromDate:startDate];
    
    [m_textFieldStartDate setText:strstartDate];
}

-(void)saveStartTime
{
    //NSString* strTemp = [m_pickerStartDate description];
    NSDate* startDate = [m_pickerStartTime date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"hh:mm aa"];
    NSString* strstartDate = [dateFromat stringFromDate:startDate];
    
    [m_textFieldStartTime setText:strstartDate];
}

-(void)saveHostedBy
{
    NSString* strHostedBy = [m_pickerAdmins description];
    
    [m_textFieldAdmins setText:strHostedBy];
}

-(void)goSearchPageForArtists
{
    m_intCreateField = 2;
    [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
}

-(void)presentViewSelectCategory
{
    m_viewSelectCategory.hidden = NO;
    m_imageViewBackscreen.hidden = NO;
    
    intTemp_m_intTableDataType = m_intTableDataType;
    m_intTableDataType = 10;
    
    [m_tableViewSelectCategory reloadData];
    //
    //    m_viewMapView.hidden = false;
        [m_tableViewFull setFrame:CGRectMake(0, 64, 320, 504) ];
    //    m_tableViewFull.center = CGPointMake(160, 315);  // 315 - tableview original position_y
    //    //    [m_tableViewFull reloadData];
    //    [self refreshTableView];
    //
    //    [self frontCoverFromBack];
    
}

#pragma mark -------------Create View --------delegate ------ actionsheet for choose cover picture ----------
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    
    if (actionSheet.tag == 10) { // actionsheet for Selecting Category
        if (buttonIndex != 0) {
            m_currentCategory = buttonIndex;
        }
    } else if (actionSheet.tag == -1) { // actionsheet for Changing Network
        if (buttonIndex == 0) {
            [self performSegueWithIdentifier:@"segueToNetworkPage" sender:nil];
        }
    } else if (actionSheet.tag == -11) { // actionsheet for Changing Network
        
        if (buttonIndex == 0) {
            [self setNetworkFromLocationInfo:m_strTemp];
            
            [self loadDataFromDB];
            
            [self searchBarCancelButtonClicked:m_searchBar];
            
            [m_tableViewFull reloadData];
        }
    } else {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        switch (buttonIndex) {
            case 0:  // --------------- click PhotoLibrary Item ---------
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
                
            case 1:  // --------------- click Camera Item ---------
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
                
            default:
                break;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    m_imageCreateEventPhoto = [info valueForKey:UIImagePickerControllerOriginalImage];
    [m_imageViewCreateEventPhoto setImage:m_imageCreateEventPhoto];
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    m_strCreateEventPhoto = [NSString stringWithFormat:@"img%ld.png", (long)today];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -------------Create View --------delegate ------ uipicker view for Admin(Hostedby) -----
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    plaEventData* globData = [plaEventData getInstance];
    if (pickerView.tag == 3) {
        return [globData.arrayglobCategories count];
    }
    return [globData.arrayglobMyEntities count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    plaEventData* globData = [plaEventData getInstance];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 174)];
    //label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-regular" size:20];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    //label.text = [NSString stringWithFormat:@"  %ld", row+1];
    if (pickerView.tag == 2) {
        plaEntity* entity = [globData.arrayglobMyEntities objectAtIndex:row];
        label.text = entity.EN_SNAME;
    } else if (pickerView.tag ==3) {
        NSString* strTemp = [globData.arrayglobCategories objectAtIndex:row];
        label.text = strTemp;
    }
    
    return label;
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    plaEventData* globData = [plaEventData getInstance];
    //    plaEntity* entity = [globData.arrayglobMyEntities objectAtIndex:row];
    //
    //    [m_textFieldAdmins setText:entity.EN_SNAME];
}

#pragma mark -------------Create View --------delegate ------ textfield -----

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1: // ------------------  'where' field
            m_intCreateField = 1;
            [self hideKeyboardAll];
            [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
            return false;
            break;
            
        case 2: // ------------------  'artist' field
            m_intCreateField = 2;
            [self hideKeyboardAll];
            [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
            return false;
            break;
            
        case 4:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateStartDate];
            return false;
            break;
            
        case 5:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateStartTime];
            return false;
            break;
            
        case 6:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateHostedBy];
            return false;
            break;
            
        case 8:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateCategory];
            return false;
            break;
            
        default:
            [self hideViewAll];
            break;
    }
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardAll];
    return true;
}

-(void)cancelChange
{
    [self hideOverView:m_viewCreateHostedBy];
    [self hideViewAll];
}

-(void)saveChange
{
    [self hideOverView:m_viewCreateHostedBy];
    [self hideViewAll];
}

-(void) hideOverView:(UIView*)__view
{
    //UIView* view = __view;
    //view.center = CGPointMake(160, 672);
}

-(void)hideViewAll
{
    //    m_viewCreateHostedBy.center = CGPointMake(160, 672);
    //    m_viewCreateStartDate.center = CGPointMake(160, 672);
    //    m_viewCreateStartTime.center = CGPointMake(160, 672);
    
    m_viewCreateHostedBy.hidden = true;
    m_viewCreateStartDate.hidden = true;
    m_viewCreateStartTime.hidden = true;
    m_viewCreateCategory.hidden = true;
    
}

-(void)hideKeyboardAll
{
    [m_textFieldAdmins resignFirstResponder];
    [m_textFieldArtists resignFirstResponder];
    [m_textFieldEventName resignFirstResponder];
    [m_textFieldHashtagsForEvent resignFirstResponder];
    [m_textFieldStartDate resignFirstResponder];
    [m_textFieldStartTime resignFirstResponder];
    [m_textFieldTicketsURL resignFirstResponder];
    [m_textFieldWhere resignFirstResponder];
    [m_textViewDescription resignFirstResponder];
    
    [m_textFldQuestion1 resignFirstResponder];
    [m_textFldQuestion2 resignFirstResponder];
    [m_textFldQuestion3 resignFirstResponder];
    [m_textFldQuestion4 resignFirstResponder];
}

-(void)showViewAll
{
    m_viewCreateHostedBy.hidden = false;
    m_viewCreateStartDate.hidden = false;
    m_viewCreateStartTime.hidden = false;
    m_viewCreateCategory.hidden = false;
}

-(void) showOverView:(UIView*)__view
{
    [self hideViewAll];
    UIView* view = __view;
    view.hidden = false;
}

-(void) presentCreateEventView
{
    m_intCurrentViewStatus = 3;
    m_imageViewBackscreen.hidden = false;
    m_viewCreateView.hidden = false;
}

-(void)resetCreateEntityObject
{
    self.m_createWhereEntity = [[plaEntity alloc] init];
    self.m_createArtistEntity = [[plaEntity alloc] init];
    self.m_createHostedByEntity = [[plaEntity alloc] init];
    
    UIImage* imageName = [UIImage imageNamed:@"createView_photo.p_ng"];
    [m_imageViewCreateEventPhoto setImage:imageName];
    [m_textFieldWhere setText:@""];
    [m_textFieldEventName setText:@""];
    [m_textFieldArtists setText:@""];
    [m_textFieldStartDate setText:@""];
    [m_textFieldStartTime setText:@""];
    [m_textFieldAdmins setText:@""];
    [m_textViewDescription setText:@""];
    [m_textFieldHashtagsForEvent setText:@""];
    [m_textFieldTicketsURL setText:@""];
    [m_textFieldCategory setText:@""];
    
    //    [m_arrayTableViewArtistData removeAllObjects];
    m_arrayTableViewArtistData = [[NSMutableArray alloc] init];
    
    m_viewArtistAdd.hidden = false;
    
    [m_tableViewArtists reloadData];
}

#pragma mark -------- FBHandler delegate functions
- (void) OnFBSuccess
{
    NSLog(@"Successful");
}

- (void)OnFBFailed:(NSError *)error
{
    if (error == nil) {
        NSLog(@"User Cancelled");
    } else {
        NSLog(@"Failed");
    }
}

#pragma mark ------ touch delegate -------------
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self hideViewAll];
    [self hideKeyboardAll];
}

-(void)dismissCreateEventView
{
    [self resetCreateEntityObject];
    m_intCurrentViewStatus = 2;
    m_viewCreateView.hidden = YES;
    m_imageViewBackscreen.hidden = YES;
}

- (IBAction)onBtnScrollLeft:(id)sender {
    
    //[self sendRequest];
    
    NSInteger index = 0;
    
    CGFloat pageWidth = m_scrollViewTopEvents.frame.size.width;
    
    index = floor((m_scrollViewTopEvents.contentOffset.x - pageWidth / 2) / pageWidth ) + 1;
    if (index > 0) {
        index = index - 1;
    }
    CGRect frame;
    frame.origin.x = m_scrollViewTopEvents.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = m_scrollViewTopEvents.frame.size;
    [m_scrollViewTopEvents scrollRectToVisible:frame animated:YES];
}

- (IBAction)onBtnScrollRight:(id)sender {
    NSInteger index = 0;
    
    CGFloat pageWidth = m_scrollViewTopEvents.frame.size.width;
    
    index = floor((m_scrollViewTopEvents.contentOffset.x - pageWidth / 2) / pageWidth ) + 1;
    if (index < 7) {
        index = index + 1;
    }
    CGRect frame;
    frame.origin.x = m_scrollViewTopEvents.frame.size.width * index;
    frame.origin.y = 0;
    frame.size = m_scrollViewTopEvents.frame.size;
    [m_scrollViewTopEvents scrollRectToVisible:frame animated:YES];
}

#pragma mark ------------- omnisearch --------------------
- (IBAction)onBtnLoadMoreForNetwork:(id)sender {
    intTemp_m_btnLoadMoreForNetworkTag = intTemp_m_btnLoadMoreForNetworkTag + 3;
    [m_tableViewOmniSearch reloadData];
}

#pragma mark ----------- Feedback --------------
- (IBAction)onBtnSettingPGhLeaveFeedback:(id)sender
{
    [self presendFBView];
}

- (IBAction)onBtnFBQuestionCancel:(id)sender {
    [self dismissFBView];
}

- (IBAction)onBtnFBQuestionSubmit:(id)sender {
    [self sendEmailFeedback];
    [self dismissFBView];
}

- (IBAction)onBtnFBProvideNoThx:(id)sender {
    [self dismissFBView];
}

- (IBAction)onBtnFBProvideLeaveFB:(id)sender {
    [self hideAllFBView];
    m_viewFBQueation.hidden = false;
}

- (IBAction)onBtnFBHappyUnhappy:(id)sender {
    [self hideAllFBView];
    
    m_viewFBProvide.hidden = false;
}

- (IBAction)onBtnFBHappyHappy:(id)sender {
    [self hideAllFBView];
    
    m_viewFBProvide.hidden = false;
}

-(void)hideAllFBView
{
    m_viewFBHappy.hidden = true;
    m_viewFBProvide.hidden = true;
    m_viewFBQueation.hidden = true;
}

-(void)dismissFBView
{
    m_imageViewBackscreenForFB.hidden = true;
    m_viewFeedback.hidden = true;
    
    m_textFldQuestion1.text = @"";
    m_textFldQuestion2.text = @"";
    m_textFldQuestion3.text = @"";
    m_textFldQuestion4.text = @"";
}

-(void)presendFBView
{
    [self performSelector:@selector(showFBView) withObject:nil afterDelay:5.0f];
}

-(void)showFBView
{
    m_imageViewBackscreenForFB.hidden = false;
    m_viewFeedback.hidden = false;
    [self hideAllFBView];
    m_viewFBHappy.hidden = false;
}

-(void)sendEmailFeedback
{
    [self sendEmailToServer];
}

-(void)hideAllFBQuestionTextFlds
{
    [m_textFldQuestion1 resignFirstResponder];
    [m_textFldQuestion2 resignFirstResponder];
    [m_textFldQuestion3 resignFirstResponder];
    [m_textFldQuestion4 resignFirstResponder];
}

-(void)showFeedBackScreen
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    NSString* _strNumber = [prefs objectForKey:@"numberOfOpeningForFB"];
    NSInteger _intNumber;
    if (_strNumber == nil) {
        [prefs setObject:@"1" forKey:@"numberOfOpeningForFB"];
    } else {
        _intNumber = [_strNumber integerValue];
        
        if (_intNumber == 5 || _intNumber == 13 || _intNumber == 23 || _intNumber == 43) {
            [self presendFBView];
            _intNumber = _intNumber + 1;
            [prefs setObject:[NSString stringWithFormat:@"%ld", (long)_intNumber] forKey:@"numberOfOpeningForFB"];
        }
    }
}

-(void) sendEmailToServer
{
    NSString* question = @""; //[NSString stringWithFormat:@"current location is   %@(%f, %f).", currentLocationAdress, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSString* strBody = [NSString stringWithFormat:@"%@", question];
    
    question = m_textFldQuestion1.text;
    strBody = [NSString stringWithFormat:@"%@<br>%@", strBody, @"What is 1 or more things you like about the app?"];
    strBody = [NSString stringWithFormat:@"%@<br>%@<br>", strBody, question];
    
    question = m_textFldQuestion2.text;
    strBody = [NSString stringWithFormat:@"%@<br>%@", strBody, @"What is 1 or more things you do not like about the app?"];
    strBody = [NSString stringWithFormat:@"%@<br>%@<br>", strBody, question];
    
    question = m_textFldQuestion3.text;
    strBody = [NSString stringWithFormat:@"%@<br>%@", strBody, @"What is 1 or more features you would like to see on the app in the future?"];
    strBody = [NSString stringWithFormat:@"%@<br>%@<br>", strBody, question];
    
    question = m_textFldQuestion4.text;
    strBody = [NSString stringWithFormat:@"%@<br>%@", strBody, @"Any other questions, comments or concerns?"];
    strBody = [NSString stringWithFormat:@"%@<br>%@<br><br>", strBody, question];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    // his class should be the delegate of the mc
    mc.mailComposeDelegate = self;
    
    // set a mail subject ... but you do not need to do this :)
    [mc setSubject:@"Leave Feedback!"];
    
    // set some basic plain text as the message body ... but you do not need to do this :)
    [mc setMessageBody:[NSString stringWithFormat:@"%@", strBody] isHTML:YES];
    
    //NSArray* array = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@", saveData.m_personEmail], nil];
    // set some recipients ... but you do not need to do this :)
    [mc setToRecipients:[NSArray arrayWithObjects:@"hello@playentertainmentnetwork.com", nil]];
    
    //[mc setCcRecipients:array];
    
    //[mc setToRecipients:[NSArray arrayWithObjects:@"first.address@test.com", @"second.address@test.com", nil]];
    
    // displaying our modal view controller on the screen with standard transition
    [self presentViewController:mc animated:YES completion:nil];
    
    // be a good memory manager and release mc, as you are responsible for it because your alloc/init
}

#pragma mark -------- delegate ------ email --------
// delegate function callback
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // switchng the result
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled.");
            /*
             Execute your code for canceled event here ...
             */
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved.");
            /*
             Execute your code for email saved event here ...
             */
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent.");
            /*
             Execute your code for email sent event here ...
             */
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send error: %@.", [error localizedDescription]);
            /*
             Execute your code for email send failed event here ...
             */
            break;
        default:
            break;
    }
    // hide the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
