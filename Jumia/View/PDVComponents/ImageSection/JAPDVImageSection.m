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
#import "RISeller.h"
#import "RIProductSimple.h"
#import "RIImage.h"
#import "UIImageView+WebCache.h"
#import "JAPageControl.h"
#import "JARatingsView.h"

@interface JAPDVImageSection ()

@property (nonatomic, strong)JAPriceView* priceView;
@property (nonatomic, assign)NSInteger numberOfImages;
@property (nonatomic, strong) JAPageControl* pageControl;

@property (nonatomic, strong)UILabel* soldByLabel;
@property (nonatomic, strong)UIButton* sellerButton;
@property (nonatomic, strong)UILabel* sellerDeliveryLabel;
@property (nonatomic, strong)JARatingsView* sellerRatings;
@property (nonatomic, strong)UIButton* rateSellerButton;
@property (nonatomic, strong)UILabel* numberOfSellerReviewsLabel;

@property (nonatomic, strong)RIProduct* product;

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
    self.product = product;
    
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
    
    self.productNameLabel.text = product.brand;
    self.productNameLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.productDescriptionLabel.text = product.name;
    self.productDescriptionLabel.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.sizeClickableView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.separatorImageView.translatesAutoresizingMaskIntoConstraints = YES;
    
    self.imageScrollView.translatesAutoresizingMaskIntoConstraints = YES;
    
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
    
    [self.pageControl removeFromSuperview];
    self.pageControl = [[JAPageControl alloc] initWithFrame:CGRectMake(self.imageScrollView.frame.origin.x,
                                                                       self.imageScrollView.frame.origin.y + self.imageScrollView.frame.size.height - 20.0f,
                                                                       self.imageScrollView.frame.size.width,
                                                                       10.0f)];
    self.pageControl.numberOfPages = [product.images array].count;
    [self addSubview:self.pageControl];
    self.pageControl.currentPage = 0;
}

- (void)setupForPortrait:(CGRect)frame product:(RIProduct*)product
{
    [self.productNameLabel setFrame:CGRectMake(6.0f,
                                               CGRectGetMaxY(self.separatorImageView.frame) + 6.0f,
                                               self.imageScrollView.frame.size.width - 12.0f,
                                               1000.0f)];
    [self.productNameLabel sizeToFit];
    
    [self.productDescriptionLabel setFrame:CGRectMake(6.0f,
                                                      CGRectGetMaxY(self.productNameLabel.frame) + 2.0f,
                                                      self.imageScrollView.frame.size.width - 12.0f,
                                                      1000.0f)];
    [self.productDescriptionLabel sizeToFit];

    
    CGFloat currentY = CGRectGetMaxY(self.productDescriptionLabel.frame) + 6.0f;
    
    [self.soldByLabel removeFromSuperview];
    [self.sellerButton removeFromSuperview];
    [self.sellerDeliveryLabel removeFromSuperview];
    [self.sellerRatings removeFromSuperview];
    [self.rateSellerButton removeFromSuperview];
    [self.numberOfSellerReviewsLabel removeFromSuperview];
    if (VALID_NOTEMPTY(product.seller, RISeller)) {
        
        currentY += 20.0f;
        
        self.soldByLabel = [UILabel new];
        self.soldByLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        self.soldByLabel.textColor = UIColorFromRGB(0x666666);
        self.soldByLabel.text = @"Sold by:";
        [self.soldByLabel sizeToFit];
        [self.soldByLabel setFrame:CGRectMake(6.0f,
                                              currentY,
                                              self.soldByLabel.frame.size.width,
                                              self.soldByLabel.frame.size.height)];
        [self addSubview:self.soldByLabel];
        
        
        self.sellerButton = [UIButton new];
        [self.sellerButton setTitle:product.seller.name forState:UIControlStateNormal];
        [self.sellerButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateNormal];
        self.sellerButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        [self.sellerButton sizeToFit];
        self.sellerButton.center = self.soldByLabel.center;
        [self.sellerButton setFrame:CGRectMake(CGRectGetMaxX(self.soldByLabel.frame) + 6.0f,
                                               self.sellerButton.frame.origin.y,
                                               self.sellerButton.frame.size.width,
                                               self.sellerButton.frame.size.height)];
        [self addSubview:self.sellerButton];
        
        
        self.numberOfSellerReviewsLabel = [UILabel new];
        self.numberOfSellerReviewsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f];
        self.numberOfSellerReviewsLabel.textColor = UIColorFromRGB(0xcccccc);
        self.numberOfSellerReviewsLabel.text = [NSString stringWithFormat:@"%d reviews", [product.seller.reviewTotal integerValue]];
        [self.numberOfSellerReviewsLabel sizeToFit];
        [self.numberOfSellerReviewsLabel setFrame:CGRectMake(self.frame.size.width - 6.0f - self.numberOfSellerReviewsLabel.frame.size.width,
                                                             currentY + 4.0f,
                                                             self.numberOfSellerReviewsLabel.frame.size.width,
                                                             self.numberOfSellerReviewsLabel.frame.size.height)];
        [self addSubview:self.numberOfSellerReviewsLabel];
        
        
        self.sellerRatings = [JARatingsView getNewJARatingsView];
        self.sellerRatings.rating = [product.seller.reviewAverage integerValue];
        [self.sellerRatings setFrame:CGRectMake(self.numberOfSellerReviewsLabel.frame.origin.x - 6.0f - self.sellerRatings.frame.size.width,
                                                currentY + 4.0f,
                                                self.sellerRatings.frame.size.width,
                                                self.sellerRatings.frame.size.height)];
        [self addSubview:self.sellerRatings];
        
        CGFloat buttonHeight = 22.0f;
        CGFloat buttonOffset = -(buttonHeight - self.sellerRatings.frame.size.height)/2;
        self.rateSellerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.sellerRatings.frame.origin.x,
                                                                           self.sellerRatings.frame.origin.y + buttonOffset,
                                                                           self.sellerRatings.frame.size.width,
                                                                           buttonHeight)];
        [self.rateSellerButton addTarget:self action:@selector(sellerRatingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rateSellerButton];
        
        currentY += self.soldByLabel.frame.size.height;
        
        self.sellerDeliveryLabel = [UILabel new];
        self.sellerDeliveryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        self.sellerDeliveryLabel.textColor = UIColorFromRGB(0x666666);
        self.sellerDeliveryLabel.text = [NSString stringWithFormat:@"Delivery Within: %d - %d days", [product.seller.minDeliveryTime integerValue], [product.seller.maxDeliveryTime integerValue]];
        [self.sellerDeliveryLabel sizeToFit];
        [self.sellerDeliveryLabel setFrame:CGRectMake(6.0f,
                                                      currentY,
                                                      self.sellerDeliveryLabel.frame.size.width,
                                                      self.sellerDeliveryLabel.frame.size.height)];
        [self addSubview:self.sellerDeliveryLabel];
        
        currentY += self.sellerDeliveryLabel.frame.size.height + 16.0f;
    }
    
    [self setFrame:CGRectMake(self.frame.origin.x,
                              self.frame.origin.y,
                              self.frame.size.width,
                              currentY)];
}

