#import "BasicMapAnnotation.h"
#import "plaEvent.h"

@implementation BasicMapAnnotation

@synthesize latitude = _latitude;
@synthesize longitude = _longitude;
@synthesize eventData = _eventData;

- (id)initWithEventData:(plaEvent*)_event {
	if (self = [super init]) {
        self.eventData = _event;
		self.latitude = _event.EV_SLOCATIONADDRESS.coordinate.latitude;
		self.longitude = _event.EV_SLOCATIONADDRESS.coordinate.longitude;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate {
	self.latitude = newCoordinate.latitude;
	self.longitude = newCoordinate.longitude;
}

@end
