//
//  plaEntityPageViewController.h
//  Play
//
//  Created by JinLong on 11/18/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageView/AsyncImageView.h"

@class plaEvent;
@class plaEntity;

@interface plaEntityPageViewController : UIViewController <UITableViewDataSource, UITabBarDelegate, UINavigationBarDelegate, UIActionSheetDelegate>
{
    BOOL isTableDataEmpty;
    
    plaEvent* m_parsedEvent;
    plaEntity* m_entity;
    
    NSMutableArray* m_arrayTableViewData;
    
    NSInteger intToday;
    
    BOOL isNewCreated;
    
    IBOutlet AsyncImageView* m_imageEntity;
    IBOutlet AsyncImageView* m_imageCricleEntity;
    
    IBOutlet UILabel* m_lblName;
    IBOutlet UILabel* m_lblCategory;
    IBOutlet UILabel* m_lblPhoneNum;
    IBOutlet UILabel* m_lblDistance;
    IBOutlet UILabel* m_lblLocation;
    IBOutlet UILabel* m_lblAddress;
    
    IBOutlet UITableView* m_tableView;
    IBOutlet UIImageView* m_activityViewLoading;
    
    IBOutlet UIButton *m_btnSetting;
    
    // -------- edit Facebook ID
    
    IBOutlet UIView *m_viewEditEntity;
    IBOutlet UIImageView *m_imageViewBG;
    IBOutlet UITextField *m_textFieldFBPageID;
}

-(void)loadEntityData;

//-(IBAction)onBtnHost:(id)sender
-(IBAction)btnBack:(UIButton *)sender;
-(IBAction)btnEdit:(id)sender;

- (IBAction)onEditBtnCancel:(id)sender;
- (IBAction)onEditBtnInfo:(id)sender;
- (IBAction)onEditBtnSave:(id)sender;


-(void)makeSortingItem:(plaEvent*)_model;
-(void)addEventToTableData:(plaEvent*)_event;
-(void)refreshTableView;

@end
