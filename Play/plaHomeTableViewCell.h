//
//  plaHomeTableViewCell.h
//  Play
//
//  Created by Darcy Allen on 10/5/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AsyncImageView;

@interface plaHomeTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet AsyncImageView* m_imageView0;
@property (nonatomic, retain) IBOutlet UIImageView* m_imageView1;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText1;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText2;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText3; // Weekday & day & Month
@property (nonatomic, retain) IBOutlet UILabel* m_lblWeekday;
@property (nonatomic, retain) IBOutlet UILabel* m_lblDay;
@property (nonatomic, retain) IBOutlet UILabel* m_lblMonth;


@property (nonatomic, retain) IBOutlet UILabel* m_lblAttendFriendCount;

@property (nonatomic, retain) IBOutlet UILabel* m_lalDistance;

@property (nonatomic, retain) IBOutlet UILabel* m_lblTextAttendCount;

// ----------- to show in upcoming or activity feed -------------
@property (nonatomic, retain) IBOutlet UIView* m_viewCover;
@property (nonatomic, retain) IBOutlet UILabel* m_lblState;
@property (nonatomic, retain) IBOutlet UILabel* m_lblState2;
@end
