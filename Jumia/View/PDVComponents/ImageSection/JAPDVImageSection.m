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


// as of https://jira.rocket-internet.de/browse/NAFAMZ-14582
#define xFavOffset 16.f
#define yFavOffset 20.f

@interface JAPDVImageSection () {
    
}

@property (nonatomic, strong) UIButton *globalButton;
@property (nonatomic, strong) RIProduct* product;
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

- (UIButton *)wishListButton
{
    CGRect frame = CGRectMake(16.f, 0, 25, 25);
    if (!_wishListButton) {
        _wishListButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_wishListButton setFrame:frame];
        [_wishListButton setBackgroundImage:[UIImage imageNamed:@"FavButton"] forState:UIControlStateNormal];
        [_wishListButton setBackgroundImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateHighlighted];
        [_wishListButton setBackgroundImage:[UIImage imageNamed:@"FavButtonPressed"] forState:UIControlStateSelected];
        [self addSubview:_wishListButton];
    }else if (!CGRectEqualToRect(frame, _wishListButton.frame)) {
//        [_wishListButton setFrame:frame];
    }
    return _wishListButton;
}

- (UIView *)separatorImageView
{
    if (!_separatorImageView) {
        _separatorImageView = [[UIView alloc] initWithFrame:CGRectMake(0, 449, self.width, 1)];
        [_separatorImageView setBackgroundColor:JABlack300Color];
        [self addSubview:_separatorImageView];
    }else if (self.width != _separatorImageView.width)
    {
        [_separatorImageView setWidth:self.width];
    }
    return _separatorImageView;
}

- (UILabel *)productNameLabel
{
    CGRect frame = CGRectMake(16.f, 32.f, self.width - 16.f*2, 20);
    if (self.product.seller.isGlobal) {
        frame.size.width = self.globalButton.x - frame.origin.x;
    }
    if (!_productNameLabel) {
        _productNameLabel = [[UILabel alloc] initWithFrame:frame];
        _productNameLabel.font = JAListFont;
        _productNameLabel.textColor = JABlackColor;
        [_productNameLabel setTextAlignment:NSTextAlignmentLeft];
        [self addSubview:_productNameLabel];
    }else if (_productNameLabel.width != frame.size.width) {
        [_productNameLabel setWidth:frame.size.width];
    }
    
    return _productNameLabel;
}

- (UILabel *)productDescriptionLabel
{
    CGFloat width = self.width - xFavOffset * 2 - self.wishListButton.width;
    if (self.product.seller.isGlobal) {
        width = self.width - (xFavOffset * 2) - self.globalButton.width - xFavOffset;
    }

    if (!_productDescriptionLabel) {
        CGRect frame = CGRectMake(xFavOffset, CGRectGetMaxY(self.productNameLabel.frame), width, 60);
        
        _productDescriptionLabel = [[UILabel alloc] initWithFrame:frame];
        _productDescriptionLabel.font = JACaptionFont;
        [_productDescriptionLabel setTextColor:JABlack800Color];
        _productDescriptionLabel.numberOfLines = 2;
        [_productDescriptionLabel setLineBreakMode:NSLineBreakByTruncatingTail];
        [self addSubview:_productDescriptionLabel];
    } else if (_productDescriptionLabel.width != width) {
        [_productDescriptionLabel setWidth:width];
        [_productDescriptionLabel setHeight:60];
        [_productDescriptionLabel sizeToFit];
    }
    return _productDescriptionLabel;
}

- (UIButton *)globalButton
{
    if (!_globalButton) {
        _globalButton = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *plane = [UIImage imageNamed:@"plane_corner"];
        [_globalButton setImage:plane forState:UIControlStateNormal];
        [_globalButton setFrame:CGRectMake(self.width - plane.size.width, 0, plane.size.width, plane.size.height)];
        [self addSubview:_globalButton];
        if (RI_IS_RTL)
        {
            [_globalButton flipViewImage];
        }
    }
    return _globalButton;
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
    
    if (!VALID_NOTEMPTY(product, RIProduct)) {
        return;
    }
    
    if (self.product == product) {
        [self reloadViews];
        return;
    }
    self.product = product;

    [self.productNameLabel setText:product.brand];
    
    self.productDescriptionLabel.text = product.name;
    [self.productDescriptionLabel sizeToFit];
    [self.productDescriptionLabel setYBottomOf:self.productNameLabel at:0.f];
    
    CGRect imagePageFrame = CGRectMake(0, CGRectGetMaxY(self.productDescriptionLabel.frame), self.width, imagesPageHeight);
    [self.imagesPagedView setFrame:imagePageFrame];
    [self loadWithImages:[product.images array]];
    
    [self reloadViews];
}

- (void)reloadViews
{
    if ([self.product.seller isGlobal]) {
        [self.globalButton setX:self.width-self.globalButton.width];
    }
    [self.productNameLabel setX:16.f];
    [self.productDescriptionLabel setX:16.f];
    [self imagesPagedView];
    [self separatorImageView];
    [self.wishListButton setXRightAligned:xFavOffset];
    [self.productNameLabel setTextAlignment:NSTextAlignmentLeft];
    [self.productDescriptionLabel setTextAlignment:NSTextAlignmentLeft];
    
    if (self.product.fashion) {
        if ([self.product.seller isGlobal]) {
            [_imagesPagedView setYBottomOf:self.globalButton at:yFavOffset];
        } else {
            [_imagesPagedView setY:yFavOffset];
        }
        [self.wishListButton setY:self.imagesPagedView.y];
        [_productNameLabel setYBottomOf:_imagesPagedView at:16.f];
        [_productDescriptionLabel setYBottomOf:_productNameLabel at:0.f];
        [self setHeight:CGRectGetMaxY(_productDescriptionLabel.frame) + 16.f];
    }else{
        [_productNameLabel setY:14.f];
        [_productDescriptionLabel setYBottomOf:_productNameLabel at:0.f];
        if ([self.product.seller isGlobal]) {
            [_imagesPagedView setYBottomOf:self.globalButton at:yFavOffset];
            [self.wishListButton setYBottomOf:self.globalButton at:yFavOffset];
        } else {
            [_imagesPagedView setYBottomOf:_productDescriptionLabel at:yFavOffset];
            [self.wishListButton setY:yFavOffset];
        }
        [self setHeight:CGRectGetMaxY(_imagesPagedView.frame)];
    }
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
    [self.wishListButton setY:yFavOffset];
    
    if (self.product.images.count > 1)
    {
        [self.imagesPagedView addImageClickedTarget:self selector:@selector(imageViewPressed)];
    }
    
    [self bringSubviewToFront:self.wishListButton];
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

- (void)addGlobalButtonTarget:(id)target action:(SEL)action
{
    [self.globalButton addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
@end
