//
//  plaHomeViewController.h
//  Play
//
//  Created by Darcy Allen on 2014-06-20.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "plaEventData.h"
#import "plaEvent.h"
#import "plaMapViewController.h"
#import "FBHandler.h"

@class plaViewController;
@class plaMapViewController;
@class plaUser;
@class SPGooglePlacesAutocompleteQuery;

#define MERGE_ACTION_NOCHANGE 0
#define MERGE_ACTION_INSERT 10
#define MERGE_ACTION_UPDATE 20

@interface plaHomeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, MapViewControllerDidSelectDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UISearchBarDelegate, FBDelegate, MFMailComposeViewControllerDelegate >
{
    NSInteger intTemp_m_intTableDataType;
    NSInteger intTemp_bottomIndex;
    NSString* m_strCurrentCategory;
    NSInteger m_intOriginTablePositionY;
    
    FBHandler* fbHandler;
    plaUser* m_tempUser;
    
    BOOL isTableDataEmpty;
    
    BOOL _doneLoading;
    
    int draw1;
    
    IBOutlet UIView* m_viewBack;
    IBOutlet UIView* m_viewFront;
    
    UIPanGestureRecognizer* panGesture;
    CGPoint pointFirst, pointSecond;
    BOOL isRemoved;
    
    IBOutlet UIScrollView* m_scrollViewFull;
    IBOutlet UITableView *m_tableViewInbox;
    
    IBOutlet UIView* m_viewMapView;
    
    // ------------ Top Event & Entity SrollView -------------------
    IBOutlet UIScrollView *m_scrollViewTopEvents;
    IBOutlet UILabel *m_lblType1;
    IBOutlet UIImageView *m_imageViewScroll1;
    IBOutlet UILabel *m_lblScroll1;
    
    IBOutlet UILabel *m_lblType2;
    IBOutlet UIImageView *m_imageViewScroll2;
    IBOutlet UILabel *m_lblScroll2;
    
    IBOutlet UILabel *m_lblType3;
    IBOutlet UIImageView *m_imageViewScroll3;
    IBOutlet UILabel *m_lblScroll3;
    
    IBOutlet UILabel *m_lblType4;
    IBOutlet UIImageView *m_imageViewScroll4;
    IBOutlet UILabel *m_lblScroll4;
    
    IBOutlet UILabel *m_lblType5;
    IBOutlet UIImageView *m_imageViewScroll5;
    IBOutlet UILabel *m_lblScroll5;
    
    IBOutlet UILabel *m_lblType6;
    IBOutlet UIImageView *m_imageViewScroll6;
    IBOutlet UILabel *m_lblScroll6;
    
    IBOutlet UILabel *m_lblType7;
    IBOutlet UIImageView *m_imageViewScroll7;
    IBOutlet UILabel *m_lblScroll7;
    
    IBOutlet UILabel *m_lblType8;
    IBOutlet UIImageView *m_imageViewScroll8;
    IBOutlet UILabel *m_lblScroll8;
    
    NSMutableArray* m_arrayTableViewData;
    NSMutableArray* m_arrayGlobalTableViewData;
    NSMutableArray* m_arrayInboxTableData;
    NSMutableArray* m_arrayTemp;
    NSMutableArray* m_arrayTopEvents;
    
    // ------- Floating View -------
    IBOutlet UIView *m_viewFloatingSectionTitle;
    IBOutlet UIView *m_viewFloatGestreView;
    IBOutlet UIView *m_viewFloatGestureHeaderView;
    
    IBOutlet UILabel *m_lblFloatingSectionTitle;
    
    // ------------ Select Category -------------------
    IBOutlet UITableView *m_tableViewSelectCategory;
    IBOutlet UIButton *m_btnCategory;
    IBOutlet UIButton *m_btnCategoryBG;
    BOOL m_intLocationState;
    
    IBOutlet UISearchBar *m_searchBar;
    IBOutlet UIButton *m_btnLocateMe;
    IBOutlet UIButton *m_btnLocateMeBack;
    
    // ----------- Omni Search ----------------------
    NSInteger intTemp_m_btnLoadMoreForNetworkTag;
    NSArray *searchResultPlaces;
    SPGooglePlacesAutocompleteQuery *searchQuery;
    
    IBOutlet UITableView *m_tableViewOmniSearch;
    NSMutableArray* m_arrayOmniSearchData;
    
    NSMutableArray* m_arrayFriendUser;
    
    plaEvent* m_eventTemp;
    plaUser* m_MainUser;
    
    NSTimer* m_timer;
    
    IBOutlet UIView *m_viewSettingPage;
    
