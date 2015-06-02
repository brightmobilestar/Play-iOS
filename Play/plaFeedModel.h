//
//  plaFeedModel.h
//  Play
//
//  Created by System Administrator on 2/3/15.
//  Copyright (c) 2015 Play Entertainment. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface plaFeedModel : NSObject

@property(nonatomic, retain) NSString* FEED_ID;
@property(nonatomic, retain) NSString* FEED_USER;
@property(nonatomic, retain) NSString* FEED_ACTION; // value: unAttend, Attend, Friend
@property(nonatomic, retain) NSString* FEED_CONTENT;

@end
