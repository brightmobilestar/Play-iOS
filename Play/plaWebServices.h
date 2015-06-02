//
//  plaWebServices.h
//  Play
//
//  Created by Darcy Allen on 2014-10-01.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#ifndef Play_plaWebServices_h
#define Play_plaWebServices_h

#import "plaEvent.h"
@class plaUser;
@class plaMail;
@class plaVisitPlace;
@class plaViewController;
@class plaHomeViewController;
@class plaEntityPageViewController;
@class plaFeedModel;

#define SERVER_RETURN_ERROR 0
#define SERVER_RETURN_SUCCESS 10

#define PLAY_URL_START @"http://playentertainmentnetwork.com/ws/pen"
#define PLAY_URL_END @".php"
#define CPWS_HEADER_ACCEPT @"Accept"
#define CPWS_HEADER_JSON @"application/json"

@interface plaWebServices : NSObject
{
    plaEvent* m_event;
    plaViewController* m_viewController;
    plaHomeViewController* m_viewControllerHome;
}

// --------- To ready event
- (NSInteger)backgroundReadEvents:(NSInteger)_startNum sec:(NSInteger)_endNum third:(plaViewController*)_controller fourth:(plaHomeViewController*)_rootCtrl;

- (NSInteger)backgroundReadEvents:(NSInteger)_startNum sec:(NSInteger)_endNum;

- (NSInteger)backgroundReadEventsByLocation:(plaEntity*)personName sec:(plaViewController*)_controller third:(plaEntityPageViewController*)_rootCtrl; //
- (NSMutableArray*)backgroundReadEventsAll; // To read eventID and entityID of all events

-(NSInteger)backgroundInsertEvent:(plaEvent*)_eventModel; // To add event
-(NSInteger)backgroundUpdateEvent:(plaEvent*)_eventModel; // To upgrate event on editing page
-(NSInteger)backgroundUpdateEventAttendState:(plaEvent*)_eventModel; // To upgrade event Attend state

#pragma mark -------- delegate ------- entity -------------
-(NSMutableArray*)backgroundReadEntityAll; // To read all entity from Entity Table
-(NSInteger)backgroundInsertEntity:(plaEntity*)_entityModel; // To add event
-(NSInteger)backgroundUpdateEntity:(plaEntity*)_entityModel; // To upgrate event on editing page

-(void)insertEntityFull:(plaEntity*)_entityModel; // To insert Entity Full info
-(void)readEntityFull; // To read Entity Full info
- (NSMutableArray*)getAllEntityInfoFromFile;
#pragma mark -------- delegate ------- user -------------
-(NSMutableArray*)backgroundReadUserAll; // To read all users from USER Table
-(NSMutableArray*)backgroundReadUserAllChange; // To read all users change from USER Table
-(NSInteger)backgroundInsertUser:(plaUser*)_userModel; // To add user
-(NSInteger)backgroundUpdateUser:(plaUser*)_userModel action:(NSString*)_action; // To upgrate user on user page

#pragma mark -------- delegate ------- mail -------------
-(NSMutableArray*)backgroundReadMailAll; // To read all users from Mail Table
-(NSMutableArray*)backgroundReadMailAllChange; // To read all users change from Mail Table
-(NSInteger)backgroundInsertMail:(plaMail*)_mailModel; // To add user
-(NSInteger)backgroundUpdateMail:(plaMail*)_mailModel; // To upgrate user on user page

#pragma mark -------- delegate ------- visitplace -------------
-(NSMutableArray*)backgroundReadVisitPlaceAll; // To read all users from VisitPlace Table
//-(NSMutableArray*)backgroundReadVisitPlaceAllChange; // To read all users change from VisitPlace Table
-(NSInteger)backgroundInsertVisitPlace:(plaVisitPlace*)_mailModel; // To add user
-(NSInteger)backgroundUpdateVisitPlace:(plaVisitPlace*)_mailModel; // To upgrate user on user page
-(void) sendVisitPlaceData:(plaVisitPlace*)_mailModel action:(NSString*)_action;

#pragma mark -------- delegate ------- mail -------------
-(NSMutableArray*)backgroundReadFeedAll; // To read all users from Mail Table
//-(NSMutableArray*)backgroundReadMailAllChange; // To read all users change from Mail Table
-(NSInteger)backgroundInsertFeed:(plaFeedModel*)_feedModel; // To add user
-(NSInteger)backgroundDeleteFeed:(plaFeedModel*)_feedModel;
//-(NSInteger)backgroundUpdateMail:(plaMail*)_mailModel; // To upgrate user on user page

#pragma mark -------- delegate ------- image file -------------
-(void) uploadImage:(UIImage*)_image name:(NSString*)imageName;

-(NSString *)replaceToWhitesSpace:(NSString *)aString;

@end

#endif
