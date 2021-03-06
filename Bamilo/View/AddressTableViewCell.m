//
//  AddressTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressTableViewCell.h"
#import "IconButton.h"
#import "Address.h"

@interface AddressTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressPhoneLabel;
@property (weak, nonatomic) IBOutlet IconButton *addressEditButton;
@property (weak, nonatomic) IBOutlet IconButton *addressDeleteButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *checkmarkIconTrailingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteButtonWidthConstraint;
@end

@implementation AddressTableViewCell {
@private
    Address *_model;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //Address Title Label Setup
    [self.addressTitleLabel applyStyle:[Theme font:kFontVariationBold size:12.0f] color:[Theme color:kColorExtraDarkGray]];

    //Address Label Setup
    [self.addressLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorDarkGray]];
    
    //Address Phone Label Setup
    [self.addressPhoneLabel applyStyle:[Theme font:kFontVariationRegular size:12.0f] color:[Theme color:kColorDarkGray]];
    
    //Address Edit Button Setup
    [self.addressEditButton applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorLightGray]];
    self.addressEditButton.titleLabel.text = STRING_EDIT;
    
    //Address Remove Button Setup
    [self.addressDeleteButton applyStyle:[Theme font:kFontVariationRegular size:11.0f] color:[Theme color:kColorLightGray]];
    self.addressDeleteButton.titleLabel.text = STRING_REMOVE;
    
    [self setSeparatorInset:UIEdgeInsetsZero];
    
    [self updateAppearanceToInitialState];
}

-(void)setOptions:(AddressCellOptions)options {
    [self updateAppearanceToInitialState];
    
    if((options & ADDRESS_CELL_NONE) == ADDRESS_CELL_NONE) {
        return;
    }
    
    if((options & ADDRESS_CELL_EDIT) == ADDRESS_CELL_EDIT) {
        self.addressEditButton.hidden = NO;
    }
    
    if((options & ADDRESS_CELL_DELETE) == ADDRESS_CELL_DELETE) {
        self.deleteButtonWidthConstraint.constant = 45;
        self.addressDeleteButton.hidden = NO;
    }
    
    if((options & ADDRESS_CELL_SELECT) == ADDRESS_CELL_SELECT) {
        self.checkmarkIconTrailingConstraint.constant = 10;
        //self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
}

#pragma mark - Overrides
+(CGFloat)cellHeight {
    return 160.0f;
}

+(NSString *)nibName {
    return @"AddressTableViewCell";
}

-(void)updateWithModel:(id)model {
    Address *addressObj = (Address *)model;
    
    //Address Title Setup
    NSMutableString *addressTitleText = [NSMutableString new];
    
    [addressTitleText smartAppend:addressObj.firstName];
    [addressTitleText smartAppend:addressObj.lastName];
    
    self.addressTitleLabel.text = [addressTitleText numbersToPersian];
    
    //Address Setup
    NSMutableString *addressText = [NSMutableString new];
    
    [addressText smartAppend:addressObj.address];
    [addressText smartAppend:addressObj.address1];
    
    self.addressLabel.text = [addressText numbersToPersian];
    
    //Phone Setup
    NSMutableString *phoneText = [NSMutableString stringWithFormat:@"%@:", STRING_PHONE];
    [phoneText smartAppend:[addressObj.phone numbersToPersian] replacer:@"-"];
    
    self.addressPhoneLabel.text = phoneText;
    self.checkmarkIconImageView.image = addressObj.isDefaultShipping ? [UIImage imageNamed:@"BlueTick"] : nil;
    _model = model;
}

#pragma mark - IBActions
- (IBAction)addressEditButtonTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(addressEditButtonTapped:)]) {
        [self.delegate addressEditButtonTapped:_model];
    }
}

- (IBAction)addressDeleteButtonTapped:(id)sender {
    if([self.delegate respondsToSelector:@selector(addressDeleteButtonTapped:)]) {
        [self.delegate addressDeleteButtonTapped:_model];
    }
}

#pragma mark - Helpers
-(void) updateAppearanceToInitialState {
    self.checkmarkIconTrailingConstraint.constant = -1 * self.checkmarkIconImageView.frame.size.width;
    self.addressEditButton.hidden = YES;
    self.addressDeleteButton.hidden = YES;
    self.deleteButtonWidthConstraint.constant = 0;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

@end
