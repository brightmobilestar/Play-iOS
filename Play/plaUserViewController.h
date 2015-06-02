//
//  plaUserViewController.h
//  Play
//
//  Created by User on 12/17/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
@class plaUser;

@interface plaUserViewController : UIViewController <UIActionSheetDelegate>
{
    plaUser* m_mainUser; // current User
    plaUser* m_defaultUser; // App main User
    
    IBOutlet UIView *m_viewFriendRequest;
}

@property (strong, nonatomic) IBOutlet UIImageView *m_imageViewCover;
@property (strong, nonatomic) IBOutlet UIImageView *m_imageViewProfile;
@property (strong, nonatomic) IBOutlet UILabel *m_lblUserName;
@property (strong, nonatomic) IBOutlet UILabel *m_lblUserNetwork;
@property (strong, nonatomic) IBOutlet UIButton *m_btnFriend;


- (IBAction)onBtnBack:(id)sender;

- (IBAction)onBtnFriend:(id)sender;

- (IBAction)onBtnConfirm:(id)sender;
- (IBAction)onBtnDecline:(id)sender;

@end
