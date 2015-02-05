//
//  JAPDVBundles.h
//  Jumia
//
//  Created by epacheco on 21/01/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPDVBundles : UIView
@property (weak, nonatomic) IBOutlet UILabel *bundleTitle;

@property (weak, nonatomic) IBOutlet UIScrollView *bundleScrollView;
@property (weak, nonatomic) IBOutlet UILabel *totalLabel;
@property (weak, nonatomic) IBOutlet UIButton *buynowButton;

+ (JAPDVBundles *)getNewPDVBundle;
+ (JAPDVBundles *)getNewPDVBundleWithSize;

- (void)setupWithFrame:(CGRect)frame;

@end
