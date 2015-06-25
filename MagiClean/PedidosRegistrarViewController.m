//
//  PedidosRegistrarViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 18/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "PedidosRegistrarViewController.h"
#import "CustomPickerViewController.h"
#import "CustomDatePickerViewController.h"
#define GOOGLE_API_KEY @"AIzaSyARBKRTVctNUoDrfFa-9xn8O0wwu1uGn9U"
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
@import GoogleMaps;
@interface PedidosRegistrarViewController () <CustomPickerDelegate, MyCVDatePickerDelegate>
{
    GMSMapView *googleMap;
    GMSPlacesClient *placesClient;
}
@property (nonatomic) NSArray *arrayCategorias;
@property (nonatomic) NSArray *arrayProductos;
@property (nonatomic) NSArray *arrayStatus;
@property (nonatomic) NSArray *arrayClients;
@property (nonatomic) NSMutableArray *arrayCategoryTitles;
@property (nonatomic) NSMutableArray *arrayProductTitles;
@property (nonatomic) NSMutableArray *arrayStatusTitles;
@property (nonatomic) NSMutableArray *arrayClientTitles;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) Categorias *selectedCategoria;
@property (nonatomic, strong) Producto *selectedProducto;
@property (nonatomic, strong) CustomPickerViewController *customPicker;
@property (nonatomic, strong) CustomDatePickerViewController *customDatePicker;
@property (nonatomic, strong) Cliente *selectedClient;
@property (nonatomic) double finalPrice;
@end

@implementation PedidosRegistrarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadUI];
    [self loadMaps];
    self.locationManager = [[CLLocationManager alloc]init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    placesClient = [[GMSPlacesClient alloc]init];
  
    
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    [self loadData];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self.scrollView setContentSize:CGSizeMake(self.view.frame.size.width, googleMap.frame.origin.y + googleMap.frame.size.height + 200)];
}

-(void)loadMaps
{
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:-33.86 longitude:151.20 zoom:6];
    googleMap = [GMSMapView mapWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 30, 188) camera:camera];
    googleMap.myLocationEnabled = YES;
    [self.mapView addSubview:googleMap];
    
}

