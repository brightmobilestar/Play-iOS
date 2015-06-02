//
//  plaEntityPageViewController.m
//  Play
//
//  Created by JinLong on 11/18/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaEntityPageViewController.h"
#import "plaEntity.h"
#import "plaEvent.h"
#import "plaEventData.h"
#import "plaHomeTableViewCell.h"
#import "plaAppDelegate.h"
#import "plaViewController.h"
#import "plaWebServices.h"
#import "UIImage+animatedGIF.h"
#import "plaHomeViewController.h"

@interface plaEntityPageViewController ()

@end

@implementation plaEntityPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // show the event details
    m_entity = [[plaEntity alloc] init];
    [self getTodayDate];
    
    plaEventData *globEvents = [plaEventData getInstance];
    globEvents.m_currentController = @"entityPageViewController";
    int iObj = (int)globEvents.iglobEventRow;
    //m_parsedEvent = [ globEvents.arrayglobDBEvents objectAtIndex: iObj];
    m_parsedEvent = [g_arrayTemp objectAtIndex:iObj];
    
    [self loadData];
    
    isNewCreated  = true;
    g_controllerEntityPage = self;
    
    [self dismissEditView];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (isNewCreated) {
        [self getArrayTableViewData];
    }
    isNewCreated = false;
    
    [self cleanerTableDataArray];
    
    [m_tableView reloadData];
}

#pragma mark -------------- data load -------------

- (void)loadData//:(plaEvent*)_parseEvent
{
    [self getEntityImage];
    m_imageCricleEntity.clipsToBounds = YES;
    [m_imageCricleEntity.layer setCornerRadius:35.0f];
    
    [self loadEntityData];
}

- (void)getArrayTableViewData
{
    plaEventData* globData = [plaEventData getInstance];
    
    m_arrayTableViewData = [[NSMutableArray alloc] init];
    
    plaWebServices *webServ = [[plaWebServices alloc] init];
    
    [webServ backgroundReadEventsByLocation:m_entity sec:g_controllerView third:self];
    
    
    for (int i = 0; i < [globData.arrayglobDBCreatedEntitiesStatic1 count]; i ++) {
        plaEntity* _entity = [globData.arrayglobDBCreatedEntitiesStatic1 objectAtIndex:i];
        if ([_entity.EN_SFACEBOOKID isEqualToString:m_entity.EN_SID]) {
            [webServ backgroundReadEventsByLocation:m_entity sec:g_controllerView third:self];
        }
        if ([_entity.EN_SID isEqualToString:m_entity.EN_SID]) {
            plaEntity* _entity = [[plaEntity alloc] init];
            _entity.EN_SID = m_entity.EN_SFACEBOOKID;
            [webServ backgroundReadEventsByLocation:_entity sec:g_controllerView third:self];
        }
    }
    //    if (m_parsedEvent.EV_SENTITYSTATE == 1) { // ----------------    hosted by ------------
    //        [webServ backgroundReadEventsByLocation:m_entity sec:g_controllerView third:self];
    //    } else if (m_parsedEvent.EV_SENTITYSTATE == 2) { // ---------    location -------------
    //        [webServ backgroundReadEventsByLocation:m_entity sec:g_controllerView third:self];
    //    } else if (m_parsedEvent.EV_SENTITYSTATE == 3) { // ---------    artist -------------
    //        [webServ backgroundReadEventsByLocation:m_entity sec:g_controllerView third:self];
    //    }
}

