//
//  plaWebServices.m
//  Play
//
//  Created by Darcy Allen on 2014-10-01.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "plaWebServices.h"

#import "plaEvent.h"
#import "plaEntity.h"
#import "plaUser.h"
#import "plaMail.h"
#import "plaVisitPlace.h"
#import "plaEventData.h"
#import "plaDB.h"
#import "plaViewController.h"
#import "plaHomeViewController.h"
#import "plaEntityPageViewController.h"
#import "plaAppDelegate.h"
#import "plaFeedModel.h"

@implementation plaWebServices

// @synthesize sResource;
// @synthesize sQueryParms;

/**
* backgroundReadEvents
*
* parm: none
* return: the Information System Server Build Number, integer, incremented by 1 with each server change. For internal logging only.
*/
- (NSMutableArray*)backgroundReadEventsAll
{
    [self backgroundReadEntityAll];
    [self backgroundReadVisitPlaceAll];
    //[self backgroundReadUserAll];
    
    NSMutableArray* array = [[NSMutableArray alloc] init];
    NSMutableArray* arrayTemp = [[NSMutableArray alloc] init];
    NSMutableArray* arrayTempUser = [[NSMutableArray alloc] init];
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_id.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [json objectForKey: @"TBLEVENT"];
        
        plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            
            plaEvent* eventTemp = [[plaEvent alloc] init];
            
            NSString* strID = [eventObj valueForKey:@"EV_SEVENTID"];
            [array addObject:strID];
            
            //------------ get all event data ----------------
            eventTemp.EV_SEVENTID = strID;
            eventTemp.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            eventTemp.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            eventTemp.EV_SCATEGORY = [eventObj valueForKey:@"EV_SCATEGORY"];
            
            eventTemp.EV_SIMAGE = [self JSONString:eventTemp.EV_SIMAGE];
            
            [g_arrayAllEventData addObject:eventTemp];
            [g_controllerView makeRequestForEventAttendingNum:eventTemp];
            
            [g_controllerViewHome refreshTableView];
            
            // ----------- get User Info --------------------
            
            strID = [eventObj valueForKey:@"EV_SUSERID"];
            if ( (![arrayTempUser containsObject:strID]) && (![strID isEqualToString:@""]) ) {
                [arrayTempUser addObject:strID];
                //[g_controllerView makeRequestForUserInfo:strID];
            }
            // ----------- get entity id ---------------------
            strID = [eventObj valueForKey:@"EV_SENTITYID"];
            if ([strID isEqualToString:@"115811875115972"]) {
                //
                
            }
            if (strID != nil) {
                if (![self isContainString:arrayTemp sec:strID]) {
                    [arrayTemp addObject:strID];
                    [g_controllerView getEntityPageInfo:strID];
                }
            }
            
            strID = [eventObj valueForKey:@"EV_SENTITYARTISTID"]; //
            if (strID != nil) {
                if (![self isContainString:arrayTemp sec:strID]) {
                    [arrayTemp addObject:strID];
                    [g_controllerView getEntityPageInfo:strID];
                }
            }
            //
            strID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            if (strID != nil) {
                if (![self isContainString:arrayTemp sec:strID]) {
                    [arrayTemp addObject:strID];
                    [g_controllerView getEntityPageInfo:strID];
                }
            }
        }    // end for
        NSLog( @"Events now in arrayglobDBEvents in-mem db = %d",  (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    [self backgroundReadEvents:0 sec:10000];
    
    return(  array  );
}

- (BOOL)isContainString:(NSMutableArray*)array sec:(NSString*)_str
{    
    for (int i = 0; i < [array count]; i ++) {
        NSString* strTemp = [array objectAtIndex:i];
        if ([_str isEqualToString:strTemp]) {
            return true;
        }
    }
    return false;
}

-(NSString *)replaceWhitesSpace:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@" " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

-(NSString *)replaceWhitesSpaceForPersonName:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@" " withString:@"%20" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

-(NSString *)replaceToWhitesSpace:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    [s replaceOccurrencesOfString:@"%20" withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

- (plaEntity*)getEntityFromID:(plaEntity*)_entity
{
    NSString* _fbID = _entity.EN_SID;
    
    plaEntity* returnEntity;
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBCreatedEntitiesStatic count]; i++) {
        plaEntity* entity = [globData.arrayglobDBCreatedEntitiesStatic objectAtIndex:i];
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
            
            _entity.EN_SFACEBOOKID = entity.EN_SFACEBOOKID;
            
            break;
        }
    }
    return returnEntity;
}

- (NSInteger)backgroundReadEventsByLocation:(plaEntity*)personName sec:(plaViewController*)_controller third:(plaEntityPageViewController*)_rootCtrl
{
    [self getEntityFromID:personName];
    int iReturn = 0;
    NSString* strToday = [self getTodayDate];
    
    NSString* strPersonName = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    
    NSString* strLocation = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    if ([personName.EN_SNAME isEqualToString:@"Calgary, Alberta"]) {
        strLocation = @"Calgary";
    }
    NSString* strArtistID = [self replaceWhitesSpace:personName.EN_SID];
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_location.php?location=%@&personName=%@&artistID=%@&strToday=%@", strLocation, strPersonName, strArtistID, strToday];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        //plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        if ([responseA count] == 0) {
            [_rootCtrl refreshTableView];
        }
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];

            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            iReturn++;

            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            strTemp = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            if ([strTemp isEqualToString:@"(null)"]) {
                strTemp = @"";
            }
            parsedEvent.EV_SENTITYARTIST.EN_SID = strTemp;
            parsedEvent.EV_SENTITYARTISTID = strTemp;
            
            parsedEvent.EV_SHASHTAGS = [eventObj valueForKey:@"EV_SENTITYHASHTAGS"];
            parsedEvent.EV_SCATEGORY = [eventObj valueForKey:@"EV_SENTITYCATEGORY"];
            
            strTemp = [eventObj valueForKey:@"EV_SUSERID"];
            parsedEvent.EV_SUSERID = strTemp;
            
            if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location == NSNotFound) {
                strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION"];
                parsedEvent.EV_SDESCRIPTION = strTemp;
                
                [_controller makeRequestForUserEvent:parsedEvent third:_rootCtrl];
            } else {
                [_rootCtrl makeSortingItem:parsedEvent];
                
                [_rootCtrl addEventToTableData:parsedEvent];
                [_rootCtrl refreshTableView];
            }
            
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    if (iReturn == 0) {
        //[_rootCtrl hideLoadingActivityView];
    }
    return(  iReturn  );
    
}

- (NSInteger)backgroundReadEventsByHostedName:(plaEntity*)personName sec:(plaViewController*)_controller third:(plaEntityPageViewController*)_rootCtrl
{
    int iReturn = 0;
    
    NSString* strPersonName = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    NSString* strLocation = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    NSString* strArtistID = [self replaceWhitesSpace:personName.EN_SID];
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_location.php?location=%@&personName=%@&artistID=%@", strLocation, strPersonName, strArtistID];

    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        if ([responseA count] == 0) {
            [_rootCtrl refreshTableView];
        }
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];

            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            iReturn++;
            
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYARTIST.EN_SID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            parsedEvent.EV_SENTITYARTISTID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            
            if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location == NSNotFound) {
                strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION"];
                parsedEvent.EV_SDESCRIPTION = strTemp;
                
                [_controller makeRequestForUserEvent:parsedEvent third:_rootCtrl];
            } else {
                [_rootCtrl makeSortingItem:parsedEvent];
                
                [_rootCtrl addEventToTableData:parsedEvent];
                [_rootCtrl refreshTableView];
            }
            //[m_viewController getEntityPageInfo:m_event.EV_SENTITY.EN_SID];
            
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    if (iReturn == 0) {
        //[_rootCtrl hideLoadingActivityView];
    }
    return(  iReturn  );
    
}

