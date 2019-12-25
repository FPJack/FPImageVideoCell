//
//  FPViewController.m
//  FPImageVideoCell
//
//  Created by FPJack on 12/24/2019.
//  Copyright (c) 2019 FPJack. All rights reserved.
//

#import "FPViewController.h"
#import <FPImageVideoCell.h>
#import "TestVC.h"
@interface FPViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong)NSArray *titles;

@end

@implementation FPViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titles = @[@(FPImageTypeShowImage),
                    @(FPImageTypeSelectImage),
                    @(FPImageTypeShowVideo),
                    @(FPImageTypeSelectVideo),
                    @(FPImageTypeSelectImageOrVideo),
                    @(FPImageTypeSelectImageAndVideo),
                    @(FPImageTypeShowImageAndVideo)
                    
    ];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.titles.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSNumber *type = self.titles[indexPath.row];
    NSString *title = @"";
    switch (type.integerValue) {
        case FPImageTypeShowImage:
            title = @"展示图片";
            break;
        case FPImageTypeSelectImage:
            title = @"选择图片";
            break;
        case FPImageTypeShowVideo:
            title = @"展示视频";
            break;
        case FPImageTypeSelectVideo:
            title = @"选择视频";
            break;
        case FPImageTypeSelectImageOrVideo:
            title = @"图片视频二选一";
            break;
        case FPImageTypeSelectImageAndVideo:
            title = @"选择图片和视频";
            break;
        case FPImageTypeShowImageAndVideo:
            title = @"展示图片和视频";
            break;
        default:
            break;
    }
    cell.textLabel.text = title;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TestVC *vc = [TestVC new];
    NSNumber *type = self.titles[indexPath.row];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    vc.title = cell.textLabel.text;
    vc.type = type.integerValue;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
