//
//  plaEventData.h
//  Play
//
//  Created by Darcy Allen on 2014-06-22.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class plaEntity;

@interface plaEventData : NSObject
{
    // thread safe and memory safe singleton pattern global variables
    NSMutableArray *arrayglobFBEvents;
    NSMutableArray *arrayglobDBEvents;
    NSInteger iglobLoggingOut;  // 10=not Logging Out, 20 = Logging Out
    NSIndexPath *nsipEventRow;  // the event tapped on to bring up its detail page
    float fglobLatitude;
    float fglobLongitude;
    NSString *sglobUsername;
    NSString *sglobCityLocation;
    NSString *sglobEmailAddress;
    NSString *sglobFBProfileImageURL;
}

@property( nonatomic, strong )NSMutableArray *arrayglobFBEvents;
@property( nonatomic, strong )NSMutableArray *arrayglobDBEvents;
@property( nonatomic, strong )NSMutableArray *arrayglobDBEntities;
@property( nonatomic, strong) NSMutableArray* arrayglobDBCreatedEntities; // array for entity that is created on this app
@property( nonatomic, strong) NSMutableArray* arrayglobDBCreatedEntitiesStatic;
@property( nonatomic, strong) NSMutableArray* arrayglobDBCreatedEntitiesStatic1;
@property( nonatomic, strong) NSMutableArray* arrayglobMyEntities;
@property( nonatomic, strong) NSMutableArray* arrayglobCategories;
@property( nonatomic )NSInteger iglobLoggingOut;
@property( nonatomic )NSIndexPath *nsipEventRow;

@property( nonatomic, retain) plaEntity* sglobNearestEntity;

@property( nonatomic )float fglobLatitude;
@property( nonatomic )float fglobLongitude;
@property( nonatomic, strong )NSString *sglobUserID;
@property( nonatomic, strong )NSString *sglobUsername;
@property( nonatomic, strong )NSString *sglobCityLocation;
@property( nonatomic, strong )NSString *sglobEmailAddress;
@property( nonatomic, strong )NSString *sglobFBProfileImageURL;

@property( nonatomic, readwrite) NSInteger iglobEventRow;

// ---- extension for location infomation
@property( nonatomic, retain) CLLocation* sglobLocation;
@property( nonatomic, retain) NSString* sglobCity;
@property( nonatomic, retain) NSString* sglobStreet;
@property( nonatomic, retain) NSString* sglobState;
@property( nonatomic, retain) NSString* sglobCountry;

// ----- to recognize what current controller is.
@property(readwrite) NSInteger sglobControllerIndex; // = 1 : homeviewcontroller
                                                     // = 2 : eventdetail view controller
@property(nonatomic, retain) NSString* m_currentController;

+(plaEventData*)getInstance;

-(BOOL)isDataLoaded;
-(void)startDataLoad;
-(void)endDataLoad;

-(NSString*) convertDateType:(NSString*)_date;
-(NSString*) getWeekday:(NSString*)_date;
-(NSString*) getDay:(NSString*)_date;
-(NSString*) getMonth:(NSString*)_date;
-(NSMutableArray*) getFriendList;

-(void)setEnableVPNotification:(BOOL)_bool;
-(BOOL)isEnableVPNotification;

@end
