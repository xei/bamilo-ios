//
//  JAPDVImageSection.m
//  Jumia
//
//  Created by Miguel Chaves on 04/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAPDVImageSection.h"
#import "JAPriceView.h"
#import "RIProduct.h"
#import "RIProductSimple.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"

@interface JAPDVImageSection ()

@property (nonatomic, strong)JAPriceView* priceView;

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

- (void)setupWithFrame:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize
{
    self.layer.cornerRadius = 5.0f;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    
    CGFloat width = frame.size.width - 12.0f;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            width = frame.size.width - 6.0f;
        }
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              width,
                              self.frame.size.height)];
    
    [self.imageScrollView setFrame:CGRectMake(self.imageScrollView.frame.origin.x,
                                              self.imageScrollView.frame.origin.y,
                                              width,
                                              self.imageScrollView.frame.size.height)];
    
    [self.separatorImageView setFrame:CGRectMake(self.separatorImageView.frame.origin.x,
                                                 self.separatorImageView.frame.origin.y,
                                                 width,
                                                 self.separatorImageView.frame.size.height)];    
    
    [self loadWithImages:[product.images array]];
    
    self.productNameLabel.text = product.brand;
    [self.productNameLabel sizeToFit];
    
    self.productDescriptionLabel.text = product.name;
    [self.productDescriptionLabel sizeToFit];
    
    CGRect productDescriptionLabelRect = [self.productDescriptionLabel.text boundingRectWithSize:CGSizeMake(self.imageScrollView.frame.size.width, 1000.0f)
                                                                                         options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      attributes:@{NSFontAttributeName:self.productDescriptionLabel.font} context:nil];
    
    [self.productDescriptionLabel setFrame:CGRectMake(self.productDescriptionLabel.frame.origin.x,
                                                      CGRectGetMaxY(self.productNameLabel.frame),
                                                      self.imageScrollView.frame.size.width,
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
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            [self setupForLandscape:frame product:product preSelectedSize:preSelectedSize];
        }
        else
        {
            [self setupForPortrait:frame product:product];
        }
    }
    else
    {
        [self setupForPortrait:frame product:product];
    }
}

- (void)setupForPortrait:(CGRect)frame product:(RIProduct*)product
{
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              CGRectGetMaxY(self.productDescriptionLabel.frame) + 6.0f)];
}

- (void)setupForLandscape:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize

{
    CGFloat width = frame.size.width - 6.0f;
    
    [self setPriceWithNewValue:product.specialPriceFormatted
                   andOldValue:product.priceFormatted];
    
    [self.sizeImageViewSeparator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    
    [self.sizeClickableView setFrame:CGRectMake(self.sizeClickableView.frame.origin.x,
                                                self.sizeClickableView.frame.origin.y,
                                                width,
                                                self.sizeClickableView.frame.size.height)];
    
    [self.sizeImageViewSeparator setFrame:CGRectMake(self.sizeImageViewSeparator.frame.origin.x,
                                                     self.sizeImageViewSeparator.frame.origin.y,
                                                     width,
                                                     self.sizeImageViewSeparator.frame.size.height)];
    
    if (ISEMPTY(product.productSimples))
    {
        [self.sizeClickableView removeFromSuperview];
        [self.sizeImageViewSeparator removeFromSuperview];
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  CGRectGetMaxY(self.imageScrollView.frame))];
    }
    else if (1 == product.productSimples.count)
    {
        [self.sizeClickableView setEnabled:NO];
        RIProductSimple *currentSimple = product.productSimples[0];
        
        if (VALID_NOTEMPTY(currentSimple.variation, NSString))
        {
            [self.sizeLabel setText:currentSimple.variation];
            
            [self setFrame:CGRectMake(self.frame.origin.x,
                                      self.frame.origin.y,
                                      self.frame.size.width,
                                      CGRectGetMaxY(self.sizeClickableView.frame))];
        }
        else
        {
            [self.sizeClickableView removeFromSuperview];
            [self.sizeImageViewSeparator removeFromSuperview];
            
            [self setFrame:CGRectMake(self.frame.origin.x,
                                      self.frame.origin.y,
                                      self.frame.size.width,
                                      CGRectGetMaxY(self.imageScrollView.frame))];
        }
    }
    else if (1 < product.productSimples.count)
    {
        [self.sizeClickableView setEnabled:YES];
        [self.sizeLabel setText:STRING_SIZE];
        
        [self setFrame:CGRectMake(self.frame.origin.x,
                                  self.frame.origin.y,
                                  self.frame.size.width,
                                  CGRectGetMaxY(self.sizeClickableView.frame))];
        
        if (VALID_NOTEMPTY(preSelectedSize, NSString))
        {
            for (RIProductSimple *simple in product.productSimples)
            {
                if ([simple.variation isEqualToString:preSelectedSize])
                {
                    [self.sizeLabel setText:simple.variation];
                    break;
                }
            }
        }
    }
}

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue
{
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:oldValue
                     specialPrice:newValue
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(6.0f,
                                      CGRectGetMaxY(self.productDescriptionLabel.frame) + 3.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self addSubview:self.priceView];
    
    self.separatorImageViewYConstrain.constant = CGRectGetMaxY(self.priceView.frame) + 6.0f;
    
    [self layoutIfNeeded];
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
