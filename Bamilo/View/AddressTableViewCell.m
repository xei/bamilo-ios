//
//  AddressTableViewCell.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/4/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "AddressTableViewCell.h"

@interface AddressTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkIconImageView;
@property (weak, nonatomic) IBOutlet UILabel *addressTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressPhoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressEditButton;
@end

@implementation AddressTableViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    
    //Address Title Label Setup
    [self.addressTitleLabel applyStyle:kFontBoldName fontSize:12 color:cEXTRA_DARK_GRAY_COLOR];
    
    //Address Label Setup
    [self.addressLabel applyStyle:kFontRegularName fontSize:12 color:cDARK_GRAY_COLOR];
    
    //Address Phone Label Setup
    [self.addressPhoneLabel applyStyle:kFontRegularName fontSize:12 color:cDARK_GRAY_COLOR];
    
    //Address Edit Button Setup
    [self.addressEditButton applyStyle:kFontRegularName fontSize:11 color:cLIGHT_GRAY_COLOR];
    self.addressEditButton.titleLabel.text = STRING_EDIT;
}

#pragma mark - Overrides
+(NSString *)nibName {
    return @"AddressTableViewCell";
}

-(void)updateWithModel:(NSManagedObject *)model {
    RIAddress *addressObj = (RIAddress *)model;

    //Address Title Setup
    if(addressObj.firstName && addressObj.lastName) {
        self.addressTitleLabel.text = [NSString stringWithFormat:@"%@ %@", addressObj.firstName, addressObj.lastName];
    } else if(addressObj.firstName) {
        self.addressTitleLabel.text = addressObj.firstName;
    } else if(addressObj.lastName) {
        self.addressTitleLabel.text = addressObj.lastName;
    }
    
    //Address Setup
    NSMutableString *addressText = [NSMutableString new];
    
    [addressText smartAppend:addressObj.address];
    [addressText smartAppend:addressObj.address2];
    [addressText smartAppend:addressObj.city];
    [addressText smartAppend:addressObj.postcode];
    
    self.addressLabel.text = addressText;
    
    //Phone Setup
    NSMutableString *phoneText = [NSMutableString stringWithFormat:@"%@:", STRING_PHONE];
    [phoneText smartAppend:addressObj.phone replacer:@"-"];
    
    self.addressPhoneLabel.text = phoneText;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    self.checkmarkIconImageView.image = selected ? [UIImage imageNamed:@"ArrowLeft"] : nil;
}

#pragma mark - IBActions
- (IBAction)addressEditButtonTapped:(id)sender {
}

@end
