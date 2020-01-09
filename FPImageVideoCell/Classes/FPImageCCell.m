//
//  FPImageCCell.m
//  Huobanys
//
//  Created by nan on 2019/4/4.
//  Copyright © 2019 Noah. All rights reserved.
//

#import "FPImageCCell.h"
#define kSWidth [UIScreen mainScreen].bounds.size.width
@implementation FPVideoItem
- (CGSize)itemSize{
    if (CGSizeEqualToSize(_itemSize, CGSizeZero)) {
        if (self.pixelWidth == 0 || self.pixelHeight == 0) {
            _itemSize = CGSizeZero;
        }else{
            if (self.pixelHeight > self.pixelWidth) {
                CGFloat width = kSWidth * 0.45;
                CGFloat height = width / 0.68;
                _itemSize = CGSizeMake(width, height);
            }else{
                CGFloat width = kSWidth * 0.45;
                CGFloat height = width * 0.68;
                _itemSize = CGSizeMake(width, height);
            }
        }
    }
    return _itemSize;
}
@end
@implementation FPImageCCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (IBAction)deleteAction:(id)sender {
    if (self.deleteBlock) {
        self.deleteBlock(@"");
    }
}
- (IBAction)playBtnAction:(UIButton*)sender {
    if (self.playBlock) {
        self.playBlock(sender);
    }
}
@end


@implementation FPImageResuableView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end