-(void)loadUI
{
    self.btnCategoria.tag = 102;
    self.btnProducto.tag = 101;
    self.btnCLiente.tag = 103;
    self.btnStatus.tag = 104;
    
    [self.btnCategoria.layer setCornerRadius:10];
    [self.btnProducto.layer setCornerRadius:10];
    [self.btnCLiente.layer setCornerRadius:10];
    [self.btnFechaEntrega.layer setCornerRadius:10];
    [self.btnFechaPedido.layer setCornerRadius:10];
    [self.btnStatus.layer setCornerRadius:10];
    
    [self.btnFechaPedido addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnFechaEntrega addTarget:self action:@selector(showDatePicker:) forControlEvents:UIControlEventTouchUpInside];
     self.customDatePicker = [[CustomDatePickerViewController alloc]initWithDelegate:self];
    self.customDatePicker.pickerView.backgroundColor = [UIColor whiteColor];
     self.txtCantidad.enabled = NO;
    self.stepperCantidad.enabled = NO;
    [self.stepperCantidad addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

-(void)showDatePicker:(UIButton *)datePickerBtn
{
    if (datePickerBtn == self.btnFechaPedido) {
        self.customDatePicker.pickerView.tag = 2001;
    }else if (datePickerBtn == self.btnFechaEntrega){
        self.customDatePicker.pickerView.tag = 2002;
    }
   
    self.customDatePicker.pickerHeight = self.view.frame.size.height * 0.33;
    [self showPicker:self.customDatePicker];
}

-(void)showPicker:(CustomDatePickerViewController *)picker
{
    UIViewController *parent = self.parentViewController.parentViewController;
    if (parent == nil) {
        parent = self.parentViewController;
    }
    if (parent == nil) {
        parent = self;
    }
    [self.customDatePicker showInViewController:self.parentViewController];
    
}

-(void)pickerWasCancelled:(CustomDatePickerViewController *)picker
{
    
}

-(void)picker:(CustomDatePickerViewController *)picker pickedDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
    [dateFormatter setDateFormat:@"dd MMMM"];
    NSString *dateString = [dateFormatter stringFromDate:date];

    switch (self.customDatePicker.pickerView.tag) {
        case 2001:
        {
            [self.btnFechaPedido setTitle:dateString forState:UIControlStateNormal];
        }
            break;
        case 2002:
        {
           [self.btnFechaEntrega setTitle:dateString forState:UIControlStateNormal];
        }
            break;
        default:
            break;
    }
    
}


- (IBAction)valueChanged:(UIStepper *)sender {
    double value = [sender value];
    [self.txtCantidad setText:[NSString stringWithFormat:@"%d", (int)value]];
    self.finalPrice = [self.selectedProducto.precioVenta doubleValue] * value;
    [self.lblTotal setText:[NSString stringWithFormat:@"$ %.2f", self.finalPrice]];
}


-(void)loadData
{
    self.arrayCategorias = [cdh savedCategoriesOnDB];
    self.arrayClients = [cdh savedClients];
    self.customPicker =[[CustomPickerViewController alloc]initWithDelegate:self];
    self.customPicker.view.backgroundColor = [UIColor whiteColor];
    [self.btnCategoria addTarget:self action:@selector(showPickerForTag:) forControlEvents:UIControlEventTouchDown];
    [self.btnProducto addTarget:self action:@selector(showPickerForTag:) forControlEvents:UIControlEventTouchDown];
    [self.btnCLiente addTarget:self action:@selector(showPickerForTag:) forControlEvents:UIControlEventTouchDown];
    [self.btnStatus addTarget:self action:@selector(showPickerForTag:) forControlEvents:UIControlEventTouchDown];
    self.arrayStatus = @[@"Pendiente", @"Entregado", @"Cancelado"];
    if (self.willRegister) {
        
    }
}
-(void)showPickerForTag:(UIButton *)sender{
    switch (sender.tag) {
        case 101:{
            if (self.selectedCategoria) {
                self.customPicker.pickerView.tag = 1001;
                NSMutableArray *fillProductArray = [[NSMutableArray alloc]init];
                self.arrayProductos = [cdh savedProductsOnDBForCategory:self.selectedCategoria.idCategoria];
                if ([self.arrayProductos count] > 0) {
                    for (Producto *currentProduct in self.arrayProductos) {
                        [fillProductArray addObject:currentProduct.nombreProducto];
                    }
                    self.arrayProductTitles = fillProductArray;
                    [self loadPickerWithInfoArray:self.arrayProductTitles];
                }else{
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"No hay productos registrados en esta categoría" preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                        
                    }];
                    [alert addAction:cancelAction];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
            }else{
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Necesitas seleccionar primero una categoría" preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    
                }];
                [alert addAction:okAction];
                [self presentViewController:alert animated:YES completion:nil];
            }
            break;
        }
        case 102:{
            self.customPicker.pickerView.tag = 1002;
            NSMutableArray *fillCategoryArray = [[NSMutableArray alloc]init];
            for (Categorias *currentCategory in self.arrayCategorias) {
                [fillCategoryArray addObject:currentCategory.nombreCategoria];
            }
            self.arrayCategoryTitles = fillCategoryArray;
            [self loadPickerWithInfoArray:self.arrayCategoryTitles];
            break;
        }
        case 103:{
            self.customPicker.pickerView.tag = 1003;
            NSMutableArray *fillClientArray = [[NSMutableArray alloc]init];
            for (Cliente *currentClient in self.arrayClients) {
                [fillClientArray addObject:[NSString stringWithFormat:@"%@ %@", currentClient.nombreCliente, currentClient.apellidoCliente]];
            }
            self.arrayClientTitles = fillClientArray;
            [self loadPickerWithInfoArray:self.arrayClientTitles];
            
        }
            break;
        case 104:{
            self.customPicker.pickerView.tag = 1004;
            
            [self loadPickerWithInfoArray:self.arrayStatus];
        }
            break;
        default:
            break;
    }
}

-(void)loadPickerWithInfoArray:(NSArray *)array
{
    self.customPicker.pickerItems = array;
    [self.customPicker.pickerView reloadAllComponents];
    [self.customPicker showInViewController:self.parentViewController];
}


-(void)picker:(CustomPickerViewController *)picker pickedValueAtIndex:(NSInteger)index{
    switch (picker.pickerView.tag) {
        case 1001:
        {
            self.selectedProducto = [self.arrayProductos objectAtIndex:index];
            [self.btnProducto setTitle:[self.arrayProductTitles objectAtIndex:index] forState:UIControlStateNormal];
            self.stepperCantidad.enabled = YES;
            [self.lblTotal setText:[NSString stringWithFormat:@"$ %@",self.selectedProducto.precioVenta]];
        }
            break;
        case 1002:
        {
            self.selectedCategoria = [self.arrayCategorias objectAtIndex:index];
            self.selectedProducto = nil;
            [self.btnProducto setTitle:@"Elige un Producto" forState:UIControlStateNormal];
            [self.btnCategoria setTitle:self.selectedCategoria.nombreCategoria forState:UIControlStateNormal];
             self.stepperCantidad.enabled = NO;
            [self.lblTotal setText:[NSString stringWithFormat:@"$ 0.00"]];
        }
            break;
        case 1003:
        {
            self.selectedClient = [self.arrayClients objectAtIndex:index];
            [self.btnCLiente setTitle:[self.arrayClientTitles objectAtIndex:index] forState:UIControlStateNormal];
        }
            break;
         case 1004:
        {
            [self.btnStatus setTitle:[self.arrayStatus objectAtIndex:index] forState:UIControlStateNormal];
            if ([[self.arrayStatus objectAtIndex:index] isEqualToString:@"Pendiente"]) {
                [self.btnStatus setBackgroundColor:[UIColor colorWithHexString:@"CFBE27"]];
            }else if ([[self.arrayStatus objectAtIndex:index] isEqualToString:@"Entregado"]){
                [self.btnStatus setBackgroundColor:[UIColor baseColor]];
            }else if ([[self.arrayStatus objectAtIndex:index] isEqualToString:@"Cancelado"]){
                [self.btnStatus setBackgroundColor:[UIColor redColor]];
            }
        }
            break;
        default:
            break;
    }
}

