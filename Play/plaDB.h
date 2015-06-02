//
//  plaDB.h
//  Play
//
//  Created by Darcy Allen on 2014-06-20.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

#define EVENT_IMAGE_PLACEHOLDER   @"http://allentiumsoftware.com/images/eventpic.jpg"
#define EVENT_IMAGE_NONE @"event.jpg"
#define EVENT_INFO_PLACEHOLDER @"na"
#define CREDENTIALS_MESSAGE    @"Your credentials are wrong."

@interface plaDB : NSObject

+(UIAlertView *)credentialsAlert;

@end