- (NSInteger)backgroundReadEventsByArtist:(plaEntity*)personName sec:(plaViewController*)_controller third:(plaEntityPageViewController*)_rootCtrl
{
    int iReturn = 0;
    
    NSString* strPersonName = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    NSString* strLocation = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    NSString* strArtistID = [self replaceWhitesSpace:personName.EN_SID];
    
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_location.php?location=%@&personName=%@&artistID=%@", strLocation, strPersonName, strArtistID];

    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        //plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        if ([responseA count] == 0) {
            [_rootCtrl refreshTableView];
        }
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];

            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            iReturn++;
            
            //m_event = parsedEvent;
            //m_viewController = _controller;
            //m_viewControllerHome = _rootCtrl;
            
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYARTIST.EN_SID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            parsedEvent.EV_SENTITYARTISTID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            
            if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location == NSNotFound) {
                strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION"];
                parsedEvent.EV_SDESCRIPTION = strTemp;
                
                [_controller makeRequestForUserEvent:parsedEvent third:_rootCtrl];
            } else {
                [_rootCtrl makeSortingItem:parsedEvent];
                
                [_rootCtrl addEventToTableData:parsedEvent];
                [_rootCtrl refreshTableView];
            }
            //[m_viewController getEntityPageInfo:m_event.EV_SENTITY.EN_SID];
            
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    if (iReturn == 0) {
        //[_rootCtrl hideLoadingActivityView];
    }
    return(  iReturn  );
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

- (NSInteger)backgroundReadEvents:(NSInteger)_startNum sec:(NSInteger)_endNum third:(plaViewController*)_controller fourth:(plaHomeViewController *)_rootCtrl
{
    m_viewController = _controller;
    m_viewControllerHome = _rootCtrl;
    
    plaEventData* globData = [plaEventData getInstance];
    
    NSString* strCurrentCategory;
    if (m_currentCategory == 0) {
        strCurrentCategory = @"";
    } else if (m_currentCategory > 0) {
        strCurrentCategory = [globData.arrayglobCategories objectAtIndex:m_currentCategory - 1];
    }
    
    strCurrentCategory = [self JSONStringOposite:strCurrentCategory];
    strCurrentCategory = [self replaceWhitesSpaceForPersonName:strCurrentCategory];
    
    NSString* location = [NSString stringWithFormat:@"%@,%@", [self replaceWhitesSpace:globData.sglobCity], [self replaceWhitesSpace:globData.sglobState]];
    NSArray* array = [_rootCtrl.m_lblBGNetwork.text componentsSeparatedByString:@", "];
    location = [NSString stringWithFormat:@"%@,%@", [array objectAtIndex:0], [array objectAtIndex:1]];
    if ([[array objectAtIndex:0] isEqualToString:[array objectAtIndex:1]]) {
        location = [NSString stringWithFormat:@"%@,(null)", [array objectAtIndex:0]];
    }
    location = [self replaceWhitesSpaceForPersonName:location];
    
    //location = @"Calgary,AB";
    
    int iReturn = 0;
    
    NSString* strToday = [self getTodayDate];
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0.php?startNum=%ld&endNum=%ld&network=%@&description=description&type=%ld&userID=%@&category=%@&strToday=%@", (long)_startNum, (long)_endNum, location, (long)m_intTableDataType, globData.sglobUserID, strCurrentCategory, strToday];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        //plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];
            
            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            
            strTemp = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            if ([strTemp isEqualToString:@"(null)"]) {
                strTemp = @"";
            }
            parsedEvent.EV_SENTITYARTIST.EN_SID = strTemp;
            parsedEvent.EV_SENTITYARTISTID = strTemp;
            
            parsedEvent.EV_SHASHTAGS = [eventObj valueForKey:@"EV_SHASHTAGS"];
            parsedEvent.EV_SCATEGORY = [eventObj valueForKey:@"EV_SCATEGORY"];
            parsedEvent.EV_SCATEGORY = [self JSONString:parsedEvent.EV_SCATEGORY];
            
            strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            parsedEvent.EV_SDESCRIPTION = strTemp;
            
            strTemp = [eventObj valueForKey:@"EV_SUSERID"];
            parsedEvent.EV_SUSERID = strTemp;
            
            switch (m_intTableDataType) {
                    
                case 2:
                    if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
                        [g_arrayActivityFeedData addObject:parsedEvent];
                        [_rootCtrl refreshTableView];
                    } else {
                        m_event = parsedEvent;
                        [self makeRequestForUserEvent];
                    }
                    break;
                    
                case 3:
                    if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
                        [g_arrayUpcommingEventData addObject:parsedEvent];
                        [_rootCtrl refreshTableView];
                    } else {
                        m_event = parsedEvent;
                        [self makeRequestForUserEvent];
                    }
                    break;
                    
                default:
                    if (m_currentCategory > 0) {
                        if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
                            [g_arraySelectedCategoryEventsData addObject:parsedEvent];
                            [_rootCtrl refreshTableView];
                        } else {
                            m_event = parsedEvent;
                            [self makeRequestForUserEvent];
                        }
                    } else {
                        if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
                            [globData.arrayglobDBEvents addObject:parsedEvent];
                        } else {
                            m_event = parsedEvent;
                            [self makeRequestForUserEvent];
                        }
                        
                    }
                    break;
            }
            
            iReturn++;
            //            [self performSelector:@selector(makeRequestForUserEvent) withObject:nil afterDelay:0.0001f];
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    if (iReturn == 0) {
        [_rootCtrl hideLoadingActivityView];
    }
    return(  iReturn  );
    
}

- (plaEvent*) cloneEvent:(plaEvent*)eventObj
{
    plaEvent *parsedEvent = [[plaEvent alloc] init];
    
    /* then we dig deeper into the JSON asking for the value for each known key
     */
    parsedEvent.EV_SNAME = eventObj.EV_SNAME;
    parsedEvent.EV_SEVENTID = eventObj.EV_SEVENTID;
    parsedEvent.EV_SPERSONNAME = eventObj.EV_SPERSONNAME;
    parsedEvent.EV_SSTARTDATETIME = eventObj.EV_SSTARTDATETIME;
    
    parsedEvent.EV_SEVENTDATE = eventObj.EV_SEVENTDATE;
    
    parsedEvent.EV_SENDDATE = eventObj.EV_SENDDATE;
    parsedEvent.EV_SLOCATION = eventObj.EV_SLOCATION;
    parsedEvent.EV_SUPCOMMINGUSER = eventObj.EV_SUPCOMMINGUSER;
    parsedEvent.EV_SACTIVITYUSER = eventObj.EV_SACTIVITYUSER;
    parsedEvent.EV_SENTITYPAGEID = eventObj.EV_SENTITYPAGEID;
    parsedEvent.EV_SENTITY = eventObj.EV_SENTITY;
    
    parsedEvent.EV_SUPCOMMINGUSERARRAY = eventObj.EV_SUPCOMMINGUSERARRAY;
    parsedEvent.EV_SACTIVITYUSERARRAY = eventObj.EV_SACTIVITYUSERARRAY;
    parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
    parsedEvent.EV_SIMAGE = eventObj.EV_SIMAGE;
    
    parsedEvent.EV_STICKETURL = eventObj.EV_STICKETURL;
    parsedEvent.EV_SDESCRIPTION = eventObj.EV_SDESCRIPTION;
    
    parsedEvent.EV_SATTENDCOUNT = eventObj.EV_SATTENDCOUNT;
    
    parsedEvent.EV_SFRIENDCOUNT = eventObj.EV_SFRIENDCOUNT;
    
    parsedEvent.EV_SDISTANCE = eventObj.EV_SDISTANCE;
    
    parsedEvent.EV_STICKETCOUNT = eventObj.EV_STICKETCOUNT;
    
    parsedEvent.EV_SENTITYLOCATION = eventObj.EV_SENTITYLOCATION;
    
    parsedEvent.EV_SENTITYARTIST  = eventObj.EV_SENTITYARTIST;
    
    parsedEvent.EV_SENTITYARTISTID = eventObj.EV_SENTITYARTISTID;
    
    parsedEvent.EV_SHASHTAGS = eventObj.EV_SHASHTAGS;
    parsedEvent.EV_SCATEGORY = eventObj.EV_SCATEGORY;
    parsedEvent.EV_SCATEGORY = eventObj.EV_SCATEGORY;
    
    parsedEvent.EV_SUSERID = eventObj.EV_SUSERID;
    
    return parsedEvent;
}