- (void)loadEntityData
{
    if ([m_entity.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self getEntityFromFBID:m_entity];
    }
    m_imageEntity.imageURL = [NSURL URLWithString: m_entity.EN_SIMAGE];
    m_imageCricleEntity.imageURL = [NSURL URLWithString:m_entity.EN_SIMAGEPROFILE];
    
    UIImage* image = [UIImage imageNamed:@"artist_yet.jpg"];
    if (([m_entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (m_entity.EN_SFACEBOOKID == nil || [m_entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [m_entity.EN_SFACEBOOKID isEqualToString:@""])) {
        [m_imageEntity setImage:image];
        [m_imageCricleEntity setImage:image];
    }
    
    m_lblName.text = m_entity.EN_SNAME;
    m_lblPhoneNum.text = m_entity.EN_SPHONENUMBER;
    m_lblCategory.text = m_entity.EN_SCATEGORY;
    m_lblLocation.text = [NSString stringWithFormat:@"%@, %@", m_entity.EN_SCITY, m_entity.EN_SSTATE];
    if ([m_entity.EN_SCITY isEqualToString:@"(null)"]) {
        m_lblLocation.text = [NSString stringWithFormat:@"%@, %@", m_entity.EN_SSTATE, m_entity.EN_SSTATE];
    }
    m_lblDistance.text = [NSString stringWithFormat:@"%@ km", m_entity.EN_SDISTANCE];
    m_lblAddress.text = [NSString stringWithFormat:@"%@", m_entity.EN_SADDRESSSTR];
    
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"dribbble" withExtension:@"gif"];
    m_activityViewLoading.image = [UIImage animatedImageWithAnimatedGIFURL:url];
    
    plaEventData* globData = [plaEventData getInstance];
    
    m_btnSetting.hidden = true;
    if ([globData.sglobUserID isEqualToString:@"10201503648988208"]) {
        m_btnSetting.hidden = false;
    }
    
    for (int i = 0; i < [globData.arrayglobMyEntities count]; i ++) {
        plaEntity* entityModel = [globData.arrayglobMyEntities objectAtIndex:i];
        if ([entityModel.EN_SID isEqualToString:m_entity.EN_SID]) {
            m_btnSetting.hidden = false;
        }
    }
}

- (void)getTodayDate
{
    NSDate *today = [NSDate date];
    
    NSString* strTemp = [today description];
    NSArray* array1 = [[today description] componentsSeparatedByString:@" "];
    NSArray* arrayTemp = [[array1 objectAtIndex:0] componentsSeparatedByString:@"-"];
    strTemp = [NSString stringWithFormat:@"%@%@%@", [arrayTemp objectAtIndex:0], [arrayTemp objectAtIndex:1], [arrayTemp objectAtIndex:2]];
    
    intToday = [strTemp integerValue];
}

- (void)getEntityImage
{
    plaEventData* globData = [plaEventData getInstance];
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        m_entity = entity;
        if ([entity.EN_SID isEqualToString:m_parsedEvent.EV_SENTITY.EN_SID] && m_parsedEvent.EV_SENTITYSTATE == 1) {
            m_entity = entity;
            m_parsedEvent.EV_SENTITY.EN_SIMAGE = entity.EN_SIMAGE;
            break;
        } else if ([entity.EN_SID isEqualToString:m_parsedEvent.EV_SENTITYLOCATION.EN_SID] && m_parsedEvent.EV_SENTITYSTATE == 2) {
            m_entity = entity;
            m_parsedEvent.EV_SENTITYLOCATION.EN_SIMAGE = entity.EN_SIMAGE;
            break;
        } else if ([entity.EN_SID isEqualToString:m_parsedEvent.EV_SENTITYARTIST.EN_SID] && m_parsedEvent.EV_SENTITYSTATE == 3) {
            m_entity = entity;
            m_parsedEvent.EV_SENTITYARTIST.EN_SIMAGE = entity.EN_SIMAGE;
            break;
        }
    }
}

#pragma mark ------------- background functions --------------
-(void)addEventToTableData:(plaEvent*)_event
{
    [m_arrayTableViewData addObject:_event];
}

-(void)refreshTableView
{
    m_activityViewLoading.hidden = YES;
    
    [self cleanerTableDataArray];
    
    [m_tableView reloadData];
}

-(void)cleanerTableDataArray
{
    for (NSInteger i = [m_arrayTableViewData count] - 1; i > -1; i --) {
        plaEvent * entity = [m_arrayTableViewData objectAtIndex:i];
        
        for (NSInteger j = 0; j < i; j ++) {
            plaEvent* entity1 = [m_arrayTableViewData objectAtIndex:j];
            if ([[entity.EV_SNAME uppercaseString] isEqualToString:[entity1.EV_SNAME uppercaseString]]) {
                [m_arrayTableViewData removeObjectAtIndex:i];
                break;
            }
        }
    }
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

#pragma mark ----- To make sorting item -------
- (void)makeSortingItem:(plaEvent*)_model
{
    NSString* sortDistance, *sortDate, *sortAttendCount; //
    sortDistance = [NSString stringWithFormat:@"%f", _model.EV_SDISTANCE];
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

#pragma mark ----- delete event --------

- (IBAction)btnBack:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    //[g_controllerViewHome changeFriendCountText];
}

-(IBAction)btnEdit:(id)sender
{
    if ([m_entity.EN_SID rangeOfString:@"db"].location == NSNotFound) {
        return;
    } else {
        UIActionSheet* actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Connect this Entity To Facebook", nil];
        [actionSheet showInView:self.view];
    }
}

- (IBAction)onEditBtnInfo:(id)sender {
//    UIAlertView* alertViewInfo = [[UIAlertView alloc] initWithTitle:nil message:@"Instructions to get FB ID" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
//    [alertViewInfo show];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.findmyfacebookid.com/"]];
}

- (IBAction)onEditBtnCancel:(id)sender {
    [self dismissEditView];
}

- (IBAction)onEditBtnSave:(id)sender {
    
    plaWebServices* webService = [[plaWebServices alloc] init];
    
    m_entity.EN_SFACEBOOKID = m_textFieldFBPageID.text;
    
    [g_controllerView getEntityPageInfo:m_entity.EN_SFACEBOOKID];
    
    [webService backgroundUpdateEntity:m_entity];
    
    //[self loadEntityData];
//    [self performSelector:@selector(loadEntityData) withObject:nil afterDelay:0.5f];
    
    [self dismissEditView];
}

-(void) dismissEditView
{
    m_textFieldFBPageID.text = @"";
    m_imageViewBG.hidden = YES;
    m_viewEditEntity.hidden = YES;
    [m_textFieldFBPageID resignFirstResponder];
}

-(void) presentEditView
{
    m_textFieldFBPageID.text = m_entity.EN_SFACEBOOKID;
    m_viewEditEntity.hidden = NO;
    m_imageViewBG.hidden = NO;
}

#pragma mark ----- delegate actionsheet ------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self presentEditView];
            break;
            
        default:
            break;
    }
}

