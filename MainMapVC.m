//
//  MainMapVC.m
//  TestPaco
//
//  Created by Irvin Robles on 01/03/16.
//  Copyright © 2016 Irvin Robles. All rights reserved.
//

#import "MainMapVC.h"
#import <GoogleMaps/GoogleMaps.h>
#import "Constant.h"
#import "AFNetworking.h"
#import <Social/Social.h>

@interface MainMapVC ()
{
    CLLocationManager *locationManager;
    GMSPlacesClient *placesClient;
    NSArray *searchPlaces;
    NSString *strForCurLatitude;
    NSString *strForCurLongitude;
    GMSMarker *pinDestino;
    GMSMarker *pinUser;
    BOOL actionFlag;
    BOOL insideFlag;
    BOOL inside1050;
    BOOL inside50100;
    BOOL inside100200;
}

@end

@implementation MainMapVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [locationManager startUpdatingLocation];
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate=self;
    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
    locationManager.distanceFilter=kCLDistanceFilterNone;
    [self CheckForLocationAutorization];
    [self.txtDireccionObjetivo addTarget:self
                        action:@selector(txtDireccionObjetivoDidChangeOrigen:)
              forControlEvents:UIControlEventEditingChanged];
    placesClient=[[GMSPlacesClient alloc]init];
    self.txtDireccionObjetivo.delegate=self;
    actionFlag=NO;
    insideFlag=NO;
    inside50100=NO;
    inside1050=NO;
    inside100200=NO;
    self.mapView.delegate=self;
    
}

-(void)CheckForLocationAutorization
{
    if([CLLocationManager locationServicesEnabled])
    {
        NSLog(@"Location Services Enabled");
        if([CLLocationManager authorizationStatus]==kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted)
        {
                UIAlertController *alert;
                
                alert =[UIAlertController
                        alertControllerWithTitle:@"TestPaco"
                        message:@"TestPaco no tiene permiso de localizacion, favor de habilitar la opcion desde Ajustes."
                        preferredStyle:UIAlertControllerStyleAlert];
                
                UIAlertAction *accionSettings=[UIAlertAction actionWithTitle:@"Ajustes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                    NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                    [[UIApplication sharedApplication] openURL:appSettings];
                }];
                [alert addAction:accionSettings];
                
                [self presentViewController:alert animated:YES completion:nil];
        }
        else
        {
            if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
                [locationManager requestAlwaysAuthorization];
            }
            locationManager.allowsBackgroundLocationUpdates=YES;
            [locationManager startUpdatingLocation];
            GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:16];
            self.mapView.camera=camera;
            [self.mapView clear];
            pinUser=[GMSMarker markerWithPosition:locationManager.location.coordinate];
            pinUser.icon=[UIImage imageNamed:@"pinUser"];
            pinUser.map=self.mapView;
        }
    }
}

