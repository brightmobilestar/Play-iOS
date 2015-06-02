//
//  plaEventDetailViewController.m
//  Play
//
//  Created by Darcy Allen on 2014-08-16.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaEventDetailViewController.h"
#import "plaViewController.h"
#import "plaEvent.h"
#import "plaEventData.h"
#import "FPPopoverController.h"
#import "FPPopoverKeyboardResponsiveController.h"
#import "plaTestViewController.h"
#import "plaWebServices.h"
#import "plaAppDelegate.h"
#import "plaEntity.h"
#import "plaCreateEventViewController.h"
#import "plaHomeViewController.h"
#import "plaFeedModel.h"
#import "plaHashtagFeedModel.h"

@interface plaEventDetailViewController ()

@end

@implementation plaEventDetailViewController

@synthesize m_parsedEvent;;
@synthesize m_textFieldWhere, m_arrayTableViewArtistData, m_createArtistEntity, m_createHostedByEntity, m_createWhereEntity, m_intCreateField, m_intCurrentSelectedArtist, m_textFieldArtists;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    m_arrayTblHashtag = [[NSMutableArray alloc] init];
    m_intTblViewHashTag = 500;
    
    g_controllerEventDetail = self;
    
    m_imageViewBackscreen.hidden = YES;
    m_viewCreateView.hidden = YES;
    
    m_createscrollView.contentSize = CGSizeMake(272, 850);
    
    m_intCurrentViewStatus = 3;
    if (m_intCurrentViewStatus == 3) {
        m_tableViewArtists.editing = YES;
        [m_tableViewArtists reloadData];
        //[self presentCreateEventView];
    }
    // Do any additional setup after loading the view.
    
    m_colorGray = [UIColor colorWithRed:151.0f/255.0f green:151.0f/255.0f blue:151.0f/255.0f alpha:1];
    m_colorGray = [UIColor lightGrayColor];
//    m_colorGray = [UIColor darkGrayColor];
    
    [self catchAutoRotationEvent];
    
    // show the event details
    
    plaEventData *globEvents = [plaEventData getInstance];
    int iObj = (int)globEvents.iglobEventRow;
    if ([g_arrayTemp count] < iObj + 1) {
        iObj = 0;
    }
    m_parsedEvent = [ g_arrayTemp objectAtIndex: iObj];
    globEvents.m_currentController = @"detailViewController";
    
    [self loadData];
}

-(void) viewWillAppear:(BOOL)animated
{
   
}

- (void) viewDidAppear:(BOOL)animated
{
    
    m_scrollViewImageList.contentSize = CGSizeMake(640, 114);
    NSLog(@"width=%f, height=%d", m_scrollView.contentSize.height, 12);
    
    m_scrollView.contentSize = CGSizeMake(320, 550 + m_intTblViewHashTag);
    
    CGAffineTransform affineTransform = CGAffineTransformMakeRotation(15.7079f / 2.0f);
    m_imageViewFullCoverImage.transform = affineTransform;
    
    plaEventData* globData = [plaEventData getInstance];
    globData.sglobControllerIndex = 2;
    
    //m_viewCreateView.hidden = YES;
}

-(void) loadDataFromFB:(plaEvent*)_event;
{
    m_parsedEvent = _event;
    
    [self performSelector:@selector(loadData) withObject:nil afterDelay:0.5f];
//    [self loadData];
}

-(void) getPhotoFeedDtaFromFB:(NSMutableArray *)_array
{
    m_arrayTblHashtag = _array;
    
    while ([_array count] > 20) {
        [m_arrayTblHashtag removeObjectAtIndex:10];
    }
    
    [m_tableViewHashtag2 reloadData];
    [m_tableViewHashtag reloadData];
}

- (void) loadData
{
    [self loadData:m_parsedEvent];
    
    if (m_parsedEvent.EV_SEVENTSTATE == -1) {
        [self changeToAttendState];
    } else if (m_parsedEvent.EV_SEVENTSTATE == 1) {
        [self changeToAttendingState];
    }
    
    [self getArrayMyEntitiesData];
    
    [self getEntityData];
}

- (plaEntity*)getEntityFromID:(plaEntity*)_entity
{
    NSString* _fbID = _entity.EN_SID;
    
    plaEntity* returnEntity;
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ([entity.EN_SID isEqualToString:_fbID]) {
            
            _entity.EN_SNAME = entity.EN_SNAME;
            _entity.EN_SIMAGE = entity.EN_SIMAGE;
            _entity.EN_SDISTANCE = entity.EN_SDISTANCE;
            _entity.EN_SCITY = entity.EN_SCITY;
            _entity.EN_SIMAGEPROFILE = entity.EN_SIMAGEPROFILE;
            _entity.EN_SADDRESSSTR = entity.EN_SADDRESSSTR;
            _entity.EN_SCATEGORY = entity.EN_SCATEGORY;
            _entity.EN_SLOCATION= entity.EN_SLOCATION;
            _entity.EN_SLOCATIONSTR = entity.EN_SLOCATIONSTR;
            
            _entity.EN_SFACEBOOKID = entity.EN_SFACEBOOKID;
            
            break;
        }
    }
    return returnEntity;
}

- (plaEntity*)getEntityFromFBID:(plaEntity*)_entity
{
    NSString* _fbID = _entity.EN_SFACEBOOKID;
    
    plaEntity* returnEntity;
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ([entity.EN_SID isEqualToString:_fbID]) {
            
            _entity.EN_SNAME = entity.EN_SNAME;
            _entity.EN_SIMAGE = entity.EN_SIMAGE;
            _entity.EN_SDISTANCE = entity.EN_SDISTANCE;
            _entity.EN_SCITY = entity.EN_SCITY;
            _entity.EN_SIMAGEPROFILE = entity.EN_SIMAGEPROFILE;
            _entity.EN_SADDRESSSTR = entity.EN_SADDRESSSTR;
            _entity.EN_SCATEGORY = entity.EN_SCATEGORY;
            _entity.EN_SLOCATION= entity.EN_SLOCATION;
            _entity.EN_SLOCATIONSTR = entity.EN_SLOCATIONSTR;
            
            break;
        }
    }
    return returnEntity;
}

