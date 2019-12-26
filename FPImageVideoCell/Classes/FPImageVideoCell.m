//
//  FPImageVideoCell.m
//  test
//
//  Created by fanpeng on 2019/12/5.
//  Copyright © 2019 Mac. All rights reserved.
//
#import "FPImageVideoCell.h"
#import <SDWebImage/SDWebImage.h>
#import <YBImageBrowser/YBImageBrowser.h>
#import <AVKit/AVKit.h>
static void *contentSizeContext = &contentSizeContext;
@interface FPImageVideoCell()<UICollectionViewDelegateFlowLayout,UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightCon;
@property (nonatomic,assign)FPImageType interType;
@property (nonatomic,strong)NSBundle *bundle;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@end
@implementation FPImageVideoCell
- (NSBundle*)bundle{return [FPImageVideoCell fpSourceBundle];}
- (NSTimeInterval)maxVideoDurtaion{return _maxVideoDurtaion <= 0 ? 60 : _maxVideoDurtaion;}
- (void)setType:(FPImageType)type{
    _type = type;
    self.interType = type;
}
- (NSInteger)maxAllCount{
    if (_maxAllCount == 0) return self.maxImageCount + self.maxVideoCount;
    NSInteger min =  MIN(self.maxImageCount, self.maxVideoCount);
    NSInteger max =  self.maxVideoCount + self.maxImageCount;
    if (_maxAllCount >= max) {
        return max;
    }else if (_maxAllCount <= min){
        return min;
    }else{
        return _maxAllCount;
    }
}
- (NSMutableArray *)imageSource{
    NSMutableArray *arr = [NSMutableArray array];
    [self.source enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[FPVideoItem class]]) [arr addObject:obj];
    }];
    return arr;
}
- (NSMutableArray<FPVideoItem *> *)videoSource{
    NSMutableArray *arr = [NSMutableArray array];
    [self.source enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[FPVideoItem class]]) [arr addObject:obj];
    }];
    return arr;
}
- (void)refreshHeight{
    UIView *superView = self.superview;
    if ([superView isKindOfClass:[UITableView class]]) {
        UITableView *tableView = (UITableView*)superView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [tableView beginUpdates];
            self.heightCon.constant = self.cellHeight;
            [tableView endUpdates];
        });
    }
}
- (CGFloat)column{return _column <= 0 ? 3 : _column;}
- (UIImage *)placeholderImage{
    if (!_placeholderImage) {
        _placeholderImage = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"" ofType:@"png"]];
    }
    return _placeholderImage;
}
- (UIImage *)addIconImage{
    if (!_addIconImage) {
        _addIconImage = [UIImage imageWithContentsOfFile:[self.bundle pathForResource:@"icon_photo@2x" ofType:@"png"]];
    }
    return _addIconImage;
}
- (UIImage *)deleteImage{
    if (!_deleteImage) {
        _deleteImage = [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"icon_delete@2x" ofType:@"png"]];
    }
    return _deleteImage;
}
- (UIImage *)playImage{
    if (!_playImage) {
        _playImage = [UIImage imageWithContentsOfFile:[[self bundle] pathForResource:@"ic_play big@2x" ofType:@"png"]];
    }
    return _playImage;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FPImageResuableView" bundle:self.bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"FPImageResuableView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FPImageResuableView" bundle:self.bundle] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:@"FPImageResuableView"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"FPImageCCell" bundle:self.bundle] forCellWithReuseIdentifier:@"FPImageCCell"];
    [self.collectionView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:contentSizeContext];
    self.source = [NSMutableArray array];
    self.minimumInteritemSpacing = 10;
    self.minimumLineSpacing = 10;
    self.maxVideoCount = 1;
    self.maxImageCount = 9;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == contentSizeContext) {
        CGFloat newHeight = [change[@"new"] CGSizeValue].height;
        CGFloat oldHeight = [change[@"old"] CGSizeValue].height;
        if (newHeight != oldHeight) {
            self.cellHeight = newHeight;
            if (self.heightChangeBlock) self.heightChangeBlock(newHeight, self.source);
            [self refreshHeight];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}
- (void)dealloc
{
    [self.collectionView removeObserver:self forKeyPath:@"contentSize"];
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    //过滤与类型不一致的数据
    [_source enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (self.interType == FPImageTypeSelectImage || self.interType == FPImageTypeShowImage) {
            if ([obj isKindOfClass:[FPVideoItem class]]) [_source removeObjectAtIndex:idx];
        }else if (self.interType == FPImageTypeSelectVideo || self.interType == FPImageTypeShowVideo){
            if (![obj isKindOfClass:[FPVideoItem class]]) [_source removeObjectAtIndex:idx];
        }
    }];
    
    if (self.interType == FPImageTypeShowImage) {
        return self.source.count > self.maxImageCount ? self.maxImageCount : self.source.count;
    }else if (self.interType == FPImageTypeSelectImage) {
        return self.source.count >= self.maxImageCount ? self.maxImageCount : self.source.count + 1;
    }else if (self.interType == FPImageTypeShowVideo) {
        return self.source.count >= self.maxVideoCount ? self.maxVideoCount : self.source.count;
    }else if (self.interType == FPImageTypeSelectVideo) {
        return self.source.count >= self.maxVideoCount ? self.maxVideoCount : self.source.count + 1;
    }else if (self.interType == FPImageTypeShowImageAndVideo){
        NSInteger maxCount = self.maxAllCount > 0 ? self.maxAllCount : (self.maxImageCount + self.maxVideoCount);
        return self.source.count >= maxCount ? maxCount : self.source.count;
    }else if (self.interType == FPImageTypeSelectImageOrVideo){
        NSInteger maxCount = self.maxAllCount > 0 ? self.maxAllCount : (self.maxImageCount + self.maxVideoCount);
        return self.source.count >= maxCount ? maxCount : self.source.count + 1;
    }else if (self.interType == FPImageTypeSelectImageAndVideo){
        NSInteger maxCount = self.maxAllCount > 0 ? self.maxAllCount : (self.maxImageCount + self.maxVideoCount);
        return self.source.count >= maxCount ? maxCount : self.source.count + 1;
    }
    return 0;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    FPImageResuableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"FPImageResuableView" forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        view.titleLab.text = self.headerTitle;
    }else{
        view.titleLab.text = self.footerTitle;
    }
    if (self.configureReusableView) self.configureReusableView(view, kind);
    return view;
}
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewCell *cell;
    __weak typeof(self) weakSelf = self;
    if (self.interType == FPImageTypeShowImage) {
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.playBtn.hidden = YES;
        imgCell.deleteBtn.hidden = YES;
        id obj = self.source[indexPath.item];
        if ([obj isKindOfClass:[UIImage class]]) {
            imgCell.imgView.image = (UIImage*)obj;
        }else if ([obj isKindOfClass:[NSString class]]){
            //网络加载
            [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:self.source[indexPath.item]] placeholderImage:self.placeholderImage];
        }
        cell = imgCell;
    }else if (self.interType == FPImageTypeSelectImage){
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.playBtn.hidden = YES;
        if (indexPath.item >= self.source.count) {//添加cell
            imgCell.deleteBtn.hidden = YES;
            imgCell.imgView.image = self.addIconImage;
        }else{//正常cell
            imgCell.deleteBtn.hidden = NO;
            [imgCell.deleteBtn setImage:self.deleteImage forState:UIControlStateNormal];
            imgCell.deleteBlock = ^(id  _Nonnull object) {
                id deleteObj = weakSelf.source[indexPath.item];
                [weakSelf.source removeObjectAtIndex:indexPath.item];
                NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
                weakSelf.source = newSource;
                if (weakSelf.deleteSourceBlock) weakSelf.deleteSourceBlock(deleteObj, weakSelf.source);
                if (weakSelf.type == FPImageTypeSelectImageOrVideo && weakSelf.source.count == 0) {
                    weakSelf.type = weakSelf.type;
                }
                [weakSelf.collectionView reloadData];
            };
            id obj = self.source[indexPath.item];
            if ([obj isKindOfClass:[UIImage class]]) {
                imgCell.imgView.image = (UIImage*)obj;
            }else if ([obj isKindOfClass:[NSString class]]){
                //网络加载
                [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:self.source[indexPath.item]] placeholderImage:self.placeholderImage];
            }
        }
        cell = imgCell;
    }else if (self.interType == FPImageTypeSelectVideo){
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        if (indexPath.item >= self.source.count) {//添加cell
            imgCell.imgView.image = self.addIconImage;
            imgCell.playBtn.hidden = YES;
            imgCell.deleteBtn.hidden = YES;
        }else{//正常cell
            imgCell.playBtn.hidden = NO;
            imgCell.deleteBtn.hidden = NO;
            [imgCell.playBtn setImage:self.playImage forState:UIControlStateNormal];
            imgCell.deleteBlock = ^(id  _Nonnull object) {
                id deleteObj = weakSelf.source[indexPath.item];
                [weakSelf.source removeObjectAtIndex:indexPath.item];
                NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
                weakSelf.source = newSource;
                if (weakSelf.deleteSourceBlock) weakSelf.deleteSourceBlock(deleteObj, weakSelf.source);
                if (weakSelf.type == FPImageTypeSelectImageOrVideo && weakSelf.source.count == 0) {
                    weakSelf.type = weakSelf.type;
                }
                [weakSelf.collectionView reloadData];
            };
            FPVideoItem *videoItem = self.source[indexPath.item];
            if (videoItem.coverImage) {
                imgCell.imgView.image = videoItem.coverImage;
            }else{
                [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.coverUrl] placeholderImage:self.placeholderImage];
            }
        }
        cell = imgCell;
    }else if (self.interType == FPImageTypeShowVideo){
        FPVideoItem *videoItem = self.source[indexPath.item];
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.playBtn.hidden = NO;
        imgCell.deleteBtn.hidden = YES;
        [imgCell.playBtn setImage:self.playImage forState:UIControlStateNormal];
        if (videoItem.coverImage) {
            imgCell.imgView.image = videoItem.coverImage;
        }else{
            [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.coverUrl] placeholderImage:self.placeholderImage];
        }
        cell = imgCell;
    }else if (self.interType == FPImageTypeSelectImageOrVideo){
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.deleteBtn.hidden = YES;
        if (indexPath.item >= self.source.count) {//添加cell
            imgCell.imgView.image = self.addIconImage;
            imgCell.playBtn.hidden = YES;
        }else{//正常cell
            imgCell.playBtn.hidden = NO;
            [imgCell.playBtn setImage:self.playImage forState:UIControlStateNormal];
            FPVideoItem *videoItem = self.source[indexPath.item];
            if (videoItem.coverImage) {
                imgCell.imgView.image = videoItem.coverImage;
            }else{
                [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.coverUrl] placeholderImage:self.placeholderImage];
            }
        }
        cell = imgCell;
    }else if (self.interType == FPImageTypeSelectImageAndVideo){
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.deleteBtn.hidden = NO;
        if (indexPath.item >= self.source.count) {//添加cell
            imgCell.imgView.image = self.addIconImage;
            imgCell.playBtn.hidden = YES;
            imgCell.deleteBtn.hidden = YES;
            
        }else{//正常cell
            id source = self.source[indexPath.item];
            if ([source isKindOfClass:[FPVideoItem class]]) {//视频
                imgCell.playBtn.hidden = NO;
                [imgCell.playBtn setImage:self.playImage forState:UIControlStateNormal];
                FPVideoItem *videoItem = self.source[indexPath.item];
                imgCell.deleteBlock = ^(id  _Nonnull object) {
                    id deleteObj = weakSelf.source[indexPath.item];
                    [weakSelf.source removeObjectAtIndex:indexPath.item];
                    NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
                    weakSelf.source = newSource;
                    if (weakSelf.deleteSourceBlock) weakSelf.deleteSourceBlock(deleteObj, weakSelf.source);
                    [weakSelf.collectionView reloadData];
                };
                if (videoItem.coverImage) {
                    imgCell.imgView.image = videoItem.coverImage;
                }else{
                    [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.coverUrl] placeholderImage:self.placeholderImage];
                }
            }else{//图片
                [imgCell.deleteBtn setImage:self.deleteImage forState:UIControlStateNormal];
                imgCell.playBtn.hidden = YES;
                imgCell.deleteBlock = ^(id  _Nonnull object) {
                    id deleteObj = weakSelf.source[indexPath.item];
                    [weakSelf.source removeObjectAtIndex:indexPath.item];
                    NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
                    weakSelf.source = newSource;
                    if (weakSelf.deleteSourceBlock) weakSelf.deleteSourceBlock(deleteObj, weakSelf.source);
                    [weakSelf.collectionView reloadData];
                };
                if ([source isKindOfClass:[UIImage class]]) {
                    imgCell.imgView.image = (UIImage*)source;
                }else if ([source isKindOfClass:[NSString class]]){
                    //网络加载
                    [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:source] placeholderImage:self.placeholderImage];
                }
            }
        }
        cell = imgCell;
        
    }else if (self.interType == FPImageTypeShowImageAndVideo){
        FPImageCCell *imgCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"FPImageCCell" forIndexPath:indexPath];
        imgCell.deleteBtn.hidden = YES;
        id source = self.source[indexPath.item];
        if ([source isKindOfClass:[FPVideoItem class]]) {//视频
            imgCell.playBtn.hidden = NO;
            [imgCell.playBtn setImage:self.playImage forState:UIControlStateNormal];
            FPVideoItem *videoItem = self.source[indexPath.item];
            if (videoItem.coverImage) {
                imgCell.imgView.image = videoItem.coverImage;
            }else{
                [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:videoItem.coverUrl] placeholderImage:self.placeholderImage];
            }
        }else{//图片
            [imgCell.deleteBtn setImage:self.deleteImage forState:UIControlStateNormal];
            imgCell.playBtn.hidden = YES;
            if ([source isKindOfClass:[UIImage class]]) {
                imgCell.imgView.image = (UIImage*)source;
            }else if ([source isKindOfClass:[NSString class]]){
                //网络加载
                [imgCell.imgView sd_setImageWithURL:[NSURL URLWithString:source] placeholderImage:self.placeholderImage];
            }
        }
        cell = imgCell;
        
    }
    if (self.cornerRadius > 0) {
        cell.layer.cornerRadius = self.cornerRadius;
        cell.layer.masksToBounds = YES;
    }
    if (self.configureCell) self.configureCell((FPImageCCell*)cell, indexPath,self.source);
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item >= self.source.count) {//添加
        __weak typeof(self) weakSelf = self;
        NSArray *imageSource = self.imageSource;
        NSArray *videoSource = self.videoSource;
        FPImageType type = FPImageTypeSelectImage;
        NSInteger imageMaxCount = MIN(self.maxAllCount - self.source.count, self.maxImageCount - imageSource.count);
        NSInteger videoMaxCount = MIN(self.maxAllCount - self.source.count, self.maxVideoCount - videoSource.count);
//        FPChooesConfiure *configure = [FPChooesConfiure new];
//        configure.maxVideoDurtaion = self.maxVideoDurtaion;;
//        configure.allowEditImage = self.allowsEditingImage;
//        configure.allowEditVideo = self.allowsEditingVideo;
//
//        configure.maxImageCount = imageMaxCount;
        if (self.interType == FPImageTypeSelectImage) {
//            configure.type = AlertTypeTakePAndChooesP;
            type = FPImageTypeSelectImage;
        }else if (self.interType == FPImageTypeSelectVideo){
//            configure.type = AlertTypeTakeVAndChooesV;
            type = FPImageTypeSelectVideo;
        }else if (self.interType == FPImageTypeSelectImageOrVideo){
//            configure.type = AlertTypeTakePVAndChooesPV;
            type = FPImageTypeSelectImageOrVideo;
        }else if (self.interType == FPImageTypeSelectImageAndVideo){
//            configure.type = AlertTypeTakePVAndChooesPV;
            type = FPImageTypeSelectImageAndVideo;
            if (self.maxVideoCount > 0) {
                if (videoSource.count >= self.maxVideoCount) {
//                    configure.type = AlertTypeTakePAndChooesP;
                    type = FPImageTypeSelectImage;
                }
            }
            if (self.maxImageCount > 0){
                if (imageSource.count >= self.maxImageCount) {
//                    configure.type = AlertTypeTakeVAndChooesV;
                    type = FPImageTypeSelectVideo;
                }
            }
        }
//        configure.didFinishTakeVideoHandle = ^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull pAsset, NSError * _Nonnull error) {
//            if (weakSelf.type == FPImageTypeSelectImageOrVideo){
//                weakSelf.interType = FPImageTypeSelectVideo;
//            }
//            PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
//            options.version = PHImageRequestOptionsVersionCurrent;
//            options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
//            [[PHImageManager defaultManager] requestAVAssetForVideo:pAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
//                AVURLAsset *urlAsset = (AVURLAsset *)asset;
//                FPVideoItem *item = [FPVideoItem new];
//                item.coverImage = coverImage;
//                item.videoUrl = urlAsset.URL;
//                item.pixelWidth = pAsset.pixelWidth;
//                item.pixelHeight = pAsset.pixelHeight;
//                NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
//                [newSource addObject:item];
//                weakSelf.source = newSource;
//                if (weakSelf.addSourceBlock) weakSelf.addSourceBlock(@[item], weakSelf.source);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [weakSelf.collectionView reloadData];
//                });
//            }];
//        };
//        configure.didFinishTakePhotosHandle = ^(NSArray<UIImage *> * _Nonnull images, NSError * _Nonnull error) {
//            if (weakSelf.type == FPImageTypeSelectImageOrVideo){
//                weakSelf.interType = FPImageTypeSelectImage;
//            }
//            NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
//            [newSource addObjectsFromArray:images];
//            weakSelf.source = newSource;
//            if (weakSelf.addSourceBlock) weakSelf.addSourceBlock(images, weakSelf.source);
//            [weakSelf.collectionView reloadData];
//        };
        //        [FPChooesImageHelper chooesImageOrVideoConfiure:configure fromVC:nil];
        if (self.tapAddSourceBlock) {
            self.tapAddSourceBlock(type, imageMaxCount,videoMaxCount, ^(NSArray<UIImage *> * _Nonnull images, NSArray<PHAsset *> * _Nonnull assets) {
                if (weakSelf.type == FPImageTypeSelectImageOrVideo && images.count > 0){
                    weakSelf.interType = FPImageTypeSelectImage;
                }
                if (weakSelf.type == FPImageTypeSelectImageOrVideo && assets.count > 0){
                    weakSelf.interType = FPImageTypeSelectVideo;
                }
                NSMutableArray *newSource = [NSMutableArray arrayWithArray:weakSelf.source];
                [newSource addObjectsFromArray:images];
                if (assets.count > 0) {
                    dispatch_group_t dispatchGroup = dispatch_group_create();
                    NSMutableArray *videoItems = [NSMutableArray array];
                    [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull pAsset, NSUInteger idx, BOOL * _Nonnull stop) {
                        PHVideoRequestOptions *options = [[PHVideoRequestOptions alloc] init];
                        options.version = PHImageRequestOptionsVersionCurrent;
                        options.deliveryMode = PHVideoRequestOptionsDeliveryModeAutomatic;
                        dispatch_group_enter(dispatchGroup);
                        [[PHImageManager defaultManager] requestAVAssetForVideo:pAsset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                            AVURLAsset *urlAsset = (AVURLAsset *)asset;
                            FPVideoItem *item = [FPVideoItem new];
                            item.coverImage = [self getVideoPreViewImage:urlAsset.URL];
                            item.videoUrl = urlAsset.URL;
                            item.pixelWidth = pAsset.pixelWidth;
                            item.pixelHeight = pAsset.pixelHeight;
                            item.asset = pAsset;
                            [videoItems addObject:item];
                            dispatch_group_leave(dispatchGroup);
                        }];
                    }];
                    dispatch_group_notify(dispatchGroup, dispatch_get_main_queue(), ^{
                        [newSource addObjectsFromArray:videoItems];
                        weakSelf.source = newSource;
                        [weakSelf.collectionView reloadData];
                    });
                }else{
                    weakSelf.source = newSource;
                    [weakSelf.collectionView reloadData];
                }
                
            });
        }
    }else{//预览
        id source = self.source[indexPath.item];
        if ([source isKindOfClass:[FPVideoItem class]]) {//点击视频
            if (self.tapVideoBlock) {
                self.tapVideoBlock(self.source[indexPath.item], [collectionView cellForItemAtIndexPath:indexPath]);
            }else{
                AVPlayerViewController *ctrl = [[AVPlayerViewController alloc] init];
                FPVideoItem *videoItem = self.source[indexPath.item];
                ctrl.player= [[AVPlayer alloc]initWithURL:videoItem.videoUrl];
                [ctrl.player play];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:ctrl animated:YES completion:nil];
            }
        }else{//点击图片
            if (self.tapImageBlock) {
                self.tapImageBlock(self.source[indexPath.item], [collectionView cellForItemAtIndexPath:indexPath]);
            }else{
                NSMutableArray *images = [NSMutableArray array];
                [self.source enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (![obj isKindOfClass:[FPVideoItem class]]) {
                        YBIBImageData *data = [YBIBImageData new];
                        if ([obj isKindOfClass:[UIImage class]]) {
                            data.image  = ^__kindof UIImage * _Nullable{return obj;};
                        }else{
                            data.imageURL = [NSURL URLWithString:obj];
                        }
                        data.projectiveView = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:idx inSection:0]];
                        [images addObject:data];
                    }
                }];
                YBImageBrowser *browser = [YBImageBrowser new];
                browser.dataSourceArray = images;
                browser.currentPage = indexPath.item;
                [browser show];
            }
        }
    }
}
- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