    UITapGestureRecognizer* m_gesture1;
    UITapGestureRecognizer* m_gesture2;
    UITapGestureRecognizer* m_gesture3;
    UITapGestureRecognizer* m_gesture4;
    UITapGestureRecognizer* m_gesture5;
    UITapGestureRecognizer* m_gesture6;
    UITapGestureRecognizer* m_gesture7;
    UITapGestureRecognizer* m_gesture8;
    
#pragma mark --- Selecte Cateory
    IBOutlet UIView *m_viewSelectCategory;
    IBOutlet UIButton *m_btnSelectCategoryTapHereToView;
    IBOutlet UILabel *m_lblSelectCategoryEvents;
    
#pragma mark --- BackGround
    
    IBOutlet UIImageView* m_imageviewBGPicture;
    IBOutlet UILabel*       m_lblBGName;
    
    IBOutlet UILabel*       m_lblBGLocation;
    IBOutlet UIButton *m_btnBGLocation;
    IBOutlet UILabel *m_lblBGNetwork;
    
    IBOutlet UIButton *m_btnFriendsCount;
    NSInteger m_intCurrentViewStatus; // 1: background View         2: tableview            3: create view
    
    NSInteger intDataCount;
    // load more
    IBOutlet UIView *m_viewLoadMore;
    IBOutlet UIButton* m_buttonLoadMore;
    IBOutlet UIImageView* m_activityViewLoading;
    IBOutlet UIImageView* m_imageViewLoading;
    IBOutlet UIView *m_viewLoadingText;
    NSInteger intBeforCellNum;
    
    // ---- current DB events ID array --------
    NSMutableArray* m_arrayEventIDListInDB;
    
    NSMutableArray* m_arrayDataForMap;
    plaMapViewController* mapViewFullScreenCtrl;
    
    IBOutlet UILabel *m_lblInboxCount;
    
    NSString* m_strTemp;
    
    
#pragma mark ------ settingPage -------------
    IBOutlet UISwitch *m_switchVPNotification;
    
    
#pragma mark ------ create View -------------
    
    IBOutlet UIImageView* m_imageViewCreateEventPhoto;
    UIImage* m_imageCreateEventPhoto;
    NSString* m_strCreateEventPhoto;
    IBOutlet UIImageView* m_imageViewBackscreen;
    IBOutlet UIView* m_viewCreateView;
    IBOutlet UIScrollView* m_createscrollView;
    
    IBOutlet UITextField* m_textFieldEventName;
    IBOutlet UITextField* m_textFieldWhere;
    
    IBOutlet UITextField* m_textFieldArtists;
    IBOutlet UITableView* m_tableViewArtists;
    IBOutlet UIView* m_viewArtistAdd;
    
    IBOutlet UITextField* m_textFieldTicketsURL;
    IBOutlet UITextField* m_textFieldStartDate;
    IBOutlet UITextField* m_textFieldStartTime;
    IBOutlet UITextField* m_textFieldAdmins;
    IBOutlet UITextField* m_textFieldHashtagsForEvent;
    IBOutlet UITextField* m_textFieldCategory;
    IBOutlet UIButton*    m_buttonIsDuplicated;
    IBOutlet UITextView*  m_textViewDescription;
    
    IBOutlet UIView* m_viewCreateHostedBy;
    IBOutlet UIView* m_viewCreateStartDate;
    IBOutlet UIView* m_viewCreateStartTime;
    IBOutlet UIView* m_viewCreateCategory;
    
    IBOutlet UIDatePicker* m_pickerStartDate;
    IBOutlet UIDatePicker* m_pickerStartTime;
    IBOutlet UIPickerView* m_pickerAdmins;
    IBOutlet UIPickerView* m_pickerCategory;
    
#pragma mark --------- feedback -------
    
    IBOutlet UIView *m_viewFeedback;
    IBOutlet UIImageView *m_imageViewBackscreenForFB;
    
    IBOutlet UIView *m_viewFBQueation;
    IBOutlet UIScrollView *m_ScrollViewFBQuestion;
    IBOutlet UITextField *m_textFldQuestion1;
    IBOutlet UITextField *m_textFldQuestion2;
    IBOutlet UITextField *m_textFldQuestion3;
    IBOutlet UITextField *m_textFldQuestion4;
    
    IBOutlet UIView *m_viewFBProvide;
    
    IBOutlet UIView *m_viewFBHappy;
    
    BOOL intIsFirstLoading;
}

@property IBOutlet UIImageView* m_imageViewBackscreen;
@property IBOutlet UITableView* m_tableViewFull;

@property (nonatomic, readwrite) NSInteger m_intTemp;

@property (strong, nonatomic) IBOutlet UILabel*       m_lblBGLocation;
@property (strong, nonatomic) IBOutlet UIButton* m_btnBGLocation;
@property (strong, nonatomic) IBOutlet UILabel *m_lblBGNetwork;

