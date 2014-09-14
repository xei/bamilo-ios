//
//  JARatingsViewController.m
//  Jumia
//
//  Created by Miguel Chaves on 06/Aug/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JARatingsViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "JAReviewCell.h"
#import "JANewRatingViewController.h"
#import "JAPriceView.h"

@interface JARatingsViewController ()
<
    UITableViewDelegate,
    UITableViewDataSource
>

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *brandLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *oldPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *labelNewPrice;
@property (weak, nonatomic) IBOutlet UIView *resumeView;
@property (weak, nonatomic) IBOutlet UIImageView *star1;
@property (weak, nonatomic) IBOutlet UIImageView *star2;
@property (weak, nonatomic) IBOutlet UIImageView *star3;
@property (weak, nonatomic) IBOutlet UIImageView *star4;
@property (weak, nonatomic) IBOutlet UIImageView *star5;
@property (weak, nonatomic) IBOutlet UILabel *reviewsNumber;
@property (weak, nonatomic) IBOutlet UILabel *labelUsedProduct;
@property (weak, nonatomic) IBOutlet UIButton *writeReviewButton;
@property (weak, nonatomic) IBOutlet UITableView *tableViewComments;
@property (nonatomic, strong) JAPriceView *priceView;

@end

@implementation JARatingsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navBarLayout.showBackButton = YES;
    self.navBarLayout.showLogo = NO;
    
    self.brandLabel.text = self.productBrand;
    self.nameLabel.text = self.productRatings.productName;
    
    [self.oldPriceLabel removeFromSuperview];
    [self.labelNewPrice removeFromSuperview];
    
    self.priceView = [[JAPriceView alloc] init];
    [self.priceView loadWithPrice:self.productOldPrice
                     specialPrice:self.productNewPrice
                         fontSize:14.0f
            specialPriceOnTheLeft:NO];
    self.priceView.frame = CGRectMake(12.0f,
                                      68.0f,
                                      self.priceView.frame.size.width,
                                      self.priceView.frame.size.height);
    [self.view addSubview:self.priceView];
    
    self.reviewsNumber.text = [NSString stringWithFormat:STRING_REVIEWS, self.productRatings.commentsCount];
    
    NSInteger media = 0;
    
    for (RIRatingComment *rating in self.productRatings.comments) {
        media += [rating.avgRating integerValue];
    }
    
    if (media > 0) {
        media = (media / self.productRatings.comments.count);
        
        [self setNumberOfStars:media];
    }
    
    self.resumeView.layer.cornerRadius = 4.0f;
    
    [self.writeReviewButton setTitle:STRING_WRITE_REVIEW
                            forState:UIControlStateNormal];
    [self.writeReviewButton setTitleColor:UIColorFromRGB(0x4e4e4e)
                                 forState:UIControlStateNormal];
    
    self.labelUsedProduct.text = STRING_RATE_PRODUCT;
    
    self.tableViewComments.layer.cornerRadius = 4.0f;
    self.tableViewComments.allowsSelection = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showNewRating"]) {
        [segue.destinationViewController setRatingProductSku:self.productRatings.productSku];
        [segue.destinationViewController setRatingProductBrand:self.productBrand];
        [segue.destinationViewController setRatingProductNameForLabel:self.productRatings.productName];
        [segue.destinationViewController setRatingProductNewPriceForLabel:self.productNewPrice];
        [segue.destinationViewController setRatingProductOldPriceForLabel:self.productOldPrice];
    }
}

#pragma mark - Action

- (IBAction)goToNewReviews:(id)sender
{
    [self performSegueWithIdentifier:@"showNewRating"
                              sender:nil];
}

#pragma mark - Tableview methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.productRatings.comments.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self heightForBasicCellAtIndexPath:indexPath];
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath
{
    static JAReviewCell *cell = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableViewComments dequeueReusableCellWithIdentifier:@"reviewCell"];
    });
    
    RIRatingComment *comment = [self.productRatings.comments objectAtIndex:indexPath.row];
    cell.labelDescription.text = comment.detail;
    
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell
{
    [sizingCell setNeedsLayout];
    [sizingCell layoutSubviews];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    
    cell.labelPrice.text = STRING_PRICE;
    cell.labelAppearance.text = STRING_APPEARENCE;
    cell.labelQuality.text = STRING_QUANTITY;
    
    RIRatingComment *comment = [self.productRatings.comments objectAtIndex:indexPath.row];
    
    cell.labelTitle.text = comment.title;
    cell.labelDescription.text = comment.detail;

    NSInteger count = comment.options.count;
    
    if (count == 1) {
        [cell.viewAppearance removeFromSuperview];
        [cell.viewQuality removeFromSuperview];
    } else if (2 == count) {
        [cell.viewQuality removeFromSuperview];
    }
    
    for (int i = 0 ; i < count ; i++)
    {
        RIRatingOption *option = comment.options[i];
        
        if (i == 0)
        {
            [cell setPriceRating:[option.optionValue integerValue]];
            cell.labelPrice.text = option.title;
        }
        else if (i == 1)
        {
            [cell setAppearanceRating:[option.optionValue integerValue]];
            cell.labelAppearance.text = option.title;
        }
        else if (i == 2)
        {
            [cell setQualityRating:[option.optionValue integerValue]];
            cell.labelQuality.text = option.title;
        }
    }
    
    NSString *string;
    
    if (comment.nickname.length > 0) {
        string = [NSString stringWithFormat:STRING_POSTED_BY, comment.nickname, comment.createdAt];
    } else {
        string = [NSString stringWithFormat:STRING_POSTED_BY_ANONYMOUS, comment.createdAt];
    }
    
    cell.labelAuthorDate.text = string;
    
    [cell layoutSubviews];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Number of stars

- (void)setNumberOfStars:(NSInteger)stars
{
    switch (stars) {
        case 0: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 1: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 2: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 3: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 4: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
            
        case 5: {
            
            self.star1.image = [self getFilledStar];
            self.star2.image = [self getFilledStar];
            self.star3.image = [self getFilledStar];
            self.star4.image = [self getFilledStar];
            self.star5.image = [self getFilledStar];
            
        }
            break;
            
        default: {
            
            self.star1.image = [self getEmptyStar];
            self.star2.image = [self getEmptyStar];
            self.star3.image = [self getEmptyStar];
            self.star4.image = [self getEmptyStar];
            self.star5.image = [self getEmptyStar];
            
        }
            break;
    }
}

- (UIImage *)getEmptyStar
{
    return [UIImage imageNamed:@"img_rating_star_big_empty"];
}

- (UIImage *)getFilledStar
{
    return [UIImage imageNamed:@"img_rating_star_big_full"];
}

@end
