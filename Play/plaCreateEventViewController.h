//
//  plaCreateEventViewController.h
//  Play
//
//  Created by User on 11/21/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
@class plaHomeViewController;

@interface plaCreateEventViewController : UIViewController
{
    IBOutlet UIScrollView* m_scrollView;
}

@property (nonatomic, retain) plaHomeViewController* m_viewControllerHome;

-(IBAction)onBtnCancel:(id)sender;
-(IBAction)onBtnSave:(id)sender;

@end
