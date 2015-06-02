//
//  plaUser.m
//  Play
//
//  Created by Darcy Allen on 2014-06-08.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaUser.h"
#import <FacebookSDK/FacebookSDK.h>
#import <Foundation/Foundation.h>

@implementation plaUser{
    NSString* accessToken;
}

@synthesize USER_PROFILEIMAGE, USER_COVERIMAGE, USER_ID, USER_NAME;
@synthesize USER_FRIENDS, USER_NETWORK;
@synthesize USER_FRIENDSTATE, USER_INVITEDSTATE;
@synthesize _isChecked;

- (NSString*) getToken {
    accessToken = [[[FBSession activeSession] accessTokenData] accessToken];
    return accessToken;
}

- (void) registerUser {

    NSString* jsonString = [NSString stringWithFormat:@"{\"token\":%@}", accessToken];
    
    NSLog(@"jsonString = %@", jsonString );
}

@end
