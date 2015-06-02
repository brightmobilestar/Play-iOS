//
//  plaLeftMenuViewController.m
//  Play
//
//  Created by Darcy Allen on 2014-08-13.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaLeftMenuViewController.h"
#import "plaEventData.h"
#import "UIImage+MultiFormat.h"

@interface plaLeftMenuViewController ()

@end

@implementation plaLeftMenuViewController

@synthesize imgPersonPic;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)returnToHome:(id)sender
{
	[self performSegueWithIdentifier:@"UnwindFromSecondView" sender:self];
}

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue {
    ;  // unit test successful:  NSLog(@"Open Menu");
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // self.slidingViewController.topViewAnchoredGesture = ECSlidingViewControllerAnchoredGesturePanning | ECSlidingViewControllerAnchoredGestureTapping;
    
    plaEventData *globEvents = [plaEventData getInstance];
	self.lblName.text = globEvents.sglobUsername;
    self.lblCity.text = globEvents.sglobCityLocation;
    self.lblEmailAddress.text = globEvents.sglobEmailAddress;


    self.imgPersonPic.imageURL = [NSURL URLWithString: globEvents.sglobFBProfileImageURL ];

    // another way to convert the square into a circle:
    self.imgPersonPic.layer.cornerRadius = self.imgPersonPic.frame.size.width / 2;
    self.imgPersonPic.clipsToBounds = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
