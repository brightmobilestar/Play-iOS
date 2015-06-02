//
//  JingDianMapCell.h
//  IYLM
//
//  Created by Jian-Ye on 12-11-8.
//  Copyright (c) 2012年 Jian-Ye. All rights reserved.
//

#import <UIKit/UIKit.h>
@class plaEvent;
@class plaHomeViewController;

@interface JingDianMapCell : UIView
{
    IBOutlet UIImageView*  m_imagePic;
    IBOutlet UILabel* m_lblName;
    IBOutlet UILabel* m_lblAddress;
    
    plaEvent* m_eventData;
    plaHomeViewController* m_homeViewController;
}

-(IBAction)onBtnInfo:(id)sender;

-(void)setData:(plaEvent*)_eventData ctrl:(plaHomeViewController*)_ctrl;

@end