@property (strong, nonatomic) IBOutlet UILabel *m_lblInboxCount;

// -----homeviewcontroller ----------
@property (nonatomic, retain) plaViewController* m_viewControllerRoot;
// @property (strong, nonatomic) IBOutlet UIImageView *imageLogout;

@property (retain, nonatomic ) IBOutlet UIScrollView *scrollViewMenu;

@property ( nonatomic, strong ) plaEventData *globEvents;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet MKMapView *mapViewFullScreen;

@property NSInteger iSizeOfDBArray;

- (IBAction)onBtnScrollLeft:(id)sender;
- (IBAction)onBtnScrollRight:(id)sender;


@property (strong, nonatomic) NSMutableArray* m_arrayMyLikesEntities;
@property (strong, nonatomic) NSMutableArray* m_arraySugestedEvents;
@property (strong, nonatomic) NSMutableArray* m_arrayMeAttendingEvents;
@property (strong, nonatomic) NSMutableArray* m_arrayPopularEvents;
- (void) getEventsFor3Items;  // Susgested, My Attending, Popular Events

#pragma mark --------- feedback -------
- (IBAction)onBtnFBQuestionCancel:(id)sender;
- (IBAction)onBtnFBQuestionSubmit:(id)sender;
- (IBAction)onBtnFBProvideNoThx:(id)sender;
- (IBAction)onBtnFBProvideLeaveFB:(id)sender;
- (IBAction)onBtnFBHappyUnhappy:(id)sender;
- (IBAction)onBtnFBHappyHappy:(id)sender;

-(void)showFeedBackScreen;
#pragma mark ------ Omni Search -------------
@property (strong, nonatomic) IBOutlet UIButton *m_btnLoadMoreForNetwork;

- (IBAction)onBtnLoadMoreForNetwork:(id)sender;


#pragma mark ------ create View -------------

//IBOutlet UIImageView* m_imageViewBackscreen;
//IBOutlet UIView* m_viewCreateView;
//IBOutlet UIScrollView* m_createscrollView;
//
@property (readwrite) NSInteger m_intCreateField;
//IBOutlet UITextField* m_textFieldEventName;
@property (strong, nonatomic) IBOutlet UITextField* m_textFieldWhere;
@property (nonatomic, retain) plaEntity* m_createWhereEntity;

@property (strong, nonatomic) IBOutlet UITextField* m_textFieldArtists;
@property (nonatomic, retain) plaEntity* m_createArtistEntity;
@property (nonatomic, retain) NSMutableArray* m_arrayTableViewArtistData;
@property (readwrite) NSInteger m_intCurrentSelectedArtist;

@property (nonatomic, retain) plaEntity* m_createHostedByEntity;

@property (strong, nonatomic) IBOutlet UIButton *m_createBtnCheck;

//----------------------------------------------------------------------
- (void)setNetworkFromLocationInfo:(NSString*)strTemp;
-(void)changeFriendCountText;
-(void)toDetailPage;

- (IBAction) OpenMenu:(id)sender;
- (IBAction)onBtnCategory:(id)sender;

// call back from the left menu
- (IBAction)returnedHomeFromSegue:(UIStoryboardSegue *)segue;
- (IBAction)returnedHomeFromSearchNetwork:(UIStoryboardSegue *)sender;

// -(IBAction)select:(id)sender;
-(void)MergeFBandDB;
-(NSInteger)isFBEventInDB:(plaEvent *)FBPlayEvent;
-(void)addPlayEvent:(plaEvent *)thePlayEvent;

-(void)refreshTableView;
-(void)hideLoadingActivityView;

-(void)addEventToTableData:(plaEvent*)_eventData;
-(void)getDBEvents:(NSInteger)_count;

- (void)calEventAttendFriendCount:(plaEvent*)_eventModel;
- (void)makeSortingItem:(plaEvent*)_model;

-(void)sendToDetailPage:(plaEvent*)_model;

-(void)addMarkerToMapView;

#pragma mark ------ background  action functions -------

- (NSString*)getTodayDate;

- (IBAction)onBtnFriendsCount:(id)sender;
- (void)getLocationDataFromEntityData:(plaEvent*)parsedEvent;


#pragma mark ------ create View  functions ----------
-(IBAction)onChangePicture:(id)sender;
- (IBAction)onBtnCheck:(id)sender;


-(IBAction)onBtnCancel:(id)sender;
-(IBAction)onBtnSave:(id)sender;

-(IBAction)onBtnCancelField:(id)sender;
-(IBAction)onBtnSaveField:(id)sender;


- (IBAction)onBtnViewAllEntity:(id)sender;

@end

NSInteger m_intTableDataType; // 1: default data
// 2: activity feed data        3: upcomming event data
NSInteger m_currentCategory;
