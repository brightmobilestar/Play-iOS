//
//  plaEventData.m
//  Play
//
//  Created by Darcy Allen on 2014-06-29.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaEventData.h"
#import "plaUser.h"
#import "plaAppDelegate.h"

@implementation plaEventData

@synthesize arrayglobFBEvents;
@synthesize arrayglobDBEvents;
@synthesize arrayglobDBEntities;
@synthesize arrayglobDBCreatedEntities;
@synthesize arrayglobDBCreatedEntitiesStatic;
@synthesize arrayglobDBCreatedEntitiesStatic1;
@synthesize arrayglobMyEntities;
@synthesize arrayglobCategories;
@synthesize iglobLoggingOut;
@synthesize nsipEventRow;
@synthesize fglobLatitude;
@synthesize fglobLongitude;
@synthesize sglobUserID;
@synthesize sglobUsername;
@synthesize sglobCityLocation;
@synthesize sglobEmailAddress;
@synthesize sglobFBProfileImageURL;
@synthesize iglobEventRow;
@synthesize sglobLocation;
@synthesize sglobCity;
@synthesize sglobCountry;
@synthesize sglobState;
@synthesize sglobStreet;
@synthesize sglobControllerIndex;
@synthesize m_currentController;
@synthesize sglobNearestEntity;

static plaEventData *instance = nil;

+(plaEventData *)getInstance
{
    @synchronized( self )
         {
         if ( instance == nil )
             {
             instance = [plaEventData new];
             }
         }
	return( instance );
}

-(BOOL)isDataLoaded
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    NSString* strStatus = [prefs objectForKey:@"isDataLoaded"];
    if ([strStatus isEqualToString:@"end"]) {
        return true;
    }
    
    return false;
}

-(void)startDataLoad
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    [prefs setObject:@"start" forKey:@"isDataLoaded"];
}

-(void)endDataLoad
{
    NSUserDefaults* prefs = [[NSUserDefaults alloc] initWithSuiteName:@"ios.app.playentertainment"];
    
    float deviceVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (deviceVersion < 8.0) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    
    [prefs setObject:@"end" forKey:@"isDataLoaded"];
}

- (NSString*) convertDateType:(NSString*)_date
{
    if ([_date isEqualToString:@""]) {
        return @"";
    }
    
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
//    NSArray* arrayWeekday = @[@"", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSString* strTemp, *temp1, *temp2Month;
    NSArray* arrayTemp1, *arrayTemp2;
    arrayTemp1 = [_date componentsSeparatedByString:@"T"];
    temp1 = (NSString*)[arrayTemp1 objectAtIndex:0];
    //temp3Time = (NSString*)[arrayTemp1 objectAtIndex:1];
    arrayTemp2 = [temp1 componentsSeparatedByString:@"-"];
    temp2Month = (NSString*)[arrayTemp2 objectAtIndex:1];
    NSInteger intTemp = temp2Month.integerValue;
    
    temp2Month = [arrayMonth objectAtIndex:intTemp];
    
    NSString* m_strDateDay = [arrayTemp2 objectAtIndex:2];
    if ([m_strDateDay isEqualToString:@"1"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@st", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"2"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@nd", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"3"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@rd", m_strDateDay];
    } else {
        m_strDateDay = [NSString stringWithFormat:@"%@th", m_strDateDay];
    }
    
    // -----   to get weekday from date  ---------
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    
    [nowComponents setYear:[[arrayTemp2 objectAtIndex:0] intValue]];
    [nowComponents setMonth:[[arrayTemp2 objectAtIndex:1] intValue]];
    [nowComponents setDay:[[arrayTemp2 objectAtIndex:2] intValue]];
    
    //NSDate *beginningOfWeek = [gregorian dateFromComponents:nowComponents];
    
    // NSCalendar* cal = [NSCalendar currentCalendar];
    //NSDateComponents* comp = [cal components:NSWeekdayCalendarUnit fromDate:beginningOfWeek];
    //long weekday = [comp weekday];
    
    //    strTemp = [NSString stringWithFormat:@"%@ %@ %@, %@", [arrayWeekday objectAtIndex:weekday], temp2Month, [arrayTemp2 objectAtIndex:2], [arrayTemp2 objectAtIndex:0]];
    strTemp = [NSString stringWithFormat:@"%@ %@, %@", temp2Month, [arrayTemp2 objectAtIndex:2], [arrayTemp2 objectAtIndex:0]];
    
    return strTemp;
}

-(NSString*) getWeekday:(NSString*)_date
{
    if ([_date isEqualToString:@""]) {
        return @"";
    }
    
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    NSArray* arrayWeekday = @[@"", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSString* strTemp, *temp1, *temp2Month;
    NSArray* arrayTemp1, *arrayTemp2;
    arrayTemp1 = [_date componentsSeparatedByString:@"T"];
    temp1 = (NSString*)[arrayTemp1 objectAtIndex:0];
    //temp3Time = (NSString*)[arrayTemp1 objectAtIndex:1];
    arrayTemp2 = [temp1 componentsSeparatedByString:@"-"];
    temp2Month = (NSString*)[arrayTemp2 objectAtIndex:1];
    NSInteger intTemp = temp2Month.integerValue;
    
    temp2Month = [arrayMonth objectAtIndex:intTemp];
    
    NSString* m_strDateDay = [arrayTemp2 objectAtIndex:2];
    if ([m_strDateDay isEqualToString:@"1"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@st", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"2"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@nd", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"3"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@rd", m_strDateDay];
    } else {
        m_strDateDay = [NSString stringWithFormat:@"%@th", m_strDateDay];
    }
    
    // -----   to get weekday from date  ---------
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    
    [nowComponents setYear:[[arrayTemp2 objectAtIndex:0] intValue]];
    [nowComponents setMonth:[[arrayTemp2 objectAtIndex:1] intValue]];
    [nowComponents setDay:[[arrayTemp2 objectAtIndex:2] intValue]];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:nowComponents];
    
     NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSWeekdayCalendarUnit fromDate:beginningOfWeek];
    long weekday = [comp weekday];
    
    strTemp = [arrayWeekday objectAtIndex:weekday];
    //[NSString stringWithFormat:@"%@ %@ %@, %@", , temp2Month, [arrayTemp2 objectAtIndex:2], [arrayTemp2 objectAtIndex:0]];

    return strTemp;
}

-(NSString*) getDay:(NSString*)_date
{
    if ([_date isEqualToString:@""]) {
        return @"";
    }
    
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];

    NSString* temp1, *temp2Month;
    NSArray* arrayTemp1, *arrayTemp2;
    arrayTemp1 = [_date componentsSeparatedByString:@"T"];
    temp1 = (NSString*)[arrayTemp1 objectAtIndex:0];
    //temp3Time = (NSString*)[arrayTemp1 objectAtIndex:1];
    arrayTemp2 = [temp1 componentsSeparatedByString:@"-"];
    temp2Month = (NSString*)[arrayTemp2 objectAtIndex:1];
    NSInteger intTemp = temp2Month.integerValue;
    
    temp2Month = [arrayMonth objectAtIndex:intTemp];
    
    NSString* m_strDateDay = [arrayTemp2 objectAtIndex:2];
    
    
    return m_strDateDay;
}

