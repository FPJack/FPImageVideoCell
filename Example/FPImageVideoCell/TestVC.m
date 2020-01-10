//
//  TestVC.m
//  test
//
//  Created by fanpeng on 2019/10/19.
//  Copyright © 2019 Mac. All rights reserved.
//

#import "TestVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <FPImageVideoCell.h>
#import "FPChooesImageHelper.h"
#import <SDWebImage/SDWebImage.h>
//#import <FPZuJianHua/Example.h>
//#import <Private/Example.h>
@interface TestVC ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic,strong)NSArray *titles;
@end

@implementation TestVC
- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    [FPImageVideoCell registerClassFromTableView:self.tableView];
    
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    FPImageVideoCell *cell = [FPImageVideoCell dequeueReusableCellFromTableView:tableView indexPath:indexPath];
    cell.type = self.type;
    cell.headerHeight = 50;
   //cell.footerHeight = 50;
    cell.headerTitle = @"选择图片";
//    cell.footerTitle = @"上传图片";
    cell.cornerRadius = 5;
    cell.maxVideoDurtaion = 60;
    cell.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    switch (self.type) {
        case FPImageTypeShowImage:
        {
            NSString *url1 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url2 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url3 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url4 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSArray *source = @[url1,url2,url3,url4];
//            NSArray *source = @[url1];
//            cell.itemSize = CGSizeMake(300, 200);
            cell.source = [source mutableCopy];
            
//            cell.maxImageCount = 1;
        }
            break;
        case FPImageTypeSelectImage:
            cell.maxImageCount = 9;
            
            break;
        case FPImageTypeShowVideo:
        {
            FPVideoItem *item = [FPVideoItem new];
            item.coverUrl =  @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSURL*url=  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"mp4"]];
            item.videoUrl = url;
            item.itemSize = CGSizeMake(300, 200);
//            cell.maxVideoCount = 1;
            cell.source = [@[item] mutableCopy];
        }
            break;
        case FPImageTypeSelectVideo:
            cell.maxVideoCount = 9;
            break;
        case FPImageTypeSelectImageOrVideo:
            cell.maxImageCount = 9;
            cell.maxVideoCount = 2;
            cell.maxAllCount = 9;
            break;
        case FPImageTypeSelectImageAndVideo:
        {
            cell.maxImageCount = 9;
            cell.maxVideoCount = 9;
            cell.maxAllCount = 9;
        }
            break;
        case FPImageTypeShowImageAndVideo:
        {
            NSString *url1 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url2 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url3 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSString *url4 = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            FPVideoItem *item = [FPVideoItem new];
            item.coverUrl = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            NSURL*url=  [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"example" ofType:@"mp4"]];
            item.videoUrl = url;
            FPVideoItem *item1 = [FPVideoItem new];
            item1.coverUrl = @"https://img.52z.com/upload/news/image/20180621/20180621055651_47663.jpg";
            item1.videoUrl = url;
            NSArray *arr = @[url1,url2,item,url3,url4,item1];
            cell.source = [arr mutableCopy];
        }
            break;
        default:
            break;
    }
    
    cell.configureReusableView = ^(FPImageResuableView * _Nonnull resuableView, NSString * _Nonnull kind) {
        resuableView.imgWidthCon.constant = 0;
        resuableView.labLeftCon.constant = 0;
        resuableView.titleLab.text = self.title;
    };
    cell.tapAddSourceBlock = ^(FPImageType type, NSInteger leaveMaxCount,NSInteger leaveVideoMaxCount, void (^ _Nonnull injectBlock)(NSArray<UIImage *> * , NSArray<PHAsset *> * )) {
        FPChooesConfiure *configure = [FPChooesConfiure new];
        configure.maxVideoDurtaion = 60;
        configure.maxImageCount = leaveMaxCount;
        if (type == FPImageTypeSelectImage) {
            configure.type = AlertTypeTakePAndChooesP;
        }else if (type == FPImageTypeSelectVideo){
            configure.type = AlertTypeTakeVAndChooesV;
        }else if (type == FPImageTypeSelectImageOrVideo){
            configure.type = AlertTypeTakePVAndChooesPV;
        }else if (type == FPImageTypeSelectImageAndVideo){
            configure.type = AlertTypeTakePVAndChooesPV;
        }
        configure.didFinishTakeVideoHandle = ^(UIImage * _Nonnull coverImage, PHAsset * _Nonnull asset, NSError * _Nullable error) {
            if (injectBlock) {
                injectBlock(nil,@[asset]);
            }
        };
        configure.didFinishTakePhotosHandle = ^(NSArray<UIImage *> * _Nonnull images, NSError * _Nullable error) {
            if (injectBlock) {
                injectBlock(images,nil);
            }
        };
        [FPChooesImageHelper chooesImageOrVideoConfiure:configure fromVC:nil];
    };
    cell.loadNetworkImageBlock = ^(UIImageView * _Nonnull imageView, NSURL * _Nonnull url, UIImage * _Nonnull placeholderImage) {
        [imageView sd_setImageWithURL:url placeholderImage:placeholderImage];
    };
    return cell;
}
@end