//- (NSInteger)backgroundReadEvents:(NSInteger)_startNum sec:(NSInteger)_endNum third:(plaViewController*)_controller fourth:(plaHomeViewController *)_rootCtrl
//{
//    m_viewController = _controller;
//    m_viewControllerHome = _rootCtrl;
//    
//    plaEventData* globData = [plaEventData getInstance];
//    
//    NSString* strCurrentCategory;
//    if (m_currentCategory == 0) {
//        strCurrentCategory = @"";
//    } else if (m_currentCategory > 0) {
//        strCurrentCategory = [globData.arrayglobCategories objectAtIndex:m_currentCategory - 1];
//    }
//    
//    strCurrentCategory = [self JSONStringOposite:strCurrentCategory];
//    strCurrentCategory = [self replaceWhitesSpaceForPersonName:strCurrentCategory];
//    
//    NSString* location = [NSString stringWithFormat:@"%@,%@", [self replaceWhitesSpace:globData.sglobCity], [self replaceWhitesSpace:globData.sglobState]];
//    NSArray* array = [_rootCtrl.m_lblBGNetwork.text componentsSeparatedByString:@", "];
//    location = [NSString stringWithFormat:@"%@,%@", [array objectAtIndex:0], [array objectAtIndex:1]];
//    if ([[array objectAtIndex:0] isEqualToString:[array objectAtIndex:1]]) {
//        location = [NSString stringWithFormat:@"%@,(null)", [array objectAtIndex:0]];
//    }
//    location = [self replaceWhitesSpaceForPersonName:location];
//    
//    //location = @"Calgary,AB";
//    
//    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
//    
//    NSString* strTodayDate = [g_controllerViewHome getTodayDate];
//    NSError * error = nil;
//
//    if ( error == nil )
//    {
//        //plaEventData *globEvents = [plaEventData getInstance];
//        
//        // initialize the DB list of events
//        
//        for ( NSInteger i = 0; i < [g_arrayAllEventData count]; i ++ ) //
//        {
//            plaEvent *eventObj = [g_arrayAllEventData objectAtIndex:i];
//            
//            if ([eventObj.EV_SLOCATION containsString:@"(null)"] || [eventObj.EV_SDESCRIPTION1 containsString:@"(null)"]) continue;
//            
//            if ([eventObj.EV_SSTARTDATETIME compare:strTodayDate] == NSOrderedAscending)  continue;
//            
//            // create space in-mem to hold this event
//            
//            plaEvent* parsedEvent = [self cloneEvent:eventObj];
//            
//            switch (m_intTableDataType) {
//                    
//                case 2:
//                    if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
//                        [g_arrayActivityFeedData addObject:parsedEvent];
//                        [_rootCtrl refreshTableView];
//                    } else {
//                        m_event = parsedEvent;
//                        [self makeRequestForUserEvent];
//                    }
//                    break;
//                    
//                case 3:
//                    if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
//                        [g_arrayUpcommingEventData addObject:parsedEvent];
//                        [_rootCtrl refreshTableView];
//                    } else {
//                        m_event = parsedEvent;
//                        [self makeRequestForUserEvent];
//                    }
//                    break;
//                    
//                default:
//                    if (m_currentCategory > 0) {
//                        if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
//                            [g_arraySelectedCategoryEventsData addObject:parsedEvent];
//                            [_rootCtrl refreshTableView];
//                        } else {
//                            m_event = parsedEvent;
//                            [self makeRequestForUserEvent];
//                        }
//                    } else {
//                        if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
//                            [globData.arrayglobDBEvents addObject:parsedEvent];
//                        } else {
//                            m_event = parsedEvent;
//                            [self makeRequestForUserEvent];
//                        }
//                        
//                    }
//                    break;
//            }
//            
//            //            [self performSelector:@selector(makeRequestForUserEvent) withObject:nil afterDelay:0.0001f];
//        }    // end for
//        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
//    }   // end if no error
//
//    
//
//    return 0;
//    
//}

- (NSInteger)backgroundReadEvents:(NSInteger)_startNum sec:(NSInteger)_endNum
{
    [g_arrayAllEventData removeAllObjects];
    
    plaEventData* globData = [plaEventData getInstance];
    
    NSString* strCurrentCategory;
    if (m_currentCategory == 0) {
        strCurrentCategory = @"";
    } else if (m_currentCategory > 0) {
        strCurrentCategory = [globData.arrayglobCategories objectAtIndex:m_currentCategory - 1];
    }
    strCurrentCategory = [self JSONStringOposite:strCurrentCategory];
    strCurrentCategory = [self replaceWhitesSpaceForPersonName:strCurrentCategory];
    
    NSString* location;
    
    location = @""; // ominisearch
    
    int iReturn = 0;
    
    NSString* strToday =  @"2014-12-20-T00:00:00"; //[self getTodayDate];
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0.php?startNum=%ld&endNum=%ld&network=%@&description=description&type=%ld&userID=%@&category=%@&strToday=%@", (long)_startNum, (long)_endNum, location, (long)m_intTableDataType, globData.sglobUserID, strCurrentCategory, strToday];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        //plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];
            
            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            
            strTemp = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            if ([strTemp isEqualToString:@"(null)"]) {
                strTemp = @"";
            }
            parsedEvent.EV_SENTITYARTIST.EN_SID = strTemp;
            parsedEvent.EV_SENTITYARTISTID = strTemp;
            
            parsedEvent.EV_SHASHTAGS = [eventObj valueForKey:@"EV_SHASHTAGS"];
            parsedEvent.EV_SCATEGORY = [eventObj valueForKey:@"EV_SCATEGORY"];
            parsedEvent.EV_SCATEGORY = [self JSONString:parsedEvent.EV_SCATEGORY];
            
            strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION1"];
            parsedEvent.EV_SDESCRIPTION1 = strTemp;
            
            strTemp = [eventObj valueForKey:@"EV_SUSERID"];
            parsedEvent.EV_SUSERID = strTemp;
            
            [g_arrayAllEventData addObject:parsedEvent];
            [g_controllerView makeRequestForEventAttendingNum:parsedEvent];
            [g_controllerView makeRequestForEventAttendingUsers:parsedEvent];
            
            iReturn++;
            //            [self performSelector:@selector(makeRequestForUserEvent) withObject:nil afterDelay:0.0001f];
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  iReturn  );
    
}

-(NSInteger)GET_EV_SEVENTSTATE:(plaEvent*)_event //   THIS IS 0 WHEN BE INIT, 1 WHEN BE ATTENDING, -1 WHEN BE UNATTENDING
{
    plaEventData* globData = [plaEventData getInstance];
    if ([_event.EV_SUPCOMMINGUSERARRAY indexOfObject:globData.sglobUserID] != NSNotFound) {
        _event.EV_SEVENTSTATE = 1;
    } else if([_event.EV_SACTIVITYUSERARRAY indexOfObject:globData.sglobUserID] != NSNotFound) {
        _event.EV_SEVENTSTATE = -1;
    } else {
        _event.EV_SEVENTSTATE = 0;
    }
    return _event.EV_SEVENTSTATE;
}

-(void)makeRequestForUserEvent
{
    [m_viewController makeRequestForUserEvent:m_event sec:m_viewControllerHome];
    //[m_viewController getEntityPageInfo:m_event.EV_SENTITY.EN_SID];
}

- (void)saveImage:(UIImage*)image name:(NSString*)_name
{
    if (image != nil)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString* path = [documentsDirectory stringByAppendingPathComponent:_name ];
        NSData* data = UIImagePNGRepresentation(image);
        [data writeToFile:path atomically:YES];
    }
}

- (UIImage*)loadImage:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: name ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

