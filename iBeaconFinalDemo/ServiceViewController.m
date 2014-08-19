//
//  ServiceViewController.m
//  iBeaconFinalDemo
//
//  Created by Nitesh_iMac on 8/18/14.
//  Copyright (c) 2014 Webonise. All rights reserved.
//


#import "ServiceViewController.h"
#import "ESTBeaconTableVC.h"
#import "ESTTemperatureDemoVC.h"
#import "ESTAccelerometerDemoVC.h"
#import "ESTUpdateFirmwareDemoVC.h"
#import "CloudAuthVC.h"
#import "ESTCloudBeaconTableVC.h"

@interface ESTDemoTableViewCell : UITableViewCell

@end

@implementation ESTDemoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        
    }
    
    return self;
}

@end


@implementation ServiceViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    [CloudAuthVC setAuthenticationStatus:false];
    [self.navigationController.navigationBar setHidden:NO];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    self.title = @"Estimote Demos";
    
    self.tableView.sectionHeaderHeight = 20;
    [self.tableView registerClass:[ESTDemoTableViewCell class] forCellReuseIdentifier:@"DemoCellIdentifier"];
    
    UIBarButtonItem *authButton = [[UIBarButtonItem alloc] initWithTitle:@"Authorize"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(authorizeBtnTapped:)];
    
    self.navigationItem.rightBarButtonItem = authButton;
    
    self.beaconDemoList = @[@[@"Temperature Demo", @"Accelerometer Demo"],
                             @[@"Update Firmware Demo", @"My beacons in Cloud Demo"]];
    
}

-(void)authorizeBtnTapped:(UIButton *)button
{
    UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CloudAuthVC *cloudAuthVC = [mystoryboard instantiateViewControllerWithIdentifier:@"cloudAuthVC"];
    [self presentViewController:cloudAuthVC animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self.beaconDemoList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.beaconDemoList objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    if(section == 0)
        return @"Sensor demos";
    if(section == 1)
        return @"Utilities demos";
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ESTDemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DemoCellIdentifier" forIndexPath:indexPath];
    cell.textLabel.text = [[self.beaconDemoList objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 40;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *v = (UITableViewHeaderFooterView *)view;
    v.backgroundView.backgroundColor = [UIColor darkGrayColor];
    v.textLabel.textColor = [UIColor whiteColor];
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *demoViewController;
    if (indexPath.section == 0)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                demoViewController = [[ESTBeaconTableVC alloc]initWithScanType:ESTScanTypeBeacon completion:^(ESTBeacon *beacon){
                    ESTTemperatureDemoVC *teperatureVC = [[ESTTemperatureDemoVC alloc] initWithBeacon:beacon];
                    [self.navigationController pushViewController:teperatureVC animated:YES];
                }];
            }
                break;
            case 1:
            {
                demoViewController = [[ESTBeaconTableVC alloc]initWithScanType:ESTScanTypeBeacon completion:^(ESTBeacon *beacon){
                ESTAccelerometerDemoVC *accelerometerDemoVC = [[ESTAccelerometerDemoVC alloc] initWithBeacon:beacon];
                [self.navigationController pushViewController:accelerometerDemoVC animated:YES];
                }];
                
            }
                break;
            default:
                break;
        }
    }else if (indexPath.section == 1)
    {
        switch (indexPath.row)
        {
            case 0:
            {
                demoViewController = [[ESTBeaconTableVC alloc]initWithScanType:ESTScanTypeBluetooth completion:^(ESTBeacon *beacon){
                    ESTUpdateFirmwareDemoVC *updateFirmware = [[ESTUpdateFirmwareDemoVC alloc] initWithBeacon:beacon];
                    [self.navigationController pushViewController:updateFirmware animated:YES];
                }];
            }
                break;
                
            case 1:
            {
                demoViewController = [ESTCloudBeaconTableVC new];
                
                break;
            }
                
            default:
                break;
        }
    }
    
    if (demoViewController)
    {
        if([CloudAuthVC getAuthenticationStatus]){
            [self.navigationController pushViewController:demoViewController animated:YES];
        }else{
            UIStoryboard *mystoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            CloudAuthVC *cloudAuthVC = [mystoryboard instantiateViewControllerWithIdentifier:@"cloudAuthVC"];
            [self presentViewController:cloudAuthVC animated:YES completion:nil];
            //[self.navigationController pushViewController:cloudAuthVC animated:YES];
        }
        
    }
    
    
}

@end
