//
//  plaAttendViewController.m
//  Play
//
//  Created by User on 10/24/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaMapViewController.h"
#import "CallOutAnnotationVifew.h"
#import "JingDianMapCell.h"
#import "plaHomeViewController.h"
#import "plaAppDelegate.h"

#define span 40000

#import "plaEvent.h"

@interface plaMapViewController ()
{
    NSMutableArray *_annotationList;
    
    CalloutMapAnnotation *_calloutAnnotation;
    CalloutMapAnnotation *_previousdAnnotation;
    
}

-(void)setAnnotionsWithList:(NSArray *)list;

@end

@implementation plaMapViewController

@synthesize delegate;
@synthesize homeViewController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _annotationList = [[NSMutableArray alloc] init];
    _origianlMapAnnotationArray = [[NSMutableArray alloc] init];

    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"mapViewController";
    
    [self catchAutoRotationEvent];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation(15.7079f/2);
    mkMapViewFullScreen.transform = affineTransform;
}

#pragma mark ---- UI device rotate -----
- (void)catchAutoRotationEvent
{
    isShowingLandscapeView = NO;
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    plaEventData* globData = [plaEventData getInstance];
    if (globData.sglobControllerIndex != 1 || g_controllerViewHome.m_imageViewBackscreen.hidden == false) {
        return;
    }
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation) &&
        !isShowingLandscapeView)
    {
        [homeViewController addMarkerToMapView];
        isShowingLandscapeView = YES;
        
        self.view.hidden = false;
        
        if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            CGAffineTransform affineTransform = CGAffineTransformMakeRotation(15.7079f/2.0f);
            mkMapViewFullScreen.transform = affineTransform;
            m_btnLocateMe1.transform = affineTransform;
            m_btnLocateMe1.hidden = false;
            m_btnLocateme2.hidden = true;
            
        } else {
            CGAffineTransform affineTransform = CGAffineTransformMakeRotation(-15.7079f/2.0f);
            mkMapViewFullScreen.transform = affineTransform;
            m_btnLocateme2.transform = affineTransform;
            m_btnLocateMe1.hidden = true;
            m_btnLocateme2.hidden = false;
        }
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) &&
             isShowingLandscapeView)
    {
        isShowingLandscapeView = NO;
        self.view.hidden = true;
     }
}

- (IBAction)onBtnLocateMe:(id)sender
{
    plaEventData* globData = [plaEventData getInstance];
    CLLocationCoordinate2D coornitation = globData.sglobLocation.coordinate;
    [mkMapViewFullScreen setCenterCoordinate:coornitation animated:YES];
}

-(void)setAnnotionsWithList:(NSArray *)list
{
    for (BasicMapAnnotation *  annotation in _origianlMapAnnotationArray) {
        
        [mkMapViewFullScreen removeAnnotation:annotation];
        
    }
    
    [_origianlMapAnnotationArray removeAllObjects];
    
    for (plaEvent *event in list) {
        
//        CLLocationDegrees latitude=[[dic objectForKey:@"latitude"] doubleValue];
//        CLLocationDegrees longitude=[[dic objectForKey:@"longitude"] doubleValue];
        CLLocationCoordinate2D location = event.EV_SLOCATIONADDRESS.coordinate; //CLLocationCoordinate2DMake(latitude, longitude);
        
        MKCoordinateRegion region=MKCoordinateRegionMakeWithDistance(location,span ,span );
        MKCoordinateRegion adjustedRegion = [mkMapViewFullScreen regionThatFits:region];
        [mkMapViewFullScreen setRegion:adjustedRegion animated:YES];
        
        BasicMapAnnotation *  annotation=[[BasicMapAnnotation alloc] initWithEventData:event];
        [mkMapViewFullScreen  addAnnotation:annotation];
        [_origianlMapAnnotationArray addObject:annotation];
        
        //[mkMapViewFullScreen removeAnnotation:annotation];
    }
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[BasicMapAnnotation class]]) {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
            return;
        }
        if (_calloutAnnotation) {
            [mapView removeAnnotation:_calloutAnnotation];
            _calloutAnnotation = nil;
        }
        BasicMapAnnotation* basicAnnotion = (BasicMapAnnotation*)view.annotation;
        _calloutAnnotation = [[CalloutMapAnnotation alloc]
                               initWithLatitude:basicAnnotion.eventData] ;
        [mapView addAnnotation:_calloutAnnotation];
        
        //[mapView setCenterCoordinate:_calloutAnnotation.coordinate animated:YES];
    }
    else{
        if([delegate respondsToSelector:@selector(customMKMapViewDidSelectedWithInfo:)]){
            [delegate customMKMapViewDidSelectedWithInfo:@"点击至之后你要在这干点啥"];
        }
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view {
    if (_calloutAnnotation&& ![view isKindOfClass:[CallOutAnnotationVifew class]]) {
        if (_calloutAnnotation.coordinate.latitude == view.annotation.coordinate.latitude&&
            _calloutAnnotation.coordinate.longitude == view.annotation.coordinate.longitude) {
            [mapView removeAnnotation:_calloutAnnotation];
            _calloutAnnotation = nil;
        }
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    if ([annotation isKindOfClass:[CalloutMapAnnotation class]]) {
        
        CallOutAnnotationVifew *annotationView = (CallOutAnnotationVifew *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CalloutView"];
        if (!annotationView) {
            annotationView = [[CallOutAnnotationVifew alloc] initWithAnnotation:annotation reuseIdentifier:@"CalloutView1"];
            CalloutMapAnnotation* mapAnnotation = (CalloutMapAnnotation*)annotation;
            JingDianMapCell  *cell = [[[NSBundle mainBundle] loadNibNamed:@"JingDianMapCell" owner:self options:nil] objectAtIndex:0];
            [cell setData:mapAnnotation.eventData ctrl:homeViewController];
            [annotationView.contentView addSubview:cell];
            
        }
        return annotationView;
    } else if ([annotation isKindOfClass:[BasicMapAnnotation class]]) {
        
        MKAnnotationView *annotationView =[mkMapViewFullScreen dequeueReusableAnnotationViewWithIdentifier:@"CustomAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation
                                                           reuseIdentifier:@"CustomAnnotation"];
            annotationView.canShowCallout = NO;
            annotationView.image = [UIImage imageNamed:@"pin_1.png"];
        }
        
        return annotationView;
    }
    return nil;
}
- (void)resetAnnitations:(NSArray *)data
{
    [_annotationList removeAllObjects];
    [_annotationList addObjectsFromArray:data];
    [self setAnnotionsWithList:_annotationList];
}

@end