-(void)mapViewWillStartLoadingMap:(MKMapView *)mapView
{
    
}

-(void)mapViewWillStartLocatingUser:(MKMapView *)mapView
{
    
}

-(void)getCurrentPlace
{
    [placesClient currentPlaceWithCallback:^(GMSPlaceLikelihoodList *likelihoodList, NSError *error) {
        if (error != nil) {
            NSLog(@"Current Place error %@", [error localizedDescription]);
            return;
        }
        
        for (GMSPlaceLikelihood *likelihood in likelihoodList.likelihoods) {
            GMSPlace* place = likelihood.place;
            NSLog(@"Current Place name %@ at likelihood %g", place.name, likelihood.likelihood);
            NSLog(@"Current Place address %@", place.formattedAddress);
            NSLog(@"Current Place attributions %@", place.attributions);
            NSLog(@"Current PlaceID %@", place.placeID);
        }
        
    }];
}


-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        [self.locationManager startUpdatingLocation];
        
        googleMap.myLocationEnabled = YES;
        googleMap.settings.myLocationButton = YES;
        //[self getCurrentPlace];
       // [self.locationManager startUpdatingLocation];
    }
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations firstObject];
    googleMap.camera =  [[GMSCameraPosition alloc] initWithTarget:location.coordinate zoom:15 bearing:0 viewingAngle:0];
    GMSMarker *marker = [[GMSMarker alloc]init];
    marker.position = location.coordinate;
    //marker.title = @"Sydney";
    //marker.snippet = @"Australia";
    [self queryGooglePlaces];
    CLGeocoder *reverseGeoCoder = [[CLGeocoder alloc]init];
   /* [reverseGeoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            return ;
        }
        CLPlacemark *myPlaceMark = [placemarks objectAtIndex:0];
        marker.title = [NSString stringWithFormat:@"%@, %@", myPlaceMark.thoroughfare, myPlaceMark.locality];
        marker.snippet = myPlaceMark.country;
        
        marker.map = googleMap;
    }];*/
    
    
    
    [manager stopUpdatingLocation];
}

-(void)queryGooglePlaces
{
   /* NSString *url = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/geocode/json?address=Avenida+Americas,+Guadalajara,+JAL,+Mexico&key=%@", GOOGLE_API_KEY];
    NSURL *googleRequestURL = [NSURL URLWithString:url];
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: googleRequestURL];
        [self performSelectorOnMainThread:@selector(fetchedData:) withObject:data waitUntilDone:YES];
    });*/
    CLGeocoder *geoCoder = [[CLGeocoder alloc]init];
    [geoCoder geocodeAddressString:@"Avenida V, Zapopan, Jalisco" completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            return ;
        }else{
            CLPlacemark *placemark = [placemarks lastObject];
            float spanX = 0.00725;
            float spanY = 0.00725;
            MKCoordinateRegion region;
            region.center.latitude = placemark.location.coordinate.latitude;
            region.center.longitude = placemark.location.coordinate.longitude;
            
            region.span = MKCoordinateSpanMake(spanX, spanY);
            CLPlacemark *myPlaceMark = [placemarks objectAtIndex:0];
            GMSMarker *marker = [[GMSMarker alloc]init];
            marker.position = placemark.location.coordinate;
            marker.title = [NSString stringWithFormat:@"%@, %@", myPlaceMark.thoroughfare, myPlaceMark.locality];
            marker.snippet = myPlaceMark.country;
            
            marker.map = googleMap;
            googleMap.camera =  [[GMSCameraPosition alloc] initWithTarget:placemark.location.coordinate zoom:15 bearing:0 viewingAngle:0];
            
            //[self.mapView setRegion:region animated:YES];
        }
    }];
    
}

-(void)fetchedData:(NSData *)results
{
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:results
                          
                          options:kNilOptions
                          error:&error];
    
    //The results from Google will be an array obtained from the NSDictionary object with the key "results".
    NSArray* places = [json objectForKey:@"results"];
    
    //Write out the data to the console.
    NSLog(@"Google Data: %@", places);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
