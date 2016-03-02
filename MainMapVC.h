//
//  MainMapVC.h
//  TestPaco
//
//  Created by Irvin Robles on 01/03/16.
//  Copyright © 2016 Irvin Robles. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>
#import "AFNetworking.h"


@interface MainMapVC : UIViewController <CLLocationManagerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,GMSMapViewDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *mapView;
@property (weak, nonatomic) IBOutlet UITextField *txtDireccionObjetivo;
@property (weak, nonatomic) IBOutlet UITableView *tblDirecciones;
@property (weak, nonatomic) IBOutlet UIButton *btnAccion;
@property (weak, nonatomic) IBOutlet UITextField *txtDistancia;
@property (weak, nonatomic) IBOutlet UIImageView *imgPin;

@end