- (void)loadData:(plaEvent*)parsedEvent
{
    [g_controllerView makeRequestForFBEventPhotos:parsedEvent.EV_SEVENTID];
    
    [g_controllerView makeUploadRequeat:parsedEvent];
    
    if (parsedEvent.EV_STICKETURL == nil || [parsedEvent.EV_STICKETURL isEqualToString:@""] || [parsedEvent.EV_STICKETURL isEqualToString:@"(null)"]) {
        m_btnTicketUri.hidden = YES;
    } else {
        m_btnTicketUri.hidden = NO;
    }
    
    [self getEntityFromID:parsedEvent.EV_SENTITY];
    if ([parsedEvent.EV_SENTITY.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self getEntityFromFBID:parsedEvent.EV_SENTITY];
    }
    
    [self getEntityFromID:parsedEvent.EV_SENTITYLOCATION];
    if ([parsedEvent.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self getEntityFromFBID:parsedEvent.EV_SENTITYLOCATION];
    }
    
    plaEventData*globData = [plaEventData getInstance];
    //m_btnEditing.hidden = true;
    //m_btnEdittingBG.hidden = true;
    m_isPossbleEditing = false;
    if ([globData.sglobUserID isEqualToString:@"10201503648988208"]) {
        //m_btnEditing.hidden = false;
        //m_btnEdittingBG.hidden = false;
        m_isPossbleEditing = true;
    }
    for (int i = 0; i < [globData.arrayglobMyEntities count]; i ++) {
        plaEntity* entityModel = [globData.arrayglobMyEntities objectAtIndex:i];
        if ([entityModel.EN_SID isEqualToString:parsedEvent.EV_SENTITY.EN_SID]) {
            //m_btnEditing.hidden = false;
            //m_btnEdittingBG.hidden = false;
            m_isPossbleEditing = true;
        }
    }
    
    m_imageViewEventPic.clipsToBounds = YES;
    [m_imageViewEventPic.layer setCornerRadius:35.0f];
    m_labelHostedBy.text = [NSString stringWithFormat:@"%@", parsedEvent.EV_SPERSONNAME];
    m_textViewDescription.text = parsedEvent.EV_SDESCRIPTION;
    
//    for (NSInteger j = 0; j < [globData.arrayglobDBEntities count]; j ++) {
//        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:j];
//        if ([parsedEvent.EV_SENTITYLOCATION.EN_SID isEqualToString:entity.EN_SID]) {
//            parsedEvent.EV_SLOCATION = entity.EN_SNAME;
//            parsedEvent.EV_SADDRESS = entity.EN_SLOCATIONSTR;
//            
//            int intdistand = [entity.EN_SLOCATION distanceFromLocation:globData.sglobLocation];
//            
//            parsedEvent.EV_SDISTANCE = (float)intdistand / distance_param;
//            entity.EN_SDISTANCE = [NSString stringWithFormat:@"%f", parsedEvent.EV_SDISTANCE];
//            //[NSString stringWithFormat:@"%.1f", ((float)intdistand) / distance_paramf];
//            
//            break;
//        }
//    }
    
    m_labelDistance.text = [NSString stringWithFormat:@"%.1f km", parsedEvent.EV_SDISTANCE];
    
    m_textViewDescription2.text = parsedEvent.EV_SDESCRIPTION;
    m_labelDistance.text = [NSString stringWithFormat:@"%.1f km", parsedEvent.EV_SDISTANCE];
    
    if ([parsedEvent.EV_SHASHTAGS isEqualToString:@"(null)"] || [parsedEvent.EV_SHASHTAGS isEqualToString:@""]) {
        m_labelHashTag.text = @"Feed";
        m_labelHashTag2.text = @"Feed";
    } else {
        m_labelHashTag.text = [NSString stringWithFormat:@"#%@ Feed", parsedEvent.EV_SHASHTAGS];
        m_labelHashTag2.text = [NSString stringWithFormat:@"#%@ Feed", parsedEvent.EV_SHASHTAGS];
    }
    
    self.lblEventName.text = parsedEvent.EV_SNAME;
    
    self.lblDateTime.text = parsedEvent.EV_SSTARTDATETIME;
    
    self.imgEvent.imageURL = [NSURL URLWithString:parsedEvent.EV_SIMAGE];
    m_imageViewEventPic.imageURL = [NSURL URLWithString: parsedEvent.EV_SIMAGE]; // --- image ------
    [m_imageViewFullCoverImage setImageURL:[NSURL URLWithString: parsedEvent.EV_SIMAGE]];
    
    [self getArtistEntity]; /// ------ artist image ------------
    
    UIImage* image = [UIImage imageNamed:@"artist.jpg"];
    
    [m_imageViewArtist1 setImage:image];
    [m_imageViewArtist2 setImage:image];
    [m_imageViewArtist3 setImage:image];
    [m_imageViewArtist4 setImage:image];
    
    [m_labelArtistName1 setText:@""];
    [m_labelArtistName2 setText:@""];
    [m_labelArtistName3 setText:@""];
    [m_labelArtistName4 setText:@""];
    
    image = [UIImage imageNamed:@"artist_yet.jpg"];
    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] > 0) {
        plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:0];
        
        if ( ([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
            entity.EN_SFACEBOOKID = @"";
            [m_imageViewArtist1 setImage:image];
            [m_labelArtistName1 setText:entity.EN_SNAME];
        } else {
            
            if (!(entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
                [self setImage:m_imageViewArtist1 entity:entity];
            } else {
                [m_imageViewArtist1 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE] ];
            }
            [m_labelArtistName1 setText:@""];
        }
    }
    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] > 1) {
        plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:1];
        if ( ([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""]) ) {
            entity.EN_SFACEBOOKID = @"";
            [m_labelArtistName2 setText:entity.EN_SNAME];
            [m_imageViewArtist2 setImage:image];
        } else {
            [m_labelArtistName2 setText:@""];
            if (!(entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
                [self setImage:m_imageViewArtist2 entity:entity];
            } else {
                [m_imageViewArtist2 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE] ];
            }
            
        }
    }
    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] > 2) {
        plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:2];
        if (([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
            entity.EN_SFACEBOOKID = @"";
            [m_labelArtistName3 setText:entity.EN_SNAME];
            [m_imageViewArtist3 setImage:image];
        } else {
            [m_labelArtistName3 setText:@""];
            if (!(entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
                [self setImage:m_imageViewArtist3 entity:entity];
            } else {
                [m_imageViewArtist3 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE] ];
            }
            
        }
    }
    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] > 3) {
        plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:3];
        if (([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
            entity.EN_SFACEBOOKID = @"";
            [m_labelArtistName4 setText:entity.EN_SNAME];
            [m_imageViewArtist4 setImage:image];
        } else {
            [m_labelArtistName4 setText:@""];
            if (!(entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) {
                [self setImage:m_imageViewArtist4 entity:entity];
            } else {
                [m_imageViewArtist4 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE] ];
            }
            
        }
    }
    
    // --------- image scroll -------
    m_scrollViewImageList.contentSize = CGSizeMake(640, 114);
    
    
    // --------- Attent acount ---------
    [m_labelAttendCount setText:[NSString stringWithFormat:@"%ld", (long)parsedEvent.EV_SATTENDCOUNT]];
    
    // --------- Attent Friends acount ---------
    [g_controllerViewHome calEventAttendFriendCount:parsedEvent];
    [m_labelAttendFriendCount setText:[NSString stringWithFormat:@"%ld", (long)parsedEvent.EV_SATTENDFRIENDCOUNT]];
    
    // --------- date --------------
    
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"]; // Sat Nov 22 8:00 pm
//    NSArray* arrayMonth1 = @[@"", @"Jan", @"Feb", @"Mar", @"Apr", @"May", @"Jun", @"Jul", @"Aug", @"Sep", @"Oct", @"Nov", @"Dec"];

    NSArray* temp = [parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
    NSArray* temp1 = [parsedEvent.EV_SENDDATE componentsSeparatedByString:@"T"];
    
    NSArray* arrayComDate = [[temp objectAtIndex:0] componentsSeparatedByString:@"-"];
    m_strDateDay = [arrayComDate objectAtIndex:2];

    if ([m_strDateDay isEqualToString:@"01"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@st", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"02"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@nd", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"03"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@rd", m_strDateDay];
    } else {
        m_strDateDay = [NSString stringWithFormat:@"%@th", m_strDateDay];
    }

    if ([temp count] > 1) {
        m_strDateTimeStart = [temp objectAtIndex:1];
        m_strDateTimeStart = [self convertTimeType:m_strDateTimeStart ];
    } else {
        m_strDateTimeStart = @"";
    }

    if ([temp1 count] > 1) {
        m_strDateTimeEnd = [temp1 objectAtIndex:1];
        m_strDateTimeEnd = [self convertTimeType:m_strDateTimeEnd ];
    } else {
        m_strDateTimeEnd = @"";
    }
    
    NSString* strMonthtemp = [arrayComDate objectAtIndex:1];
    m_strDateMonth = [arrayMonth objectAtIndex:strMonthtemp.integerValue];
    
    [m_labelDate setText:[NSString stringWithFormat:@"%@ %@", m_strDateMonth, m_strDateDay]];
    [m_labelTime setText: [NSString stringWithFormat:@"%@", m_strDateTimeStart]];

    // --------- location --------------
    
    [m_labelLocationState setText: parsedEvent.EV_SENTITYLOCATION.EN_SNAME];
    [m_labelLocationCity setText:parsedEvent.EV_SENTITYLOCATION.EN_SADDRESSSTR];
 
    
    [self performSelector:@selector(moveDescriptionView) withObject:nil afterDelay:1.0f];
}

- (void)setImage:(UIImageView*)_imageView entity:(plaEntity*)_entity
{
    plaEventData* globData = [plaEventData getInstance];
    
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i ++) {
        plaEntity* __entity = [globData.arrayglobDBEntities objectAtIndex:i];
        if ([__entity.EN_SID isEqualToString:_entity.EN_SFACEBOOKID]) {
            [_imageView setImageURL:[NSURL URLWithString:__entity.EN_SIMAGE]];
        }
    }
}

- (void) moveDescriptionView
{    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] == 0) {
        m_pageControlImageList.hidden = YES;
        m_scrollViewImageList.hidden = YES;
        //_centerPoint.y = _centerPoint.y - 113;
        m_viewDescription2.hidden = false;
        //m_viewCreateView.hidden = true;
    } else {
        m_pageControlImageList.hidden = false;
        m_scrollViewImageList.hidden = false;
        //m_labelDescription2.hidden = true;
        //m_textViewDescription2.hidden = true;
        m_viewDescription2.hidden = true;
        //m_viewCreateView.hidden = false;
    }
    
