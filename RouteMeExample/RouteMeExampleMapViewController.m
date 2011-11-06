//
//  RouteMeExampleMapViewController.m
//  RouteMeExample
//
//  Created by Zhe Liang on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RouteMeExampleMapViewController.h"

@implementation RouteMeExampleMapViewController

@synthesize mapSettingButton;
@synthesize mapPicker;
@synthesize mapView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    [RMMapView class]; // this important, maps won't display without it
    [mapView setDelegate:self];
    
    mapSourceNumber = 0;
    self.mapPicker.hidden = true;
    [self setMapSourceWithNumber:mapSourceNumber];
    [self.mapPicker selectRow:mapSourceNumber inComponent:0 animated:NO];
    
    //set center
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(53.91000, -122.77634);
    [self.mapView.contents moveToLatLong:center];
    [self.mapView.contents setZoom:11.0f];
    
    //add marker
    UIImage *markerIcon = [UIImage imageNamed:@"pin.png"];
    CLLocationCoordinate2D markerLocation = CLLocationCoordinate2DMake(53.91081, -122.76192);
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:markerIcon anchorPoint:CGPointMake(0.5, 1.0)];
    [self.mapView.contents.markerManager addMarker:marker AtLatLong:markerLocation];
    
    //add path
    
    //RMPath* routePath = [[RMPath alloc] initWithContents:mapView.contents];
    RMPath *routePath = [[RMPath alloc] initForMap:mapView];
    routePath.enableRotation = TRUE;
    
    //style
    routePath.lineColor = [[UIColor redColor] colorWithAlphaComponent:0.6];
    routePath.fillColor = [UIColor clearColor];
    routePath.lineWidth = 3;
    routePath.scaleLineWidth = NO;
    
    [routePath setDrawingMode:kCGPathStroke];
    
    
    [routePath addLineToLatLong:CLLocationCoordinate2DMake(53.929007017259, -122.77976989746)];
    [routePath addLineToLatLong:CLLocationCoordinate2DMake(53.901101814728, -122.78045654297)];
    [routePath addLineToLatLong:CLLocationCoordinate2DMake(53.878440403329, -122.76947021484)];
    [routePath addLineToLatLong:CLLocationCoordinate2DMake(53.855361704511, -122.77839660645)];
    [routePath addLineToLatLong:CLLocationCoordinate2DMake(53.846450730723, -122.81753540039)];
    
    [self.mapView.contents.overlay addSublayer:routePath];
    
    //add polygon
    RMPath *polygonPath = [[RMPath alloc] initForMap:mapView];
    polygonPath.enableRotation = TRUE;
    
    //style
    polygonPath.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.6];
    polygonPath.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.2];
    polygonPath.lineWidth = 2;
    polygonPath.scaleLineWidth = NO;
    
    [polygonPath setDrawingMode:kCGPathFillStroke];
    
    [polygonPath addLineToLatLong:CLLocationCoordinate2DMake(53.900292690168, -122.81204223633)];
    [polygonPath addLineToLatLong:CLLocationCoordinate2DMake(53.880464243188, -122.81066894531)];
    [polygonPath addLineToLatLong:CLLocationCoordinate2DMake(53.880464243188, -122.78663635254)];
    [polygonPath addLineToLatLong:CLLocationCoordinate2DMake(53.900697254407, -122.78869628907)];
    [polygonPath addLineToLatLong:CLLocationCoordinate2DMake(53.900292690168, -122.81204223633)];
    
    [self.mapView.contents.overlay addSublayer:polygonPath];
    
    //updating location
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    [locationManager startUpdatingLocation];
    
    
}


- (void)viewDidUnload
{
    [self setMapSettingButton:nil];
    [self setMapPicker:nil];
    [super viewDidUnload];
    mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void) setMapSourceWithNumber:(int)number
{
    if (mapSourceNumber == number)
        return;
    
    switch (number) {
        case 0:
            mapView.contents.tileSource = [[RMOpenStreetMapSource alloc] init];
            break;
        case 1:
            mapView.contents.tileSource = [[RMYahooMapSource alloc] init]; 
            break;
            
        case 2:
            mapView.contents.tileSource = [[RMVirtualEarthSource alloc] initWithAerialThemeUsingAccessKey:CONST_MAP_KEY_bing]; 
            break;
        case 3:
            mapView.contents.tileSource = [[RMVirtualEarthSource alloc] initWithHybridThemeUsingAccessKey:CONST_MAP_KEY_bing]; 
            break;
        case 4:
            mapView.contents.tileSource = [[RMVirtualEarthSource alloc] initWithRoadThemeUsingAccessKey:CONST_MAP_KEY_bing]; 
            break;
            
        case 5:
            mapView.contents.tileSource = [[RMCloudMadeMapSource alloc] initWithAccessKey:CONST_MAP_KEY_cloud styleNumber:1];
            break;
            
        default:
            return;
            break;
    }
    
    // this trick refreshs maps with new source
    [mapView moveBy:CGSizeMake(640,960)]; 
    [mapView moveBy:CGSizeMake(-640,-960)];
    
    mapSourceNumber = number;
    // remember user choice between runnings
    [[NSUserDefaults standardUserDefaults] setInteger:mapSourceNumber forKey:@"mapSourceNumber"];
}

- (IBAction)showMapSettings:(id)sender 
{
    NSLog(@"show map settings");
    
    BOOL toShow = [self.mapPicker isHidden];
    
    if (toShow)
    {
        [self.mapSettingButton setStyle:UIBarButtonItemStyleDone];
    }
    else // hidding
    {
        [self.mapSettingButton setStyle:UIBarButtonItemStyleBordered];
        [self setMapSourceWithNumber:[self.mapPicker selectedRowInComponent:0]];
    }
    
    
    [self.mapPicker setHidden:![self.mapPicker isHidden]];
    if (self.mapPicker.hidden) {
        NSLog(@"hidden");
    }
    else
    {
        NSLog(@"show");
    }
    //[self.mapView setUserInteractionEnabled:self.mapPicker.isHidden];
}

/*
 * UIPickerViewDelegate methods
 */
- (NSString *)pickerView:(UIPickerView *)pickerView 
titleForRow:(NSInteger)row 
forComponent:(NSInteger)component
{
    return [titles objectAtIndex:row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView 
numberOfRowsInComponent:(NSInteger)component
{
    if (!titles)
    {
        titles = [[NSArray alloc] initWithObjects:
                  @"Open Street Maps", 
                  @"Yahoo Map",
                  @"Virtual Earth Aerial", 
                  @"Virtual Earth Hybrid", 
                  @"Virtual Earth Road", 
                  @"Cloud Made Map", 
                  nil];
    }
    
    return [titles count];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component 
{
    
}

/*
 * CLLocationManagerDelegate methods
 */
- (void)locationManager:(CLLocationManager *)manager
didUpdateToLocation:(CLLocation *)newLocation
fromLocation:(CLLocation *)oldLocation
{
    double lat = newLocation.coordinate.latitude;
    
    double lng = newLocation.coordinate.longitude;
    
    NSLog(@"(%f, %f)", lat, lng);
}


@end