- (void)txtDireccionObjetivoDidChangeOrigen:(UITextField *)textfield {
    self.tblDirecciones.hidden=NO;
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude);
    CLLocationCoordinate2D northEast = CLLocationCoordinate2DMake(center.latitude + 0.001,
                                                                  center.longitude + 0.001);
    CLLocationCoordinate2D southWest = CLLocationCoordinate2DMake(center.latitude - 0.001,
                                                                  center.longitude - 0.001);
    GMSAutocompleteFilter *filter = [[GMSAutocompleteFilter alloc] init];
    filter.type = kGMSPlacesAutocompleteTypeFilterNoFilter;
    
    GMSCoordinateBounds *radio=[[GMSCoordinateBounds alloc]init];
    radio=[radio includingCoordinate:center];
    radio=[radio includingCoordinate:northEast];
    radio=[radio includingCoordinate:southWest];
    
    [placesClient autocompleteQuery:textfield.text bounds:radio filter:filter callback:^(NSArray *results, NSError *error) {
        if (error != nil) {
            return;
        }
        searchPlaces=results;
        [self.tblDirecciones reloadData];
    }];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus) status
{
    if(status!=kCLAuthorizationStatusAuthorizedAlways && status!= kCLAuthorizationStatusNotDetermined)
    {
        UIAlertController *alert;
        
        alert =[UIAlertController
                alertControllerWithTitle:@"TestPaco"
                message:@"TestPaco no tiene permiso de localizacion, favor de habilitar la opcion desde Ajustes."
                preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *accionSettings=[UIAlertAction actionWithTitle:@"Ajustes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            NSURL *appSettings = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:appSettings];
        }];
        [alert addAction:accionSettings];
        
        [self presentViewController:alert animated:YES completion:nil];
    }
    else
    {
        if ([locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [locationManager requestAlwaysAuthorization];
        }
        [locationManager startUpdatingLocation];
        locationManager.allowsBackgroundLocationUpdates=YES;
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:16];
        self.mapView.camera=camera;
        pinUser=[GMSMarker markerWithPosition:locationManager.location.coordinate];
        pinUser.icon=[UIImage imageNamed:@"pinUser"];
        [self.mapView clear];
        pinUser.map=self.mapView;
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    pinUser.position=newLocation.coordinate;
    if (actionFlag) {
        CLLocationDistance distance=[[[CLLocation alloc]initWithLatitude:pinUser.position.latitude longitude:pinUser.position.longitude] distanceFromLocation:[[CLLocation alloc] initWithLatitude:pinDestino.position.latitude longitude:pinDestino.position.longitude]];
        
        if (distance>200) {
            self.txtDistancia.text=@"Estás muy lejos del punto objetivo";
        }
        else
        {
            if(distance>100 && distance<=200)
            {
                self.txtDistancia.text=@"Estas lejos del Punto Objectivo";
                insideFlag=NO;
                inside50100=NO;
                inside1050=NO;
                if(!inside100200)
                {
                    UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                    localNotification.fireDate = [NSDate date];
                    localNotification.alertBody = @"Estas lejos del Punto Objectivo";
                    localNotification.soundName = UILocalNotificationDefaultSoundName;
                    localNotification.applicationIconBadgeNumber = 1;
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                    inside100200=YES;
                }
            }
            else
            {
                if(distance>50 && distance <=100)
                {
                    self.txtDistancia.text=@"Estás próximo al punto objetivo";
                    insideFlag=NO;
                    inside100200=NO;
                    inside1050=NO;
                    if (!inside50100)
                    {
                        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate date];
                        localNotification.alertBody = @"Estás próximo al punto objetivo";
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                        localNotification.applicationIconBadgeNumber = 1;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        inside50100=YES;
                    }
                }
                else
                {
                    if(distance>10 && distance <=50)
                    {
                        self.txtDistancia.text=@"Estás muy próximo al punto objetivo";
                        insideFlag=NO;
                        inside100200=NO;
                        inside50100=NO;
                        
                        if(!inside1050)
                        {
                            UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                            localNotification.fireDate = [NSDate date];
                            localNotification.alertBody = @"Estás muy próximo al punto objetivo";
                            localNotification.soundName = UILocalNotificationDefaultSoundName;
                            localNotification.applicationIconBadgeNumber = 1;
                            
                            [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];                        inside1050=YES;
                        }
                    }
                    else
                    {
                        self.txtDistancia.text=@"Estás en el punto objetivo";
                        insideFlag=YES;
                        
                        UILocalNotification* localNotification = [[UILocalNotification alloc] init];
                        localNotification.fireDate = [NSDate date];
                        localNotification.alertBody = @"Estás en el punto objetivo";
                        localNotification.soundName = UILocalNotificationDefaultSoundName;
                        localNotification.applicationIconBadgeNumber = 1;
                        
                        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
                        
                        
                        if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
                        {
                            SLComposeViewController *tweetSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
                            [tweetSheet setInitialText:[NSString stringWithFormat:@"Latitud: %f, Longitud: %f",locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude]];
                            [tweetSheet addImage:[self imageWithView:self.mapView]];
                            
                            [self presentViewController:tweetSheet animated:YES completion:nil];
                        }
                        else
                        {
                            NSLog(@"No se pudo mandar el tweet");
                        }
                    }
                }
            }
        }
        
    }
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [textField performSelector:@selector(selectAll:) withObject:textField afterDelay:0.f];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(searchPlaces.count<1)
    {
        self.tblDirecciones.hidden=YES;
    }
    return searchPlaces.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    GMSAutocompletePrediction *place=(GMSAutocompletePrediction *)searchPlaces[indexPath.row];
    cell.textLabel.text = place.attributedFullText.string;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *index = [NSIndexPath indexPathForRow:indexPath.row inSection:0];
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:index];
    self.txtDireccionObjetivo.text= cell.textLabel.text;
    NSLog(@"%ld",(long)indexPath.row);
    NSLog(@"%@",cell.textLabel.text);
    GMSAutocompletePrediction *place=(GMSAutocompletePrediction *)searchPlaces[indexPath.row];
    [self getCoordinateFromPlaceID:place.placeID];
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