//    [UIView beginAnimations:@"" context:nil];
//    [UIView setAnimationDuration:1.0f];
//    
//    [m_viewDescription setCenter:_centerPoint];
//    
//    [UIView commitAnimations];

}

- (void)getEntityData
{
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];

        if ([entity.EN_SID isEqualToString:m_parsedEvent.EV_SENTITY.EN_SID]) {
            m_parsedEvent.EV_SENTITY = entity;
        } else if ([entity.EN_SID isEqualToString:m_parsedEvent.EV_SENTITYLOCATION.EN_SID]) {
            m_parsedEvent.EV_SENTITYLOCATION = entity;
        }
    }
}

- (void)getArrayMyEntitiesData
{
    NSMutableArray* array = [[NSMutableArray alloc] init];
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobMyEntities count]; i ++) {
        plaEntity* entityTemp1 = [globData.arrayglobMyEntities objectAtIndex:i];
        for (int j = 0; j < [globData.arrayglobDBEntities count]; j ++) {
            plaEntity* entityTemp2 = [globData.arrayglobDBEntities objectAtIndex:j];
            if ([entityTemp1.EN_SID isEqualToString:entityTemp2.EN_SID]) {
                //                entityTemp1 = entityTemp2;
                [array addObject:entityTemp2];
                break;
            }
        }
    }
    globData.arrayglobMyEntities = array;
}

- (void)getArtistEntity
{
    plaEventData* globData = [plaEventData getInstance];
    m_parsedEvent.EV_SARRAYARTISTS = [[NSMutableArray alloc] init];
    
    NSArray* array = [m_parsedEvent.EV_SENTITYARTISTID componentsSeparatedByString:@"***"];
    for (int j = 0; j < [array count]; j ++) {
        NSString* strTemp = [array objectAtIndex:j];
        
        for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
            plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
            
            if ([entity.EN_SID isEqualToString:strTemp])
            {
                [m_parsedEvent.EV_SARRAYARTISTS addObject:entity];
                break;
            }
        }
    }
}

- (UIImage*)loadImage:(NSString*)name
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* path = [documentsDirectory stringByAppendingPathComponent: name ];
    UIImage* image = [UIImage imageWithContentsOfFile:path];
    return image;
}

- (NSString*) convertTimeType:(NSString*)_time
{
    NSString* strTime;
    NSArray* temp = [_time componentsSeparatedByString:@":"];
    NSString* strHour = [temp objectAtIndex:0];
    NSString* strMin = [temp objectAtIndex:1];
    
    NSInteger intHour = strHour.integerValue;
    if (intHour > 12) {
        intHour = intHour - 12;
        strTime = [NSString stringWithFormat:@"%ld:%@pm", (long)intHour, strMin];
    } else {
        strTime = [NSString stringWithFormat:@"%ld:%@am", (long)intHour, strMin];
    }
    
    return strTime;
}

-(void)updatePlayEvent:(plaEvent *)thePlayEvent
{
    plaEventData* globEvents = [plaEventData getInstance];
    for (int i = 0; i < [globEvents.arrayglobDBEvents count]; i ++) {
        plaEvent* eventModel = [globEvents.arrayglobDBEvents objectAtIndex:i];
        if ([eventModel.EV_SEVENTID isEqualToString:m_parsedEvent.EV_SEVENTID]) {
            //eventModel = m_parsedEvent;
            [globEvents.arrayglobDBEvents insertObject:m_parsedEvent atIndex:i];
            [globEvents.arrayglobDBEvents removeObject:eventModel];
        }
    }
    // instantiate our custom Web Services object and call the background Insert Event command:
    plaWebServices *webServ = [[plaWebServices alloc] init];
    //    NSInteger iResult = [webServ backgroundInsertEvent:thePlayEvent.EV_SEVENTID withName:thePlayEvent.EV_SNAME  atDate:thePlayEvent.EV_SSTARTDATETIME atLoc:thePlayEvent.EV_SLOCATION withImg:thePlayEvent.EV_SIMAGE ];
    NSInteger iResult = [webServ backgroundUpdateEventAttendState:thePlayEvent];
    NSLog( @"iResult = %d", (int)iResult );
    
    
}

- (void) insertActivityFeed:(NSString*)_action
{
    plaEventData* globEvents = [plaEventData getInstance];
    plaFeedModel* _feedModel = [[plaFeedModel alloc] init];
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    
    _feedModel.FEED_ID = [NSString stringWithFormat:@"%ld", (long)today];
    _feedModel.FEED_USER = globEvents.sglobUserID;
    _feedModel.FEED_CONTENT = m_parsedEvent.EV_SEVENTID;
    _feedModel.FEED_ACTION = _action;
    
    plaWebServices* webServices = [[plaWebServices alloc] init];
    [webServices backgroundInsertFeed:_feedModel];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void) changeToAttendingState
{
    UIImage* _image = [UIImage imageNamed:@"Attending Icon 1.png"];
    [m_labelAtten setText:@"Attending"];
    [m_imageViewAttenIcon setImage:_image];
    [m_labelAtten setTextColor:m_colorGray];
    
    [self insertActivityFeed:@"Attend"];
}

- (void) changeToAttendState
{
    UIImage* _image = [UIImage imageNamed:@"Attend Icon 1.png"];
    [m_labelAtten setText:@"Attend"];
    [m_imageViewAttenIcon setImage:_image];
    [m_labelAtten setTextColor:[UIColor darkGrayColor]];
    
    [self insertActivityFeed:@"unAttend"];
}