-(UIImage *) getImageFromURL:(NSString *)fileURL {
    UIImage * result;
    
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

//-(void)methodToSaveImageFileLocal:(NSString*)_imageUrl name:(NSString*)_imageName{
//    
//    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,   NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Content_ Folder"];
//    // Content_ Folder is your folder name
//    NSError *error = nil;
//    
//    if (![[NSFileManager defaultManager] fileExistsAtPath:stringPath])
//        [[NSFileManager defaultManager] createDirectoryAtPath:stringPath  withIntermediateDirectories:NO attributes:nil error:&error];
//    //This will create a new folder if content folder is not exist
//    
//    _imageName = [NSString stringWithFormat:@"/%@", _imageName];
//    NSString *fileName = [stringPath stringByAppendingFormat:_imageName];
//    NSString *str ;//= @"http://demos.nanostuffs.com/Cab/uploads/Paddy_dest_1.png";
//    str = _imageUrl;
//    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSLog(@"embed %@",str);
//    NSData *data = [NSData dataWithContentsOfURL:[NSURL  URLWithString:str]];
//    [data writeToFile:fileName atomically:YES];
//}
//
//Method to Retrieve image file from local
-(UIImage *)readFileFromPath:(NSString*)_imageName{
    NSString *stringPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:@"Content_Folder"];
    stringPath  = [stringPath stringByAppendingPathComponent:_imageName];
    NSLog(@"stringpath %@",stringPath);
    return [UIImage imageWithContentsOfFile:stringPath];
}

- (NSInteger)backgroundReadEvents
{
    int iReturn = 0;
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://playentertainmentnetwork.com/ws/penrev0.php"]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
        {
        
            NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            
            strTemp = [self JSONString:strTemp];
            
            NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
            
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
            
       NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
 
            plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        
        for ( plaEvent *eventObj in responseA )
            {
                // create space in-mem to hold this event
                plaEvent *parsedEvent = [[plaEvent alloc] init];
                
                /* then we dig deeper into the JSON asking for the value for each known key
                 */
                parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
                parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
                parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
                parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
                parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
                parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
                parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
                parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];
                parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
                parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
                
                NSString* strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
                parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
                
                strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
                parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
                
                strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
                parsedEvent.EV_SDISTANCE = strTemp.integerValue;
                
                strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
                parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
                
                [self GET_EV_SEVENTSTATE:parsedEvent];
                
                iReturn++;
                // add to our global array
                
                [globEvents.arrayglobDBEvents addObject: parsedEvent];
//                if (iReturn > 10) {
//                    break;
//                }
            }    // end for
        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
        }   // end if no error
	else
        {
        NSLog(@"Networking problem getting to our system's Web Services!");
        }
    
    return(  iReturn  );
}

-(NSString *)JSONStringOposite:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    //    [s replaceOccurrencesOfString:@"/" withString:@"\\/" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"&" withString:@"*-*-*-*-*" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

-(NSString *)JSONString:(NSString *)aString {
    if (aString == nil) {
        return nil;
    }
    NSMutableString *s = [NSMutableString stringWithString:aString];
    //    [s replaceOccurrencesOfString:@"\"" withString:@"\\\"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@" " withString:@" " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"*-*-*-*-*" withString:@"&" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\n" withString:@"\\n" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\b" withString:@"\\b" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\f" withString:@"\\f" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\r" withString:@"\\r" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    [s replaceOccurrencesOfString:@"\t" withString:@"\\t" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [s length])];
    return [NSString stringWithString:s];
}

-(void)test
{
//    <?
//    php $target_path = "iphonetest/";
//    $target_path = $target_path.$_FILES['userfile']['name'];
//    $filename = $_FILES['userfile']['name'];
//    if(move_uploaded_file($_FILES['userfile']['tmp_name'], $target_path))
//    {
//        echo "1"; } else { echo "0";
//        }
//    ?>
}

-(void) uploadImage:(UIImage*)_image name:(NSString*)imageName;
{
    UIImage * img = _image; //[UIImage imageNamed:@"SRT2.jpg"];
    NSData *imageData = UIImageJPEGRepresentation(img,0.2);     //change Image to NSData
    
    if (imageData != nil)
        
    {
        NSString * filenames = [NSString stringWithFormat:@"TextLabel"];
        NSLog(@"%@", filenames);
        
        NSString *urlString = [NSString stringWithFormat:@"%@%@%@", PLAY_URL_START, @"cev0_file", PLAY_URL_END ];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"filenames\"\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[filenames dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        NSString* dataContent = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"userfile\"; filename=\"%@\"\r\n", imageName];
        [body appendData:[dataContent dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:imageData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"Response : %@",returnString);
        
        if([returnString isEqualToString:@"Success ! The file has been uploaded"])
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Image Saved Successfully" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            
            [alert show];
        }
        NSLog(@"Finish");
    }
}