-(void)getCoordinateFromPlaceID:(NSString *)placeID
{
    [placesClient lookUpPlaceID:placeID callback:^(GMSPlace *place, NSError *error) {
        if (error != nil) {
            NSLog(@"Place Details error %@", [error localizedDescription]);
            return;
        }
        if (place != nil) {
            NSLog(@"Place name %@", place.name);
            NSLog(@"Place address %@", place.formattedAddress);
            NSLog(@"Place placeID %@", place.placeID);
            NSLog(@"Place attributions %@", place.attributions);
                
            strForCurLatitude=[NSString stringWithFormat:@"%f",place.coordinate.latitude];
            strForCurLongitude=[NSString stringWithFormat:@"%f",place.coordinate.longitude];
            
            
            if(pinDestino!=nil)
            {
                pinDestino.map=nil;
            }
            self.txtDireccionObjetivo.text=place.formattedAddress;
            pinDestino = [GMSMarker markerWithPosition:place.coordinate];
            pinDestino.title = self.txtDireccionObjetivo.text;
            pinDestino.icon=[UIImage imageNamed:@"pinDestino"];
            pinDestino.map=self.mapView;
            
            CLLocationDistance distance=[[[CLLocation alloc]initWithLatitude:pinUser.position.latitude longitude:pinUser.position.longitude] distanceFromLocation:[[CLLocation alloc] initWithLatitude:pinDestino.position.latitude longitude:pinDestino.position.longitude]];
            
            if(distance>100)
            {
                GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
                UIEdgeInsets newPadding = UIEdgeInsetsMake(80, 80, 80, 80);
                bounds = [bounds includingCoordinate:pinDestino.position];
                bounds = [bounds includingCoordinate:pinUser.position];
                [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:newPadding]];
            }
            else
            {
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:16];
                self.mapView.camera=camera;
            }

            self.tblDirecciones.hidden=YES;
            [self.tblDirecciones reloadData];
            [self.txtDireccionObjetivo resignFirstResponder];
        }
    }];
}

