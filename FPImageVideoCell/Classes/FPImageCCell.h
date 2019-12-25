//
//  FPImageCCell.h
//  Huobanys
//
//  Created by nan on 2019/4/4.
//  Copyright © 2019 Noah. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface FPVideoItem : NSObject
@property (nonatomic,copy)NSString *coverUrl;
@property (nonatomic,strong)NSURL *videoUrl;
@property (nonatomic,strong)UIImage *coverImage;
@property (nonatomic,assign)CGSize itemSize;
@property (nonatomic, assign) NSUInteger pixelWidth;
@property (nonatomic, assign) NSUInteger pixelHeight;
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
