/*
//  plaDB.m
//  Play
//
//  Created by Darcy Allen on 2014-06-20.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//
*/

#import "plaDB.h"

@implementation plaDB

+(UIAlertView *)credentialsAlert
{
    return [   [UIAlertView alloc] initWithTitle:@"Missing Credentials" message:CREDENTIALS_MESSAGE delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil  ];
}

@end

