//
//  plaAppDelegate.m
//  Play
//
//  Created by Darcy Allen on 2014-06-05.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaAppDelegate.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import "plaEventData.h"
#import "plaViewController.h"
#import "plaHomeViewController.h"
#import "plaWebServices.h"
#import "plaEntity.h"

@implementation plaAppDelegate

@synthesize timer;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
//        openURL:(NSURL *)url
//        sourceApplication:(NSString *)sourceApplication
//        annotation:(id)annotation
{
    [self setVPNotificationDefault];
    
    // Override point for customization after application launch.
    [Parse setApplicationId:@"1Vf9J2o7ZJay9OBQnmL3KsVgrcshzvNqvOjuAx0r"
                  clientKey:@"8Ff9MkCwvjM9kH8JHOxaYXfvFPmEbQvV3lcUx0ks"];
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
//    [self initGlobalData];
    
    [FBLoginView class];
    [FBProfilePictureView class];
    
    plaEventData *globEvents = [plaEventData getInstance];
    globEvents.iglobLoggingOut = 10;  // 10 means not logging out
    
    
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    if([[[UIDevice currentDevice] systemVersion] compare:@"8.0" options:NSNumericSearch] == NSOrderedAscending)
    {
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeSound];
    } else {
        UIUserNotificationSettings* settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        
    }
    
    if ([UIApplication instancesRespondToSelector:@selector(registerUserNotificationSettings:)]) {
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil]];
    }
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsAnnotationKey]) {
        //self.
    }
    
    // ------------ Push notification ----------------
    self.shareModel = [LocationShareModel sharedModel];
    self.shareModel.afterResume = NO;
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey]) {
        NSLog(@"UIApplicationLaunchOptionsLocationKey");
        
        // This "afterResume" flag is just to show that he receiving location updates
        // are actually from the key "UIApplicationLaunchOptionsLocationKey"
        self.shareModel.afterResume = YES;
        
        self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
        self.shareModel.anotherLocationManager.delegate = self;
//        self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//        self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
        self.shareModel.anotherLocationManager.desiredAccuracy = 1;
        self.shareModel.anotherLocationManager.distanceFilter = 1;
        
        if(IS_OS_8_OR_LATER) {
            [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
        }
        
        [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
        //[self.shareModel.anotherLocationManager startUpdatingLocation];
        
        [self backgroundFunction:nil];
    }
    
    return YES;
}

- (void)backgroundFunction:(NSString*)_appStatus
{
    
}

- (void) setVPNotificationDefault
{
    plaEventData* globData = [plaEventData getInstance];
    
    [globData isEnableVPNotification];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    plaEventData* globData = [plaEventData getInstance];
    if (globData.sglobUserID != nil) {
        currentInstallation[@"user_id"] = globData.sglobUserID;
    }
    currentInstallation.channels = @[@"global"];
    
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
    
    NSInteger intBadgeNumber;// = [g_controllerViewHome.m_lblInboxCount.text integerValue];
    intBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber;
    intBadgeNumber = intBadgeNumber + 1;
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:intBadgeNumber];
    
}

- (void) application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    //[UIApplication sharedApplication].applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber + 1;
    //UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //[alertView show];
}

- (void) initGlobalData
{
    g_arrayActivityFeedData = [[NSMutableArray alloc] init];
    g_arrayUpcommingEventData = [[NSMutableArray alloc] init];
    g_arraySelectedCategoryEventsData = [[NSMutableArray alloc] init];
}

