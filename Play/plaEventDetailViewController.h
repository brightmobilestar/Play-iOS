//
//  plaEventDetailViewController.h
//  Play
//
//  Created by Darcy Allen on 2014-08-16.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPPopoverController.h"
#import "AsyncImageView/AsyncImageView.h"
#import "FPPopoverKeyboardResponsiveController.h"
@class plaEvent;
@class plaEntity;

@interface plaEventDetailViewController : UIViewController <FPPopoverControllerDelegate, UIScrollViewDelegate, UIActionSheetDelegate, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, MFMailComposeViewControllerDelegate>
{
    plaEvent *m_parsedEvent;
    UIColor* m_colorGray;
    NSInteger m_intTblViewHashTag;
    
    IBOutlet UIScrollView* m_scrollView;
    IBOutlet UIButton *m_btnTicketUri;
    
    FPPopoverKeyboardResponsiveController *popover;
    
    IBOutlet UIButton *m_btnEditing;
    IBOutlet UIButton *m_btnEdittingBG;
    BOOL m_isPossbleEditing;
    
    // ----------- over view --------------------------
    IBOutlet AsyncImageView* m_imageViewEventPic;
    IBOutlet UIImageView* m_imageViewAttenIcon;
    IBOutlet UIImageView *m_imageViewInviteIcon;
    
    IBOutlet UILabel* m_labelAtten;
    
    IBOutlet UILabel *m_labelInvite;
    IBOutlet UILabel* m_labelHostedBy;
    
    IBOutlet UIButton *m_btnExpand0;
    IBOutlet UIButton *m_btnExpand;
    IBOutlet UIView *m_viewDescription;
    IBOutlet UILabel *m_labelDescription;
    IBOutlet UITextView* m_textViewDescription;
    
    IBOutlet UIButton *m_btnExpand02;
    IBOutlet UIButton *m_btnExpand2;
    IBOutlet UIView *m_viewDescription2;
    IBOutlet UILabel *m_labelDescription2;
    IBOutlet UITextView *m_textViewDescription2;
    
    IBOutlet UIView *m_viewImageFeed;
    IBOutlet UIView *m_viewImageFeed1;
    
    IBOutlet UILabel *m_labelHashTag;
    IBOutlet UILabel *m_labelHashTag2;
    
    IBOutlet UITableView *m_tableViewHashtag;
    IBOutlet UITableView *m_tableViewHashtag2;
    
    NSInteger m_intCurrentViewStatus;
    
    IBOutlet UIImageView *m_imageViewFullCoverImage;
    IBOutlet UIButton *m_buttonCloseIcon;
    IBOutlet UIButton *m_buttonCloseIcon1;
    IBOutlet UIButton *m_buttonCloseIcon2;
    
    NSMutableArray* m_arrayTblHashtag;
    
    // ---------- report event ------------------
    
    IBOutlet UIView *m_viewReportEvent;
    IBOutlet UIScrollView *m_scrollViewReportEvent;
    IBOutlet UILabel *m_lblReportEvent_EVName;
    IBOutlet UILabel *m_lblReportEvent_EVID;
    IBOutlet UILabel *m_lblReportEvent_EVUserName;
    IBOutlet UILabel *m_lblReportEvent_Email;
    IBOutlet UITextField *m_txtFldReportEevent_reason;
    
    // -----------popever view ------------------------
    IBOutlet UIView* m_viewPopover;
    IBOutlet UILabel* m_labelDate;
    IBOutlet UILabel* m_labelTime;
    
    IBOutlet UILabel *m_labelAttendFriendCount;
    IBOutlet UILabel* m_labelAttendCount;
    IBOutlet UILabel* m_labelDistance;
    
    NSString* m_strDateMonth;
    NSString* m_strDateDay;
    NSString* m_strDateTimeStart;
    NSString* m_strDateTimeEnd;
    
    IBOutlet UILabel* m_labelLocationState;
    IBOutlet UILabel* m_labelLocationCity;
    IBOutlet UIButton* m_buttonLocation;
    
    IBOutlet UIScrollView* m_scrollViewImageList;
    IBOutlet UIPageControl* m_pageControlImageList;
    
    IBOutlet UIImageView *m_imageViewArtist1;
    IBOutlet UIImageView *m_imageViewArtist2;
    IBOutlet UIImageView *m_imageViewArtist3;
    IBOutlet UIImageView *m_imageViewArtist4;
    
    IBOutlet UILabel *m_labelArtistName1;
    
    IBOutlet UILabel *m_labelArtistName2;
    
    IBOutlet UILabel *m_labelArtistName3;
    
    IBOutlet UILabel *m_labelArtistName4;
    
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
    IBOutlet UITextView*  m_textViewDescription1;
    
    IBOutlet UIView* m_viewCreateHostedBy;
    IBOutlet UIView* m_viewCreateStartDate;
    IBOutlet UIView* m_viewCreateStartTime;
    IBOutlet UIView* m_viewCreateCategory;
    
    IBOutlet UIDatePicker* m_pickerStartDate;
    IBOutlet UIDatePicker* m_pickerStartTime;
    IBOutlet UIPickerView* m_pickerAdmins;
    IBOutlet UIPickerView* m_pickerCategory;
    
}

@property (nonatomic, retain) plaEvent *m_parsedEvent;

@property (nonatomic, retain) IBOutlet UILabel *lblEventName;
@property (nonatomic, retain) IBOutlet AsyncImageView *imgEvent;
@property (nonatomic, retain) IBOutlet UILabel *lblLocation;
@property (nonatomic, retain) IBOutlet UILabel *lblDateTime;

#pragma mark ------ create View -------------

@property (readwrite) NSInteger m_intCreateField;
@property (readwrite) NSInteger m_intCurrentSelectedArtist;

@property (nonatomic, retain) IBOutlet UITextField* m_textFieldWhere;
@property (nonatomic, retain) plaEntity* m_createWhereEntity;

@property (nonatomic, retain) IBOutlet UITextField* m_textFieldArtists;
@property (nonatomic, retain) plaEntity* m_createArtistEntity;
@property (nonatomic, retain) NSMutableArray* m_arrayTableViewArtistData;
@property (readwrite) NSInteger m_intCurrntSelectedArtist;

@property (nonatomic, retain) plaEntity* m_createHostedByEntity;


-(IBAction)btnBack:(UIButton *)sender;

-(IBAction)btnSetting:(id)sender;
-(IBAction)onGoAttend:(id)sender;
- (IBAction)onBtnInvite:(id)sender;

-(IBAction)btnHostedBy:(id)sender;
-(IBAction)btnLocation:(id)sender;
-(IBAction)btnArtist:(id)sender;
-(IBAction)btnImageSlider:(id)sender;
- (IBAction)btnCoverImageFull:(id)sender;
- (IBAction)btnCoverImageCollapes:(id)sender;

- (IBAction)btnExpandDescription:(id)sender;

-(IBAction)onReturnEventDetailFromSeq:(UIStoryboardSegue*)sender;

-(void) loadDataFromFB:(plaEvent*)_event;

-(void) getPhotoFeedDtaFromFB:(NSMutableArray*)_array;

#pragma mark ------ Report Event ------------------

- (IBAction)onBtnReportEventCancel:(id)sender;
- (IBAction)onBtnReportEventSave:(id)sender;

#pragma mark ------ create View  functions ----------
-(IBAction)onChangePicture:(id)sender;

-(IBAction)onBtnCancel:(id)sender;
-(IBAction)onBtnSave:(id)sender;

-(IBAction)onBtnCancelField:(id)sender;
-(IBAction)onBtnSaveField:(id)sender;

@end
