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
#import "RMCircle.h"
#import "RMLayerCollection.h"
#import "RMMarkerManager.h"
#import "RMProjection.h"
#import "RMMercatorToScreenProjection.h"


#define CONST_MAP_KEY_bing @""
#define CONST_MAP_KEY_cloud @""

@interface RouteMeExampleMapViewController : UIViewController<RMMapViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource, CLLocationManagerDelegate>
{
    NSArray *titles;
    int mapSourceNumber;
    CLLocationManager *locationManager;
    RMMarker *userLocationMarker;
    
    CGRect originalMapViewFrame;
    BOOL isTracingUserLocation;
    BOOL isCompassOn;
}

@property (strong, nonatomic) IBOutlet RMMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *mapSettingButton;
@property (strong, nonatomic) IBOutlet UIPickerView *mapPicker;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *locationButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *compassButton;

- (void) setMapSourceWithNumber: (int) number;
- (IBAction)showMapSettings:(id)sender;
- (IBAction)toggleTraceUserLocation:(id)sender;
- (void)enlargeMapViewFrame;
- (IBAction)toggleCompass:(id)sender;
- (void)restoreMapViewFrame;

@end
