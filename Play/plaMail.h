//
//  plaMail.h
//  Play
//
//  Created by User on 12/27/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface plaMail : NSObject

@property (nonatomic, retain) NSString* MAIL_ID;
@property (nonatomic, retain) NSString* MAIL_FROMUSER;
@property (nonatomic, retain) NSString* MAIL_TOUSER;
@property (nonatomic, retain) NSString* MAIL_TYPE;
@property (nonatomic, retain) NSString* MAIL_ACTIVESTATUS; // @"true", @"false"
@property (nonatomic, retain) NSString* MAIL_CONTENT;

@end