-(NSString*) getMonth:(NSString*)_date
{
    if ([_date isEqualToString:@""]) {
        return @"";
    }
    
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];

    NSString *temp1, *temp2Month;
    NSArray* arrayTemp1, *arrayTemp2;
    arrayTemp1 = [_date componentsSeparatedByString:@"T"];
    temp1 = (NSString*)[arrayTemp1 objectAtIndex:0];
    //temp3Time = (NSString*)[arrayTemp1 objectAtIndex:1];
    arrayTemp2 = [temp1 componentsSeparatedByString:@"-"];
    temp2Month = (NSString*)[arrayTemp2 objectAtIndex:1];
    NSInteger intTemp = temp2Month.integerValue;
    
    temp2Month = [arrayMonth objectAtIndex:intTemp];
    
    return temp2Month;
}

-(NSMutableArray*) getFriendList
{
    NSMutableArray* _array = [[NSMutableArray alloc] init];
    
    plaEventData* globData = [plaEventData getInstance];
    // ------- To get Main User Info ----------
    plaUser* m_MainUser;
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
            [_array addObject:userModel];
        }
    }
    
    return _array;
}

-(void)setEnableVPNotification:(BOOL)_bool
{
    NSUserDefaults* _userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"Playentertainment"];
    
    float floatVerson = [[[UIDevice currentDevice ] systemVersion] floatValue];
    if (floatVerson < 8.0) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    
    if (_bool) {
        [_userDefault setObject:@"true" forKey:@"visitPalceNotification"];
    } else {
        [_userDefault setObject:@"false" forKey:@"visitPalceNotification"];
    }
}

-(BOOL)isEnableVPNotification
{
    NSUserDefaults* _userDefault = [[NSUserDefaults alloc] initWithSuiteName:@"Playentertainment"];
    
    float floatVerson = [[[UIDevice currentDevice ] systemVersion] floatValue];
    if (floatVerson < 8.0) {
        _userDefault = [NSUserDefaults standardUserDefaults];
    }
    
    NSString* _str = [_userDefault stringForKey:@"visitPalceNotification"];
    
    if (_str == nil) {
        [self setEnableVPNotification:true];
    } else if ([_str isEqualToString:@"true"]) {
        return true;
    } else {
        return false;
    }
    
    return true;
}

@end
