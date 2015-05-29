//
//  StationsListViewController.m
//  CodeChallenge3
//
//  Created by Vik Denic on 10/16/14.
//  Copyright (c) 2014 Mobile Makers. All rights reserved.
//

#import "StationsListViewController.h"
#import "divyBikeStation.h"
#import "MapViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@interface StationsListViewController () <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@property NSArray *results;
@property NSArray *searchResults;

@property CLLocationManager *locationManager;

@end

@implementation StationsListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;

    [self.locationManager requestAlwaysAuthorization];

    self.divvyBikesArray = [[NSMutableArray alloc] init];

    NSURL *url = [NSURL URLWithString:@"http://www.bayareabikeshare.com/stations/json"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
   [ NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {

       NSDictionary *dictionaryFromJSONRequest = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
       NSArray *jsonArray = [dictionaryFromJSONRequest objectForKey:@"stationBeanList"];
       for (NSDictionary *divvyBikeStationsDictionary in jsonArray) {
           divyBikeStation *divvyBikestation = [divyBikeStation new];
           divvyBikestation.stAddress1 = [divvyBikeStationsDictionary objectForKey:@"stAddress1"];
           divvyBikestation.city = [divvyBikeStationsDictionary objectForKey:@"city"];
           divvyBikestation.availableBikes = [[divvyBikeStationsDictionary objectForKey:@"availableBikes"] doubleValue];
           divvyBikestation.latitude = [[divvyBikeStationsDictionary objectForKey:@"latitude"] doubleValue];
           divvyBikestation.longitude = [[divvyBikeStationsDictionary objectForKey:@"longitude"] doubleValue];

           [self.divvyBikesArray addObject:divvyBikestation];

           NSLog(@"%@ , %g", divvyBikestation.stAddress1, divvyBikestation.availableBikes);

       }

       [self.tableView reloadData];


   }];

}


#pragma mark - UITableView

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{


    return self.divvyBikesArray.count;
//    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    divyBikeStation *divvyBikestation = [self.divvyBikesArray objectAtIndex:indexPath.row];
    cell.textLabel.text = divvyBikestation.stAddress1;

//    cell.textLabel.text = @"Hello World!";

    NSNumber *myDoulbeNumber = [NSNumber numberWithDouble:divvyBikestation.availableBikes];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"bikes available: %@",[myDoulbeNumber stringValue]];


    return cell;
}


#pragma mark - PrepareForSegue



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    divyBikeStation *divyBikeStationToPass = [self.divvyBikesArray objectAtIndex:indexPath.row];
    MapViewController *destVC = segue.destinationViewController;

    destVC.divyBikeStationToBePassed = divyBikeStationToPass;

    
}



- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate
                                    predicateWithFormat:@"SELF contains[cd] %@",
                                    searchText];

    self.searchResults = [self.results filteredArrayUsingPredicate:resultPredicate];
}

//-(BOOL)searchDisplayController:(UISearchDisplayController *)controller
//shouldReloadTableForSearchString:(NSString *)searchString
//{
//    [self filterContentForSearchText:searchString
//                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
//                                      objectAtIndex:[self.searchDisplayController.searchBar
//                                                     selectedScopeButtonIndex]]];
//
//    return YES;
//}












@end
