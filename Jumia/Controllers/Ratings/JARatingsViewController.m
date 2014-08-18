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

@end

@implementation JARatingsViewController

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kShowBackNofication
                                                        object:nil];
    
    self.brandLabel.text = self.productBrand;
    self.nameLabel.text = self.productRatings.productName;
    
    if ([self.productNewPrice floatValue] > 0.0)
    {
        NSMutableAttributedString *stringOldPrice = [[NSMutableAttributedString alloc] initWithString:[self.productOldPrice stringValue]];
        NSInteger stringOldPriceLenght = [self.productOldPrice stringValue].length;
        UIFont *stringOldPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringOldPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:204.0/255.0
                                                        blue:204.0/255.0
                                                       alpha:1.0f];
        
        [stringOldPrice addAttribute:NSFontAttributeName
                               value:stringOldPriceFont
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrokeColorAttributeName
                               value:stringOldPriceColor
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        [stringOldPrice addAttribute:NSStrikethroughStyleAttributeName
                               value:@(1)
                               range:NSMakeRange(0, stringOldPriceLenght)];
        
        self.oldPriceLabel.attributedText = stringOldPrice;
        
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:[self.productNewPrice stringValue]];
        NSInteger stringNewPriceLenght = [self.productNewPrice stringValue].length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.labelNewPrice.attributedText = stringNewPrice;
        
        [self.labelNewPrice sizeToFit];
        [self.oldPriceLabel sizeToFit];
        [self.topView layoutSubviews];
    }
    else
    {
        NSMutableAttributedString *stringNewPrice = [[NSMutableAttributedString alloc] initWithString:[self.productOldPrice stringValue]];
        NSInteger stringNewPriceLenght = [self.productOldPrice stringValue].length;
        UIFont *stringNewPriceFont = [UIFont fontWithName:@"HelveticaNeue-Light"
                                                     size:14.0];
        UIColor *stringNewPriceColor = [UIColor colorWithRed:204.0/255.0
                                                       green:0.0/255.0
                                                        blue:0.0/255.0
                                                       alpha:1.0f];
        
        [stringNewPrice addAttribute:NSFontAttributeName
                               value:stringNewPriceFont
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        [stringNewPrice addAttribute:NSStrokeColorAttributeName
                               value:stringNewPriceColor
                               range:NSMakeRange(0, stringNewPriceLenght)];
        
        self.labelNewPrice.attributedText = stringNewPrice;
        
        [self.oldPriceLabel removeFromSuperview];
        [self.labelNewPrice sizeToFit];
        [self.topView layoutSubviews];
    }
    
    self.reviewsNumber.text = [NSString stringWithFormat:@"%@ Reviews", self.productRatings.commentsCount];
    
    NSInteger media = 0;
    
    for (RIRatingComment *rating in self.productRatings.comments) {
        media += [rating.avgRating integerValue];
    }
    
    if (media > 0) {
        media = (media / self.productRatings.comments.count);
        
        [self setNumberOfStars:media];
    }
    
    self.resumeView.layer.cornerRadius = 4.0f;
    self.writeReviewButton.layer.borderWidth = 1.0f;
    self.writeReviewButton.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.writeReviewButton.layer.cornerRadius = 4.0f;
    
    [self.writeReviewButton setTitle:@"Write a Review"
                            forState:UIControlStateNormal];
    
    self.labelUsedProduct.text = @"You have used this Product? Rate it now!";
    
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
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JAReviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reviewCell"];
    
    cell.labelPrice.text = @"Price";
    cell.labelAppearance.text = @"Appearance";
    cell.labelQuality.text = @"Quality";
    
    RIRatingComment *comment = [self.productRatings.comments objectAtIndex:indexPath.row];
    
    cell.labelTitle.text = comment.title;
    cell.labelDescription.text = comment.detail;
    
    for (RIRatingOption *option in comment.options) {
        if ([option.typeTitle isEqualToString:@"Price"]) {
            [cell setPriceRating:[option.optionValue integerValue]];
        } else if ([option.typeTitle isEqualToString:@"Appearance"]) {
            [cell setAppearanceRating:[option.optionValue integerValue]];
        } else if ([option.typeTitle isEqualToString:@"Quality"]) {
            [cell setQualityRating:[option.optionValue integerValue]];
        }
    }
    
    NSString *string;
    
    if (comment.nickname.length > 0) {
        string = [NSString stringWithFormat:@"posted by %@, %@", comment.nickname, comment.createdAt];
    } else {
        string = [NSString stringWithFormat:@"posted by Anonimous User, %@", comment.createdAt];
    }
    
    cell.labelAuthorDate.text = string;
    
    return cell;
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
