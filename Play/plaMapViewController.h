//
//  plaAttendViewController.h
//  Play
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

#import "CalloutMapAnnotation.h"
#import "BasicMapAnnotation.h"
@class plaHomeViewController;

@protocol MapViewControllerDidSelectDelegate;
@interface plaMapViewController : UIViewController < MKMapViewDelegate >
{
    IBOutlet MKMapView* mkMapViewFullScreen;
    Boolean isShowingLandscapeView;
    
    IBOutlet UIView* m_view;
    IBOutlet UIButton* m_btnLocateMe1;
    IBOutlet UIButton* m_btnLocateme2;
    
    NSMutableArray* _origianlMapAnnotationArray;
}

@property(nonatomic,assign)id<MapViewControllerDidSelectDelegate> delegate;
@property(nonatomic, retain) plaHomeViewController* homeViewController;

- (void)resetAnnitations:(NSArray *)data;

@end

@protocol MapViewControllerDidSelectDelegate <NSObject>

@optional
- (void)customMKMapViewDidSelectedWithInfo:(id)info;

@end
