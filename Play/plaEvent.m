//
//  plaEvent.m
//  Play
//
//  Created by Darcy Allen on 2014-06-21.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaEvent.h"
#import "plaEventData.h"
#import "plaEntity.h"


@implementation plaEvent

@synthesize EV_SPERSONNAME;

@synthesize EV_SEVENTID;
@synthesize EV_SNAME;
@synthesize EV_SSTARTDATETIME;
@synthesize EV_SLOCATION;
@synthesize EV_SADDRESS, EV_SCOUNTRY, EV_SCITY, EV_SLOCATIONADDRESS;
@synthesize EV_SIMAGE;

@synthesize EV_SUPCOMMINGUSER, EV_SACTIVITYUSER;

@synthesize EV_SATTENDFRIENDCOUNT;
@synthesize EV_SATTENDCOUNT, EV_SDISTANCE, EV_SENDDATE, EV_SFRIENDCOUNT, EV_STICKETCOUNT;
@synthesize EV_SSTATE, EV_SSTREET;
@synthesize EV_SDESCRIPTION, EV_STICKETURL;
@synthesize EV_SDESCRIPTION1;
@synthesize EV_SEVENTSTATE;
@synthesize EV_SSORTINGITEM;

@synthesize EV_SENTITYPAGEID, EV_SENTITY, EV_SENTITYLOCATION;
@synthesize EV_SENTITYARTIST, EV_SENTITYARTISTID;

@synthesize EV_SACTIVITYUSERARRAY, EV_SUPCOMMINGUSERARRAY;
@synthesize EV_SEVENTDATE;
@synthesize EV_SARRAYARTISTS;
@synthesize EV_SCATEGORY, EV_SENTITYSTATE, EV_SHASHTAGS;
@synthesize EV_SPRIVACY, EV_SUSERID;

@synthesize EV_SATTENDINGUSERSARRAY;
@synthesize EV_SUSERSNUMBERONFB;
@synthesize EV_SFRIENDNUMBERONFB;

@synthesize m_strEventType;

/*
to bring this back, put the ID first:
-(id)initWithEvent:(NSString *)sEvent andID:(NSString *)sID  andDate:(NSString *)sDate andLocation:(NSString *)sLocation andImage:(NSString *)sImage
{
    self = [super init];
    if (self)
    {
        EV_SNAME = sEvent;
        EV_SEVENTID = sID;
        EV_SSTARTDATETIME = sDate;
        EV_SLOCATION = sLocation;
        EV_SIMAGE = sImage;
    }

    return self;
}
*/

//-(id)init
//{
//    self = (plaEvent*)[[NSObject alloc] init];
//    
//    self.EV_SEVENTSTATE = 0;
//    
//    return self;
//}

-(void)CALUPCOMMINGUSERARRAY:(NSString*)_userid
{
    if ([self.EV_SACTIVITYUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [self.EV_SACTIVITYUSERARRAY removeObject:_userid];
    }
    [self.EV_SUPCOMMINGUSERARRAY addObject:_userid];
    
    if ([self.EV_SUPCOMMINGUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [self.EV_SUPCOMMINGUSERARRAY removeObject:_userid];
    }
    [self.EV_SACTIVITYUSERARRAY addObject:_userid];
}

-(void)CALACTIVITYUSERARRAY:(NSString*)_userid
{
//    if ([self.EV_SACTIVITYUSERARRAY indexOfObject:_userid] != NSNotFound) {
//        [self.EV_SACTIVITYUSERARRAY removeObject:_userid];
//    }
//    [self.EV_SUPCOMMINGUSERARRAY addObject:_userid];
    
    if ([self.EV_SUPCOMMINGUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [self.EV_SUPCOMMINGUSERARRAY removeObject:_userid];
    }
    [self.EV_SACTIVITYUSERARRAY addObject:_userid];
}

-(NSInteger)GET_EV_SEVENTSTATE //   THIS IS 0 WHEN BE INIT, 1 WHEN BE ATTENDING, -1 WHEN BE UNATTENDING
{
    plaEventData* globData = [plaEventData getInstance];
    if ([self.EV_SUPCOMMINGUSERARRAY indexOfObject:globData.sglobUserID] != NSNotFound) {
        self.EV_SEVENTSTATE = 1;
    } else if([self.EV_SACTIVITYUSERARRAY indexOfObject:globData.sglobUserID] != NSNotFound) {
        self.EV_SEVENTSTATE = -1;
    } else {
        self.EV_SEVENTSTATE = 0;
    }
    return self.EV_SEVENTSTATE;
}

@end