- (void)setupForLandscape:(CGRect)frame product:(RIProduct*)product preSelectedSize:(NSString*)preSelectedSize

{
    CGFloat width = frame.size.width - 6.0f;
    
    [self.productNameLabel setFrame:CGRectMake(6.0f,
                                               6.0f,
                                               self.imageScrollView.frame.size.width - 12.0f,
                                               1000.0f)];
    [self.productNameLabel sizeToFit];
    
    [self.productDescriptionLabel setFrame:CGRectMake(6.0f,
                                                      CGRectGetMaxY(self.productNameLabel.frame) + 2.0f,
                                                      self.imageScrollView.frame.size.width - 12.0f,
                                                      1000.0f)];
    [self.productDescriptionLabel sizeToFit];
    
    [self setPriceWithNewValue:product.specialPriceFormatted
                   andOldValue:product.priceFormatted];
    
    
    CGFloat currentY = CGRectGetMaxY(self.priceView.frame) + 6.0f;
    
    [self.soldByLabel removeFromSuperview];
    [self.sellerButton removeFromSuperview];
    [self.sellerDeliveryLabel removeFromSuperview];
    [self.sellerRatings removeFromSuperview];
    [self.rateSellerButton removeFromSuperview];
    [self.numberOfSellerReviewsLabel removeFromSuperview];
    if (VALID_NOTEMPTY(product.seller, RISeller)) {
        
        currentY += 20.0f;
        
        self.soldByLabel = [UILabel new];
        self.soldByLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        self.soldByLabel.textColor = UIColorFromRGB(0x666666);
        self.soldByLabel.text = @"Sold by:";
        [self.soldByLabel sizeToFit];
        [self.soldByLabel setFrame:CGRectMake(6.0f,
                                              currentY,
                                              self.soldByLabel.frame.size.width,
                                              self.soldByLabel.frame.size.height)];
        [self addSubview:self.soldByLabel];
        
        
        self.sellerButton = [UIButton new];
        [self.sellerButton setTitle:product.seller.name forState:UIControlStateNormal];
        [self.sellerButton setTitleColor:UIColorFromRGB(0xfaa41a) forState:UIControlStateNormal];
        self.sellerButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        [self.sellerButton sizeToFit];
        self.sellerButton.center = self.soldByLabel.center;
        [self.sellerButton setFrame:CGRectMake(CGRectGetMaxX(self.soldByLabel.frame) + 6.0f,
                                               self.sellerButton.frame.origin.y,
                                               self.sellerButton.frame.size.width,
                                               self.sellerButton.frame.size.height)];
        [self addSubview:self.sellerButton];
        
        self.numberOfSellerReviewsLabel = [UILabel new];
        self.numberOfSellerReviewsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:9.0f];
        self.numberOfSellerReviewsLabel.textColor = UIColorFromRGB(0xcccccc);
        self.numberOfSellerReviewsLabel.text = [NSString stringWithFormat:@"%d reviews", [product.seller.reviewTotal integerValue]];
        [self.numberOfSellerReviewsLabel sizeToFit];
        [self.numberOfSellerReviewsLabel setFrame:CGRectMake(self.frame.size.width - 6.0f - self.numberOfSellerReviewsLabel.frame.size.width,
                                                             currentY + 4.0f,
                                                             self.numberOfSellerReviewsLabel.frame.size.width,
                                                             self.numberOfSellerReviewsLabel.frame.size.height)];
        [self addSubview:self.numberOfSellerReviewsLabel];
        
        
        self.sellerRatings = [JARatingsView getNewJARatingsView];
        self.sellerRatings.rating = [product.seller.reviewAverage integerValue];
        [self.sellerRatings setFrame:CGRectMake(self.numberOfSellerReviewsLabel.frame.origin.x - 6.0f - self.sellerRatings.frame.size.width,
                                                currentY + 4.0f,
                                                self.sellerRatings.frame.size.width,
                                                self.sellerRatings.frame.size.height)];
        [self addSubview:self.sellerRatings];
        
        CGFloat buttonHeight = 22.0f;
        CGFloat buttonOffset = -(buttonHeight - self.sellerRatings.frame.size.height)/2;
        self.rateSellerButton = [[UIButton alloc] initWithFrame:CGRectMake(self.sellerRatings.frame.origin.x,
                                                                           self.sellerRatings.frame.origin.y + buttonOffset,
                                                                           self.sellerRatings.frame.size.width,
                                                                           buttonHeight)];
        [self.rateSellerButton addTarget:self action:@selector(sellerRatingButtonPressed) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.rateSellerButton];
        
        currentY += self.soldByLabel.frame.size.height;
        
        self.sellerDeliveryLabel = [UILabel new];
        self.sellerDeliveryLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12.0f];
        self.sellerDeliveryLabel.textColor = UIColorFromRGB(0x666666);
        self.sellerDeliveryLabel.text = [NSString stringWithFormat:@"Delivery Within: %d - %d days", [product.seller.minDeliveryTime integerValue], [product.seller.maxDeliveryTime integerValue]];
        [self.sellerDeliveryLabel sizeToFit];
        [self.sellerDeliveryLabel setFrame:CGRectMake(6.0f,
                                                      currentY,
                                                      self.sellerDeliveryLabel.frame.size.width,
                                                      self.sellerDeliveryLabel.frame.size.height)];
        [self addSubview:self.sellerDeliveryLabel];
        
        currentY += self.sellerDeliveryLabel.frame.size.height + 16.0f;
    }
    
    
    [self.separatorImageView setFrame:CGRectMake(self.separatorImageView.frame.origin.x,
                                                 currentY + 6.0f,
                                                 self.separatorImageView.frame.size.width,
                                                 self.separatorImageView.frame.size.height)];
    
    [self.imageScrollView setFrame:CGRectMake(self.imageScrollView.frame.origin.x,
                                              CGRectGetMaxY(self.separatorImageView.frame),
                                              width,
                                              self.imageScrollView.frame.size.height)];
    
    [self.sizeImageViewSeparator setBackgroundColor:UIColorFromRGB(0xcccccc)];
    [self.sizeLabel setTextColor:UIColorFromRGB(0x55a1ff)];
    
    [self.sizeImageViewSeparator setFrame:CGRectMake(self.sizeImageViewSeparator.frame.origin.x,
                                                     CGRectGetMaxY(self.imageScrollView.frame),
                                                     width,
                                                     self.sizeImageViewSeparator.frame.size.height)];
    
    [self.sizeClickableView setFrame:CGRectMake(self.sizeClickableView.frame.origin.x,
                                                CGRectGetMaxY(self.sizeImageViewSeparator.frame),
                                                width,
                                                self.sizeClickableView.frame.size.height)];
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
}

