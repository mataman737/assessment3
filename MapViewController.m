//
//  MapViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property CLLocationManager *manager;
@property MKPointAnnotation *divvyBikeAnnotation;
@property CLLocation *initialLocation;
@property NSString *directionsHere;
@property NSMutableString *steps;
@property NSMutableString *lastSteps;

@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//   add the MKCoordinate region to this.
    self.mapView.delegate = self;
    self.manager.delegate = self;

    self.title = self.divyBikeStationToBePassed.stAddress1;

    self.manager.delegate = self;

    self.manager = [CLLocationManager new];
    [self.manager requestAlwaysAuthorization];
    self.mapView.showsUserLocation = YES;

    double latitude = self.divyBikeStationToBePassed.latitude;
    double longitude = self.divyBikeStationToBePassed.longitude;

    NSLog(@"%g latitude, %g longitude", self.divyBikeStationToBePassed.latitude, self.divyBikeStationToBePassed.longitude);

    self.divvyBikeAnnotation = [MKPointAnnotation new];
    self.divvyBikeAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
    self.divvyBikeAnnotation.title = self.divyBikeStationToBePassed.stAddress1;

    [self.mapView addAnnotation:self.divvyBikeAnnotation];

    self.directionsHere = [NSString stringWithFormat:@"%@, %@", self.divyBikeStationToBePassed.stAddress1, self.divyBikeStationToBePassed.city];
    self.steps = [[NSMutableString alloc] init];

    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    if ( !self.initialLocation )
    {
        self.initialLocation = userLocation.location;

        MKCoordinateRegion region;
        region.center = mapView.userLocation.coordinate;
        region.span = MKCoordinateSpanMake(0.7, 0.7);

        region = [mapView regionThatFits:region];
        [mapView setRegion:region animated:YES];
        //Animation and centering it is optional
    }
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {

    if (annotation == mapView.userLocation) {
        return nil;
    }
    
    MKPinAnnotationView *pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pin"];
    pin.canShowCallout = YES;
    pin.image = [UIImage imageNamed:@"bikeImage"];
    pin.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    return pin;
}




#pragma mark - DirectionsViewDisclosureButton

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"%@", error);
}




- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {

    [self.manager startUpdatingLocation];

    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Directions" message:@"Insert Directions Here" delegate:self cancelButtonTitle:@"Got it!" otherButtonTitles:nil, nil];
    [alert show];


}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    for (CLLocation *location in locations) {
        [self reverseGeocode:location];
        [self.manager stopUpdatingLocation];
        break;
    }
}


- (void)reverseGeocode:(CLLocation *)location {
    [self findDivvyNear:location];
}



- (void)findDivvyNear:(CLLocation *)location {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.directionsHere;

    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *mapItems = response.mapItems;
        MKMapItem *mapItem = mapItems.firstObject;
        [self getDirectionsTo:mapItem];

    }];
}


- (void)getDirectionsTo:(MKMapItem *)destinationItem {
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    request.source = [MKMapItem mapItemForCurrentLocation];
    request.destination = destinationItem;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        NSArray *routes = response.routes;
        MKRoute *route = routes.firstObject;

        NSMutableString *directions = [[NSMutableString alloc] init];
        int stepByStepInstructions = 1;

        for (MKRouteStep *step in route.steps) {
            [directions appendFormat:@"%d: %@\n", stepByStepInstructions, step.instructions];
            stepByStepInstructions ++;
        }
        self.lastSteps = directions;
        NSLog(@"%@ directions", directions);


    }];

}






















@end