#pragma mark ---- tableview delegate ---------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //    m_scrollViewFull.contentSize = CGSizeMake(320, 91 * 50);
    //    if ([eventNames count] > 50) {
    //        m_scrollViewFull.contentSize = CGSizeMake(320, 91 * 50);
    //        return 50;
    //    }
    //    m_scrollViewFull.contentSize = CGSizeMake(320, 91 * [eventNames count]);
    
    NSArray *sortedArray;
    
    for (int i = 0; i < [m_arrayTableViewData count]; i ++) {
        plaEvent* event = [m_arrayTableViewData objectAtIndex:i];
        [self makeSortingItem:event];
    }
    
    // -------  sorting array - m_arrayGlobalTableViewData
    sortedArray = [m_arrayTableViewData sortedArrayUsingComparator:^NSComparisonResult(plaEvent *p1, plaEvent *p2){
        
        return [p1.EV_SSORTINGITEM compare:p2.EV_SSORTINGITEM];
        
    }];
    
    m_arrayTableViewData = [[NSMutableArray alloc] initWithArray:sortedArray];
    
    if ([m_arrayTableViewData count] == 0) {
        isTableDataEmpty = true;
        return 1;
    }
    
    isTableDataEmpty = false;
    
    return [m_arrayTableViewData count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isTableDataEmpty) {
        UITableViewCell* cellNoResult ;
        cellNoResult = (UITableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CellNoResult" forIndexPath:indexPath];
        cellNoResult.userInteractionEnabled = false;
        return cellNoResult;
    }
    
    plaHomeTableViewCell* cell1 = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    plaEvent* tempEvent;
    
        tempEvent = [m_arrayTableViewData objectAtIndex:indexPath.row];
    
    [self getEntityFromID:tempEvent.EV_SENTITY];
    if ([tempEvent.EV_SENTITY.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self getEntityFromFBID:tempEvent.EV_SENTITY];
    }
    
    [self getEntityFromID:tempEvent.EV_SENTITYLOCATION];
    if ([tempEvent.EV_SENTITYLOCATION.EN_SID rangeOfString:@"db"].location != NSNotFound) {
        [self getEntityFromFBID:tempEvent.EV_SENTITYLOCATION];
    }
    
    [cell1.m_imageView0 setImageURL:[NSURL URLWithString:tempEvent.EV_SIMAGE] ];
    cell1.m_imageView0.clipsToBounds = YES;
    [cell1.m_imageView0.layer setCornerRadius:35.0f];
    [cell1.m_lblText1 setText:tempEvent.EV_SNAME];
    [cell1.m_lblText2 setText:tempEvent.EV_SENTITYLOCATION.EN_SNAME];
    
    [cell1.m_lalDistance setText:[NSString stringWithFormat:@"%@ km", tempEvent.EV_SENTITYLOCATION.EN_SDISTANCE] ];
    
    [cell1.m_lblText3 setText:[self convertDateType:tempEvent.EV_SSTARTDATETIME]];
    
    [g_controllerViewHome calEventAttendFriendCount:tempEvent];
    
    [cell1.m_lblTextAttendCount setText:[NSString stringWithFormat:@"%ld", (long)tempEvent.EV_SATTENDCOUNT] ];
    
    [cell1.m_lblAttendFriendCount setText:[NSString stringWithFormat:@"%ld", (long)tempEvent.EV_SATTENDFRIENDCOUNT]];

    return cell1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaEventData *globData = [plaEventData getInstance];
    globData.nsipEventRow = indexPath;
    globData.iglobEventRow = indexPath.row;
    
    NSInteger int_Temp = indexPath.row;
    
        plaEvent* data = [m_arrayTableViewData objectAtIndex:int_Temp];
        //[m_viewControllerRoot getEntityPageInfo:data];
        
        NSUInteger intTemp = [m_arrayTableViewData indexOfObject:data];
     
        globData.iglobEventRow = intTemp;

    g_arrayTemp = m_arrayTableViewData;
    
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self];
}

