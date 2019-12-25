//
//  FPImageResuableView.h
//  test
//
//  Created by fanpeng on 2019/12/11.
//  Copyright © 2019 Mac. All rights reserved.
//

#import <UIKit/UIKit.h>

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
