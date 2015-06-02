//
//  plaSearchLocationViewController.m
//  Play
//
//  Created by User on 11/23/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaSearchLocationViewController.h"
#import "plaEntity.h"
#import "plaEventData.h"
#import "AsyncImageView.h"
#import "plaAppDelegate.h"
#import "plaHomeViewController.h"
#import "plaHomeTableViewCell.h"
#import "plaEventDetailViewController.h"
#import "plaWebServices.h"

@interface plaSearchLocationViewController ()

@end

@implementation plaSearchLocationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    m_arrayTableData = [[NSMutableArray alloc] init];
    
    //[m_tableView reloadData];
    plaEventData* globData = [plaEventData getInstance];
    switch (globData.sglobControllerIndex) {
        case 1: // homeview controller
            if (g_controllerViewHome.m_intCreateField == 1) {
                [m_searchBar setText:g_controllerViewHome.m_createWhereEntity.EN_SNAME];
                NSString* str = g_controllerViewHome.m_createWhereEntity.EN_SNAME;
                [self searchBar:nil textDidChange:str ];
            } else if (g_controllerViewHome.m_intCreateField == 2) {
                [m_searchBar setText:g_controllerViewHome.m_createArtistEntity.EN_SNAME];
                NSString* str = g_controllerViewHome.m_createArtistEntity.EN_SNAME;
                [self searchBar:nil textDidChange:str ];
            }
            break;
            
        case 2: // eventdetail controller
            if (g_controllerEventDetail.m_intCreateField == 1) {
                [m_searchBar setText:g_controllerEventDetail.m_createWhereEntity.EN_SNAME];
                NSString* str = g_controllerEventDetail.m_createWhereEntity.EN_SNAME;
                [self searchBar:nil textDidChange:str ];
            } else if (g_controllerEventDetail.m_intCreateField == 2) {
                [m_searchBar setText:g_controllerEventDetail.m_createArtistEntity.EN_SNAME];
                NSString* str = g_controllerEventDetail.m_createArtistEntity.EN_SNAME;
                [self searchBar:nil textDidChange:str ];
            }
            break;
        default:
            break;
    }
}

-(void)cleanerTableDataArray
{
    plaWebServices* webService = [[plaWebServices alloc] init];
    for (NSInteger i = [m_arrayTableData count] - 1; i > -1; i --) {
        plaEntity * entity = [m_arrayTableData objectAtIndex:i];
        entity.EN_SNAME = [webService replaceToWhitesSpace:entity.EN_SNAME];
//        if (([entity.EN_SID rangeOfString:@"db"].location != NSNotFound) && (!(entity.EN_SFACEBOOKID == nil || [entity.EN_SFACEBOOKID isEqualToString:@"(null)"] || [entity.EN_SFACEBOOKID isEqualToString:@""])) ) {
//            [m_arrayTableData removeObjectAtIndex:i];
//            break;
//        } 
        for (NSInteger j = 0; j < i; j ++) {
            plaEntity* entity1 = [m_arrayTableData objectAtIndex:j];
            entity1.EN_SNAME = [webService replaceToWhitesSpace:entity1.EN_SNAME];
            if ([[entity.EN_SNAME uppercaseString] isEqualToString:[entity1.EN_SNAME uppercaseString]]) {
                [m_arrayTableData removeObjectAtIndex:i];
                break;
            }
        }
    }
}

-(IBAction)onBtnBack:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ----- delegate -- search bar -----
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText   // called when text changes (including clear)
{
    [m_arrayTableData removeAllObjects];
    plaEventData* globData = [plaEventData getInstance];
    
    for (int i = 0; i < [globData.arrayglobDBEntities count]; i++) {
        plaEntity* entity = [globData.arrayglobDBEntities objectAtIndex:i];
        
        if ([searchText isEqualToString:@""]) {
            if (i < 5) {
                [m_arrayTableData addObject:entity];
            } else {
                break;
            }
        }
        
        NSInteger length = [searchText length];
        if ([entity.EN_SNAME isEqualToString:@""]) {
            continue;
        }
        
        if ([entity.EN_SNAME length] > length - 1) {
            if ([[[entity.EN_SNAME substringWithRange: NSMakeRange(0, length)] uppercaseString] isEqualToString:[searchText uppercaseString]]) {
                [m_arrayTableData addObject:entity];
            }
        }
        //        if ([entity.EN_SNAME rangeOfString:searchText].location != NSNotFound) {
        //            [m_arrayTableData addObject:entity];
        //        }
    }
    
    [self cleanerTableDataArray];
    
    [m_tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self onBtnBack:nil];
}

