//
//  FPImageVideoCell.h
//  test
//
//  Created by fanpeng on 2019/12/5.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FPImageResuableView.h"
#import "FPImageCCell.h"
#import <Photos/Photos.h>

typedef NS_ENUM(NSInteger, FPImageType) {
    FPImageTypeShowImage = 0,
    FPImageTypeSelectImage,
    FPImageTypeShowVideo,
    FPImageTypeSelectVideo,
    FPImageTypeSelectImageOrVideo,//图片Or视频
    FPImageTypeSelectImageAndVideo,//图片&&视频
    FPImageTypeShowImageAndVideo
};
NS_ASSUME_NONNULL_BEGIN
@interface FPImageVideoCell : UITableViewCell
@property (nonatomic,assign)UIEdgeInsets sectionInset;
@property (nonatomic,assign)CGFloat minimumLineSpacing;
@property (nonatomic,assign)CGFloat minimumInteritemSpacing;
@property (nonatomic,assign)CGFloat column;
//[MIN(maxVideoCount,maxImageCount),maxVideoCount + maxImageCount] default maxVideoCount + maxImageCount
@property (nonatomic,assign)NSInteger maxAllCount;
@property (nonatomic,assign)NSInteger maxVideoCount; //最大视频个数 default 1
@property (nonatomic,assign)NSInteger maxImageCount;//最大图片个数 default 9

@property (nonatomic,assign)NSTimeInterval maxVideoDurtaion; //default 60s
@property (nonatomic,strong)UIImage *placeholderImage;
@property (nonatomic,strong)UIImage *addIconImage;
@property (nonatomic,strong)UIImage *deleteImage;
@property (nonatomic,strong)UIImage *playImage;
@property (nonatomic,assign)CGFloat cornerRadius;
@property (nonatomic,assign)CGFloat headerHeight;
@property (nonatomic,copy)NSString *headerTitle;
@property (nonatomic,assign)CGFloat footerHeight;
@property (nonatomic,copy)NSString *footerTitle;
//只有单选视频或者图片并且maxCount == 1的时候有效果 不建议设置
@property (nonatomic,assign)CGSize itemSize;
//选择视频时当maxVideoCount=1的时候，是否自动计算视频的尺寸
@property (nonatomic,assign)BOOL automaticConfiureVideoSize;
@property (nonatomic,assign)BOOL allowsEditingImage;//拍摄图片是否允许编辑
@property (nonatomic,assign)BOOL allowsEditingVideo;//拍摄视频是否允许编辑
@property (nonatomic,assign)CGFloat cellHeight;//实际高度 布局完之后才有值
@property (nonatomic,strong)NSMutableArray *source;//UIImage Or Url  Or FPVideoItem

@property (nonatomic,strong,readonly)NSMutableArray <FPVideoItem *> *videoSource;
@property (nonatomic,strong,readonly)NSMutableArray  *imageSource;

//configure cell header  Footer
@property (nonatomic,copy)void (^configureReusableView)(FPImageResuableView *resuableView , NSString *kind);
@property (nonatomic,copy)void (^configureCell)(FPImageCCell *cell , NSIndexPath *indexPath,NSArray *source);

//Observer Block
@property (nonatomic,copy)void (^heightChangeBlock)(CGFloat height,NSArray *source);
@property (nonatomic,copy)void (^deleteSourceBlock)(NSArray* deleteSource,NSArray *source);

//custom tap event
@property (nonatomic,copy)void (^tapAddSourceBlock)(FPImageType type,NSInteger leaveImageMaxCount,NSInteger leaveVideoMaxCount,void(^callBackBlock)(NSArray <UIImage *>  * _Nullable images,NSArray <PHAsset *> * _Nullable assets));
@property (nonatomic,copy)void (^tapImageBlock)(id obj,UICollectionViewCell *cell);
@property (nonatomic,copy)void (^tapVideoBlock)(FPVideoItem * item,UICollectionViewCell *cell);
@property (nonatomic,assign)FPImageType type;
//Nib注册Cell
+ (NSBundle*)fpSourceBundle;
+ (instancetype)loadVideoCellFromXib;
+ (void)registerNibFromTableView:(UITableView*)tableView;
+ (FPImageVideoCell*)dequeueReusableCellFromTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
@end
NS_ASSUME_NONNULL_END
