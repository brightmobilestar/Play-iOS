//
//  plaSeachNetworkViewController.m
//  Play
//
//  Created by User on 12/15/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaSeachNetworkViewController.h"
#import "plaEntity.h"
#import "plaEventData.h"
#import "SPGooglePlacesAutocompleteQuery.h"
#import "SPGooglePlacesAutocompletePlace.h"
#import "plaAppDelegate.h"
#import "plaHomeViewController.h"

@interface plaSeachNetworkViewController ()

@end

@implementation plaSeachNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initData];
}

-(void)viewWillAppear:(BOOL)animated
{
    
}

- (void)initData
{
    m_arrayTableData = [[NSMutableArray alloc] init];
    
    searchQuery = [[SPGooglePlacesAutocompleteQuery alloc] init];
    searchQuery.radius = 100.0;
    searchQuery.types = 1;
    shouldBeginEditing = YES;
    
    plaEventData* globData = [plaEventData getInstance];
    globData.m_currentController = @"searchNetworkController";
}

#pragma mark ------- delegate ------ search bar -----------------------
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar                       // called when text ends editing
{
    if (shouldBeginEditing) {
        // Animate in the table view.
        NSTimeInterval animationDuration = 0.3;
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.searchDisplayController.searchResultsTableView.alpha = 1.0;
        [UIView commitAnimations];
        
        [self.searchDisplayController.searchBar setShowsCancelButton:YES animated:YES];
    }
    //BOOL boolToReturn = shouldBeginEditing;
    shouldBeginEditing = YES;
}

-(void)searchBar:(UISearchBar *)_searchBar textDidChange:(NSString *)searchText
{
    searchQuery.input = searchBar.text;
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            searchResultPlaces = places;
            [m_tableView reloadData];
        }
    }];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar                     // called when keyboard search button pressed
{
    [searchBar resignFirstResponder];
    
    searchQuery.input = searchBar.text;
    
    [searchQuery fetchPlaces:^(NSArray *places, NSError *error) {
        if (error) {
            SPPresentAlertViewWithErrorAndTitle(error, @"Could not fetch Places");
        } else {
            searchResultPlaces = places;
            [m_tableView reloadData];
        }
    }];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar                     // called when cancel button pressed
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark ------- delegate ------ table view -----------------------

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView              // Default is 1 if not implemented
{
    return 1;
}

- (SPGooglePlacesAutocompletePlace *)placeAtIndexPath:(NSIndexPath *)indexPath {
    return [searchResultPlaces objectAtIndex:indexPath.row];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [searchResultPlaces count];
//    return [m_arrayTableData count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    plaEntity* entity = [m_arrayTableData objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    UILabel* label = (UILabel*)[cell.contentView viewWithTag:1];
//    label.text = [NSString stringWithFormat:@"%@, %@", entity.EN_SCITY, entity.EN_SSTATE];
    
    label.text = [self placeAtIndexPath:indexPath].name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SPGooglePlacesAutocompletePlace *place = [self placeAtIndexPath:indexPath];
//    [place resolveToPlacemark:^(CLPlacemark *placemark, NSString *addressString, NSError *error) {
//        if (error) {
//            SPPresentAlertViewWithErrorAndTitle(error, @"Could not map selected Place");
//        } else if (placemark) {
//            [self.searchDisplayController.searchResultsTableView deselectRowAtIndexPath:indexPath animated:NO];
//        }
//    }];
    
//    globData.sglobCity], [self replaceWhitesSpace:globData.sglobState]
    [searchBar resignFirstResponder];
    
    NSString* strTemp = [self placeAtIndexPath:indexPath].name;
    
    [g_controllerViewHome setNetworkFromLocationInfo:strTemp];
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