#pragma mark ------ GPS Tracking -------------
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    if ([self.timer isValid] && self.timer != nil) {
        
    } else {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:300.0f target:self.shareModel.anotherLocationManager selector:@selector(startUpdatingLocation) userInfo:nil repeats:YES];
    }
    
    NSLog(@"locationManager didUpdateLocations: %@",locations);
    
    if (![[plaEventData getInstance] isDataLoaded]) {
        return;
    }
    
    CLLocation * newLocation = [locations lastObject];
    
    plaWebServices* service = [[plaWebServices alloc] init];
    NSMutableArray* entityArray = [service getAllEntityInfoFromFile];
    
    BOOL isFinded = false;
    
    int minDistance = 100000;
    plaEntity* entityTemp;
    
    for (int i = 0; i < [entityArray count]; i ++) {
        
        plaEntity* entity = [entityArray objectAtIndex:i];
        
        int intdistand = [entity.EN_SLOCATION distanceFromLocation:newLocation];
        entity.EN_SDISTANCE = [NSString stringWithFormat:@"%d", intdistand];
        
        if (minDistance > intdistand) {
            minDistance = intdistand;
            entityTemp = entity;
        }
        
        if ( intdistand < 20  ) {
            [self sendNotificationPerPlace:entity];
            isFinded = true;
            
            break;
        }
    }
    
    if (!isFinded) {
        //[self sendNotification:entityTemp];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"applicationDidEnterBackground");
    [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    //[self.shareModel.anotherLocationManager startUpdatingLocation];
    
    [self backgroundFunction:@"applicationDidEnterBackground"];
    
    UIApplication* app = [UIApplication sharedApplication];
    
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:100.0f target:self.shareModel.anotherLocationManager selector:@selector(startUpdatingLocation) userInfo:nil repeats:YES];
//    
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:100.0f target:self.shareModel.anotherLocationManager selector:@selector(startMonitoringSignificantLocationChanges) userInfo:nil repeats:YES];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    plaEventData* globData = [plaEventData getInstance];
    NSString* _strNumber = [prefs objectForKey:@"numberOfOpeningForFB"];
    NSInteger _intNumber;
    if (_strNumber == nil) {
        [prefs setObject:@"1" forKey:@"numberOfOpeningForFB"];
    } else {
        _intNumber = [_strNumber integerValue];
        
        if (_intNumber == 5 || _intNumber == 13 || _intNumber == 23 || _intNumber == 43) {
            if (g_controllerViewHome != nil) {
                if ([globData.m_currentController isEqualToString:@"homeViewController"]) {
                    [g_controllerViewHome showFeedBackScreen];
                }
            }
        } else {
            _intNumber = _intNumber + 1;
            [prefs setObject:[NSString stringWithFormat:@"%ld", (long)_intNumber] forKey:@"numberOfOpeningForFB"];
        }
    }
    
    NSLog(@"applicationDidBecomeActive");
    
    [self backgroundFunction:@"applicationDidBecomeActive"];
    
    //Remove the "afterResume" Flag after the app is active again.
    self.shareModel.afterResume = NO;
    
    if(self.shareModel.anotherLocationManager)
        [self.shareModel.anotherLocationManager stopMonitoringSignificantLocationChanges];
    
    self.shareModel.anotherLocationManager = [[CLLocationManager alloc]init];
    self.shareModel.anotherLocationManager.delegate = self;
//    self.shareModel.anotherLocationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    self.shareModel.anotherLocationManager.activityType = CLActivityTypeOtherNavigation;
    self.shareModel.anotherLocationManager.desiredAccuracy = 1;
    self.shareModel.anotherLocationManager.distanceFilter = 1;
    
    if(IS_OS_8_OR_LATER) {
        [self.shareModel.anotherLocationManager requestAlwaysAuthorization];
    }
    [self.shareModel.anotherLocationManager startMonitoringSignificantLocationChanges];
    //[self.shareModel.anotherLocationManager startUpdatingLocation];
}


-(void)applicationWillTerminate:(UIApplication *)application{
    NSLog(@"applicationWillTerminate");
    [self backgroundFunction:@"applicationWillTerminate"];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

// added FBAppCall in the return so that this app can handle responses from Facebook

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    BOOL urlWasHandled =
    [FBAppCall handleOpenURL:url
           sourceApplication:sourceApplication
             fallbackHandler:
     ^(FBAppCall *call) {
         // Parse the incoming URL to look for a target_url parameter
         NSString *query = [url query];
         NSDictionary *params = [self parseURLParams:query];
         // Check if target URL exists
         NSString *appLinkDataString = [params valueForKey:@"al_applink_data"];
         
         if (appLinkDataString) {
             NSError *error = nil;
             NSDictionary *applinkData =
             [NSJSONSerialization JSONObjectWithData:[appLinkDataString dataUsingEncoding:NSUTF8StringEncoding]
                                             options:0
                                               error:&error];
             if (!error &&
                 [applinkData isKindOfClass:[NSDictionary class]] &&
                 applinkData[@"target_url"]) {
                 self.refererAppLink = applinkData[@"referer_app_link"];
                 NSString *targetURLString = applinkData[@"target_url"];
                 // Show the incoming link in an alert
                 // Your code to direct the user to the
                 // appropriate flow within your app goes here
                 [[[UIAlertView alloc] initWithTitle:@"Received link:"
                                             message:targetURLString
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil] show];
             }
         }
     }];
    
    return urlWasHandled;
}

// A function for parsing URL parameters
- (NSDictionary*)parseURLParams:(NSString *)query {
    NSArray *pairs = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    for (NSString *pair in pairs) {
        NSArray *kv = [pair componentsSeparatedByString:@"="];
        NSString *val = [[kv objectAtIndex:1]
                         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [params setObject:val forKey:[kv objectAtIndex:0]];
    }
    return params;
}

#pragma mark ----- send notification -------------------
- (BOOL) isVisited:(plaEntity*)_entity
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"PlaceName"];
    
    NSString* strPlaceName = [prefs stringForKey:@"LastVisitedPlaceName"];
    
    if ([_entity.EN_SNAME isEqualToString:strPlaceName]) {
        return true;
    } else {
        [prefs setObject:_entity.EN_SNAME forKey:@"LastVisitedPlaceName"];
        return false;
    }
    
    return false;
}

