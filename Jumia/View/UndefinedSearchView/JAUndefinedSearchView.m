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

@property (nonatomic, strong) RIUndefinedSearchTerm* searchResult;
@property (nonatomic, assign) UIInterfaceOrientation myOrientation;
@property (nonatomic, strong) NSString* searchText;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UIView* topView;
@property (nonatomic, strong) UIImageView* searchIconImageView;
@property (nonatomic, strong) UILabel *labelNoResults;
@property (nonatomic, strong) UIView *separatorView;
@property (nonatomic, strong) UILabel *searchTipsTitleLabel;
@property (nonatomic, strong) UILabel *searchTipsTextLabel;

@property (nonatomic, strong) UIView* topSellersView;
@property (nonatomic, strong) UIView* topBrandsView;
@property (nonatomic, strong) UIView* noticeView;
@property (assign, nonatomic) CGFloat scrollViewY;
@property (assign, nonatomic) CGFloat leftMargin;

@end

@implementation JAUndefinedSearchView

- (void)setupWithUndefinedSearchResult:(RIUndefinedSearchTerm *)searchResult
                            searchText:(NSString *)searchText
                           orientation:(UIInterfaceOrientation) myOrientation
{
    self.searchResult = searchResult;
    self.searchText = searchText;
    self.myOrientation = myOrientation;
    
    self.leftMargin = 6.0f;
    self.translatesAutoresizingMaskIntoConstraints = YES;
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        if(UIInterfaceOrientationIsLandscape(myOrientation)){
            self.leftMargin = 256.0f;
        }else
        {
            self.leftMargin = 126.0f;
        }
    }
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];
    
    CGFloat scrollViewY = 6.0f;
    
    /////// TOP VIEW ///////
    
    self.topView = [[UIView alloc] initWithFrame:CGRectMake(0.0, //horizontal margin is already included in this whole view
                                                            scrollViewY,
                                                            self.scrollView.frame.size.width,
                                                            10.0f)]; //starting height, will be recalculated
    self.topView.backgroundColor = [UIColor whiteColor];
    self.topView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:self.topView];
    
    UIImage* searchIcon = [UIImage imageNamed:@"img_nosearchresults"];
    self.searchIconImageView = [[UIImageView alloc] initWithImage:searchIcon];
    [self.searchIconImageView setFrame:CGRectMake((self.topView.frame.size.width - searchIcon.size.width) / 2,
                                                  20.0f,
                                                  searchIcon.size.width,
                                                  searchIcon.size.height)];
    [self.topView addSubview:self.searchIconImageView];
    
    self.labelNoResults = [[UILabel alloc] initWithFrame:CGRectMake(6.0f,
                                                                    CGRectGetMaxY(self.searchIconImageView.frame) + 20.0f,
                                                                    self.topView.bounds.size.width - 6.0f*2,
                                                                    10.0f)];
    self.labelNoResults.textAlignment = NSTextAlignmentCenter;
    self.labelNoResults.numberOfLines = -1;
    self.labelNoResults.font = [UIFont fontWithName:kFontLightName size:14.0f];
    self.labelNoResults.textColor = UIColorFromRGB(0x666666);
    
    NSString *text = searchResult.errorMessage;
    
    NSMutableAttributedString *stringText = [[NSMutableAttributedString alloc] initWithString:text];
    NSInteger stringTextLenght = text.length;
    
    UIFont *stringTextFont = [UIFont fontWithName:kFontLightName size:14.0f];
    UIFont *subStringTextFont = [UIFont fontWithName:kFontBoldName size:14.0f];
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
    [self.labelNoResults setFrame:CGRectMake(6.0f,
                                             CGRectGetMaxY(self.searchIconImageView.frame) + 20.0f,
                                             self.topView.bounds.size.width - 6.0f*2,
                                             self.labelNoResults.frame.size.height)];
    
    [self.topView addSubview:self.labelNoResults];
    
    self.separatorView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                  CGRectGetMaxY(self.labelNoResults.frame) + 10.0f,
                                                                  self.topView.frame.size.width,
                                                                  1)];
    self.separatorView.backgroundColor = UIColorFromRGB(0xcccccc);
    [self.topView addSubview:self.separatorView];
    
    CGFloat labelY = CGRectGetMaxY(self.separatorView.frame) + 15.0f;
    
    RISearchType *searchType = searchResult.searchType;
    if (searchType.title.length > 0) {
        self.searchTipsTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.leftMargin,
                                                                              labelY,
                                                                              self.topView.frame.size.width - 6.0f*2,
                                                                              10.0f)];
        self.searchTipsTitleLabel.numberOfLines = -1;
        self.searchTipsTitleLabel.textColor = UIColorFromRGB(0x666666);
        self.searchTipsTitleLabel.font = [UIFont fontWithName:kFontRegularName size:14.0f];
        self.searchTipsTitleLabel.text = searchType.title;
        [self.searchTipsTitleLabel sizeToFit];
        
        [self.topView addSubview:self.searchTipsTitleLabel];
        labelY = CGRectGetMaxY(self.searchTipsTitleLabel.frame);
    }
    
    self.searchTipsTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.leftMargin,
                                                                         labelY,
                                                                         self.topView.frame.size.width - self.leftMargin*2,
                                                                         10.0f)];
    self.searchTipsTextLabel.numberOfLines = -1;
    self.searchTipsTextLabel.textColor = UIColorFromRGB(0x666666);
    self.searchTipsTextLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    self.searchTipsTextLabel.text = searchType.text;
    [self.searchTipsTextLabel sizeToFit];
    
    [self.topView addSubview:self.searchTipsTextLabel];
    [self.topView setFrame:CGRectMake(self.topView.frame.origin.x,
                                      self.topView.frame.origin.y,
                                      self.topView.frame.size.width,
                                      CGRectGetMaxY(self.searchTipsTextLabel.frame) + 15.0f)];
    
    scrollViewY += self.topView.frame.size.height + 6.0f;
    
    /////// TOP SELLERS ///////
    RIFeaturedBox *featuredBox = searchResult.featuredBox;
    if (0 < featuredBox.products.count) {
        self.topSellersView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                       scrollViewY,
                                                                       self.scrollView.frame.size.width,
                                                                       137.f)];
        self.topSellersView.layer.cornerRadius = 5.0f;
        self.topSellersView.backgroundColor = [UIColor whiteColor];
        self.topSellersView.clipsToBounds = YES;
        [self.scrollView addSubview:self.topSellersView];
        
        UILabel* topSellersTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.topSellersView.bounds.origin.x + 6.0f,
                                                                             self.topSellersView.bounds.origin.y,
                                                                             self.topSellersView.bounds.size.width - 6.0f*2,
                                                                             26.0f)];
        topSellersTitle.text = STRING_TOP_SELLERS;
        topSellersTitle.font = [UIFont fontWithName:kFontRegularName size:11.0f];
        topSellersTitle.textColor = UIColorFromRGB(0x4e4e4e);
        [self.topSellersView addSubview:topSellersTitle];
        
        UIView* lineView = [[UIView alloc] initWithFrame:CGRectMake(self.topSellersView.bounds.origin.x,
                                                                    CGRectGetMaxY(topSellersTitle.frame),
                                                                    self.topSellersView.bounds.size.width,
                                                                    1.0f)];
        lineView.backgroundColor = UIColorFromRGB(0xfaa41a);
        [self.topSellersView addSubview:lineView];
        
        UIScrollView* productScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.topSellersView.bounds.origin.x,
                                                                                         CGRectGetMaxY(lineView.frame),
                                                                                         self.topSellersView.bounds.size.width,
                                                                                         self.topSellersView.bounds.size.height - lineView.frame.size.height - topSellersTitle.frame.size.height)];
        productScrollView.showsHorizontalScrollIndicator = NO;
        [self.topSellersView addSubview:productScrollView];
        
        CGFloat currentX = productScrollView.bounds.origin.x;
        
        NSMutableArray *convertedProd = [NSMutableArray arrayWithCapacity:featuredBox.products.count];
        
        NSEnumerator *enumeratorProd = [ featuredBox.products reverseObjectEnumerator];
        for (id element in enumeratorProd) {
            [convertedProd addObject:element];
        }
        
        NSArray *arrayToUse = featuredBox.products;
        
        if (RI_IS_RTL) {
            
            arrayToUse = convertedProd;
        }

