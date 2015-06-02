//
//  plaEntity.h
//  Play
//
//  Created by JinLong on 11/18/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface plaEntity : NSObject

@property(nonatomic, retain) NSString* EN_SID;
@property(nonatomic, retain) NSString* EN_SNAME;
@property(nonatomic, retain) NSString* EN_SIMAGE; // ---------------- cover image ----------------
@property(nonatomic, retain) NSString* EN_SIMAGEPROFILE;
@property(nonatomic, retain) NSString* EN_SADDRESSSTR;
@property(nonatomic, retain) NSString* EN_SLOCATIONSTR;
@property(nonatomic, retain) CLLocation* EN_SLOCATION;
@property(nonatomic, retain) NSString* EN_SDISTANCE;
@property(nonatomic, retain) NSString* EN_SCITY;
@property(nonatomic, retain) NSString* EN_SSTATE;
@property(nonatomic, retain) NSString* EN_SSTREET;

@property(nonatomic, retain) NSString* EN_SPHONENUMBER;
@property(nonatomic, retain) NSString* EN_SCATEGORY;

@property(nonatomic, retain) NSString* EN_SFACEBOOKID;

@property(nonatomic, retain) NSString* EN_SNETWORK;

@property(readwrite) NSInteger m_intEventsCount;

@property(readwrite) NSInteger m_intStayTime;

@end
