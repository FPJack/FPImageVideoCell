//
//  FPChooesImageHelper.h
//  ZhiChongRadar
//
//  Created by fanpeng on 2019/10/25.
//  Copyright © 2019 zhichongjia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
typedef NS_ENUM(NSInteger, AlertType) {
    AlertTypeTakePAndChooesPV, //拍照 相册可选择图片和视频
    AlertTypeTakePAndChooesP, //拍照 相册可选择图片
    AlertTypeTakeVAndChooesPV,//拍视频 相册可选择图片和视频
    AlertTypeTakeVAndChooesP, //拍视频 相册可选择图片
    AlertTypeTakeVAndChooesV, //拍视频 相册可选择视频
    AlertTypeTakePVAndChooesPV, //可拍图片和视频 相册可选择图片视频
    AlertTypeTakePVAndChooesP //可拍图片和视频 相册可选择图片
};
NS_ASSUME_NONNULL_BEGIN
@interface FPChooesConfiure : NSObject
@property (nonatomic,assign)AlertType type;
@property (nonatomic,copy)NSString *title;
@property (nonatomic,strong)NSArray<NSString*> *indexTitles;
@property (nonatomic,assign)NSInteger maxImageCount;
@property (nonatomic,assign)NSTimeInterval maxVideoDurtaion;
@property (nonatomic,assign)BOOL allowEditImage;
@property (nonatomic,assign)BOOL allowEditVideo;
@property (nonatomic,copy)void(^didFinishTakePhotosHandle)(NSArray<UIImage*>* images,NSError* __nullable error);
@property (nonatomic, copy) void (^didFinishTakeVideoHandle)(UIImage *coverImage,PHAsset *asset,NSError * __nullable error);
@end
NS_ASSUME_NONNULL_END
NS_ASSUME_NONNULL_BEGIN
@interface FPChooesImageHelper : NSObject
+ (instancetype)chooesImageOrVideoConfiure:(FPChooesConfiure*)configure fromVC:(UIViewController* __nullable)fromVC;
@end
NS_ASSUME_NONNULL_END