#pragma mark ---- UI device rotate -----
- (void)catchAutoRotationEvent
{
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(orientationChanged:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    [m_imageViewFullCoverImage setImage:m_imageViewEventPic.image];
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {        
        [self showCoverFullImage];
        
        if (deviceOrientation == UIDeviceOrientationLandscapeLeft) {
            CGAffineTransform affineTransform = CGAffineTransformMakeRotation(15.7079f / 2.0f);
            m_imageViewFullCoverImage.transform = affineTransform;
            
            m_buttonCloseIcon.hidden = true;
            m_buttonCloseIcon1.hidden = false;
            m_buttonCloseIcon2.hidden = true;
            
        } else {
            CGAffineTransform affineTransform = CGAffineTransformMakeRotation(-15.7079f / 2.0f);
            m_imageViewFullCoverImage.transform = affineTransform;
            
            m_buttonCloseIcon.hidden = false;
            m_buttonCloseIcon1.hidden = true;
            m_buttonCloseIcon2.hidden = true;
        }
    }
    else if (UIDeviceOrientationIsPortrait(deviceOrientation) )
    {
        [self hideCoverFullImage];
    }
}

#pragma mark ---- delegate go to the EntityPgae -------

-(IBAction)btnHostedBy:(id)sender
{

    plaEventData *globEvents = [plaEventData getInstance];

    globEvents.iglobEventRow = [g_arrayTemp count];
    m_parsedEvent.EV_SENTITYSTATE  = 1;
    [g_arrayTemp addObject:m_parsedEvent];
    
    [self goEntityPage];
}

-(IBAction)btnLocation:(id)sender
{
    plaEventData *globEvents = [plaEventData getInstance];

    globEvents.iglobEventRow = [g_arrayTemp count];
    m_parsedEvent.EV_SENTITYSTATE  = 2;
    [g_arrayTemp addObject:m_parsedEvent];

    [self goEntityPage];
}

-(IBAction)btnArtist:(id)sender
{
    UIButton* button = (UIButton*)sender;
    
    if ([m_parsedEvent.EV_SARRAYARTISTS count] < button.tag + 1) {
        return;
    }
    
    plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:button.tag];
    m_parsedEvent.EV_SENTITYARTIST = entity;
    
    plaEventData *globEvents = [plaEventData getInstance];

    globEvents.iglobEventRow = [g_arrayTemp count];
    m_parsedEvent.EV_SENTITYSTATE  = 3;
    [g_arrayTemp addObject:m_parsedEvent];
    
    [self goEntityPage];
}

-(IBAction)btnImageSlider:(id)sender
{
    [self goEntityPage];
}

- (IBAction)btnCoverImageFull:(id)sender {
    [self showCoverFullImage];
}

- (IBAction)btnCoverImageCollapes:(id)sender{
    [self hideCoverFullImage];
}

- (IBAction)btnExpandDescription:(id)sender {
    
    UIButton* _button = (UIButton*)sender;
    CGPoint centerPoint = m_viewImageFeed.center;
    CGPoint centerPoint1 = m_viewImageFeed1.center;
    UIImage* image, *image0;
    
    if (_button.tag == 0) { // To expend
        _button.tag = 1;
        image = [UIImage imageNamed:@"collapse arrow icon.png"];
        
        //[_button setTitle:@"Collapes" forState:0];
        centerPoint.y = centerPoint.y + m_textViewDescription.contentSize.height + 50 - 115;
        centerPoint1.y = centerPoint1.y + m_textViewDescription.contentSize.height + 50 - 115;
        
        m_scrollView.contentSize = CGSizeMake(320, 550 + m_textViewDescription.contentSize.height + m_intTblViewHashTag);
    } else { // To Callapse
        _button.tag = 0;
        image = [UIImage imageNamed:@"expand arrow icon.png"];
        
        //[_button setTitle:@"Expand" forState:0];
        centerPoint.y = centerPoint.y - m_textViewDescription.contentSize.height - 50 + 115;
        centerPoint1.y = centerPoint1.y - m_textViewDescription.contentSize.height - 50 + 115;
        
        m_scrollView.contentSize = CGSizeMake(320, 550 + m_intTblViewHashTag);
    }
    image0 = [[UIImage alloc] init];
    [m_btnExpand0 setBackgroundImage:image0 forState:0];
    [m_btnExpand02 setBackgroundImage:image0 forState:0];
    
    [m_btnExpand setTitle:@"" forState:0];
    [m_btnExpand setBackgroundImage:image forState:0];
    [m_btnExpand2 setTitle:@"" forState:0];
    [m_btnExpand2 setBackgroundImage:image forState:0];
    
    [UIView beginAnimations:@"" context:nil];
    [UIView setAnimationDuration:1.0f];
    
    [m_viewImageFeed setCenter:centerPoint];
    [m_viewImageFeed1 setCenter:centerPoint1];
    
    [UIView commitAnimations];
}

-(IBAction)onReturnEventDetailFromSeq:(UIStoryboardSegue*)sender
{
    //[self onGoAttend:nil];
}

// ------------------------
-(void) goEntityPage
{
    [self performSegueWithIdentifier: @"segueToEntityPage" sender:self];
}

-(void) showCoverFullImage
{
    m_imageViewFullCoverImage.hidden = NO;
    m_buttonCloseIcon2.hidden = NO;
}

-(void) hideCoverFullImage
{
    m_imageViewFullCoverImage.hidden = YES;
    m_buttonCloseIcon.hidden = true;
    m_buttonCloseIcon1.hidden = true;
    m_buttonCloseIcon2.hidden = true;
}

#pragma mark -------- delegate -----------  actionshoot for setting event------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (actionSheet.tag == 2) { // To invite event to friend
        switch (buttonIndex) {
            case 0:  // --------------- click invite friend Item ---------
                [self performSegueWithIdentifier:@"segueToSelectUser" sender:self];
                break;
                
            default:
                break;
        }
        
    } else     if (actionSheet.tag == 1) {
        UIImagePickerController* picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        switch (buttonIndex) {
            case 0:  // --------------- click PhotoLibrary Item ---------
                picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                break;
                
            case 1:  // --------------- click Camera Item ---------
                picker.sourceType = UIImagePickerControllerSourceTypeCamera;
                break;
                
            default:
                break;
        }
        
        [self presentViewController:picker animated:YES completion:nil];
    } else if (actionSheet.tag == 0) { // to be possible to edit event
        switch (buttonIndex) {
            case 0:
                [self goEditingEvent];
                break;
                
            case 1:
                
                break;
                
            case 2:
                
                break;
                
            case 3: ///// Edit Event
                //[self goEditingEvent];
                break;
                
            default:
                break;
        }
    } else if (actionSheet.tag == -1) { // to be possible to edit event
        switch (buttonIndex) {
            case 0:
                [self goReportEvent];
                break;
                
            case 1:
                
                break;
                
            case 2:
                
                break;
                
            case 3: ///// Edit Event
                //[self goEditingEvent];
                break;
                
            default:
                break;
        }
    }
}

-(void) goEditingEvent
{
    if ([m_parsedEvent.EV_SEVENTID rangeOfString:@"db"].location == NSNotFound) {
//        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"I am sorry. You can't edit FB event yet." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
//        [alertView show];
//        return;
    }
    [self setEventData];
    [m_pickerAdmins reloadAllComponents];
    [m_pickerCategory reloadAllComponents];
    [self presentCreateEventView];
}

