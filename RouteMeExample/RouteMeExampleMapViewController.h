//
//  RouteMeExampleMapViewController.h
//  RouteMeExample
//
//  Created by Clint Liang on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import "RMMapView.h"
#import "RMVirtualEarthSource.h"
#import "RMYahooMapSource.h"
#import "RMCloudMadeMapSource.h"
#import "RMOpenStreetMapSource.h"
#import "RMPath.h"
#import "RMMarker.h"
#import "RMLayerCollection.h"
#import "RMMarkerManager.h"


#define CONST_MAP_KEY_bing @""
#define CONST_MAP_KEY_cloud @""

@interface RouteMeExampleMapViewController : UIViewController<RMMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate>
{
    NSArray *titles;
    int mapSourceNumber;
    CLLocationManager *locationManager;
}

@property (strong, nonatomic) IBOutlet RMMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapSettingButton;
@property (strong, nonatomic) IBOutlet UIPickerView *mapPicker;

- (void) setMapSourceWithNumber: (int) number;
- (IBAction)showMapSettings:(id)sender;

@end
