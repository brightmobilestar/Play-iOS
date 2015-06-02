//
//  plaAppDelegate.h
//  Play
//
//  Created by Darcy Allen on 2014-06-05.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "plaEvent.h"
#import "LocationShareModel.h"
@class plaViewController;
@class plaHomeViewController;
@class plaEntityPageViewController;
@class plaEventDetailViewController;
@class PushNotificationManagement;

@interface plaAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>
{
    BOOL isActive;
    
    UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) LocationShareModel * shareModel;
@property (strong, nonatomic) NSTimer* timer;

//@property (nonatomic) CLLocationCoordinate2D myLastLocation;
//@property (nonatomic) CLLocationAccuracy myLastLocationAccuracy;
//
//@property (nonatomic) CLLocationCoordinate2D myLocation;
//@property (nonatomic) CLLocationAccuracy myLocationAccuracy;

@property (strong, nonatomic) NSDictionary *refererAppLink;

@property (strong, nonatomic) UIWindow *window;

// If we were using xibs then the app delegate maintains a property for the current
// active session, and the view controllers reference the session via
// this property, as well as play a role in keeping the session object
// up to date; a more complicated application may choose to introduce
// a simple singleton that owns the active FBSession object as well
// as access to the object by the rest of the application
// @property (strong, nonatomic) FBSession *session;

@end

NSMutableArray* g_arrayTemp;

NSMutableArray* g_arrayUpcommingEventData;
NSMutableArray* g_arrayActivityFeedData;
NSMutableArray* g_arrayActivityFeeds; // To get data from Activity Feed Tbl
NSMutableArray* g_arraySelectedCategoryEventsData;
NSMutableArray* g_arrayUpcommingEventDataOnFB;
NSMutableArray* g_arrayVisitPlaceData;

NSMutableArray* g_arrayUserData;
NSMutableArray* g_arrayAllEventData;
NSMutableArray* g_arrayMailData;

NSMutableArray* g_arrayFBFriendsDta;

plaViewController* g_controllerView;
plaHomeViewController* g_controllerViewHome;
plaEventDetailViewController* g_controllerEventDetail;
plaEntityPageViewController* g_controllerEntityPage;
PushNotificationManagement* g_managePush;