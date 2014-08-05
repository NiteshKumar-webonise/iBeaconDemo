//
//  ChangeUUIDViewController.h
//  iBeaconFinalDemo


#import <UIKit/UIKit.h>
#import <ESTBeaconManager.h>
@interface ChangeUUIDViewController : UIViewController<ESTBeaconManagerDelegate>
@property (nonatomic,retain) IBOutlet UIButton *btnCancel;
@property (nonatomic,retain) IBOutlet UITextField *txtFeild;
@property (nonatomic, strong) ESTBeaconManager* beaconManager;
@property (nonatomic, strong) ESTBeacon* selectedBeacon;
@property (nonatomic, strong) ESTBeaconRegion* beaconRegion;

-(IBAction)cancel:(id)sender;
-(IBAction)updateNewUUID:(id)sender;
@end
