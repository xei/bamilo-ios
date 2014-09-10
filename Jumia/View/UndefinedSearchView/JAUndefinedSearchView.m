//
//  JAUndefinedSearchView.m
//  Jumia
//
//  Created by Miguel Chaves on 10/Sep/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JAUndefinedSearchView.h"
#import "JAPDVSingleRelatedItem.h"
#import "UIImageView+WebCache.h"
#import "RIConfiguration.h"
#import "RICountry.h"

@interface JAUndefinedSearchView ()

@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *labelNoResults;
@property (weak, nonatomic) IBOutlet UIImageView *lineImageView;
@property (weak, nonatomic) IBOutlet UILabel *labelSearchTipsTitle;
@property (weak, nonatomic) IBOutlet UILabel *labelSearchTipsText;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *spaceLabelConstraint;
@property (weak, nonatomic) IBOutlet UIView *topSellersView;
@property (weak, nonatomic) IBOutlet UILabel *topSellersLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineSellersImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *topSellersScrollView;
@property (weak, nonatomic) IBOutlet UIView *topBrandsView;
@property (weak, nonatomic) IBOutlet UILabel *topBrandsLabel;
@property (weak, nonatomic) IBOutlet UIImageView *lineBrandsImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *topBrandsScrollView;
@property (weak, nonatomic) IBOutlet UIView *noticeView;
@property (weak, nonatomic) IBOutlet UILabel *noticeLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noticeConstraintHeight;

@end

@implementation JAUndefinedSearchView

+ (JAUndefinedSearchView *)getNewJAUndefinedSearchView
{
    NSArray *xib = [[NSBundle mainBundle] loadNibNamed:@"JAUndefinedSearchView"
                                                 owner:nil
                                               options:nil];
    
    for (NSObject *obj in xib) {
        if ([obj isKindOfClass:[JAUndefinedSearchView class]]) {
            return (JAUndefinedSearchView *)obj;
        }
    }
    
    return nil;
}

- (void)setupWithUndefinedSearchResult:(RIUndefinedSearchTerm *)searchTerm
{
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.topView.layer.cornerRadius = 4.0f;
    self.labelNoResults.textColor = UIColorFromRGB(0x666666);
    self.labelNoResults.text = searchTerm.errorMessage;
    [self.labelNoResults sizeToFit];
    
    self.lineImageView.backgroundColor = UIColorFromRGB(0xcccccc);
    
    self.labelSearchTipsTitle.textColor = UIColorFromRGB(0x666666);
    self.labelSearchTipsText.textColor = UIColorFromRGB(0x666666);
    
    RISearchType *searchType = searchTerm.searchType;

    if (searchType.title.length > 0) {
        self.labelSearchTipsTitle.text = searchType.title;
    } else {
        [self.labelSearchTipsTitle removeFromSuperview];
        self.spaceLabelConstraint.constant = 15.0f;
    }
    
    self.labelSearchTipsText.text = searchType.text;
    [self.labelSearchTipsText sizeToFit];
    
    float newTopViewHeightValue = self.labelNoResults.frame.size.height + self.labelSearchTipsText.frame.size.height + 110;
    self.topViewHeightConstraint.constant = newTopViewHeightValue;
    
    [self.topView needsUpdateConstraints];
    
    // Top sellers
    self.topSellersView.layer.cornerRadius = 4.0f;
    
    RIFeaturedBox *featuredBox = searchTerm.featuredBox;
    
    self.topSellersLabel.textColor = UIColorFromRGB(0x666666);
    self.topSellersLabel.text = featuredBox.title;
    
    float relatedItemStart = 5.0f;
    
    for (RISearchTypeProduct *product in featuredBox.products)
    {
        if (product.imagesArray.count > 0)
        {
            JAPDVSingleRelatedItem *singleItem = [JAPDVSingleRelatedItem getNewPDVSingleRelatedItem];
            
            CGRect tempFrame = singleItem.frame;
            tempFrame.origin.x = relatedItemStart;
            singleItem.frame = tempFrame;
            
            if (product.imagesArray.count > 0) {
                NSString *url = [product.imagesArray firstObject];
                [singleItem.imageViewItem setImageWithURL:[NSURL URLWithString:url]
                                         placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            } else {
                [singleItem.imageViewItem setImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            }
            
            singleItem.labelBrand.text = product.brand;
            singleItem.labelName.text = product.name;
            
            singleItem.labelPrice.text = [RICountryConfiguration formatPrice:[NSNumber numberWithFloat:[product.price floatValue]]
                                                                     country:[RICountryConfiguration getCurrentConfiguration]];
            
//#warning add delegate here to fire action in catalogue
//            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
//                                                                                  action:@selector(selectedRelatedItem:)];
//            singleItem.userInteractionEnabled = YES;
//            [singleItem addGestureRecognizer:tap];
            
            [self.topSellersScrollView addSubview:singleItem];
            
            relatedItemStart += 110.0f;
        }
    }
    
    [self.topSellersScrollView setContentSize:CGSizeMake(relatedItemStart, 110)];
    
    [self.topSellersView needsUpdateConstraints];
    
    // Brands view
    self.topBrandsView.layer.cornerRadius = 4.0f;
    
    RIFeaturedBrandBox *featuredBrandBox = searchTerm.featuredBrandBox;
    
    self.topBrandsLabel.textColor = UIColorFromRGB(0x666666);
    self.topBrandsLabel.text = featuredBrandBox.title;
    
    float brandItemStart = 0.0f;
    
    for (RIBrand *brand in featuredBrandBox.brands)
    {
        if (brand.image.length > 0)
        {
            UIView *brandView = [[UIView alloc] initWithFrame:CGRectMake(brandItemStart, 0, 110, 100)];
            brandView.backgroundColor = [UIColor clearColor];
            
            UIImageView *brandImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, 50, 40)];
            
            if (brand.image.length > 0) {
                [brandImage setImageWithURL:[NSURL URLWithString:brand.image]
                           placeholderImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            } else {
                [brandImage setImage:[UIImage imageNamed:@"placeholder_scrollableitems"]];
            }
            
            [brandView addSubview:brandImage];
            
            UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 80, 104, 20)];
            brandLabel.textAlignment = NSTextAlignmentCenter;
            brandLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light"
                                              size:13.0f];
            brandLabel.textColor = UIColorFromRGB(0x666666);
            brandLabel.text = brand.name;
            
            [brandView addSubview:brandLabel];
            
            [self.topBrandsScrollView addSubview:brandView];
            brandItemStart += 110.0f;
        }
    }
    
    [self.topBrandsScrollView setContentSize:CGSizeMake(brandItemStart, 110)];
    
    [self.topBrandsView needsUpdateConstraints];
    
    // notice view
    self.noticeView.layer.cornerRadius = 4.0f;
    self.noticeLabel.textColor = UIColorFromRGB(0x666666);
    self.noticeLabel.text = searchTerm.noticeMessage;
    [self.noticeLabel sizeToFit];
    
    self.noticeConstraintHeight.constant = self.noticeLabel.frame.size.height + 35;
    
    [self.noticeView needsUpdateConstraints];
    
    [self needsUpdateConstraints];
    [self layoutSubviews];
    
    float contentHeight = self.noticeConstraintHeight.constant + self.topViewHeightConstraint.constant + 320;
    
    self.contentScrollView.contentSize = CGSizeMake(self.contentScrollView.frame.size.width, contentHeight);
}

@end