- (IBAction)btnAccion:(id)sender
{
    if (!actionFlag)
    {
        if(pinDestino!=nil)
        {
            CLLocationCoordinate2D circleCenter200 = pinDestino.position;
            GMSCircle *circ200 = [GMSCircle  circleWithPosition:circleCenter200 radius:200];
            circ200.fillColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1];
            circ200.strokeColor = [UIColor colorWithRed:255/255.0 green:0/255.0 blue:0/255.0 alpha:1];
            circ200.map = self.mapView;
            
            CLLocationCoordinate2D circleCenter100 = pinDestino.position;
            GMSCircle *circ100 = [GMSCircle  circleWithPosition:circleCenter100 radius:100];
            circ100.fillColor = [UIColor colorWithRed:240/255.0 green:125/255.0 blue:52/255.0 alpha:1];
            circ100.strokeColor = [UIColor colorWithRed:240/255.0 green:125/255.0 blue:21/255.0 alpha:1];
            circ100.map = self.mapView;
            
            CLLocationCoordinate2D circleCenter50 = pinDestino.position;
            GMSCircle *circ50 = [GMSCircle  circleWithPosition:circleCenter50 radius:50];
            circ50.fillColor = [UIColor colorWithRed:230/255.0 green:216/255.0 blue:101/255.0 alpha:1];
            circ50.strokeColor = [UIColor colorWithRed:230/255.0 green:216/255.0 blue:101/255.0 alpha:1];
            circ50.map = self.mapView;
            
            CLLocationCoordinate2D circleCenter10 = pinDestino.position;
            GMSCircle *circ10 = [GMSCircle  circleWithPosition:circleCenter10 radius:10];
            circ10.fillColor = [UIColor colorWithRed:87/255.0 green:207/255.0 blue:16/255.0 alpha:1];
            circ10.strokeColor = [UIColor colorWithRed:87/255.0 green:207/255.0 blue:16/255.0 alpha:1];
            circ10.map = self.mapView;
            actionFlag=YES;
            [self.btnAccion setTitle:@"Reiniciar" forState:UIControlStateNormal];
            self.imgPin.hidden=YES;
            self.txtDireccionObjetivo.userInteractionEnabled=NO;
            
            CLLocationDistance distance=[[[CLLocation alloc]initWithLatitude:pinUser.position.latitude longitude:pinUser.position.longitude] distanceFromLocation:[[CLLocation alloc] initWithLatitude:pinDestino.position.latitude longitude:pinDestino.position.longitude]];
            
            pinDestino.icon=[UIImage imageNamed:@"pinDestino"];
            pinDestino.map=self.mapView;
            
            if(distance>100)
            {
                GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] init];
                UIEdgeInsets newPadding = UIEdgeInsetsMake(80, 80, 80, 80);
                bounds = [bounds includingCoordinate:pinDestino.position];
                bounds = [bounds includingCoordinate:pinUser.position];
                [self.mapView animateWithCameraUpdate:[GMSCameraUpdate fitBounds:bounds withEdgeInsets:newPadding]];
            }
            else
            {
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:16];
                self.mapView.camera=camera;
            }
        }
    }
    else
    {
        actionFlag=NO;
        insideFlag=NO;
        inside50100=NO;
        inside1050=NO;
        inside100200=NO;
        self.txtDireccionObjetivo.userInteractionEnabled=YES;
        self.imgPin.hidden=NO;
        [self.btnAccion setTitle:@"Iniciar" forState:UIControlStateNormal];
        self.txtDireccionObjetivo.text=@"";
        self.txtDistancia.text=@"";
        pinDestino.map=nil;
        pinDestino=nil;
        [self.mapView clear];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:locationManager.location.coordinate.latitude longitude:locationManager.location.coordinate.longitude zoom:16];
        pinUser=[GMSMarker markerWithPosition:locationManager.location.coordinate];
        pinUser.map=self.mapView;
        pinUser.icon=[UIImage imageNamed:@"pinUser"];
        self.mapView.camera=camera;
    }
}

- (UIImage *) imageWithView:(UIView *)view
 {
     UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 0.0);
     [view.layer renderInContext:UIGraphicsGetCurrentContext()];
     UIImage * img = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     return img;
 }

- (void)mapView:(GMSMapView *)mapView idleAtCameraPosition:(GMSCameraPosition *)position {
    if (!actionFlag) {
        GMSGeocoder *geocoder;
        geocoder=[[GMSGeocoder alloc]init];
        [geocoder reverseGeocodeCoordinate:position.target completionHandler:^(GMSReverseGeocodeResponse * handler, NSError *error) {
            if(error == nil)
            {
                NSString *direccion = [[NSString alloc]init];
                if(handler.firstResult!=nil)
                {
                    direccion=[NSString stringWithFormat:@"%@, %@",handler.firstResult.lines[0],handler.firstResult.lines[1]];
                }
                self.txtDireccionObjetivo.text=direccion;
                self.txtDireccionObjetivo.textAlignment=NSTextAlignmentLeft;
                pinDestino = [GMSMarker markerWithPosition:position.target];
                pinDestino.title = self.txtDireccionObjetivo.text;
                pinDestino.icon=[UIImage imageNamed:@"pinDestino"];
            }
        }];
    }
}

- (void)mapView:(GMSMapView *)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate
{
    [self.txtDireccionObjetivo resignFirstResponder];
    self.tblDirecciones.hidden=YES;
}


@end
