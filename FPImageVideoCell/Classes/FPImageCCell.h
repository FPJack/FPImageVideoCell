//
//  FPImageCCell.h
//  Huobanys
//
//  Created by nan on 2019/4/4.
//  Copyright © 2019 Noah. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PHAsset;
NS_ASSUME_NONNULL_BEGIN
@interface FPVideoItem : NSObject
//require
@property (nonatomic,strong)NSURL *videoUrl;
//Optional
@property (nonatomic,copy)NSString *coverUrl;
@property (nonatomic,strong)UIImage *coverImage;
@property (nonatomic,assign)CGSize itemSize;
@property (nonatomic, assign) NSUInteger pixelWidth;
@property (nonatomic, assign) NSUInteger pixelHeight;
@property (nonatomic,strong)PHAsset *asset;
@end
NS_ASSUME_NONNULL_END
NS_ASSUME_NONNULL_BEGIN

@interface FPImageCCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (nonatomic,copy)void (^deleteBlock)(id object);
@property (nonatomic,copy)void (^playBlock)(UIButton* playBtn);

@end

NS_ASSUME_NONNULL_END



NS_ASSUME_NONNULL_BEGIN

@interface FPImageResuableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgHeightCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgWidthCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imgLeftCon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labLeftCon;
@end

NS_ASSUME_NONNULL_END