// each row of the table launches its detail screen of its Event
// [self performSegueWithIdentifier:@"starttoevents" sender:self];

-(void)tableView:(__unused UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    // unit test success:  NSLog( @"calling segueToEventDetail" );
    plaEventData *globData = [plaEventData getInstance];
    globData.nsipEventRow = indexPath;
    [self performSegueWithIdentifier: @"segueToEventDetail" sender:self ];
}



#pragma mark --- convert date type ---
- (NSString*) convertDateType:(NSString*)_date
{
    if ([_date isEqualToString:@""]) {
        return @"";
    }
    NSArray* arrayMonth = @[@"", @"January", @"February", @"March", @"April", @"May", @"June", @"July", @"August", @"September", @"October", @"November", @"December"];
    NSArray* arrayWeekday = @[@"", @"Sunday", @"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday"];
    NSString* strTemp, *temp1, *temp2Month;
    NSArray* arrayTemp1, *arrayTemp2;
    arrayTemp1 = [_date componentsSeparatedByString:@"T"];
    temp1 = (NSString*)[arrayTemp1 objectAtIndex:0];
    //temp3Time = (NSString*)[arrayTemp1 objectAtIndex:1];
    arrayTemp2 = [temp1 componentsSeparatedByString:@"-"];
    temp2Month = (NSString*)[arrayTemp2 objectAtIndex:1];
    NSInteger intTemp = temp2Month.integerValue;
    
    temp2Month = [arrayMonth objectAtIndex:intTemp];
    
    NSString* m_strDateDay = [arrayTemp2 objectAtIndex:2];
    if ([m_strDateDay isEqualToString:@"1"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@st", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"2"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@nd", m_strDateDay];
    } else if ([m_strDateDay isEqualToString:@"3"]) {
        m_strDateDay = [NSString stringWithFormat:@"%@rd", m_strDateDay];
    } else {
        m_strDateDay = [NSString stringWithFormat:@"%@th", m_strDateDay];
    }
    
    // -----   to get weekday from date  ---------
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    [gregorian setLocale:[NSLocale currentLocale]];
    
    NSDateComponents *nowComponents = [gregorian components:NSYearCalendarUnit | NSWeekCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit fromDate:today];
    
    [nowComponents setYear:[[arrayTemp2 objectAtIndex:0] intValue]];
    [nowComponents setMonth:[[arrayTemp2 objectAtIndex:1] intValue]];
    [nowComponents setDay:[[arrayTemp2 objectAtIndex:2] intValue]];
    
    NSDate *beginningOfWeek = [gregorian dateFromComponents:nowComponents];
    
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSWeekdayCalendarUnit fromDate:beginningOfWeek];
    long weekday = [comp weekday];
    
    strTemp = [NSString stringWithFormat:@"%@ %@ %@, %@", [arrayWeekday objectAtIndex:weekday], temp2Month, [arrayTemp2 objectAtIndex:2], [arrayTemp2 objectAtIndex:0]];
    
    return strTemp;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