- (void) setEventData
{
    [m_imageViewCreateEventPhoto setImageURL:[NSURL URLWithString:m_parsedEvent.EV_SIMAGE] ];
    [m_imageViewFullCoverImage setImageURL:[NSURL URLWithString:m_parsedEvent.EV_SIMAGE]];
    
    m_textFieldEventName.text = m_parsedEvent.EV_SNAME;
    
    m_createHostedByEntity = m_parsedEvent.EV_SENTITY;
    m_textFieldAdmins.text = m_parsedEvent.EV_SPERSONNAME;
    
    m_createWhereEntity = m_parsedEvent.EV_SENTITYLOCATION;
    m_textFieldWhere.text = m_parsedEvent.EV_SLOCATION;
    
    m_arrayTableViewArtistData = m_parsedEvent.EV_SARRAYARTISTS;
    [m_tableViewArtists reloadData];
    
    m_textFieldTicketsURL.text = m_parsedEvent.EV_STICKETURL;
    
    NSArray* array = [m_parsedEvent.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
    if ([array count] == 2) {
        m_textFieldStartDate.text = [array objectAtIndex:0];
        m_textFieldStartTime.text = [array objectAtIndex:1];
    } else if ([array count] == 1) {
        m_textFieldStartDate.text = [array objectAtIndex:0];
        m_textFieldStartTime.text = @"";
    } else {
        m_textFieldStartDate.text = @"";
        m_textFieldStartTime.text = @"";
    }
    
    m_textFieldHashtagsForEvent.text = m_parsedEvent.EV_SHASHTAGS;
    m_textFieldCategory.text = m_parsedEvent.EV_SCATEGORY;
    
    m_textViewDescription1.text = m_parsedEvent.EV_SDESCRIPTION;
}

#pragma mark --- delegate ---------------- popover ------
-(IBAction)btnSetting:(id)sender
{
    UIActionSheet* actionSheet ;
    if (m_isPossbleEditing) { // To be possible to edit event
        actionSheet = [[UIActionSheet alloc] initWithTitle:@"Event Settings" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Edit Event", nil];  // @"Feature This Event", @"Event Tools", @"Sell Tickets",
        actionSheet.tag = 0;  /// tag = 0 for
    } else { // to report
        actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Report Event", nil];  // @"Feature This Event", @"Event Tools", @"Sell Tickets",
        actionSheet.tag = -1;  /// tag = 0 for
    }
    [actionSheet showInView:self.view];
}

- (IBAction)onGoAttend:(id)sender
{
    
    [UIView beginAnimations:UIViewAnimationCurveEaseInOut context:nil];
//    [UIView setAnimationTransition:UIViewAnimationOptionTransitionFlipFromRight forView:self.view cache:YES];
    [UIView setAnimationDelay:1.0f];
    
    m_viewPopover.hidden = false;
    
    [UIView commitAnimations];
}

- (IBAction)onBtnInvite:(id)sender { //segueToSelectUser
    [self performSegueWithIdentifier:@"segueToSelectUser" sender:self];
    //    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"invite friend", nil];
    //    actionSheet.tag = 2; // for inviting event
    //    [actionSheet showInView:self.view];
}

- (IBAction)onBtnInviteFriends:(id)sender { //segueToSelectUser
    
    [self performSegueWithIdentifier:@"segueToSelectUser" sender:self];
    //    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"invite friend", nil];
    //    actionSheet.tag = 2; // for inviting event
    //    [actionSheet showInView:self.view];
}

- (void) changeLabelColor:(UILabel*)_label color:(UIColor*)_color
{
    [_label setTextColor:_color];
}

- (void)presentedNewPopoverController:(FPPopoverController *)newPopoverController
          shouldDismissVisiblePopover:(FPPopoverController*)visiblePopoverController
{
    [visiblePopoverController dismissPopoverAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark ---  delegate imagelist scroll
- (void)scrollViewDidScroll:(UIScrollView *)scrollView;
{
    CGFloat pageWidth = m_scrollViewImageList.frame.size.width;
    int page = floor((m_scrollViewImageList.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    m_pageControlImageList.currentPage = page;
}

- (IBAction)changePage:(id)sender
{
    CGRect frame;
    frame.origin.x = m_scrollViewImageList.frame.size.width * m_pageControlImageList.currentPage;
    frame.origin.y = 0;
    frame.size = m_scrollViewImageList.frame.size;
    [m_scrollViewImageList scrollRectToVisible:frame animated:YES];
}

#pragma mark ----- To make sorting item -------
- (void)makeSortingItem:(plaEvent*)_model
{
    NSString* sortDistance, *sortDate, *sortAttendCount; //
    sortDistance = [NSString stringWithFormat:@"%.1f", _model.EV_SDISTANCE];
    if ([_model.EV_SSTARTDATETIME isEqualToString:@""]) {
        sortDate = @"0000-00-00";
    }
    NSArray* arrayTemp = [_model.EV_SSTARTDATETIME componentsSeparatedByString:@"T"];
    sortDate = (NSString*)[arrayTemp objectAtIndex:0];
    arrayTemp = [sortDate componentsSeparatedByString:@"-"];
    sortAttendCount = [NSString stringWithFormat:@"%ld", (long)(100000 - _model.EV_SATTENDCOUNT - 1)];
    
    // sorting order ------- distance, sortDate, sortAttendCount
    _model.EV_SSORTINGITEM = [NSString stringWithFormat:@"%@%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2], sortAttendCount];
}

#pragma mark --- calculate upcomming, activity feed count -----------
-(void)CALUPCOMMINGUSERARRAY:(NSString*)_userid
{
    if ([m_parsedEvent.EV_SACTIVITYUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [m_parsedEvent.EV_SACTIVITYUSERARRAY removeObject:_userid];
    }
    [m_parsedEvent.EV_SACTIVITYUSERARRAY addObject:_userid];
    
    if ([m_parsedEvent.EV_SUPCOMMINGUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [m_parsedEvent.EV_SUPCOMMINGUSERARRAY removeObject:_userid];
    }
    [m_parsedEvent.EV_SUPCOMMINGUSERARRAY addObject:_userid];
}

-(void)CALACTIVITYUSERARRAY:(NSString*)_userid;
{
    if ([m_parsedEvent.EV_SUPCOMMINGUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [m_parsedEvent.EV_SUPCOMMINGUSERARRAY removeObject:_userid];
    }
    //        [self.EV_SUPCOMMINGUSERARRAY addObject:_userid];
    
    if ([m_parsedEvent.EV_SACTIVITYUSERARRAY indexOfObject:_userid] != NSNotFound) {
        [m_parsedEvent.EV_SACTIVITYUSERARRAY removeObject:_userid];
    }
    
    [m_parsedEvent.EV_SACTIVITYUSERARRAY addObject:_userid];
}

#pragma mark ---   delegate popover ---

- (IBAction)onBtnBuyTickets:(id)sender
{
    if (m_parsedEvent.EV_STICKETURL != nil) {
        if (![m_parsedEvent.EV_STICKETURL containsString:@"https://"] && ![m_parsedEvent.EV_STICKETURL containsString:@"http://"]) {
            m_parsedEvent.EV_STICKETURL = [NSString stringWithFormat:@"http://%@", m_parsedEvent.EV_STICKETURL];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:m_parsedEvent.EV_STICKETURL]];
    }
}

- (IBAction)onBtnAddtoCal:(id)sender
{
    
}

- (IBAction)onBtnUnattend:(id)sender
{
    plaEventData* globData = [plaEventData getInstance];
    [self CALACTIVITYUSERARRAY:globData.sglobUserID];
    
    if (m_parsedEvent.EV_SEVENTSTATE == 1 && m_parsedEvent.EV_SATTENDCOUNT > 0) {
        m_parsedEvent.EV_SATTENDCOUNT = m_parsedEvent.EV_SATTENDCOUNT - 1;
        m_parsedEvent.EV_SEVENTSTATE = -1;
    }
    [self makeSortingItem:m_parsedEvent];
    
    if ([g_arrayUpcommingEventData indexOfObject:m_parsedEvent] != NSNotFound) {
        [g_arrayUpcommingEventData removeObject:m_parsedEvent];
    }

    if ([g_arrayActivityFeedData indexOfObject:m_parsedEvent] == NSNotFound) {
        [g_arrayActivityFeedData addObject:m_parsedEvent];
    }
    
    [self changeToAttendState];
    
    [self hidePopoverView];
}

- (IBAction)onBtnNoTanks:(id)sender
{
    [self changeToAttendingState];
    
    plaEventData* globData = [plaEventData getInstance];
    [self CALUPCOMMINGUSERARRAY:globData.sglobUserID];
    
    if (m_parsedEvent.EV_SEVENTSTATE != 1) {
        m_parsedEvent.EV_SATTENDCOUNT = m_parsedEvent.EV_SATTENDCOUNT + 1;
        m_parsedEvent.EV_SEVENTSTATE = 1;
    }
    [self makeSortingItem:m_parsedEvent];
    
    if ([g_arrayActivityFeedData indexOfObject:m_parsedEvent] != NSNotFound) {
//        [g_arrayActivityFeedData removeObject:m_parsedEvent];
    }
    
    if ([g_arrayUpcommingEventData indexOfObject:m_parsedEvent] == NSNotFound) {
        [g_arrayUpcommingEventData addObject:m_parsedEvent];
    }
    
    [self changeToAttendingState];
    
    [self hidePopoverView];
}

- (void) hidePopoverView
{
    [m_labelAttendCount setText:[NSString stringWithFormat:@"%d", (int)m_parsedEvent.EV_SATTENDCOUNT] ];
    
    [UIView beginAnimations:UIViewAnimationCurveEaseInOut context:nil];
    [UIView setAnimationDelay:1.0f];
    
    m_viewPopover.hidden = true;
    
    [UIView commitAnimations];
    
    [self updatePlayEvent:m_parsedEvent];
}
// back button:

#pragma mark ------- delegate -------- Create View -------
-(IBAction)onBtnAddArtist:(id)sender // to click 'add artist button'
{
    m_createArtistEntity = nil;
    m_intCurrentSelectedArtist = [m_arrayTableViewArtistData count];
    [self goSearchPageForArtists];
}

-(IBAction)onBtnCancel:(id)sender
{
    [self dismissCreateEventView];
}

-(IBAction)onBtnSave:(id)sender
{
    if ( [m_textFieldEventName.text isEqualToString:@""] ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Event Name' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldWhere.text isEqualToString:@""]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Where' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldStartDate.text isEqualToString:@""] || [m_textFieldStartTime.text isEqualToString:@""] ) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Start Date' and 'Start Time' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    if ([m_textFieldAdmins.text isEqualToString:@""]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:@"Please fill out 'Hosted By' field." delegate:nil cancelButtonTitle:@"Confirm" otherButtonTitles: nil];
        [alertView show];
        return;
    }
    [self saveEventData];
    
    //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
    
    [self dismissCreateEventView];
}

-(IBAction)onBtnCancelField:(id)sender
{
    [self cancelChange];
}

-(IBAction)onBtnSaveField:(id)sender
{
    UIButton* button = (UIButton*)sender;
    NSInteger intSelectedRow;
    plaEntity* entity;
    NSString* strCategoryData;
    
    plaEventData* globData = [plaEventData getInstance];
    
    
    if (button.tag == 3) {
        intSelectedRow = [m_pickerCategory selectedRowInComponent:0];
        strCategoryData = [globData.arrayglobCategories objectAtIndex:intSelectedRow];
    } else {
        intSelectedRow = [m_pickerAdmins selectedRowInComponent:0];
        entity = [globData.arrayglobMyEntities objectAtIndex:intSelectedRow];
    }
    
    switch (button.tag) {
        case 0: // filed ---- start date
            [self saveStartDate];
            break;
            
        case 1: // filed ----- start time
            [self saveStartTime];
            break;
            
        case 2: // filed ------ hostedby(Admins)
            
            m_createHostedByEntity = entity;
            [m_textFieldAdmins setText:entity.EN_SNAME];
            
            break;
            
        case 3: // filed ------ hostedby(Admins)
            
            [m_textFieldCategory setText:strCategoryData];
            
            break;
            
        default:
            break;
    }
    [self saveChange];
}

-(IBAction)onChangePicture:(id)sender
{
    UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:@"Choose Pictures" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Photo Library", @"Camera", nil];
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

#pragma mark --------Create View--------- backgournd functions -------------
-(void)dismissCreateEventView
{
    [self resetCreateEntityObject];
    m_intCurrentViewStatus = 2;
    m_viewCreateView.hidden = YES;
    m_imageViewBackscreen.hidden = YES;
    //m_viewFront.userInteractionEnabled = YES;
}

-(void)saveEventData
{
//    if (g_arrayTemp == nil) {
//        g_arrayTemp = [[NSMutableArray alloc] init];
//    }
    
    plaEventData *globEvents = [plaEventData getInstance];
    
    globEvents.iglobEventRow = [g_arrayTemp count];
    
    //plaEvent* event = [[plaEvent alloc] init];
    
    //NSInteger today = [[NSDate date] timeIntervalSince1970];
    //event.EV_SEVENTID = [NSString stringWithFormat:@"db%ld", today];
    m_parsedEvent.EV_SEVENTID = m_parsedEvent.EV_SEVENTID;
    
    m_parsedEvent.EV_SNAME = m_textFieldEventName.text;
    
    m_parsedEvent.EV_SLOCATION = m_textFieldWhere.text;
    m_parsedEvent.EV_SENTITYLOCATION = m_createWhereEntity;
    
    m_parsedEvent.EV_STICKETURL = m_textFieldTicketsURL.text;
    
    NSDate* startTime = [m_pickerStartTime date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"HH:mm"];
    NSString* strstartTime = [dateFromat stringFromDate:startTime];
    if ([m_textFieldStartTime.text isEqualToString:@""]) {
        strstartTime = @"";
    }
    
    m_parsedEvent.EV_SSTARTDATETIME = [NSString stringWithFormat:@"%@T%@:00", m_textFieldStartDate.text, strstartTime];
    
    m_parsedEvent.EV_SPERSONNAME = m_createHostedByEntity.EN_SNAME;
    m_parsedEvent.EV_SENTITY = m_createHostedByEntity;
    
    m_parsedEvent.EV_SDESCRIPTION = m_textViewDescription1.text;
    m_scrollView.contentSize = CGSizeMake(320, 550 + m_intTblViewHashTag);
    //event.EV_SDESCRIPTION1 = m_textViewDescription.text;
    
    m_parsedEvent.EV_SCATEGORY = m_textFieldCategory.text;
    m_parsedEvent.EV_SHASHTAGS = m_textFieldHashtagsForEvent.text;
    
    if (m_strCreateEventPhoto != nil && ![m_strCreateEventPhoto isEqualToString:@""]) {
        [self uploadCoverImage];
        m_parsedEvent.EV_SIMAGE =  [NSString stringWithFormat:@"http://playentertainmentnetwork.com/ws/images/%@", m_strCreateEventPhoto];
        m_strCreateEventPhoto = @"";
    } else {
        m_parsedEvent.EV_SIMAGE = m_parsedEvent.EV_SIMAGE;
    }
    
    m_parsedEvent.EV_SENTITYLOCATION = m_createWhereEntity;
    m_parsedEvent.EV_SSTREET = m_createWhereEntity.EN_SSTREET;
    m_parsedEvent.EV_SCITY = m_createWhereEntity.EN_SCITY;
    
    m_parsedEvent.EV_SARRAYARTISTS = m_arrayTableViewArtistData;
    
    NSString* strArtistIDs = @"";
    for (int i = 0; i < [m_parsedEvent.EV_SARRAYARTISTS count]; i ++) {
        plaEntity* entity = [m_parsedEvent.EV_SARRAYARTISTS objectAtIndex:i];
        if (i == 0) {
            strArtistIDs = entity.EN_SID;
        } else {
            strArtistIDs = [NSString stringWithFormat:@"%@***%@",strArtistIDs, entity.EN_SID];
        }
    }
    
    m_parsedEvent.EV_SENTITY = m_createHostedByEntity;
    m_parsedEvent.EV_SENTITYARTIST = [[plaEntity alloc] init];
    m_parsedEvent.EV_SENTITYARTIST.EN_SID = m_createArtistEntity.EN_SID;
    
    m_parsedEvent.EV_SENTITYARTISTID = strArtistIDs;
    
//    globEvents.iglobEventRow = [g_arrayTemp count];
//    [g_arrayTemp addObject:event];
//    [globEvents.arrayglobDBEvents addObject:event];
    
    [self loadData:m_parsedEvent];
    
    for (int i = 0; i < [globEvents.arrayglobDBEvents count]; i ++) {
        plaEvent* eventModel = [globEvents.arrayglobDBEvents objectAtIndex:i];
        if ([eventModel.EV_SEVENTID isEqualToString:m_parsedEvent.EV_SEVENTID]) {
            //eventModel = m_parsedEvent;
            [globEvents.arrayglobDBEvents insertObject:m_parsedEvent atIndex:i];
            [globEvents.arrayglobDBEvents removeObject:eventModel];

        }
    }
    // --------------------------------------------- to save event to DB ---------------------------------------
    plaWebServices *webServ = [[plaWebServices alloc] init];
    [webServ backgroundUpdateEvent:m_parsedEvent];
    
}

-(void)uploadCoverImage
{
    plaWebServices* webService = [[plaWebServices alloc] init];
    
    [webService uploadImage:m_imageCreateEventPhoto name:m_strCreateEventPhoto];
}
-(void)saveStartDate
{
    //NSString* strTemp = [m_pickerStartDate description];
    NSDate* startDate = [m_pickerStartDate date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"yyyy-MM-dd"];
    NSString* strstartDate = [dateFromat stringFromDate:startDate];
    
    [m_textFieldStartDate setText:strstartDate];
}

-(void)saveStartTime
{
    //NSString* strTemp = [m_pickerStartDate description];
    NSDate* startDate = [m_pickerStartTime date];
    NSDateFormatter* dateFromat = [[NSDateFormatter alloc] init];
    [dateFromat setDateFormat:@"hh:mm aa"];
    NSString* strstartDate = [dateFromat stringFromDate:startDate];
    
    [m_textFieldStartTime setText:strstartDate];
}

-(void)saveHostedBy
{
    NSString* strHostedBy = [m_pickerAdmins description];
    
    [m_textFieldAdmins setText:strHostedBy];
}

-(void)goSearchPageForArtists
{
    m_intCreateField = 2;
    [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
}

#pragma mark -------------Create View --------delegate ------ actionsheet for choose cover picture ----------
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    m_imageCreateEventPhoto = [info valueForKey:UIImagePickerControllerOriginalImage];
    [m_imageViewCreateEventPhoto setImage:m_imageCreateEventPhoto];
    [m_imageViewFullCoverImage setImage:m_imageCreateEventPhoto];
    
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    m_strCreateEventPhoto = [NSString stringWithFormat:@"img%ld.png", (long)today];
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -------delegate --------------------tableview -----------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:m_tableViewHashtag2] || [tableView isEqual:m_tableViewHashtag]) {
        m_intTblViewHashTag = [m_arrayTblHashtag count] * 390;
        
        if ([m_arrayTableViewArtistData count] > 0) { // To add 114 as according to if there is artist data
            m_intTblViewHashTag = m_intTblViewHashTag + 114;
        }
        
        m_scrollView.contentSize = CGSizeMake(320, 550 + m_intTblViewHashTag);
        return [m_arrayTblHashtag count];
    }
    
    return [m_arrayTableViewArtistData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:m_tableViewHashtag2] || [tableView isEqual:m_tableViewHashtag]) {
        return 390;
    }
    
    return 54;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell;
    
    if ([tableView isEqual:m_tableViewHashtag2] || [tableView isEqual:m_tableViewHashtag]) {
        cell = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        plaHashtagFeedModel* _model = [m_arrayTblHashtag objectAtIndex:indexPath.row];
        
        UIImageView* _imageView = (UIImageView*)[cell viewWithTag:1];
        [_imageView setImageURL: [NSURL URLWithString:_model.HASHTAG_PHOTOURL]];
        
        UILabel* _lbl = (UILabel*)[cell viewWithTag:3];
        _lbl.text = [NSString stringWithFormat:@"@%@", _model.HASHTAG_NAME];
        
        _lbl = (UILabel*)[cell viewWithTag:4];
        _lbl.text = _model.HASHTAG_DATE;
        
        return cell;
    } else {
        UITableViewCell* cell_artist = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        plaEntity* tempArtist = [m_arrayTableViewArtistData objectAtIndex:indexPath.row];
        UIImageView* imageView = (UIImageView*)[cell_artist.contentView viewWithTag:10];
        
        [imageView setImageURL:[NSURL URLWithString:tempArtist.EN_SIMAGE]];
        
        if ([m_arrayTableViewArtistData count] > 3) {
            m_viewArtistAdd.hidden = YES;
        } else if ([m_arrayTableViewArtistData count] < 4) {
            m_viewArtistAdd.hidden = NO;
        }
        
        return cell_artist;
    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:m_tableViewHashtag2] || [tableView isEqual:m_tableViewHashtag]) {
        return;
    }
    else {
        m_intCurrentSelectedArtist = indexPath.row;
        plaEntity* tempArtist = [m_arrayTableViewArtistData objectAtIndex:indexPath.row];
        m_createArtistEntity = tempArtist;
        [self goSearchPageForArtists];
    }
}

-(void)sendToDetailPage:(plaEvent*)_model
{
//    plaEventData *globData = [plaEventData getInstance];
//    
//        NSUInteger intTemp = [globData.arrayglobDBEvents indexOfObject:_model];
//        
//        globData.iglobEventRow = intTemp;
//    
    //[self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
}

// each row of the table launches its detail screen of its Event

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}
// Controls whether the background is indented while editing.  If not implemented, the default is YES.  This is unrelated to the indentation level below.  This method only applies to grouped style table views.

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        
        [m_arrayTableViewArtistData removeObjectAtIndex:indexPath.row];
        // Event when deleting tableviewcell
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
    
    [m_tableViewArtists reloadData];
}

- (void)moveRowAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    [m_tableViewArtists exchangeSubviewAtIndex:indexPath.row withSubviewAtIndex:newIndexPath.row];
}

// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    // Event when moving tableviewcell
    
    [m_arrayTableViewArtistData exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
    
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    return true;
}


#pragma mark -------------Create View --------delegate ------ uipicker view for Admin(Hostedby) -----
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    plaEventData* globData = [plaEventData getInstance];
    if (pickerView.tag == 3) {
        return [globData.arrayglobCategories count];
    }
    return [globData.arrayglobMyEntities count];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    plaEventData* globData = [plaEventData getInstance];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.frame.size.width, 174)];
    //label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont fontWithName:@"HelveticaNeue-regular" size:20];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setBaselineAdjustment:UIBaselineAdjustmentAlignCenters];
    //label.text = [NSString stringWithFormat:@"  %ld", row+1];
    if (pickerView.tag == 2) {
        plaEntity* entity = [globData.arrayglobMyEntities objectAtIndex:row];
        label.text = entity.EN_SNAME;
    } else if (pickerView.tag ==3) {
        NSString* strTemp = [globData.arrayglobCategories objectAtIndex:row];
        label.text = strTemp;
    }
    
    return label;
}

//- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
//{
//
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //    plaEventData* globData = [plaEventData getInstance];
    //    plaEntity* entity = [globData.arrayglobMyEntities objectAtIndex:row];
    //
    //    [m_textFieldAdmins setText:entity.EN_SNAME];
}

#pragma mark -------------Create View --------delegate ------ textfield -----

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 1: // ------------------  'where' field
            m_intCreateField = 1;
            [self hideKeyboardAll];
            [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
            return false;
            break;
            
        case 2: // ------------------  'artist' field
            m_intCreateField = 2;
            [self hideKeyboardAll];
            [self performSegueWithIdentifier: @"segueToSearchLocation" sender:self];
            return false;
            break;
            
        case 4:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateStartDate];
            return false;
            break;
            
        case 5:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateStartTime];
            return false;
            break;
            
        case 6:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateHostedBy];
            return false;
            break;
            
        case 8:
            [self hideKeyboardAll];
            //            [self performSelector:@selector(showOverView:) withObject:nil afterDelay:0.5f];
            [self showOverView:m_viewCreateCategory];
            return false;
            break;
            
        default:
            [self hideViewAll];
            break;
    }
    
    return true;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self hideKeyboardAll];
    return true;
}

-(void)cancelChange
{
    [self hideOverView:m_viewCreateHostedBy];
    [self hideViewAll];
}