- (NSInteger)backgroundInsertEvent:(plaEvent *)_eventModel
{
    plaEventData* globData = [plaEventData getInstance];
    NSString *sResource = @"cev0";
    [self sendData:_eventModel sec:sResource];
    
    // --- Cover Entity ---------
    if ([_eventModel.EV_SENTITY.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [globData.arrayglobDBEntities addObject:_eventModel.EV_SENTITY];
        [self backgroundInsertEntity:_eventModel.EV_SENTITY];
    }
    
    // --- Location Entity ---------
    if ([_eventModel.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [globData.arrayglobDBEntities addObject:_eventModel.EV_SENTITYLOCATION];
        [self backgroundInsertEntity:_eventModel.EV_SENTITYLOCATION];
    }
    
    // --- Artist Entity ---------
    for (int i = 0; i < [_eventModel.EV_SARRAYARTISTS count]; i ++) {
        plaEntity* entity = [_eventModel.EV_SARRAYARTISTS objectAtIndex:i];
        if ([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) {
            [globData.arrayglobDBEntities addObject:entity];
            [self backgroundInsertEntity:entity];
        }
    }
    return 0;
}

- (NSInteger)backgroundUpdateEvent:(plaEvent *)_eventModel
{
    NSString *sResource = @"cev0_modify";
    [self sendData:_eventModel sec:sResource];
    
    // --- Cover Entity ---------
    if ([_eventModel.EV_SENTITY.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self backgroundInsertEntity:_eventModel.EV_SENTITY];
    }
    
    // --- Location Entity ---------
    if ([_eventModel.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self backgroundInsertEntity:_eventModel.EV_SENTITYLOCATION];
    }
    
    // --- Artist Entity ---------
    for (int i = 0; i < [_eventModel.EV_SARRAYARTISTS count]; i ++) {
        plaEntity* entity = [_eventModel.EV_SARRAYARTISTS objectAtIndex:i];
        if ([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) {
            [self backgroundInsertEntity:entity];
        }
    }
//    // --- Cover Entity ---------
//    if ([_eventModel.EV_SENTITY.EN_SID rangeOfString:@"db"].location != NSNotFound) {
//        [self backgroundUpdateEntity:_eventModel.EV_SENTITY];
//    }
//    
//    // --- Location Entity ---------
//    if ([_eventModel.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
//        [self backgroundUpdateEntity:_eventModel.EV_SENTITYLOCATION];
//    }
//    
//    // --- Artist Entity ---------
//    for (int i = 0; i < [_eventModel.EV_SARRAYARTISTS count]; i ++) {
//        plaEntity* entity = [_eventModel.EV_SARRAYARTISTS objectAtIndex:i];
//        if ([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) {
//            [self backgroundUpdateEntity:entity];
//        }
//    }

    return 0;
}

-(void) sendData:(plaEvent*)_eventModel sec:(NSString*)_fileName
{
    NSString *sResource = _fileName; //= @"cev0";
    NSString* strDescription, *strImage, *realDescription, *strCategory;
    plaEntity* locationEntity = [self getEntityFromFBID:_eventModel.EV_SENTITYLOCATION.EN_SFACEBOOKID];
    if ([_eventModel.EV_SEVENTID rangeOfString:@"db"].location != NSNotFound) {
        realDescription = _eventModel.EV_SDESCRIPTION;
        if ([_eventModel.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
            if ([locationEntity.EN_SSTATE isEqualToString:@"Alberta"]) {
                locationEntity.EN_SSTATE = @"AB";
            }
            strDescription = [NSString stringWithFormat:@"%@,%@", locationEntity.EN_SCITY, locationEntity.EN_SSTATE];
            
        } else {
            if ([_eventModel.EV_SENTITYLOCATION.EN_SSTATE isEqualToString:@"Alberta"]) {
                _eventModel.EV_SENTITYLOCATION.EN_SSTATE = @"AB";
            }
            strDescription = [NSString stringWithFormat:@"%@,%@", _eventModel.EV_SENTITYLOCATION.EN_SCITY, _eventModel.EV_SENTITYLOCATION.EN_SSTATE];
        }
    } else {
        if ([_eventModel.EV_SSTATE isEqualToString:@"Alberta"]) {
            _eventModel.EV_SSTATE = @"AB";
        }
        strDescription = [NSString stringWithFormat:@"%@,%@", _eventModel.EV_SCITY, _eventModel.EV_SSTATE];
        realDescription = @"";
        //realDescription = [_eventModel.EV_SDESCRIPTION1 substringToIndex:10];
        
        if ([strDescription isEqualToString:@"(null),(null)"]) {
            for (int i = 0; i < [g_arrayTemp count]; i ++) {
                plaEntity* entity = [g_arrayTemp objectAtIndex:i];
                if ([entity.EN_SID isEqualToString:_eventModel.EV_SENTITYLOCATION.EN_SID]) {
                    if ([entity.EN_SSTATE isEqualToString:@"Alberta"]) {
                        entity.EN_SSTATE = @"AB";
                    }
                    strDescription = [NSString stringWithFormat:@"%@,%@", entity.EN_SCITY, entity.EN_SSTATE];
                }
            }
        }
    }
    
    plaEventData* globData = [plaEventData getInstance];
    if (![strDescription isEqualToString:[NSString stringWithFormat:@"%@,%@", globData.sglobCity, globData.sglobState]]) {
        if ([globData.arrayglobDBEvents containsObject:_eventModel]) {
            [globData.arrayglobDBEvents removeObject:_eventModel];
        }
    }
    
    strImage = [self JSONStringOposite:_eventModel.EV_SIMAGE];
    strCategory = [self JSONStringOposite:_eventModel.EV_SCATEGORY];
    
    NSString* strArtistIDs = _eventModel.EV_SENTITYARTISTID;
    
//    for (int i = 0; i < [_eventModel.EV_SARRAYARTISTS count]; i ++) {
//        plaEntity* entity = [_eventModel.EV_SARRAYARTISTS objectAtIndex:i];
//        if (i == 0) {
//            strArtistIDs = entity.EN_SID;
//        } else {
//            strArtistIDs = [NSString stringWithFormat:@"%@***%@",strArtistIDs, entity.EN_SID];
//        }
//    }
    
    NSString* strTempPersonName = [self replaceWhitesSpace:_eventModel.EV_SPERSONNAME];
    
    NSString *sQparms = [NSString stringWithFormat:@"?e_id=%@&e_name=%@&e_personname=%@&e_startdate=%@&e_enddate=%@&e_location=%@&e_image=%@&e_ticketurl=%@&e_description=%@&e_description1=%@&e_entityid=%@&e_entityartistid=%@&e_entitylocationid=%@&e_entityhashtags=%@&e_entitycategory=%@&e_friendcount=%ld&e_attendcount=%ld&e_distance=%ld&e_ticketcount=%ld&e_userid=%@&e_privacy=%@", _eventModel.EV_SEVENTID, _eventModel.EV_SNAME, strTempPersonName, _eventModel.EV_SSTARTDATETIME, _eventModel.EV_SENDDATE, _eventModel.EV_SLOCATION, strImage, _eventModel.EV_STICKETURL,realDescription,strDescription,_eventModel.EV_SENTITY.EN_SID,strArtistIDs,_eventModel.EV_SENTITYLOCATION.EN_SID, _eventModel.EV_SHASHTAGS, strCategory, (long)_eventModel.EV_SFRIENDCOUNT, (long)_eventModel.EV_SATTENDCOUNT, (long)_eventModel.EV_SDISTANCE, (long)_eventModel.EV_STICKETCOUNT, _eventModel.EV_SUSERID, _eventModel.EV_SPRIVACY];
    
    //NSInteger iReturn = SERVER_RETURN_SUCCESS;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [json objectForKey: @"TBLEVENT"];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
}

-(NSInteger)backgroundUpdateEventAttendState:(plaEvent *)_eventModel
{
    NSString *sResource = @"cev0_modify_attendstate";  // Create Event resource version 0
    
    _eventModel.EV_SACTIVITYUSER = [_eventModel.EV_SACTIVITYUSERARRAY componentsJoinedByString:@","];
    _eventModel.EV_SUPCOMMINGUSER = [_eventModel.EV_SUPCOMMINGUSERARRAY componentsJoinedByString:@","];
    
    NSString *sQparms = [NSString stringWithFormat:@"?e_id=%@&e_upcomminguser=%@&e_activityuser=%@&e_attendcount=%ld", _eventModel.EV_SEVENTID,_eventModel.EV_SUPCOMMINGUSER,_eventModel.EV_SACTIVITYUSER,(long)_eventModel.EV_SATTENDCOUNT ]; //(long)

    NSInteger iReturn = SERVER_RETURN_SUCCESS;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *url = [NSURL URLWithString:sUri];
    [[session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
      {
          // unit test:
          NSLog( @"response = %@", response.description );
          
          // to do: parse out the http status code and only if HTTP Status 200 OK then attempt to parse the JSON body return:
          NSString *sParsed = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
          NSLog( @"JSON parse attempt = %@", sParsed );
      } ] resume ];
    return( iReturn );
}

#pragma mark -------- delegate ------- user --------------
-(NSMutableArray*)backgroundReadUserAll // To read all users from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [g_arrayUserData removeAllObjects];
    plaEventData* globData = [plaEventData getInstance];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_users_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaUser* userModel = [[plaUser alloc] init];
            
            userModel.USER_ID = [eventObj valueForKey:@"USER_SID"];
            userModel.USER_NETWORK = [eventObj valueForKey:@"USER_SNETWORK"];
            
            NSString* strTemp = [eventObj valueForKey:@"USER_SFRIENDS"];
            NSArray* array = [strTemp componentsSeparatedByString:@"***"];
            if ([array count] > 0) {
                userModel.USER_FRIENDS = [[NSMutableArray alloc] initWithArray:array];
            } else {
                userModel.USER_FRIENDS = [[NSMutableArray alloc] init];
            }
            if ( [userModel.USER_FRIENDS containsObject:[NSString stringWithFormat:@"-%@", globData.sglobUserID]]) {
                userModel.USER_FRIENDSTATE = -1;
            } else if ( [userModel.USER_FRIENDS containsObject: globData.sglobUserID] )
            {
                userModel.USER_FRIENDSTATE = 1;
            } else {
                userModel.USER_FRIENDSTATE = 0;
            }
            
            userModel.USER_INVITEDSTATE = 0;
            
            [g_arrayUserData addObject:userModel];
            [g_controllerView makeRequestForUserInfoAdd:userModel];
//            [g_controllerView makeRequestForUserInfo:userModel.USER_ID];
        }    // end for
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    [g_controllerViewHome changeFriendCountText];
    
    return(  array  );
    
}

-(NSMutableArray*)backgroundReadUserAllChange // To read all users change from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    plaEventData* globData = [plaEventData getInstance];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_users_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaUser* userModel = [[plaUser alloc] init];
            
            userModel.USER_ID = [eventObj valueForKey:@"USER_SID"];
            
            NSString* strTemp = [eventObj valueForKey:@"USER_SFRIENDS"];
            NSArray* array = [strTemp componentsSeparatedByString:@"***"];
            if ([array count] > 0) {
                userModel.USER_FRIENDS = [[NSMutableArray alloc] initWithArray:array];
            } else {
                userModel.USER_FRIENDS = [[NSMutableArray alloc] init];
            }
            if ( [userModel.USER_FRIENDS containsObject:[NSString stringWithFormat:@"-%@", globData.sglobUserID]]) {
                userModel.USER_FRIENDSTATE = -1;
            } else if ( [userModel.USER_FRIENDS containsObject: globData.sglobUserID] )
            {
                userModel.USER_FRIENDSTATE = 1;
            } else {
                userModel.USER_FRIENDSTATE = 0;
            }
            
            for (int i = 0; i < [g_arrayUserData count]; i ++) {
                plaUser* userTemp = [g_arrayUserData objectAtIndex:i];
                if ([userTemp.USER_ID isEqualToString:userModel.USER_ID]) {
                    userTemp.USER_FRIENDS = userModel.USER_FRIENDS;
                    userTemp.USER_FRIENDSTATE = userModel.USER_FRIENDSTATE;
                }
            }
        }    // end for
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  array  );
    
}

