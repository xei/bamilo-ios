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
#import "JAScrolledImageGalleryView.h"

@interface JAPDVImageSection () {
    
}

@property (nonatomic, strong)JAPriceView* priceView;
@property (nonatomic, assign)NSInteger numberOfImages;

@property (nonatomic, strong)UILabel* soldByLabel;
@property (nonatomic, strong)UIButton* sellerButton;
@property (nonatomic, strong)UILabel* sellerDeliveryLabel;
@property (nonatomic, strong)JARatingsView* sellerRatings;
@property (nonatomic, strong)UIButton* rateSellerButton;
@property (nonatomic, strong)UILabel* numberOfSellerReviewsLabel;

@property (nonatomic, strong)RIProduct* product;

@property (nonatomic, strong) JAScrolledImageGalleryView *imagesPagedView;

@end

@implementation JAPDVImageSection

- (JAScrolledImageGalleryView *)imagesPagedView
{
    CGFloat width = self.width;
    if (!VALID_NOTEMPTY(_imagesPagedView, JAScrolledImageGalleryView)) {
        
        CGRect imagePageFrame = CGRectMake(0, CGRectGetMaxY(self.productDescriptionLabel.frame), self.width, 365);
        _imagesPagedView = [[JAScrolledImageGalleryView alloc] initWithFrame:imagePageFrame];
        
        [_imagesPagedView setInfinite:YES];
        [self addSubview:_imagesPagedView];
    }else if (_imagesPagedView.width != width) {
        [_imagesPagedView setWidth:width];
    }
    return _imagesPagedView;
}

+ (JAPDVImageSection *)getNewPDVImageSection:(BOOL)fashion
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAPDVImageSection"
                                                 owner:nil
                                               options:nil];
    
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
    CGFloat width = frame.size.width;
    CGFloat imagesPageHeight = 365;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
        {
            width = frame.size.width - 6.0f;
        }
        imagesPageHeight = 550;
    }
    [self setWidth:width];
    
    if (VALID_NOTEMPTY(self.product, RIProduct) && self.product == product) {
        [self reloadViews];
        return;
    }
    self.product = product;
    
    self.productNameLabel.font = JAListFont;
    self.productNameLabel.textColor = JABlackColor;
    self.productNameLabel.text = product.brand;
    [self.productNameLabel setX:16.f];
    
    self.productDescriptionLabel.font = JACaptionFont;
    [self.productDescriptionLabel setTextColor:JABlack800Color];
    self.productDescriptionLabel.numberOfLines = 2;
    self.productDescriptionLabel.text = product.name;
    [self.productDescriptionLabel sizeToFit];
    [self.productDescriptionLabel setYBottomOf:self.productNameLabel at:0.f];
    [self.productDescriptionLabel setX:16.f];
    
    CGRect imagePageFrame = CGRectMake(0, CGRectGetMaxY(self.productDescriptionLabel.frame), self.width, imagesPageHeight);
    [self.imagesPagedView setFrame:imagePageFrame];
    
    [self bringSubviewToFront:self.wishListButton];
    
    [self.separatorImageView setWidth:width];
    
    [self loadWithImages:[product.images array]];
    
    if (product.fashion) {
        [self.imagesPagedView setY:16.f];
        [self.productNameLabel setYBottomOf:self.imagesPagedView at:16.f];
        [self.productDescriptionLabel setYBottomOf:self.productNameLabel at:0.f];
        [self setHeight:CGRectGetMaxY(self.productDescriptionLabel.frame) + 16.f];
    }else{
        [self.productNameLabel setY:14.f];
        [self.productDescriptionLabel setYBottomOf:self.productNameLabel at:0.f];
        [self.imagesPagedView setYBottomOf:self.productDescriptionLabel at:16.f];
        [self setHeight:CGRectGetMaxY(self.imagesPagedView.frame)];
    }
    
    [_wishListButton setX:0];
    [_wishListButton setY:self.imagesPagedView.y];
}

- (void)reloadViews
{
    [self imagesPagedView];
}

-(void)selectedButton
{
    [self.sellerButton setBackgroundColor:[UIColor colorWithWhite:0.0f alpha:0.06f]];
}

- (void)setPriceWithNewValue:(NSString *)newValue
                 andOldValue:(NSString *)oldValue
{
    [self.priceView removeFromSuperview];
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:oldValue
                     specialPrice:newValue
                         fontSize:14.0f
            specialPriceOnTheLeft:YES];
    self.priceView.frame = CGRectMake(6.0f,
                                      CGRectGetMaxY(self.productDescriptionLabel.frame) + 3.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self addSubview:self.priceView];
}

- (void)loadWithImages:(NSArray *)imagesArray
{
    NSMutableArray *items = [NSMutableArray new];
    if(VALID_NOTEMPTY(imagesArray, NSArray))
    {
        for (RIImage *image in imagesArray) {
            [items addObject:image.url];
        }
        if (items.count > 1) {
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            {
                if(UIInterfaceOrientationLandscapeLeft == orientation || UIInterfaceOrientationLandscapeRight == orientation)
                {
                    [self.imagesPagedView setHeight:550];
                }else{
                    [self.imagesPagedView setHeight:450];
                }
            }else
                [self.imagesPagedView setHeight:400];
        }
    }
    [self setHeight:CGRectGetMaxY(self.imagesPagedView.frame)];
    [self.separatorImageView setY:CGRectGetMaxY(self.imagesPagedView.frame)];
    [self.separatorImageView setHidden:YES];
    [self.imagesPagedView setViews:items];
    [_wishListButton setY:self.imagesPagedView.y - 50];
    
    if (self.product.images.count > 1)
    {
        [_imagesPagedView addImageClickedTarget:self selector:@selector(imageViewPressed)];
    }
    
    [self bringSubviewToFront:_wishListButton];
}

- (void)imageViewPressed
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(imageClickedAtIndex:)]) {
        [self.delegate imageClickedAtIndex:self.imagesPagedView.selectedIndexPage];
    }
}

#pragma mark - ButtonActions

- (void)goToGalleryIndex:(NSInteger)index
{
    [self.imagesPagedView setSelectedIndexPage:index];
}

@end