-(void)saveChange
{
    [self hideOverView:m_viewCreateHostedBy];
    [self hideViewAll];
}

-(void) hideOverView:(UIView*)__view
{
    //UIView* view = __view;
    //view.center = CGPointMake(160, 672);
}

-(void)hideViewAll
{
    //    m_viewCreateHostedBy.center = CGPointMake(160, 672);
    //    m_viewCreateStartDate.center = CGPointMake(160, 672);
    //    m_viewCreateStartTime.center = CGPointMake(160, 672);
    
    m_viewCreateHostedBy.hidden = true;
    m_viewCreateStartDate.hidden = true;
    m_viewCreateStartTime.hidden = true;
    m_viewCreateCategory.hidden = true;
    
}

-(void)hideKeyboardAll
{
    [m_textFieldAdmins resignFirstResponder];
    [m_textFieldArtists resignFirstResponder];
    [m_textFieldEventName resignFirstResponder];
    [m_textFieldHashtagsForEvent resignFirstResponder];
    [m_textFieldStartDate resignFirstResponder];
    [m_textFieldStartTime resignFirstResponder];
    [m_textFieldTicketsURL resignFirstResponder];
    [m_textFieldWhere resignFirstResponder];
    [m_textViewDescription resignFirstResponder];
    [m_textViewDescription1 resignFirstResponder];
    [m_txtFldReportEevent_reason resignFirstResponder];
}