-(NSInteger)backgroundInsertUser:(plaUser*)_userModel // To add user
{
    [self sendUserData:_userModel action:@"insert"];
    return 0;
}

-(NSInteger)backgroundUpdateUser:(plaUser *)_userModel action:(NSString*)_action
{
    [self sendUserData:_userModel action:_action];  //@"update"
    return 0;
}

-(void) sendUserData:(plaUser*)_userModel action:(NSString*)_action
{
    NSString *sResource = @"0_users";               // = @"cev0";
    NSString* userFriend = [_userModel.USER_FRIENDS componentsJoinedByString:@"***"];
    
    NSString *sQparms = [NSString stringWithFormat:@"?user_id=%@&user_network=%@&user_friend=%@&action=%@", _userModel.USER_ID, _userModel.USER_NETWORK, userFriend, _action];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
}

#pragma mark -------- delegate ------- mail --------------
-(NSMutableArray*)backgroundReadMailAll // To read all users from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [g_arrayMailData removeAllObjects];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_mailbox_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaMail* mail = [[plaMail alloc] init];
            
            mail.MAIL_ID = [eventObj valueForKey:@"MAIL_ID"];
            mail.MAIL_FROMUSER = [eventObj valueForKey:@"MAIL_FROMUSER"];
            mail.MAIL_TOUSER = [eventObj valueForKey:@"MAIL_TOUSER"];
            mail.MAIL_TYPE = [eventObj valueForKey:@"MAIL_TYPE"];
            mail.MAIL_ACTIVESTATUS = [eventObj valueForKey:@"MAIL_ACTIVESTATUS"];
            mail.MAIL_CONTENT = [eventObj valueForKey:@"MAIL_CONTENT"];
            
            //[g_arrayMailData addObject:mail];
            [g_arrayMailData insertObject:mail atIndex:0];
        }    // end for
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  array  );
    
}

-(NSMutableArray*)backgroundReadMailAllChange // To read all users change from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_mailbox_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaMail* mail = [[plaMail alloc] init];
            
            mail.MAIL_ID = [eventObj valueForKey:@"MAIL_ID"];
            mail.MAIL_FROMUSER = [eventObj valueForKey:@"MAIL_FROMUSER"];
            mail.MAIL_TOUSER = [eventObj valueForKey:@"MAIL_TOUSER"];
            mail.MAIL_TYPE = [eventObj valueForKey:@"MAIL_TYPE"];
            mail.MAIL_ACTIVESTATUS = [eventObj valueForKey:@"MAIL_ACTIVESTATUS"];
            mail.MAIL_CONTENT = [eventObj valueForKey:@"MAIL_CONTENT"];
            
            for (int i = 0; i < [g_arrayMailData count]; i ++) {
                plaMail* userTemp = [g_arrayMailData objectAtIndex:i];
                if ([userTemp.MAIL_ID isEqualToString:mail.MAIL_ID]) {
                    
                    userTemp.MAIL_FROMUSER = mail.MAIL_FROMUSER;
                    userTemp.MAIL_TOUSER = mail.MAIL_TOUSER;
                    userTemp.MAIL_TYPE = mail.MAIL_TYPE;
                    userTemp.MAIL_ACTIVESTATUS = mail.MAIL_ACTIVESTATUS;
                    userTemp.MAIL_CONTENT = mail.MAIL_CONTENT;
                    
                }
            }
        }    // end for
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  array  );
}

-(NSInteger)backgroundInsertMail:(plaMail*)_mailModel // To add user
{
    [self sendMailData:_mailModel action:@"insert"];
    return 0;
}

-(NSInteger)backgroundUpdateMail:(plaMail *)_mailModel
{
    [self sendMailData:_mailModel action:@"update"];
    return 0;
}

-(void) sendMailData:(plaMail*)_mailModel action:(NSString*)_action
{
    NSString *sResource = @"0_mailbox";               // = @"cev0";
    //NSString* userFriend = [_mailModel.USER_FRIENDS componentsJoinedByString:@"***"];
    
    NSString *sQparms = [NSString stringWithFormat:@"?mail_id=%@&mail_from=%@&mail_to=%@&mail_type=%@&mail_activestatus=%@&mail_content=%@&action=%@", _mailModel.MAIL_ID, _mailModel.MAIL_FROMUSER, _mailModel.MAIL_TOUSER, _mailModel.MAIL_TYPE, _mailModel.MAIL_ACTIVESTATUS, _mailModel.MAIL_CONTENT, _action];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
}

#pragma mark ----------- delegate --------- VisitPlace ------------
-(NSMutableArray*)backgroundReadVisitPlaceAll // To read all users from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [g_arrayMailData removeAllObjects];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_visitplace_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        
        for ( plaVisitPlace *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaVisitPlace* visitPlace = [[plaVisitPlace alloc] init];
            
            visitPlace.VP_ID = [eventObj valueForKey:@"VP_ID"];
            visitPlace.VP_USER = [eventObj valueForKey:@"VP_USER"];
            visitPlace.VP_PLACE = [eventObj valueForKey:@"VP_PLACE"];
            visitPlace.VP_DATETIME = [eventObj valueForKey:@"VP_DATETIME"];
            //[g_arrayMailData addObject:mail];
            [g_arrayVisitPlaceData insertObject:visitPlace atIndex:0];
        }    // end for
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  array  );
    
}

-(NSInteger)backgroundInsertVisitPlace:(plaVisitPlace*)_mailModel // To add user
{
    [self sendVisitPlaceData:_mailModel action:@"insert"];
    return 0;
}

-(NSInteger)backgroundUpdateVisitPlace:(plaVisitPlace *)_mailModel
{
    [self sendVisitPlaceData:_mailModel action:@"update"];
    return 0;
}

-(void) sendVisitPlaceData:(plaVisitPlace*)_mailModel action:(NSString*)_action
{
    NSString *sResource = @"0_visitplace";               // = @"cev0";
    //NSString* userFriend = [_mailModel.USER_FRIENDS componentsJoinedByString:@"***"];
    
    NSString *sQparms = [NSString stringWithFormat:@"?vp_id=%@&vp_user=%@&vp_place=%@&vp_datetime=%@&action=%@", _mailModel.VP_ID, _mailModel.VP_USER, _mailModel.VP_PLACE, _mailModel.VP_DATETIME, _action];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
}

#pragma mark -------- delegate ------- Activity Feed ---------
-(NSInteger)backgroundInsertFeed:(plaFeedModel*)_feedModel
{
    [self sendFeedData:_feedModel action:@"insert"];
    return 0;
}

-(NSInteger)backgroundDeleteFeed:(plaFeedModel*)_feedModel
{
    [self sendFeedData:_feedModel action:@"delete"];
    return 0;
}

//['mail_id'];
//$sParm_from = $_REQUEST['mail_from'];
//$sParm_to = $_REQUEST['mail_to'];
//$sParm_type = $_REQUEST['mail_type'];
//$sParm_activestatus = $_REQUEST['mail_activestatus'];
//$sParm_content = $_REQUEST['mail_content'];

