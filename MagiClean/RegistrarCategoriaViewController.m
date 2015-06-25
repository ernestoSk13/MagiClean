//
//  RegistrarCategoriaViewController.m
//  MagiClean
//
//  Created by Ernesto Sánchez Kuri on 04/06/15.
//  Copyright (c) 2015 Sankurlabs. All rights reserved.
//

#import "RegistrarCategoriaViewController.h"
#import "UIImage+customProperties.h"

@interface RegistrarCategoriaViewController ()
@property (nonatomic) UIImage *originalImage;
@property (nonatomic) NSString *imageURL;
@end

@implementation RegistrarCategoriaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btnCancelar.target = self;
    self.btnCancelar.action = @selector(cancelAndDismiss);
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showActionSheet)];
    self.imgView.userInteractionEnabled = YES;
    [self.imgView addGestureRecognizer:tap];
     self.btnGuardar.target = self;
    if ([self.registerType isEqualToString:@"producto"]) {
        [self.lblRegisterType setText:@"Nombre del producto"];
        
        
    }else{
        [self.lblRegisterType setText:@"Nombre de la categoría"];
    }
    self.btnGuardar.action = @selector(saveNewCategory);
    [self.txtCategoria setDelegate:self];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    cdh =
    [(AppDelegate *)[[UIApplication sharedApplication] delegate] cdh];
    
}

-(void)cancelAndDismiss
{
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

-(NSInteger)randomIDnumber
{
    NSUInteger r = arc4random_uniform(999998) + 1;
    return r;
}

-(void)saveNewCategory
{
    if (self.txtCategoria.text.length > 0) {
        NSString *stringWithoutSpaces = [self.txtCategoria.text
                                         stringByReplacingOccurrencesOfString:@" " withString:@"_"];
        NSString *imageName =[NSString stringWithFormat:@"%@.png",stringWithoutSpaces];
        if (self.originalImage) {
            [UIImage saveImageToDocumentsDirectory:self.originalImage withName:imageName];
        }else{
            imageName = @"";
        }
        if ([self.registerType isEqualToString:@"producto"]) {
            [sharedDataHelper setNewProduct:@{
                                              @"idCategoria" : self.idCategoria,
                                              @"nombreProducto" : self.txtCategoria.text,
                                              @"imagenProducto" : imageName,//self.imageURL,
                                              @"productoID" : [NSString stringWithFormat:@"%ld", (long)[self randomIDnumber]]
                                             }withSuccess:^(id success) {
                                                 [self cancelAndDismiss];
                                             } orError:^(NSString *errorString, NSDictionary *errorDict) {
                                                 
                                             }];
        }else{
            [sharedDataHelper setNewCategory:@{
                                               @"idCategoria" : [NSString stringWithFormat:@"%ld", (long)[self randomIDnumber]],
                                               @"nombreCategoria" : self.txtCategoria.text,
                                               @"imagenCategoria" : imageName//self.imageURL
                                               }withSuccess:^(id success) {
                                                   [self cancelAndDismiss];
                                               } orError:^(NSString *errorString, NSDictionary *errorDict) {
                                                   
                                               }];

        }
    }
}


-(void)showActionSheet
{
    UIAlertController *actionSheet = [UIAlertController alertControllerWithTitle:@"¿Qué deseas hacer?" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *cameraOption = [UIAlertAction actionWithTitle:@"Tomar foto" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openFromLibrary:NO];
    }];
    UIAlertAction *galleryOption = [UIAlertAction actionWithTitle:@"Tomar desde galería" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self openFromLibrary:YES];
    }];
    UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    [actionSheet addAction:cameraOption];
    [actionSheet addAction:galleryOption];
    [actionSheet addAction:cancelOption];
    
    
    UIPopoverPresentationController *popover = actionSheet.popoverPresentationController;
    if (popover)
    {
        popover.sourceView = self.imgView;
        popover.sourceRect = self.imgView.bounds;
        popover.permittedArrowDirections = UIPopoverArrowDirectionAny;
    }
    
    [self presentViewController:actionSheet animated:YES completion:nil];
    
    
}

-(void)openFromLibrary:(BOOL)library
{
    if (library) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        
        [self presentViewController:picker animated:YES completion:nil];
    }else{
        if (![UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
           UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:@"Este dispositivo no cuenta con una cámara disponible" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelOption = [UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
                
            }];
            [alert addAction:cancelOption];
            [self presentViewController:alert animated:NO completion:nil];
            return;
        }
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:nil];
    }
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    self.originalImage = chosenImage;
    chosenImage = [UIImage imageWithImage:chosenImage scaledToSize:CGSizeMake(self.view.frame.size.width, 200)];
    self.imgView.image = chosenImage;
    [picker dismissViewControllerAnimated:YES completion:^{
    }];


}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
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
