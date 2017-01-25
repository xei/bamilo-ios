//
//  JAPDVVariations.h
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAPDVVariations : UIView

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *variationsScrollView;

+ (JAPDVVariations *)getNewPDVVariationsSection;

- (void)setupWithFrame:(CGRect)frame;

@end
