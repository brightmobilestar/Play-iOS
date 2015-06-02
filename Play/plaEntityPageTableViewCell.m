//
//  plaEntityPageTableViewCell.m
//  Play
//
//  Created by JinLong on 11/19/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaEntityPageTableViewCell.h"

@implementation plaEntityPageTableViewCell

@synthesize m_imageView0;
@synthesize m_imageView1, m_lblText1, m_lblText2, m_lblText3;
@synthesize m_lalDistance;
@synthesize m_lblTextAttendCount, multipleSelectionBackgroundView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
