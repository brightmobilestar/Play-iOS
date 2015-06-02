//
//  plaUser.h
//  Play
//
//  Created by Darcy Allen on 2014-06-08.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface plaUser : NSObject

@property (nonatomic, retain) NSString* USER_ID;
@property (nonatomic, retain) NSString* USER_NAME;
@property (nonatomic, retain) NSString* USER_COVERIMAGE;
@property (nonatomic, retain) NSString* USER_PROFILEIMAGE;

@property (nonatomic, retain) NSMutableArray* USER_FRIENDS;

@property (nonatomic, retain) NSString* USER_NETWORK;
@property (readwrite) NSInteger USER_FRIENDSTATE; //        -1: removed state    0: add friend state    1: friend state

@property (readwrite) NSInteger USER_INVITEDSTATE;   // -1: unattened state          0: nothing
                                                //  1: invited state            2: already invited

@property (strong, nonatomic) NSDictionary* rawData;

// ------------ additional ------
@property(readwrite) BOOL _isChecked;

- (void) registerUser;
- (NSString*) getToken;

@end
