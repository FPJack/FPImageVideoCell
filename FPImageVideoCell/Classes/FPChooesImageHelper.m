//
//  FPChooesImageHelper.m
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/25.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import "FPChooesImageHelper.h"
#import <UIKit/UIKit.h>
#import <FPPermission/FPOpenCamera.h>
#import <FPPermission/FPPermission.h>
#import <LCActionSheet/LCActionSheet.h>
#import <TZImagePickerController/TZImagePickerController.h>
#import <FPPermission/FPVideoEditVC.h>
@implementation FPChooesConfiure
@end
@interface FPChooesImageHelper()<UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (nonatomic, strong) UIImagePickerController *imagePickerVc;
@property (nonatomic,strong)FPChooesConfiure *configure;
@property (nonatomic,strong)UIViewController *fromVC;
@end
@implementation FPChooesImageHelper
+ (instancetype)chooesImageOrVideoConfiure:(FPChooesConfiure*)configure fromVC:(UIViewController*)fromVC{
    static dispatch_once_t onceToken;
    static FPChooesImageHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [FPChooesImageHelper new];
    });
    instance.configure = configure;
    instance.fromVC = fromVC;
    if (!configure.title) configure.title = @"资源选择";
    if (configure.type == AlertTypeTakePAndChooesP) {
        configure.title = @"图片";
    }else if (configure.type == AlertTypeTakeVAndChooesV){
        configure.title = @"视频";
    }else if (configure.type == AlertTypeTakePVAndChooesPV){
        configure.title = @"图片/视频";
    }
    if (configure.indexTitles.count == 0) configure.indexTitles = @[@"拍摄",@"相册选择"];
    if (!fromVC) fromVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    [instance alertShow:configure fromVC:fromVC];
    return instance;
}
- (UIImagePickerController *)imagePickerVc {
    if (!_imagePickerVc) {
        _imagePickerVc = [[UIImagePickerController alloc] init];
        _imagePickerVc.delegate = self;
    }
    return _imagePickerVc;
}
- (void)alertShow:(FPChooesConfiure*)configure fromVC:(UIViewController* __nullable)fromVC{
    LCActionSheet *sheet = [[LCActionSheet alloc]initWithTitle:configure.title cancelButtonTitle:@"取消" clicked:^(LCActionSheet * _Nonnull actionSheet, NSInteger buttonIndex) {
        if (buttonIndex == 1) {
            //授权
            [FPPermission requestAuthorizationStatus:FPPermissionCamer showAlertWhenDenied:YES resultBlock:^(FPPermissionStatus status) {
                if (status == FPPermissionStatusAuthorized) {
                    FPOpenCamera *camera = [FPOpenCamera share];
                    camera.didFinishTakePhotosHandle = ^(UIImage * _Nonnull image, NSDictionary * _Nonnull info, NSError * _Nonnull error) {
                        if (configure.didFinishTakePhotosHandle) {
                            configure.didFinishTakePhotosHandle(@[image], error);
                        }
                    };
                    camera.didFinishTakeVideoHandle = ^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull asset, NSError * _Nonnull error) {
                        if (configure.didFinishTakeVideoHandle) {
                            configure.didFinishTakeVideoHandle(coverImage, asset, error);
                        }
                    };
                    camera.type = CameraTypeTakePhotoAndVideo;
                    if (configure.type == AlertTypeTakePAndChooesPV || configure.type == AlertTypeTakePAndChooesP) {
                        camera.type = CameraTypeTakePhoto;
                        camera.allowEditingImage = configure.allowEditImage;
                    }else if (configure.type == AlertTypeTakeVAndChooesPV || configure.type == AlertTypeTakeVAndChooesP || configure.type == AlertTypeTakeVAndChooesV){
                        camera.type = CameraTypeTakeVideo;
                        if (configure.maxVideoDurtaion > 0) {
                            camera.videoMaxDuration = configure.maxVideoDurtaion;
                        }
                        camera.allowEditingVideo = configure.allowEditVideo;
                    }else{
                        camera.type = CameraTypeTakePhotoAndVideo;
                        camera.allowEditingVideo = configure.allowEditImage;
                        camera.allowEditingImage = configure.allowEditVideo;
                        if (configure.maxVideoDurtaion > 0) {
                            camera.videoMaxDuration = configure.maxVideoDurtaion;
                        }
                    }
                    [camera openCameraFromVC:fromVC];
                }
            }];
        }else if (buttonIndex == 2){
            //授权
            [FPPermission requestAuthorizationStatus:FPPermissionPhoto showAlertWhenDenied:YES resultBlock:^(FPPermissionStatus status) {
                if (status == FPPermissionStatusAuthorized) {
                    //授权相册
                    TZImagePickerController *pickerVC = [[TZImagePickerController alloc]initWithMaxImagesCount:configure.maxImageCount delegate:nil];
                    if (configure.type == AlertTypeTakePAndChooesP || configure.type == AlertTypeTakeVAndChooesP || configure.type == AlertTypeTakePVAndChooesP) {
                        pickerVC.allowPickingVideo = NO;
                    }else if (configure.type == AlertTypeTakeVAndChooesV){
                        pickerVC.allowPickingImage = NO;
                    }else{
                        pickerVC.allowPickingVideo = YES;
                        pickerVC.allowPickingImage = YES;
                    }
                    pickerVC.didFinishPickingPhotosWithInfosHandle = ^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isSelectOriginalPhoto, NSArray<NSDictionary *> *infos) {
                        if (configure.didFinishTakePhotosHandle) {
                            configure.didFinishTakePhotosHandle(photos, nil);
                        }
                    };
                    pickerVC.didFinishPickingVideoHandle = ^(UIImage *coverImage, PHAsset *pAsset) {
                        if (pAsset.duration > configure.maxVideoDurtaion) {//超出时长编辑视频
                            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                            options.version = PHImageRequestOptionsVersionCurrent;
                            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                            [[PHImageManager defaultManager] requestAVAssetForVideo:pAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                                AVURLAsset *urlAsset = (AVURLAsset *)asset;
                                if ([FPVideoEditVC canEditVideoAtPath:urlAsset.URL.path]) {
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        FPVideoEditVC *editVC = [[FPVideoEditVC alloc]init];
                                        editVC.videoMaximumDuration = configure.maxVideoDurtaion;
                                        editVC.videoPath = urlAsset.URL.path;
                                        editVC.callBlock = ^(PHAsset * _Nonnull pAsset,UIImage * __nullable coverImage, NSError * _Nonnull error) {
                                        if (!configure.didFinishTakeVideoHandle) return ;
                                        configure.didFinishTakeVideoHandle(coverImage, pAsset, error);
                                        };
                                        [fromVC presentViewController:editVC animated:YES completion:nil];
                                    });
                                }
                            }];
                        }else{
                            if (configure.didFinishTakeVideoHandle) {
                                configure.didFinishTakeVideoHandle(coverImage, pAsset, nil);
                            }
                        }
                    };
                    pickerVC.modalPresentationStyle = UIModalPresentationFullScreen;
                    [fromVC presentViewController:pickerVC animated:YES completion:nil];
                }
            }];
        }
    } otherButtonTitleArray:configure.indexTitles];
    [sheet show];
}
@end
