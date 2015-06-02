//
//  plaHomeTableViewCell.m
//  Play
//
//  Created by Darcy Allen on 10/5/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaHomeTableViewCell.h"

@implementation plaHomeTableViewCell

@synthesize m_imageView0;
@synthesize m_imageView1, m_lblText1, m_lblText2, m_lblText3;
@synthesize m_lblWeekday, m_lblDay, m_lblMonth;

@synthesize m_lalDistance;
@synthesize m_lblState, m_lblTextAttendCount, m_viewCover, multipleSelectionBackgroundView;
@synthesize m_lblState2;
@synthesize m_lblAttendFriendCount;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{   
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

@end
