//
//  JingDianMapCell.m
//  IYLM
//
//  Created by Jian-Ye on 12-11-8.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import "JingDianMapCell.h"
#import "plaEvent.h"
#import "plaEventData.h"
#import "plaHomeViewController.h"

@implementation JingDianMapCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)setData:(plaEvent*)_eventData ctrl:(plaHomeViewController *)_ctrl
{
    m_homeViewController = _ctrl;
    m_eventData = _eventData;
    m_lblName.text = _eventData.EV_SNAME;
//    m_lblAddress.text = [NSString stringWithFormat:@"%@, %@", _eventData.EV_SSTREET, _eventData.EV_SCITY];
    m_lblAddress.text = _eventData.EV_SLOCATION;
    NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString:_eventData.EV_SIMAGE] ];
    UIImage* image = [UIImage imageWithData:data];
    [m_imagePic setImage:image];
}

-(IBAction)onBtnInfo:(id)sender
{
    plaEventData *globData = [plaEventData getInstance];
//    globData.nsipEventRow = indexPath;
//    globData.iglobEventRow = indexPath.row;
    
//        plaEvent* data = [m_arrayTableViewData objectAtIndex:indexPath.row];
        
        NSUInteger intTemp = [globData.arrayglobDBEvents indexOfObject:m_eventData];
        
        globData.iglobEventRow = intTemp;
    
    [m_homeViewController performSegueWithIdentifier: @"segueToEventDetail" sender:m_homeViewController];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
