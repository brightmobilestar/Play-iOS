//
//  plaEntityPageTableViewCell.h
//  Play
//
//  Created by JinLong on 11/19/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AsyncImageView;

@interface plaEntityPageTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet AsyncImageView* m_imageView0;
@property (nonatomic, retain) IBOutlet UIImageView* m_imageView1;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText1;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText2;
@property (nonatomic, retain) IBOutlet UILabel* m_lblText3;

@property (nonatomic, retain) IBOutlet UILabel* m_lalDistance;

@property (nonatomic, retain) IBOutlet UILabel* m_lblTextAttendCount;

@end