- (void) sendNotificationPerPlace:(plaEntity*)_entity
{
    
    if ([self isVisited:_entity]) {
        return;
    }
    
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate date];
    
    notification.alertBody = [NSString stringWithFormat:@"Welcome to %@! There are %ld upcoming events here! distance  %@", _entity.EN_SNAME, (long)_entity.m_intEventsCount, _entity.EN_SDISTANCE ];
    
    notification.alertAction = @"View";
    notification.soundName = @"2015_best_sound.mp3";
    //notification.applicationIconBadgeNumber ++;
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void) sendNotification:(plaEntity*)_entity
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *root = [documentsDir stringByAppendingPathComponent:@"entityInfo.plist"];
    
    NSMutableDictionary *responseA = [[NSMutableDictionary alloc] initWithContentsOfFile:root];
    
    NSMutableArray * dataArray = [[NSMutableArray alloc] init];
    
    NSTimeInterval milSec = [[NSDate date] timeIntervalSince1970];
    NSInteger intMilSec = (NSInteger)milSec;
    
    
    UILocalNotification* notification = [[UILocalNotification alloc] init];
    
    notification.fireDate = [NSDate date]; //[self getRemindDate:0];
    BOOL isSuccessed = false;
    
    if (_entity != nil) {
        notification.alertBody = [NSString stringWithFormat:@"Welcome to %@! There are %ld upcoming events here! distance  %@", _entity.EN_SNAME, (long)_entity.m_intEventsCount, _entity.EN_SDISTANCE ];
    }
    
    for ( NSDictionary *eventObj in responseA ) //visited_time
    {
        // create space in-mem to hold this event
        
        /* then we dig deeper into the JSON asking for the value for each known key
         */
        
        NSString* strVisitedTime = @"";
        
        if ([eventObj valueForKey:@"visited_time"] != nil) {
            strVisitedTime = [eventObj valueForKey:@"visited_time"];
        } else {
            strVisitedTime = [NSString stringWithFormat:@"%ld", (long)intMilSec];
        }
        
        NSDictionary* dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[eventObj valueForKey:@"EN_SNAME"], @"name", [eventObj valueForKey:@"EN_SLOCATION"], @"location", [eventObj valueForKey:@"EN_SADDRESS"], @"address", [eventObj valueForKey:@"count"], @"count", strVisitedTime, @"visited_time", nil];
        
        if ([_entity.EN_SNAME isEqualToString:[eventObj valueForKey:@"EN_SNAME"]]) {
            
            NSInteger intTime ;
            
            if ([eventObj valueForKey:@"visited_time"] != nil) {
                intTime = [[eventObj valueForKey:@"visited_time"] integerValue];
            } else {
                intTime = intMilSec;
            }
            
            intTime = intMilSec - intTime;
            
            if (intTime > 24 * 3600) {
                //return;
            } else {
                isSuccessed = true;
                dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[eventObj valueForKey:@"EN_SNAME"], @"name", [eventObj valueForKey:@"EN_SLOCATION"], @"location", [eventObj valueForKey:@"EN_SADDRESS"], @"address", [eventObj valueForKey:@"count"], @"count", [NSString stringWithFormat:@"%ld", (long)intMilSec], @"visited_time", nil];
            }
            
            notification.alertBody = [NSString stringWithFormat:@"Find Entity  %@, distance is %@, visited time is %ld", _entity.EN_SNAME, _entity.EN_SDISTANCE , (long)intTime];
            
            //break;
        }
        
        [dataArray addObject:dictionary];
    }
    
    // To write data to plist
    
    if (isSuccessed) {
        [dataArray writeToFile:root atomically:YES];
    }
    
    if (isSuccessed) {
        NSLog(@" file path ---- \n%@", root);
    }
    
    // --------------------------------
    
    if (_entity != nil) {
//        if (isSuccessed) {
//            notification.alertBody = [NSString stringWithFormat:@"Welcome to %@! There are %ld upcoming events here! distance  %@", _entity.EN_SNAME, (long)_entity.m_intEventsCount, _entity.EN_SDISTANCE ];
//        } else {
//            notification.alertBody = [NSString stringWithFormat:@"Already Visited %@! distance is %@", _entity.EN_SNAME, _entity.EN_SDISTANCE ];
//        }
        
    } else {
        notification.alertBody = [NSString stringWithFormat:@"There is no entity around of you." ];
    }
    
    //notification.alertAction = @"View";
    //notification.soundName = @"2015_best_sound.mp3";
    //notification.applicationIconBadgeNumber ++;
    //notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (NSDate*)getRemindDate:(NSInteger)_beforeDate
{
    NSTimeInterval milSec = [[NSDate date] timeIntervalSince1970];
    
    NSDate* date = [NSDate dateWithTimeIntervalSince1970: milSec];
    
    return date;
}

@end