#warning TODO THIS
        for (int i = 0; i < featuredBox.products.count; i++) {
            RISearchTypeProduct* product = [arrayToUse objectAtIndex:i];
            if (product.imagesArray.count > 0)
            {
                JAPDVSingleRelatedItem *singleItem = [[JAPDVSingleRelatedItem alloc]
                                                      initWithFrame:CGRectMake(currentX, 0, 110, productScrollView.height)];
                [singleItem setSearchTypeProduct:product];
                                [singleItem setX:currentX];
                singleItem.tag = i;
                [singleItem addTarget:self
                               action:@selector(productSelected:)
                     forControlEvents:UIControlEventTouchUpInside];
                
                [productScrollView addSubview:singleItem];
                
                currentX += 110.0f;
            }
        }
        [productScrollView setContentSize:CGSizeMake(currentX,
                                                     productScrollView.frame.size.height)];
        scrollViewY += self.topSellersView.frame.size.height + 6.0f;
    }
    
    /////// TOP BRANDS ///////
    RIFeaturedBrandBox *featuredBrandBox = searchResult.featuredBrandBox;
    if (0 < featuredBrandBox.brands.count) {
        self.topBrandsView = [[UIView alloc] initWithFrame:CGRectMake(0.0f,
                                                                      scrollViewY,
                                                                      self.scrollView.frame.size.width,
                                                                      137.f)];
        self.topBrandsView.layer.cornerRadius = 5.0f;
        self.topBrandsView.backgroundColor = [UIColor whiteColor];
        self.topBrandsView.clipsToBounds = YES;
        [self.scrollView addSubview:self.topBrandsView];
        
        UILabel* topBrandsTitle = [[UILabel alloc] initWithFrame:CGRectMake(self.topBrandsView.bounds.origin.x + 6.0f,
                                                                            self.topBrandsView.bounds.origin.y,
                                                                            self.topBrandsView.bounds.size.width - 6.0f*2,
                                                                            26.0f)];
        topBrandsTitle.text = STRING_TOP_BRANDS;
        topBrandsTitle.font = [UIFont fontWithName:kFontRegularName size:11.0f];
        topBrandsTitle.textColor = UIColorFromRGB(0x4e4e4e);
        [self.topBrandsView addSubview:topBrandsTitle];
        
        UIView* brandsLineView = [[UIView alloc] initWithFrame:CGRectMake(self.topBrandsView.bounds.origin.x,
                                                                          CGRectGetMaxY(topBrandsTitle.frame),
                                                                          self.topBrandsView.bounds.size.width,
                                                                          1.0f)];
        brandsLineView.backgroundColor = UIColorFromRGB(0xfaa41a);
        [self.topBrandsView addSubview:brandsLineView];
        
        UIScrollView* brandsScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(self.topBrandsView.bounds.origin.x,
                                                                                        CGRectGetMaxY(brandsLineView.frame),
                                                                                        self.topBrandsView.bounds.size.width,
                                                                                        self.topBrandsView.bounds.size.height - brandsLineView.frame.size.height - topBrandsTitle.frame.size.height)];
        brandsScrollView.showsHorizontalScrollIndicator = NO;
        [self.topBrandsView addSubview:brandsScrollView];
        
        CGFloat brandsCurrentX = brandsScrollView.bounds.origin.x;
        
        NSMutableArray *convertedBrands = [NSMutableArray arrayWithCapacity:featuredBrandBox.brands.count];
        
        NSEnumerator *enumerator = [featuredBrandBox.brands reverseObjectEnumerator];
        for (id element in enumerator) {
            [convertedBrands addObject:element];
        }
        
        NSArray *arrayToUse = featuredBrandBox.brands;
        
        if (RI_IS_RTL) {
        
            arrayToUse = convertedBrands;
        }
        
        for (int i = 0; i < featuredBrandBox.brands.count; i++) {
            RIBrand* brand = [arrayToUse objectAtIndex:i];
            if (brand.image.length > 0)
            {
                JABrandView *brandView = [[JABrandView alloc] initWithFrame:CGRectMake(brandsCurrentX, 0, 110, 110)];
                brandView.backgroundColor = [UIColor clearColor];
                brandView.brandUrl = brand.url;
                brandView.brandName = brand.name;
                
                UIImageView *brandImage = [[UIImageView alloc] initWithFrame:CGRectMake(30, 20, 50, 40)];
                
                if (brand.image.length > 0) {
                    [brandImage setImageWithURL:[NSURL URLWithString:brand.image]
                               placeholderImage:[UIImage imageNamed:@"placeholder_scrollable"]];
                } else {
                    [brandImage setImage:[UIImage imageNamed:@"placeholder_scrollable"]];
                }
                
                [brandView addSubview:brandImage];
                
                UILabel *brandLabel = [[UILabel alloc] initWithFrame:CGRectMake(3, 80, 104, 20)];
                brandLabel.textAlignment = NSTextAlignmentCenter;
                brandLabel.font = [UIFont fontWithName:kFontLightName
                                                  size:13.0f];
                brandLabel.textColor = UIColorFromRGB(0x666666);
                brandLabel.text = brand.name;
                
                [brandView addSubview:brandLabel];
                
                brandView.tag = i;
                [brandView addTarget:self
                              action:@selector(brandSelected:)
                    forControlEvents:UIControlEventTouchUpInside];
                
                [brandsScrollView addSubview:brandView];
                brandsCurrentX += 110.0f;
            }
        }
        
        [brandsScrollView setContentSize:CGSizeMake(brandsCurrentX,
                                                    brandsScrollView.frame.size.height)];
        
        scrollViewY += self.topBrandsView.frame.size.height + 6.0f;    
    }
    
    /////// NOTICE VIEW ///////
    
    self.noticeView = [[UIView alloc] initWithFrame:CGRectMake(0.0, //horizontal margin is already included in this whole view
                                                               scrollViewY,
                                                               self.scrollView.frame.size.width,
                                                               10.0f)]; //starting height, will be recalculated
    self.noticeView.backgroundColor = [UIColor whiteColor];
    self.noticeView.layer.cornerRadius = 5.0f;
    [self.scrollView addSubview:self.noticeView];
    
    UILabel* noticeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.leftMargin,
                                                                     15.0f,
                                                                     self.noticeView.bounds.size.width - self.leftMargin*2,
                                                                     10.0f)];
    noticeLabel.numberOfLines = -1;
    noticeLabel.textColor = UIColorFromRGB(0x666666);
    noticeLabel.font = [UIFont fontWithName:kFontLightName size:13.0f];
    noticeLabel.text = searchResult.noticeMessage;
    [noticeLabel sizeToFit];
    [self.noticeView addSubview:noticeLabel];
    
    [self.noticeView setFrame:CGRectMake(self.noticeView.frame.origin.x,
                                         self.noticeView.frame.origin.y,
                                         self.scrollView.frame.size.width,
                                         CGRectGetMaxY(noticeLabel.frame) + 15.0f)];
    
    scrollViewY += self.noticeView.frame.size.height + 6.0f;
    
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.frame.size.width,
                                               scrollViewY)];
    
    if (RI_IS_RTL) {
        [self flipAllSubviews];
    }
}
-(void)didRotate
{
    [self.scrollView removeFromSuperview];
    if(UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad){
        if(UIInterfaceOrientationIsLandscape(self.myOrientation)){
            self.leftMargin = 256.0f;
        }else
        {
            self.leftMargin = 126.0f;
    
        }
    }
    [self setupWithUndefinedSearchResult:self.searchResult searchText:self.searchText orientation:self.myOrientation];
}

#pragma mark - Delegate methods

- (void)productSelected:(UIControl *)sender
{
    RIFeaturedBox *featuredBox = self.searchResult.featuredBox;
    RISearchTypeProduct *item = [featuredBox.products objectAtIndex:sender.tag];
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(didSelectProduct:)])
    {
        [self.delegate didSelectProduct:item.targetString];
    }
}
- (void)brandSelected:(UIControl *)sender
{
    RIFeaturedBrandBox *featuredBrandBox = self.searchResult.featuredBrandBox;
    RIBrand* brand = [featuredBrandBox.brands objectAtIndex:sender.tag];
    
    if (NOTEMPTY(self.delegate) && [self.delegate respondsToSelector:@selector(didSelectBrand:brandName:)])
    {
        [self.delegate didSelectBrand:brand.url
                            brandName:brand.name];
    }
}

@end
