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

@implementation JABrandView

@end

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
@property (assign, nonatomic) CGSize contentSize;

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
                            searchText:(NSString *)searchText
{
    self.contentScrollView.backgroundColor = [UIColor clearColor];
    self.topView.layer.cornerRadius = 4.0f;
    self.labelNoResults.textColor = UIColorFromRGB(0x666666);
    
    NSString *text = searchTerm.errorMessage;
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text];
    NSInteger stringTextLenght = text.length;
    
    UIFont *stringTextFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:14.0f];
    UIFont *subStringTextFont = [UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f];
    UIColor *stringTextColor = UIColorFromRGB(0X666666);
    
    
    [stringText addAttribute:NSFontAttributeName
                       value:stringTextFont
                       range:NSMakeRange(0, stringTextLenght)];
    
    [stringText addAttribute:NSStrokeColorAttributeName
                       value:stringTextColor
                       range:NSMakeRange(0, stringTextLenght)];
    
    NSRange range = [text rangeOfString:searchText];
    
    [stringText addAttribute:NSFontAttributeName
                       value:subStringTextFont
                       range:range];
    
    self.labelNoResults.attributedText = stringText;
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
            singleItem.productUrl = product.url;
            singleItem.labelPrice.text = product.priceFormatted;
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(productSelected:)];
            singleItem.userInteractionEnabled = YES;
            [singleItem addGestureRecognizer:tap];
            
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
            JABrandView *brandView = [[JABrandView alloc] initWithFrame:CGRectMake(brandItemStart, 0, 110, 100)];
            brandView.backgroundColor = [UIColor clearColor];
            brandView.brandUrl = brand.url;
            brandView.brandName = brand.name;
            
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
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                  action:@selector(brandSelected:)];
            brandView.userInteractionEnabled = YES;
            [brandView addGestureRecognizer:tap];
            
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
    
    self.contentSize = self.contentScrollView.contentSize;
}

#pragma mark - Delegate methods

- (void)productSelected:(UITapGestureRecognizer *)tap
{
    JAPDVSingleRelatedItem *item = (JAPDVSingleRelatedItem *)tap.view;
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(didSelectProduct:)])
    {
        [self.delegate didSelectProduct:item.productUrl];
    }
}

- (void)brandSelected:(UITapGestureRecognizer *)tap
{
    JABrandView *item = (JABrandView *)tap.view;
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(didSelectBrand:brandName:)])
    {
        [self.delegate didSelectBrand:item.brandUrl
                            brandName:item.brandName];
    }
}

#pragma mark - Refresh content size

- (void)refreshContentSize
{
    self.contentScrollView.contentSize = self.contentSize;
}

@end