- (void)loadWithImages:(NSArray*)imagesArray
{
    if(VALID_NOTEMPTY(imagesArray, NSArray))
    {
        //add the last item to the begining and the first item to the end in order to simulate infinite scroll
        NSInteger lastIndex = [imagesArray count] - 1;
        NSMutableArray* modifiedArray = [imagesArray mutableCopy];
        [modifiedArray insertObject:[imagesArray lastObject]
                            atIndex:0];
        [modifiedArray addObject:[imagesArray firstObject]];
        self.numberOfImages = [modifiedArray count];
        
        self.imageScrollView.pagingEnabled = YES;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        self.imageScrollView.delegate = self;
        CGFloat currentX = 0.0f;
        CGFloat imageWidth = 146.0f;
        CGFloat imageHeight = 183.0f;
        for (int i = 0; i < modifiedArray.count; i++) {
            RIImage* image = [modifiedArray objectAtIndex:i];
            if (VALID_NOTEMPTY(image, RIImage)) {
                JAClickableView* clickableView = [[JAClickableView alloc] initWithFrame:CGRectMake(currentX,
                                                                                                   0.0f,
                                                                                                   self.imageScrollView.frame.size.width,
                                                                                                   self.imageScrollView.frame.size.height)];
                
                if(0 == i || i > lastIndex)
                {
                    clickableView.tag = lastIndex;
                }
                else
                {
                    clickableView.tag = i - 1;
                }
                [clickableView addTarget:self action:@selector(imageViewPressed:) forControlEvents:UIControlEventTouchUpInside];
                [self.imageScrollView addSubview:clickableView];
                
                UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((clickableView.bounds.size.width - imageWidth) / 2,
                                                                                       (clickableView.bounds.size.height - imageHeight) / 2,
                                                                                       imageWidth,
                                                                                       imageHeight)];
                [clickableView addSubview:imageView];
                [imageView setImageWithURL:[NSURL URLWithString:image.url]
                          placeholderImage:[UIImage imageNamed:@"placeholder_pdv"]];
                
                currentX += clickableView.frame.size.width;
            }
        }
        
        [self.imageScrollView setContentSize:CGSizeMake(currentX,
                                                        self.imageScrollView.frame.size.height)];
        
        //starting index should be 1 because 0 is the last image, replicated in order to simulate infinite scroll
        [self.imageScrollView scrollRectToVisible:CGRectMake(self.imageScrollView.frame.size.width,
                                                             0,
                                                             self.imageScrollView.frame.size.width,
                                                             self.imageScrollView.frame.size.height)
                                         animated:NO];
    }
    else
    {
        self.numberOfImages = 0;
        self.imageScrollView.pagingEnabled = NO;
        self.imageScrollView.showsHorizontalScrollIndicator = NO;
        
        CGFloat imageWidth = 146.0f;
        CGFloat imageHeight = 183.0f;
        
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.imageScrollView.frame.size.width - imageWidth) / 2,
                                                                               (self.imageScrollView.frame.size.height - imageHeight) / 2,
                                                                               imageWidth,
                                                                               imageHeight)];
        [self.imageScrollView addSubview:imageView];
        [imageView setImage:[UIImage imageNamed:@"placeholder_pdv"]];
        
    }
}