-(void)showViewAll
{
    m_viewCreateHostedBy.hidden = false;
    m_viewCreateStartDate.hidden = false;
    m_viewCreateStartTime.hidden = false;
    m_viewCreateCategory.hidden = false;
}

-(void) showOverView:(UIView*)__view
{
    [self hideViewAll];
    UIView* view = __view;
    view.hidden = false;
}

-(void) presentCreateEventView
{
    m_intCurrentViewStatus = 3;
    m_imageViewBackscreen.hidden = false;
    m_viewCreateView.hidden = false;
    //m_viewFront.userInteractionEnabled = NO;
}

-(void)resetCreateEntityObject
{
    self.m_createWhereEntity = [[plaEntity alloc] init];
    self.m_createArtistEntity = [[plaEntity alloc] init];
    self.m_createHostedByEntity = [[plaEntity alloc] init];
    
    UIImage* imageName = [UIImage imageNamed:@"createView_photo.p_ng"];
    [m_imageViewCreateEventPhoto setImage:imageName];
    [m_imageViewFullCoverImage setImage:imageName];
    [m_textFieldWhere setText:@""];
    [m_textFieldEventName setText:@""];
    [m_textFieldArtists setText:@""];
    [m_textFieldStartDate setText:@""];
    [m_textFieldStartTime setText:@""];
    [m_textFieldAdmins setText:@""];
    [m_textViewDescription1 setText:@""];
    [m_textFieldHashtagsForEvent setText:@""];
    [m_textFieldTicketsURL setText:@""];
    [m_textFieldCategory setText:@""];
    
    //    [m_arrayTableViewArtistData removeAllObjects];
    m_arrayTableViewArtistData = [[NSMutableArray alloc] init];
    
    m_viewArtistAdd.hidden = false;
    
    [m_tableViewArtists reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnBack:(UIButton *)sender
{
    [g_controllerViewHome changeFriendCountText];
	[self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark ----- Report Event ------------
- (void) goReportEvent
{
    plaEventData* globData = [plaEventData getInstance];
    
    m_lblReportEvent_EVName.text = m_parsedEvent.EV_SNAME;
    m_lblReportEvent_EVID.text = m_parsedEvent.EV_SEVENTID;
    m_lblReportEvent_EVUserName.text = globData.sglobUsername;
    m_lblReportEvent_Email.text = globData.sglobEmailAddress;
    
    m_viewReportEvent.hidden = false;
}

- (IBAction)onBtnReportEventCancel:(id)sender {
    m_txtFldReportEevent_reason.text = @"";
    m_viewReportEvent.hidden = true;
}

- (IBAction)onBtnReportEventSave:(id)sender {
    [self sendEmailToServer];
    [self onBtnReportEventCancel:nil];
}

-(void) sendEmailToServer
{
    NSString* question = @"";//m_txtFldReportEevent_reason.text; //[NSString stringWithFormat:@"current location is   %@(%f, %f).", currentLocationAdress, currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
    NSString* strBody = [NSString stringWithFormat:@"%@", question];
    
    question = m_lblReportEvent_EVName.text;
    strBody = [NSString stringWithFormat:@"%@<br><br>%@", strBody, question];
    
    question = m_lblReportEvent_EVID.text;
    strBody = [NSString stringWithFormat:@"%@<br><br>%@", strBody, question];
    
    question = m_lblReportEvent_EVUserName.text;
    strBody = [NSString stringWithFormat:@"%@<br><br>%@", strBody, question];
    
    question = m_lblReportEvent_Email.text;
    strBody = [NSString stringWithFormat:@"%@<br><br>%@", strBody, question];
    
    question = m_txtFldReportEevent_reason.text;
    strBody = [NSString stringWithFormat:@"%@<br><br>%@", strBody, question];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    
    // his class should be the delegate of the mc
    mc.mailComposeDelegate = self;
    
    // set a mail subject ... but you do not need to do this :)
    [mc setSubject:@"Report Event!"];
    
    // set some basic plain text as the message body ... but you do not need to do this :)
    [mc setMessageBody:[NSString stringWithFormat:@"%@", strBody] isHTML:YES];
    
    //NSArray* array = [[NSArray alloc] initWithObjects:[NSString stringWithFormat:@"%@", saveData.m_personEmail], nil];
    // set some recipients ... but you do not need to do this :)
    [mc setToRecipients:[NSArray arrayWithObjects:@"hello@playentertainmentnetwork.com", nil]];
    
    //[mc setCcRecipients:array];
    
    //[mc setToRecipients:[NSArray arrayWithObjects:@"first.address@test.com", @"second.address@test.com", nil]];
    
    // displaying our modal view controller on the screen with standard transition
    [self presentViewController:mc animated:YES completion:nil];
    
    // be a good memory manager and release mc, as you are responsible for it because your alloc/init
}

#pragma mark -------- delegate ------ email --------
// delegate function callback
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    // switchng the result
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail send canceled.");
            /*
             Execute your code for canceled event here ...
             */
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved.");
            /*
             Execute your code for email saved event here ...
             */
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent.");
            /*
             Execute your code for email sent event here ...
             */
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail send error: %@.", [error localizedDescription]);
            /*
             Execute your code for email send failed event here ...
             */
            break;
        default:
            break;
    }
    // hide the modal view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
