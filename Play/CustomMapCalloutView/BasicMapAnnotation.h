#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class plaEvent;

@interface BasicMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
    plaEvent* _eventData;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, retain) plaEvent* eventData;

- (id)initWithEventData:(plaEvent*)_event;
- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate;

@end