#pragma mark layoutDelegate
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    collectionView.contentInset = UIEdgeInsetsZero;
    CGFloat sWidth = self.bounds.size.width;
    CGFloat itemW = floor((sWidth - self.sectionInset.left - self.sectionInset.right - (self.column - 1) * self.minimumInteritemSpacing) / self.column);
    CGFloat itemH = itemW;
    CGSize size = CGSizeMake(itemW,itemH);
    if ((self.interType == FPImageTypeShowImage || self.interType == FPImageTypeSelectImage) && self.maxImageCount == 1 && !CGSizeEqualToSize(self.itemSize, CGSizeZero) && self.source.count > indexPath.item) {
        if (self.itemSize.width + self.sectionInset.right < sWidth) {
            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, sWidth - self.itemSize.width - self.sectionInset.right);
        }
        return self.itemSize;
    }
    if (self.interType == FPImageTypeSelectImageAndVideo || self.interType == FPImageTypeShowImageAndVideo || self.interType == FPImageTypeShowImage || self.interType == FPImageTypeSelectImage) return size;
    if ((self.interType == FPImageTypeSelectVideo || self.interType == FPImageTypeShowVideo || self.interType == FPImageTypeSelectImageOrVideo) && self.maxVideoCount == 1) {
        if (self.source.count > indexPath.item) {
            id obj = self.source[indexPath.item];
            if ([obj isKindOfClass:[FPVideoItem class]]) {
                FPVideoItem *videoItem = (FPVideoItem*)obj;
                if (!CGSizeEqualToSize(videoItem.itemSize, CGSizeZero)) {
                    if (self.automaticConfiureVideoSize) {
                        if (videoItem.itemSize.width + self.sectionInset.right < sWidth) {
                            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, sWidth - videoItem.itemSize.width - self.sectionInset.right);
                        }
                        return videoItem.itemSize;
                    }else if (self.interType == FPImageTypeShowVideo){
                        if (videoItem.itemSize.width + self.sectionInset.right < sWidth) {
                            collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, sWidth - videoItem.itemSize.width - self.sectionInset.right);
                        }
                        return videoItem.itemSize;
                    }
                }
            }
        }
    }
    return CGSizeMake(itemW,itemH);
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return self.sectionInset;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return self.minimumLineSpacing;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return self.minimumInteritemSpacing;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(self.bounds.size.width, self.headerHeight);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(self.bounds.size.width, self.footerHeight);
}
+ (void)registerNibFromTableView:(UITableView*)tableView{
    [tableView registerNib:[UINib nibWithNibName:@"FPImageVideoCell" bundle:[FPImageVideoCell fpSourceBundle]] forCellReuseIdentifier:@"FPImageVideoCell"];
}
+ (FPImageVideoCell*)dequeueReusableCellFromTableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath{
    return [tableView dequeueReusableCellWithIdentifier:@"FPImageVideoCell" forIndexPath:indexPath];
}
+ (instancetype)loadVideoCellFromXib{
    return [[self fpSourceBundle] loadNibNamed:@"FPImageVideoCell" owner:nil options:nil].firstObject;
}
+ (NSBundle*)fpSourceBundle{
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[FPImageVideoCell class]];
        NSURL * url = [bundle URLForResource:@"FPImageVideoCell" withExtension:@"bundle"];
        if (url) bundle =  [NSBundle bundleWithURL:url];
    });
    return bundle;
}
@end
