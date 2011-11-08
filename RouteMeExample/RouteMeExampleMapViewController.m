//
//  RouteMeExampleMapViewController.m
//  RouteMeExample
//
//  Created by Clint Liang on 11-11-05.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "RouteMeExampleMapViewController.h"

@implementation RouteMeExampleMapViewController

@synthesize mapSettingButton;
@synthesize mapPicker;
@synthesize locationButton;
@synthesize compassButton;
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
    
    /*
     * set center
     */
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(53.91000, -122.77634);
    [self.mapView.contents moveToLatLong:center];
    [self.mapView.contents setZoom:11.0f];
    
    /*
     * add marker
     */
    UIImage *markerIcon = [UIImage imageNamed:@"pin.png"];
    CLLocationCoordinate2D markerLocation = CLLocationCoordinate2DMake(53.91081, -122.76192);
    RMMarker *marker = [[RMMarker alloc] initWithUIImage:markerIcon anchorPoint:CGPointMake(0.5, 1.0)];
    [self.mapView.contents.markerManager addMarker:marker AtLatLong:markerLocation];
    
    /*
     * add polyline (RMPath)
     */
    
    //RMPath* routePath = [[RMPath alloc] initWithContents:mapView.contents];
    RMPath *routePath = [[RMPath alloc] initForMap:mapView];
    routePath.enableRotation = TRUE;
    
    //polyline style
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
    
    /*
     * add polygon (RMPath)
     */
    RMPath *polygonPath = [[RMPath alloc] initForMap:mapView];
    polygonPath.enableRotation = TRUE;
    
    //polygon style
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
    
    /*
     * add circle
     */
    RMCircle *circle = [[RMCircle alloc] initWithContents:self.mapView.contents radiusInMeters:1000.0f latLong: CLLocationCoordinate2DMake(53.91081, -122.76192)];
    circle.lineColor = [[UIColor blueColor] colorWithAlphaComponent:0.8];
    circle.lineWidthInPixels = 1;
    circle.fillColor = [[UIColor blueColor] colorWithAlphaComponent:0.1];
    
    [self.mapView.contents.overlay addSublayer:circle];
    
    /*
     * initial location manager
     */
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone; // whenever we move
    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // 100 m
    
}


- (void)viewDidUnload
{
    [self setMapSettingButton:nil];
    [self setMapPicker:nil];
    [self setLocationButton:nil];
    [self setCompassButton:nil];

    [super viewDidUnload];
    mapView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
    return YES;
}

- (void)enlargeMapViewFrame
{
    originalMapViewFrame = self.mapView.frame;
    CGRect newFrame = self.mapView.frame;
    CGRect bounds = self.mapView.superview.bounds;
    
    // pythagoras ftw.
    CGFloat superviewDiagonal = ceilf(sqrtf(bounds.size.width * bounds.size.width + bounds.size.height * bounds.size.height));
    
    // set new size of frame
    newFrame.size.width = superviewDiagonal + 5.f;
    newFrame.size.height = superviewDiagonal + 5.f;
    self.mapView.frame = newFrame;
    
    // center in superview
    self.mapView.center = self.mapView.superview.center;
    self.mapView.frame = CGRectIntegral(self.mapView.frame);
}

- (void)restoreMapViewFrame
{
    self.mapView.frame = originalMapViewFrame;
}

- (IBAction)toggleCompass:(id)sender 
{
    if(!isCompassOn)
        isCompassOn = NO;
    
    if (isCompassOn) 
    {
        [locationManager stopUpdatingHeading];
        [self.mapView setRotation:0];
        [self restoreMapViewFrame];
        
        //restore pin annotations to the original heading
        [self.mapView.contents.markerManager setRotation:(0)];
        
        self.compassButton.style = UIBarButtonItemStyleBordered;
        isCompassOn = NO;
    }
    else
    {
        CLLocation *myLocation = [locationManager location];
        CLLocationCoordinate2D center = myLocation.coordinate;
        [self.mapView.contents moveToLatLong:center];
        
        [self enlargeMapViewFrame];

        [locationManager startUpdatingHeading];
        self.compassButton.style = UIBarButtonItemStyleDone;
        isCompassOn = YES;
    }

}


- (void) setMapSourceWithNumber:(int)number
{
    if (mapSourceNumber == number)
        return;
    
    switch (number) 
    {
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
    //[self.mapView setUserInteractionEnabled:self.mapPicker.isHidden]; //this code dosn't work on xcode 4.2
}

- (IBAction)toggleTraceUserLocation:(id)sender 
{
    if(!isTracingUserLocation)
        isTracingUserLocation = NO;
    
    if (isTracingUserLocation) 
    {
        [locationManager stopUpdatingLocation];
        [self.mapView.markerManager removeMarker:userLocationMarker];
        userLocationMarker = nil;
        self.locationButton.style = UIBarButtonItemStyleBordered;
        isTracingUserLocation = NO;
    }
    else
    {
        CLLocation *myLocation = [locationManager location];
        CLLocationCoordinate2D center = myLocation.coordinate;
        [self.mapView.contents moveToLatLong:center];
        
        [locationManager startUpdatingLocation];
        self.locationButton.style = UIBarButtonItemStyleDone;
        isTracingUserLocation = YES;
    }

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
                  //@"Virtual Earth Aerial", 
                  //@"Virtual Earth Hybrid", 
                  //@"Virtual Earth Road", 
                  //@"Cloud Made Map", 
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
    UIImage *markerIcon = [UIImage imageNamed:@"The-Sea-Turtle.png"];
    CLLocationCoordinate2D markerNewLocation = CLLocationCoordinate2DMake(lat, lng);
    CLLocationCoordinate2D markerOldLocation = CLLocationCoordinate2DMake(oldLocation.coordinate.latitude, oldLocation.coordinate.longitude);
    
    if(!userLocationMarker)
    {
        userLocationMarker = [[RMMarker alloc] initWithUIImage:markerIcon anchorPoint:CGPointMake(0.5, 1.0)];
        [self.mapView.contents.markerManager addMarker:userLocationMarker AtLatLong:markerNewLocation];
    }
    else
    {
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"position"];
        
        anim.fromValue = [NSValue valueWithCGPoint:[[mapView.contents mercatorToScreenProjection] projectXYPoint:[[mapView.contents projection] latLongToPoint:markerOldLocation]]];
        
        anim.toValue = [NSValue valueWithCGPoint:[[mapView.contents mercatorToScreenProjection] projectXYPoint:[[mapView.contents projection] latLongToPoint:markerNewLocation]]];
        
        anim.duration = 0.1f;
        
        [userLocationMarker addAnimation:anim forKey:@"positionAnimation"];
        
        [self.mapView.contents.markerManager moveMarker:userLocationMarker AtLatLon:markerNewLocation];
    }

}
     
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    //test map view rotation
    [self.mapView setRotation:(-1 * newHeading.magneticHeading * M_PI / 180)];
    for (RMMarker *marker in [self.mapView.contents.markerManager markers]) 
    {
        if ([marker isKindOfClass:[RMMarker class]]) 
        {
            [marker setAffineTransform:CGAffineTransformMakeRotation(-1 * newHeading.magneticHeading * M_PI / 180)];
        }
        
    }
    //[self.mapView.contents setRotation:(-1 * newHeading.magneticHeading * M_PI / 180)];
}


@end
