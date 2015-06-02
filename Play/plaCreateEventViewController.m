//
//  plaCreateEventViewController.m
//  Play
//
//  Created by User on 11/21/14.
//  Copyright (c) 2014 Play Entertainment. All rights reserved.
//

#import "plaCreateEventViewController.h"
#import "plaHomeViewController.h"

@interface plaCreateEventViewController ()

@end

@implementation plaCreateEventViewController

@synthesize m_viewControllerHome;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    m_scrollView.contentSize = CGSizeMake(272, 600);
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.view.bounds = CGRectMake(0, 0, 272, 483);
}

-(IBAction)onBtnCancel:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self hideSelfView];
}

-(IBAction)onBtnSave:(id)sender
{
    //[self dismissViewControllerAnimated:YES completion:nil];
    //[self hideSelfView];
}

-(void)hideSelfView
{
    self.view.hidden = YES;
    m_viewControllerHome.m_imageViewBackscreen.hidden = YES;
}

- (void)didReceiveMemoryWarning {
//    [super didReceiveMemoryWarning];
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
