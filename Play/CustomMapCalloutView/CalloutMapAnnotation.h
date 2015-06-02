#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
@class plaEvent;

@interface CalloutMapAnnotation : NSObject <MKAnnotation> {
	CLLocationDegrees _latitude;
	CLLocationDegrees _longitude;
    plaEvent* _eventData;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic, retain) plaEvent* eventData;

- (id)initWithLatitude:(plaEvent*)_event;

@end
