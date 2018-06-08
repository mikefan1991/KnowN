//
//  UserImageViewController.m
//  KnowN
//
//  Created by zhe wu on 8/11/17.
//  Copyright © 2017 BeyondRemarkable. All rights reserved.
//

#import "BRUserImageViewController.h"
#import "BRClientManager.h"
#import <MBProgressHUD.h>
#import "UIView+NavigationBar.h"
#import "UIImagePickerController+Open.h"

@interface BRUserImageViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    MBProgressHUD *hud;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation BRUserImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.imageView setImage:self.image];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
    if (@available(iOS 11.0, *)) {
        [btn addNavigationBarConstraintsWithWidth:35 height:35];
    }
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info"] forState:UIControlStateNormal];
    [btn setBackgroundImage:[UIImage imageNamed:@"more_info_highlighted"] forState:UIControlStateHighlighted];
    [btn addTarget:self action:@selector(clickMoreInfo) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
}

- (void)setImage:(UIImage *)image {
    _image = image;
    [self.imageView setImage:image];
}

- (void)clickMoreInfo {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Take Photo", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypeCamera];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Choose from Album", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self openImagePickerControllerWithType:UIImagePickerControllerSourceTypePhotoLibrary];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)openImagePickerControllerWithType:(UIImagePickerControllerSourceType)type {
    UIImagePickerController *ipc = [[UIImagePickerController alloc] init];
    ipc.delegate = self;
    ipc.allowsEditing = YES;
    switch (type) {
        case UIImagePickerControllerSourceTypeCamera:
        {
            [ipc openCameraWithSuccess:^{
                [self presentViewController:ipc animated:YES completion:nil];
            } failure:^{
                [self showAuthorizationAlertWithType:type];
            }];
        }
            break;
            
        case UIImagePickerControllerSourceTypePhotoLibrary:
        {
            [ipc openAlbumWithSuccess:^{
                [self presentViewController:ipc animated:YES completion:nil];
            } failure:^{
                
            }];
        }
            break;
        default:
            break;
    }
}

/**
 提示开启相机相册权限设置
 */
- (void)showAuthorizationAlertWithType:(UIImagePickerControllerSourceType)type
{
    NSString *typeString;
    if (type == UIImagePickerControllerSourceTypeCamera) {
        typeString = @"camera";
    }
    else if (type == UIImagePickerControllerSourceTypePhotoLibrary) {
        typeString = @"album";
    }
    NSString *title = [NSString stringWithFormat:@"Unable to access %@", typeString];
    UIAlertController *actionSheet =[UIAlertController alertControllerWithTitle:NSLocalizedString(title, nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *open = [UIAlertAction actionWithTitle:NSLocalizedString(@"Open", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if ([[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)  style:UIAlertActionStyleDestructive handler:nil];
    
    [actionSheet addAction:open];
    [actionSheet addAction:cancel];
    
    [self presentViewController:actionSheet animated:YES completion:nil];
}

#pragma mark - UIImagePickerController delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    hud = [MBProgressHUD showHUDAddedTo:picker.view animated:YES];
    // 获取选择的图片
    UIImage *image = info[UIImagePickerControllerEditedImage];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
    [[BRClientManager sharedManager] updateSelfInfoWithKeys:@[@"avatar"] values:@[imageData] success:^(NSString *message) {
        [self->hud hideAnimated:YES];
        [self.imageView setImage:image];
        if (self.delegate && [self.delegate respondsToSelector:@selector(userDidUpdateAvatarTo:)]) {
            [self.delegate userDidUpdateAvatarTo:image];
        }
        [self dismissViewControllerAnimated:YES completion:nil];
    } failure:^(EMError *error) {
        self->hud.mode = MBProgressHUDModeText;
        self->hud.label.text = error.errorDescription;
        [self->hud hideAnimated:YES afterDelay:1.5];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }];
}

@end