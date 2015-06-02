//
//  plaLeftMenuViewController.h
//  Play
//
//  Created by Darcy Allen on 2014-08-13.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "AsyncImageView.h"

@interface plaLeftMenuViewController : UIViewController

- (IBAction)unwindToMenuViewController:(UIStoryboardSegue *)segue;

@property (weak, nonatomic) IBOutlet UILabel *lblName;
@property (weak, nonatomic) IBOutlet UILabel *lblCity;
@property (nonatomic, strong) IBOutlet UIImageView *imgPersonPic;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailAddress;

@end