- (void)imageViewPressed:(UIControl*)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageClickedAtIndex:)]) {
        [self.delegate imageClickedAtIndex:sender.tag];
    }
}

#pragma mark - UIScrollView

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView == self.imageScrollView && self.numberOfImages > 1)
    {
        float contentOffsetWhenFullyScrolledRight = self.imageScrollView.frame.size.width * (self.numberOfImages - 1);
        
        if (scrollView.contentOffset.x == contentOffsetWhenFullyScrolledRight) {
            
            [self.imageScrollView scrollRectToVisible:CGRectMake(self.imageScrollView.frame.size.width,
                                                                 0,
                                                                 self.imageScrollView.frame.size.width,
                                                                 self.imageScrollView.frame.size.height)
                                             animated:NO];
            
        } else if (scrollView.contentOffset.x == 0)  {
            
            [self.imageScrollView scrollRectToVisible:CGRectMake(self.imageScrollView.contentSize.width - self.imageScrollView.frame.size.width*2,
                                                                 0,
                                                                 self.imageScrollView.frame.size.width,
                                                                 self.imageScrollView.frame.size.height)
                                             animated:NO];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //add 0.5 to make sure we scroll the indicators with the middle of the page
    //and then subtract 1 to make up for the fake image offset (fake images that are used for infinite scrolling)
    self.pageControl.currentPage = (scrollView.contentOffset.x / scrollView.frame.size.width) + 0.5f - 1.0f;
    
}

#pragma mark - ButtonActions

-(void)sellerRatingButtonPressed
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kOpenSellerReviews object:self.product];
}

@end