-(void) sendFeedData:(plaFeedModel*)_feedModel action:(NSString*)_action
{
    NSString *sResource = @"0_activityfeed";               // = @"cev0";
    //NSString* userFriend = [_mailModel.USER_FRIENDS componentsJoinedByString:@"***"];
    
    NSString *sQparms = [NSString stringWithFormat:@"?feed_id=%@&feed_userid=%@&feed_action=%@&feed_content=%@&action=%@", _feedModel.FEED_ID, _feedModel.FEED_USER, _feedModel.FEED_ACTION, _feedModel.FEED_CONTENT, _action];
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    // To Read Activity Feeds
    //[self backgroundReadFeedAll];
}

-(NSMutableArray*)backgroundReadFeedAll // To read all users from USER Table
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    [g_arrayActivityFeeds removeAllObjects];
    
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/pen0_activityfeed_read.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        plaEventData* globData = [plaEventData getInstance];
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            plaFeedModel* feed = [[plaFeedModel alloc] init];
            
            feed.FEED_ID = [eventObj valueForKey:@"FEED_ID"];
            feed.FEED_USER = [eventObj valueForKey:@"FEED_USER"];
            feed.FEED_ACTION = [eventObj valueForKey:@"FEED_ACTION"];
            feed.FEED_CONTENT = [eventObj valueForKey:@"FEED_CONTENT"];
            
            //[g_arrayMailData addObject:mail];
            if ([feed.FEED_USER isEqualToString:globData.sglobUserID]) {
                [g_arrayActivityFeeds insertObject:feed atIndex:0];
//                [g_arrayActivityFeeds addObject:feed];
            }
        }    // end for
        
        [g_controllerViewHome.m_tableViewFull reloadData];
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    return(  array  );
    
}

#pragma mark -------- delegate ------- entity -------------
- (NSMutableArray*)backgroundReadEntityAll
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_entity.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */

            plaEntity* entity = [[plaEntity alloc] init];
            plaEntity* entity1 = [[plaEntity alloc] init];
            
            entity.EN_SID = [eventObj valueForKey:@"EN_SID"];
            entity.EN_SNAME = [eventObj valueForKey:@"EN_SNAME"];
            entity.EN_SFACEBOOKID = [eventObj valueForKey:@"EN_SFBID"];
            
            entity1.EN_SID = [eventObj valueForKey:@"EN_SID"];
            entity1.EN_SNAME = [eventObj valueForKey:@"EN_SNAME"];
            entity1.EN_SFACEBOOKID = [eventObj valueForKey:@"EN_SFBID"];
            
            plaEntity* entity2 = [[plaEntity alloc] init];
            
            entity2.EN_SID = [eventObj valueForKey:@"EN_SID"];
            entity2.EN_SNAME = [eventObj valueForKey:@"EN_SNAME"];
            entity2.EN_SFACEBOOKID = [eventObj valueForKey:@"EN_SFBID"];
            
            [g_controllerView getEntityPageInfo:entity.EN_SFACEBOOKID];
            
            [globEvents.arrayglobDBEntities addObject:entity];
            [g_controllerView getEntityPageInfo:entity.EN_SID];
            [globEvents.arrayglobDBCreatedEntities addObject:entity];
            [globEvents.arrayglobDBCreatedEntitiesStatic addObject:entity1];
            
            if ([entity2.EN_SID containsString:@"db"]) {
                [globEvents.arrayglobDBCreatedEntitiesStatic1 addObject:entity2];
            }
            
        }    // end for
        NSLog( @"Events now in arrayglobDBEvents in-mem db = %d",  (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    return(  array  );
}

-(NSInteger)backgroundInsertEntity:(plaEntity*)_entityModel
{
    NSString *sResource = @"cev0_entity";
    [self sendEntityData:_entityModel sec:sResource];
    return 0;
}

-(NSInteger)backgroundUpdateEntity:(plaEntity*)_entityModel
{
    NSString *sResource = @"cev0_modify_entity";
    [self sendEntityData:_entityModel sec:sResource];

    [self backgroundUpdateEventsByLocation:_entityModel];
    
    return 0;
}

- (plaEntity*)getEntityFromFBID:(NSString*)_fbID
{
    plaEntity* returnEntity;
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ([entity.EN_SID isEqualToString:_fbID]) {
            returnEntity = entity;
            break;
        }
    }
    return returnEntity;
}

- (NSInteger)backgroundUpdateEventsByLocation:(plaEntity*)personName
{
    int iReturn = 0;
    NSString* strPersonName = @"123412341234123413241";
    NSString* strLocation = [self replaceWhitesSpaceForPersonName:personName.EN_SNAME];
    NSString* strArtistID = @"asdfasdfasdf";
    
    // If we want to send an in-mem array of results back initialize the return here:  NSArray *nsaResult = @[];
    
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_location.php?location=%@&personName=%@&artistID=%@", strLocation, strPersonName, strArtistID];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        //plaEventData *globEvents = [plaEventData getInstance];
        
        // initialize the DB list of events
        
        
        for ( plaEvent *eventObj in responseA )
        {
            // create space in-mem to hold this event
            plaEvent *parsedEvent = [[plaEvent alloc] init];
            
            /* then we dig deeper into the JSON asking for the value for each known key
             */
            parsedEvent.EV_SNAME = [eventObj valueForKey:@"EV_SNAME"];
            parsedEvent.EV_SEVENTID = [eventObj valueForKey:@"EV_SEVENTID"];
            parsedEvent.EV_SPERSONNAME = [eventObj valueForKey:@"EV_SPERSONNAME"];
            parsedEvent.EV_SSTARTDATETIME = [eventObj valueForKey:@"EV_SSTARTDATETIME"];
            
            NSArray* arrayTemp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
            arrayTemp = [[arrayTemp objectAtIndex:0] componentsSeparatedByString:@"-"];
            NSString* strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
            
            parsedEvent.EV_SEVENTDATE = [strTemp integerValue];
            
            parsedEvent.EV_SENDDATE = [eventObj valueForKey:@"EV_SENDDATETIME"];
            parsedEvent.EV_SLOCATION = [eventObj valueForKey:@"EV_SLOCATION"];
            parsedEvent.EV_SUPCOMMINGUSER = [eventObj valueForKey:@"EV_SUPCOMMINGUSER"];
            parsedEvent.EV_SACTIVITYUSER = [eventObj valueForKey:@"EV_SACTIVITYUSER"];
            parsedEvent.EV_SENTITYPAGEID = [eventObj valueForKey:@"EV_SENTITYID"];
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SUPCOMMINGUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SUPCOMMINGUSER componentsSeparatedByString:@","]];
            parsedEvent.EV_SACTIVITYUSERARRAY = [[NSMutableArray alloc] initWithArray:[parsedEvent.EV_SACTIVITYUSER componentsSeparatedByString:@","]];
            
            parsedEvent.EV_SIMAGE = [eventObj valueForKey:@"EV_SIMAGE"];
            parsedEvent.EV_SIMAGE = [self JSONString:parsedEvent.EV_SIMAGE];
            
            parsedEvent.EV_STICKETURL = [eventObj valueForKey:@"EV_STICKETURL"];
            parsedEvent.EV_SDESCRIPTION = [eventObj valueForKey:@"EV_SDESCRIPTION"];
            
            strTemp = [eventObj valueForKey:@"EV_SATTENDCOUNT"];
            parsedEvent.EV_SATTENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SFRIENDCOUNT"];
            parsedEvent.EV_SFRIENDCOUNT = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_SDISTANCE"];
            parsedEvent.EV_SDISTANCE = strTemp.integerValue;
            
            strTemp = [eventObj valueForKey:@"EV_STICKETCOUNT"];
            parsedEvent.EV_STICKETCOUNT = strTemp.integerValue;
            
            [self GET_EV_SEVENTSTATE:parsedEvent];
            
            iReturn++;
            
            parsedEvent.EV_SENTITY = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITY.EN_SID = [eventObj valueForKey:@"EV_SENTITYID"];
            
            parsedEvent.EV_SENTITYLOCATION = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYLOCATION.EN_SID = [eventObj valueForKey:@"EV_SENTITYLOCATIONID"];
            
            parsedEvent.EV_SENTITYARTIST  = [[plaEntity alloc] init];
            parsedEvent.EV_SENTITYARTIST.EN_SID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            parsedEvent.EV_SENTITYARTISTID = [eventObj valueForKey:@"EV_SENTITYARTISTID"];
            
            parsedEvent.EV_SHASHTAGS = [eventObj valueForKey:@"EV_SENTITYHASHTAGS"];
            parsedEvent.EV_SCATEGORY = [eventObj valueForKey:@"EV_SENTITYCATEGORY"];
            
            if ([parsedEvent.EV_SEVENTID rangeOfString:@"db"].location == NSNotFound) {
                strTemp = [eventObj valueForKey:@"EV_SDESCRIPTION"];
                parsedEvent.EV_SDESCRIPTION = strTemp;
            } else {
            }
            
            parsedEvent.EV_SENTITYLOCATION.EN_SFACEBOOKID = personName.EN_SFACEBOOKID;
            
            NSString *sResource = @"cev0_modify";
            [self sendData:parsedEvent sec:sResource];
            
        }    // end for
        //        NSLog( @"Events read from our system database = %d, and now in arrayglobDBEvents in-mem db = %d", iReturn, (int)globEvents.arrayglobDBEvents.count );
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
    
    if (iReturn == 0) {
        //[_rootCtrl hideLoadingActivityView];
    }
    return(  iReturn  );
}