#pragma mark ----- delegate --- tableview ------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([m_arrayTableData count] > 0) {
        return [m_arrayTableData count];
    } else {
        if (![m_searchBar.text isEqualToString:@""]) {
            return 1;
        }
    }
    return 0;
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaEventData* globData = [plaEventData getInstance];
    if ([m_arrayTableData count] > 0) {
        plaEntity* entity = [m_arrayTableData objectAtIndex:indexPath.row];
        
        plaHomeTableViewCell* cell = (plaHomeTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        [cell.m_imageView0 setImageURL:[NSURL URLWithString:entity.EN_SIMAGE]];
        [cell.m_lblText1 setText:entity.EN_SNAME];
        [cell.m_lblText2 setText:[NSString stringWithFormat:@"%@, %@", entity.EN_SSTREET, entity.EN_SCITY]];
        
        return cell;
    } else {
        UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell1" forIndexPath:indexPath];
        UILabel* lbl = (UILabel*)[cell viewWithTag:2];
        
        if ( globData.sglobControllerIndex == 1 )
        {
            if (g_controllerViewHome.m_intCreateField == 1) {
                lbl.text = @"Add new location";
            } else if (g_controllerViewHome.m_intCreateField == 2) {
                lbl.text = @"Add New Artist";
            }
        } else {
            if (g_controllerEventDetail.m_intCreateField == 1) {
                lbl.text = @"Add new location";
            } else if (g_controllerEventDetail.m_intCreateField == 2) {
                lbl.text = @"Add New Artist";
            }
        }
        
        return cell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    plaEventData* globData = [plaEventData getInstance];
    NSInteger today = [[NSDate date] timeIntervalSince1970];
    NSString* strTempEntityID = [NSString stringWithFormat:@"db%ld", (long)today];
    if ( globData.sglobControllerIndex == 1 )
    {
        if (g_controllerViewHome.m_intCreateField == 1) {
            if ([m_arrayTableData count] > 0) {
                plaEntity* entity = [m_arrayTableData objectAtIndex:indexPath.row];
                [g_controllerViewHome.m_textFieldWhere setText:entity.EN_SNAME];
                g_controllerViewHome.m_createWhereEntity = entity;
            } else {
                plaEntity* entity = [[plaEntity alloc] init];
                entity.EN_SID = strTempEntityID;
                entity.EN_SNAME = m_searchBar.text;
                
                [g_controllerViewHome.m_textFieldWhere setText:entity.EN_SNAME];
                g_controllerViewHome.m_createWhereEntity = entity;
                
                [globData.arrayglobDBEntities addObject:entity];
            }
        } else if (g_controllerViewHome.m_intCreateField == 2) {
            plaEntity* entity;
            if ([m_arrayTableData count] > 0) {
                entity = [m_arrayTableData objectAtIndex:indexPath.row];
            } else {
                entity = [[plaEntity alloc] init];
                entity.EN_SID = strTempEntityID;
                entity.EN_SNAME = m_searchBar.text;
                
                [globData.arrayglobDBEntities addObject:entity];
            }
            
            [g_controllerViewHome.m_textFieldArtists setText:entity.EN_SNAME];
            g_controllerViewHome.m_createArtistEntity = entity;
            
            if ([g_controllerViewHome.m_arrayTableViewArtistData count] > g_controllerViewHome.m_intCurrentSelectedArtist) {
                [g_controllerViewHome.m_arrayTableViewArtistData removeObjectAtIndex:g_controllerViewHome.m_intCurrentSelectedArtist];
                [g_controllerViewHome.m_arrayTableViewArtistData insertObject:entity atIndex:g_controllerViewHome.m_intCurrentSelectedArtist];
            } else {
                [g_controllerViewHome.m_arrayTableViewArtistData addObject:entity];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ( globData.sglobControllerIndex == 2 ) {
        if (g_controllerEventDetail.m_intCreateField == 1) {
            if ([m_arrayTableData count] > 0) {
                plaEntity* entity = [m_arrayTableData objectAtIndex:indexPath.row];
                [g_controllerEventDetail.m_textFieldWhere setText:entity.EN_SNAME];
                g_controllerEventDetail.m_createWhereEntity = entity;
            } else {
                plaEntity* entity = [[plaEntity alloc] init];
                entity.EN_SID = strTempEntityID;
                entity.EN_SNAME = m_searchBar.text;
                
                [g_controllerEventDetail.m_textFieldWhere setText:entity.EN_SNAME];
                g_controllerEventDetail.m_createWhereEntity = entity;
                
                [globData.arrayglobDBEntities addObject:entity];
            }
            
        } else if (g_controllerEventDetail.m_intCreateField == 2) {
            plaEntity* entity;
            if ([m_arrayTableData count] > 0) {
                entity = [m_arrayTableData objectAtIndex:indexPath.row];
            } else {
                entity = [[plaEntity alloc] init];
                entity.EN_SID = strTempEntityID;
                entity.EN_SNAME = m_searchBar.text;
                
                [globData.arrayglobDBEntities addObject:entity];
            }
            
            [g_controllerEventDetail.m_textFieldArtists setText:entity.EN_SNAME];
            g_controllerEventDetail.m_createArtistEntity = entity;
            
            if ([g_controllerEventDetail.m_arrayTableViewArtistData count] > g_controllerEventDetail.m_intCurrentSelectedArtist) {
                [g_controllerEventDetail.m_arrayTableViewArtistData removeObjectAtIndex:g_controllerEventDetail.m_intCurrentSelectedArtist];
                [g_controllerEventDetail.m_arrayTableViewArtistData insertObject:entity atIndex:g_controllerEventDetail.m_intCurrentSelectedArtist];
            } else {
                [g_controllerEventDetail.m_arrayTableViewArtistData addObject:entity];
            }
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    }
        
    
}

#pragma mark -------- to make DB EntityID including name --------
-(NSString*) getDBEntityID:(NSString*)_id sec:(NSString*)_name
{
    NSString* strTempEntityID = _id;
    
    strTempEntityID = [NSString stringWithFormat:@"%@***%@", strTempEntityID, _name];
    
    return strTempEntityID;
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
