//
//  JAPDVImageSection.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVImageSection.h"
#import "RIProduct.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JAPDVImageSection ()

@end

@implementation JAPDVImageSection

+ (JAPDVImageSection *)getNewPDVImageSection
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection"
                                                 owner:nil
                                               options:nil];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection~iPad_Portrait"
                                            owner:nil
                                          options:nil];
        
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection~iPad_Landscape"
                                                owner:nil
                                              options:nil];
        }
    }
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAPDVImageSection class]]) {
            return (JAPDVImageSection *)obj;
        }
    }
    
    return nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        
    }
    
    return self;
}

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product
{
    self.layer.cornerRadius = 5.0f;
    
    CGFloat width = frame.size.width - 12.0f;
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.imageScrollView setFrame:CGRectMake(self.imageScrollView.frame.origin.x,
                                              self.imageScrollView.frame.origin.y,
                                              width,
                                              self.imageScrollView.frame.size.height)];
    
    /*******
     Image Section
     *******/
    
    [self loadWithImages:[product.images array]];
    
    self.productNameLabel.text = product.brand;
    [self.productNameLabel sizeToFit];
    
    self.productDescriptionLabel.text = product.name;
    [self.productDescriptionLabel sizeToFit];
    
    CGRect productDescriptionLabelRect = [self.productDescriptionLabel.text boundingRectWithSize:CGSizeMake(width, 1000.0f)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      attributes:@{NSFontAttributeName:self.productDescriptionLabel.font} context:nil];
    
    [self.productDescriptionLabel setFrame:CGRectMake(self.productDescriptionLabel.frame.origin.x,
                                                      CGRectGetMaxY(self.productNameLabel.frame),
                                                      width,
                                                      productDescriptionLabelRect.size.height)];
    
    
    if (VALID_NOTEMPTY(product.maxSavingPercentage, NSString))
    {
        self.discountLabel.text = [NSString stringWithFormat:@"-%@%%", product.maxSavingPercentage];
    } else
    {
        self.discountLabel.hidden = YES;
    }
    
    UIImage *img = [UIImage imageNamed:@"img_badge_discount"];
    CGSize imgSize = self.discountLabel.frame.size;
    
    UIGraphicsBeginImageContext(imgSize);
    [img drawInRect:CGRectMake(0,0,imgSize.width,imgSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.discountLabel.backgroundColor = [UIColor colorWithPatternImage:newImage];
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              CGRectGetMaxY(self.productDescriptionLabel.frame) + 6.0f)];
}

- (void)loadWithImages:(NSArray*)imagesArray
{
    self.imageScrollView.pagingEnabled = YES;
    self.imageScrollView.showsHorizontalScrollIndicator = NO;
    CGFloat currentX = 0.0f;
    CGFloat imageWidth = 146.0f;
    CGFloat imageHeight = 183.0f;
    for (int i = 0; i < imagesArray.count; i++) {
        RIImage* image = [imagesArray objectAtIndex:i];
        if (VALID_NOTEMPTY(image, RIImage)) {
            JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                               0.0f,
                                                                                               self.imageScrollView.frame.size.width,
                                                                                               self.imageScrollView.frame.size.height)];
            [clickableView addTarget:self action:@selector(imageViewPressed:) forControlEvents:UIControlEventTouchUpInside];
            clickableView.tag = i;
            [self.imageScrollView addSubview:clickableView];
            
            UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((clickableView.bounds.size.width - imageWidth) / 2,
                                                                                   (clickableView.bounds.size.height - imageHeight) / 2,
                                                                                   imageWidth,
                                                                                   imageHeight)];
            [clickableView addSubview:imageView];
            [imageView setImageWithURL:[NSURL URLWithString:image.url]
                      placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            
            currentX += clickableView.frame.size.width;
        }
    }
    
    [self.imageScrollView setContentSize:CGSizeMake(currentX,
                                                    self.imageScrollView.frame.size.height)];
}

- (void)imageViewPressed:(UIControl*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageClickedAtIndex:)]) {
        [self.delegate imageClickedAtIndex:sender.tag];
    }
}

@end
