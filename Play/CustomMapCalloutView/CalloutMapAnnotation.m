#import "CalloutMapAnnotation.h"
#import "plaEvent.h"

@interface CalloutMapAnnotation()


@end

@implementation CalloutMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize eventData = _eventData;

- (id)initWithLatitude:(plaEvent*)_event {
	if (self = [super init]) {
		self.latitude = _event.EV_SLOCATIONADDRESS.coordinate.latitude;
        self.longitude = _event.EV_SLOCATIONADDRESS.coordinate.longitude;
        self.eventData = _event;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate
{
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

@end
