//
//  plaEvent.h
//  Play
//
//  Created by Darcy Allen on 2014-06-21.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class plaEntity;

@interface plaEvent : NSObject
{
    // instance variables that the plaEvent class has
    
    NSString* EV_SPERSONNAME;
    NSString *EV_SEVENTID;
    NSString *EV_SNAME;
    NSString *EV_SSTARTDATETIME;
    NSString *EV_SLOCATION;
    NSString *EV_SIMAGE;
    
    NSInteger EV_SATTENDCOUNT;
}
@property (strong) NSString* EV_SPERSONNAME;

@property (strong) NSString *EV_SEVENTID;
@property (strong) NSString *EV_SNAME;
@property (strong) NSString *EV_SSTARTDATETIME;
@property (strong) NSString *EV_SENDDATE;

@property (strong) NSString *EV_SLOCATION;
@property (strong) NSString *EV_SADDRESS;
@property (strong) NSString *EV_SCITY;
@property (strong) NSString *EV_SCOUNTRY;
@property (strong) NSString *EV_SSTATE;
@property (strong) NSString *EV_SSTREET;
@property (nonatomic, retain) CLLocation* EV_SLOCATIONADDRESS;

@property (strong) NSString *EV_SIMAGE;
@property (strong) NSString *EV_SDESCRIPTION;
@property (strong) NSString *EV_SDESCRIPTION1;
@property (strong) NSString *EV_STICKETURL;

@property (strong) NSString *EV_SUPCOMMINGUSER;
@property (strong) NSString* EV_SACTIVITYUSER;

@property (nonatomic, readwrite) NSInteger EV_SATTENDFRIENDCOUNT;
@property (nonatomic, readwrite) NSInteger EV_SATTENDCOUNT;
@property (nonatomic, readwrite) NSInteger EV_SFRIENDCOUNT;
@property (nonatomic, readwrite) float EV_SDISTANCE;
@property (nonatomic, readwrite) NSInteger EV_STICKETCOUNT;

@property (nonatomic, readwrite) NSInteger EV_SEVENTSTATE;  //   THIS IS 0 WHEN BE INIT, 1 WHEN BE ATTENDING, -1 WHEN BE UNATTENDING

@property (strong) NSString *EV_SENTITYPAGEID;

@property (nonatomic, retain) plaEntity *EV_SENTITY;

@property (nonatomic, retain) plaEntity *EV_SENTITYARTIST;
@property (nonatomic, retain) NSString *EV_SENTITYARTISTID;
@property (nonatomic, retain) NSMutableArray* EV_SARRAYARTISTS;

@property (nonatomic, retain) plaEntity *EV_SENTITYLOCATION;

@property (nonatomic, retain) NSString* EV_SSORTINGITEM;
@property (nonatomic, retain) NSMutableArray* EV_SUPCOMMINGUSERARRAY;
@property (nonatomic, retain) NSMutableArray* EV_SACTIVITYUSERARRAY;

@property (readwrite) NSInteger EV_SENTITYSTATE; // 1: person entity 2: location
@property (readwrite) NSInteger EV_SEVENTDATE;

@property (nonatomic, retain) NSString* EV_SHASHTAGS;
@property (nonatomic, retain) NSString* EV_SCATEGORY;

@property (nonatomic, retain) NSString* EV_SPRIVACY;

@property (nonatomic, retain) NSString* EV_SUSERID;

@property (readwrite) NSInteger EV_SUSERSNUMBERONFB; // User Number who attend this event on FB
@property (nonatomic, retain) NSMutableArray* EV_SATTENDINGUSERSARRAY;
@property (readwrite) NSInteger EV_SFRIENDNUMBERONFB;// Friend Number who attend this event on FB

@property (nonatomic, retain) NSString* m_strEventType; // 1: susgested For You 2:you are attending 3: popular event 4: top 5 events

// -(id)initWithEvent:(NSString *)sEvent andID:(NSString *)sID  andDate:(NSString *)sDate andLocation:(NSString *)sLocation andImage:(NSString *)sImage;

//-(void)CALUPCOMMINGUSERARRAY:(NSString*)_userid;
//-(void)CALACTIVITYUSERARRAY:(NSString*)_userid;

-(NSInteger)GET_EV_SEVENTSTATE;

@end
