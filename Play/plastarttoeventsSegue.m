//
//  plastarttoeventsSegue.m
//  Play
//
//  Created by Darcy Allen on 2014-06-16.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plastarttoeventsSegue.h"
#import <UIKit/UIKit.h>
#import "plaHomeViewController.h"
#import "plaViewController.h"
#import "plaAppDelegate.h"

@implementation plastarttoeventsSegue

- (void)perform
{
    // short animation to move to the events, making it look like the User and his location is going onto the Map and Events screen
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    
    if ([self.identifier isEqual:@"plastarttoeventsSegue"] ) {
        plaViewController* ctrlRoot = (plaViewController*)self.sourceViewController;
        g_controllerView = ctrlRoot;
        plaHomeViewController* ctrlTarget = (plaHomeViewController*)self.destinationViewController;
        ctrlTarget.m_viewControllerRoot = ctrlRoot;
    }
    
    [sourceViewController.view addSubview:destinationViewController.view];
    destinationViewController.view.transform = CGAffineTransformMakeScale( 0.05, 0.05 );
    
    CGPoint originalCenter = destinationViewController.view.center;
    destinationViewController.view.center = self.originatingPoint;
    
    [UIView animateWithDuration: 0.4
                            delay: 0.0
                          options:UIViewAnimationOptionCurveEaseInOut
                          animations:^{
                            destinationViewController.view.transform = CGAffineTransformMakeScale( 1.0, 1.0 );
                            destinationViewController.view.center = originalCenter;
                           }
                          completion:^(BOOL finished) {
                            [destinationViewController.view removeFromSuperview];
                            [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
                         } ];
}

@end