-(void) sendEntityData:(plaEntity*)_entityModel sec:(NSString*)_fileName
{
    NSString *sResource = _fileName;               // = @"cev0";
    NSString* strName = _entityModel.EN_SNAME;
    strName = [self replaceWhitesSpaceForPersonName:strName];
    
    NSString *sQparms = [NSString stringWithFormat:@"?e_id=%@&e_name=%@&e_fbid=%@", _entityModel.EN_SID, strName, _entityModel.EN_SFACEBOOKID];
    
    //NSInteger iReturn = SERVER_RETURN_SUCCESS;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        strTemp = [self JSONString:strTemp];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        responseA = responseA;
        
    }   // end if no error
    else
    {
        NSLog(@"Networking problem getting to our system's Web Services!");
    }
}

#pragma mark --- entity full -----
-(void) insertEntityFull:(plaEntity*)_entityModel
{
    NSString *sResource = @"cev0_entityfull";               // = @"cev0";
    NSString* strName = _entityModel.EN_SNAME;
    strName = [self replaceWhitesSpaceForPersonName:strName];
    
    NSString* strLocation = [NSString stringWithFormat:@"%f,%f",_entityModel.EN_SLOCATION.coordinate.latitude, _entityModel.EN_SLOCATION.coordinate.longitude];
    NSString* strAddress = [NSString stringWithFormat:@"%@,%@,%@", _entityModel.EN_SSTREET,_entityModel.EN_SCITY,_entityModel.EN_SSTATE]; // [NSString stringWithFormat:@"%@,%@",_entityModel.EN_SCITY,_entityModel.EN_SSTATE];;
                        //
    
    if ([strLocation isEqualToString:@"0.000000,0.000000"]) {
        return;
    }
    
    NSString *sQparms = [NSString stringWithFormat:@"?e_id=%@&e_name=%@&e_address=%@&e_location=%@", _entityModel.EN_SID, strName, strAddress, strLocation];
    
    //NSInteger iReturn = SERVER_RETURN_SUCCESS;
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{ CPWS_HEADER_ACCEPT : CPWS_HEADER_JSON }];
    
    NSString *sUri = [NSString stringWithFormat:@"%@%@%@%@", PLAY_URL_START, sResource, PLAY_URL_END, sQparms ];
    
    // unit test:
    NSLog( @"URI = %@", sUri );
    
    sUri = [sUri stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:sUri] ];
//    NSURLResponse * response = nil;
//    NSError * error = nil;
    
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:nil completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        
    }];
    
//    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
//                                          returningResponse:&response
//                                                      error:&error];
//    if ( error == nil )
//    {
//        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        
//        strTemp = [self JSONString:strTemp];
//        
//        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
//        
//        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
//        
//        responseA = responseA;
//        
//    }   // end if no error
//    else
//    {
//        NSLog(@"Networking problem getting to our system's Web Services!");
//    }
}

-(void)readEntityFull
{
    // Send a synchronous request because the screens are flipping anyways between Ready screen and Home screen:
    NSString* strUrl = [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/penrev0_entityfull.php"];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:strUrl]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    if ( error == nil )
    {
        
        NSString* strTemp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSData* dataTemp = [strTemp dataUsingEncoding:NSUTF8StringEncoding];
        
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:dataTemp options:kNilOptions error:&error];
        
        NSArray *responseA = [ json objectForKey: @"TBLEVENT" ];
        
        // initialize the DB list of events
        NSMutableArray * dataArray = [[NSMutableArray alloc] init];
        
        NSTimeInterval milSec = [[NSDate date] timeIntervalSince1970];
        NSInteger intMilSec = milSec;
        
        
        for ( plaEntity *eventObj in responseA )
        {
            // create space in-mem to hold this event
            
            /* then we dig deeper into the JSON asking for the value for each known key
            */
            
            plaEntity* entity = [[plaEntity alloc] init];
            
            entity.EN_SID = [eventObj valueForKey:@"EN_SID"];
            entity.EN_SNAME = [eventObj valueForKey:@"EN_SNAME"];
            entity.EN_SFACEBOOKID = [eventObj valueForKey:@"EN_SADDRESS"];
            
            NSInteger intCount = [self calculateEventNumber:entity];
            NSString* strTemp = [NSString stringWithFormat:@"%ld", (long)intCount];
            
            NSDictionary* dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:[eventObj valueForKey:@"EN_SNAME"], @"name", [eventObj valueForKey:@"EN_SLOCATION"], @"location", [eventObj valueForKey:@"EN_SADDRESS"], @"address", strTemp, @"count", [NSString stringWithFormat:@"%ld", (long)intMilSec], @"visited_time", nil];
            
            [dataArray addObject:dictionary];
        }
        
        // To write data to plist
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
        NSString *documentsDir = [paths objectAtIndex:0];
        NSString *root = [documentsDir stringByAppendingPathComponent:@"entityInfo.plist"];
        
        BOOL isSuccessed = [dataArray writeToFile:root atomically:YES];
        
        if (isSuccessed) {
            NSLog(@" file path ---- \n%@", root);
        }
    }
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

- (NSMutableArray*)getAllEntityInfoFromFile
{
    NSMutableArray* mutableArray = [[NSMutableArray alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory , NSUserDomainMask, YES);
    NSString *documentsDir = [paths objectAtIndex:0];
    NSString *source = [documentsDir stringByAppendingPathComponent:@"entityInfo.plist"];
    
    NSArray* array = [[NSArray alloc] initWithContentsOfFile:source];
    
    for (NSDictionary* dictionary in array) {
        plaEntity* entity = [[plaEntity alloc] init];
        
        entity.EN_SNAME = [dictionary valueForKey:@"name"];
        entity.EN_SADDRESSSTR = [dictionary valueForKey:@"address"];
        
        NSString* strlocation = [dictionary valueForKey:@"location"];
        NSArray* array = [strlocation componentsSeparatedByString:@","];
        entity.EN_SLOCATION = [[CLLocation alloc] initWithLatitude:[[array objectAtIndex:0] floatValue] longitude:[[array objectAtIndex:1] floatValue]];
        
        entity.m_intEventsCount = [[dictionary valueForKey:@"count"] integerValue];
        
        entity.m_intStayTime = [[dictionary valueForKey:@"visited_time"] integerValue];
        
        [mutableArray addObject:entity];
    }
    
    return mutableArray;
}
    
@end
