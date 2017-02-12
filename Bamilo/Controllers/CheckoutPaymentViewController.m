//
//  CheckoutPaymentViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 1/31/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CheckoutPaymentViewController.h"
#import "CheckoutProgressViewButtonModel.h"
#import "PlainTableViewHeaderCell.h"
#import "PaymentTypeTableViewCell.h"
#import "OnlinePaymentVariationTableViewCell.h"
#import "PaymentDescTableViewCell.h"

typedef NS_OPTIONS(NSUInteger, PaymentMethod) {
    PAYMENT_METHOD_ONLINE = 1 << 0,
    PAYMENT_METHOD_ON_DELIVERY = 1 << 1
};

@interface CheckoutPaymentViewController () <RadioButtonViewControlDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation CheckoutPaymentViewController {
@private
    NSMutableArray *_cellsIndexPaths;
    PaymentMethod _selectedPaymentMethod;
    NSInteger _indexForOnlineMethodVariation;
    NSArray *_onlinePaymentVariations;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //Header And Footer Cells
    [self.tableView registerNib:[UINib nibWithNibName:[PlainTableViewHeaderCell nibName] bundle:nil] forHeaderFooterViewReuseIdentifier:[PlainTableViewHeaderCell nibName]];
    
    //PaymentTypeTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentTypeTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentTypeTableViewCell nibName]];
    
    //OnlinePaymentVariationTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[OnlinePaymentVariationTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[OnlinePaymentVariationTableViewCell nibName]];
    
    //PaymentDescTableViewCell
    [self.tableView registerNib:[UINib nibWithNibName:[PaymentDescTableViewCell nibName] bundle:nil] forCellReuseIdentifier:[PaymentDescTableViewCell nibName]];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //TEMP
    OnlinePaymentVariationTableViewCellModel *saman = [OnlinePaymentVariationTableViewCellModel new];
    saman.imageName = @"SamanBankLogo";
    saman.isSelected = YES;
    
    OnlinePaymentVariationTableViewCellModel *parsian = [OnlinePaymentVariationTableViewCellModel new];
    parsian.imageName = @"ParsianBankLogo";
    parsian.isSelected = NO;
    
    _onlinePaymentVariations = @[saman, parsian];
    
    _cellsIndexPaths = [NSMutableArray arrayWithObjects:
    //Online Payment
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:0],
        [NSIndexPath indexPathForRow:1 inSection:0], nil],
    //Online Payment Variations
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:1],
        [NSIndexPath indexPathForRow:1 inSection:1], nil],
    //Pay On Delivery
    [NSMutableArray arrayWithObjects:
        [NSIndexPath indexPathForRow:0 inSection:2],
        /*[NSIndexPath indexPathForRow:1 inSection:2],*/ nil],
    nil];
    
    //Select Online Payment and Saman By Default
    _selectedPaymentMethod = PAYMENT_METHOD_ONLINE;
    _indexForOnlineMethodVariation = 0;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Overrides
-(void)updateNavBar {
    [super updateNavBar];
    
    self.navBarLayout.title = STRING_PAYMENT_OPTION;
}

#pragma mark - UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_cellsIndexPaths count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[_cellsIndexPaths objectAtIndex:section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *_cellIndexPath = [[_cellsIndexPaths objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
                    
    switch (_cellIndexPath.section) {
        case 0 : {
            switch (_cellIndexPath.row) {
                case 0: {
                    PaymentTypeTableViewCell *onlinePaymentTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
                    onlinePaymentTableViewCell.tag = PAYMENT_METHOD_ONLINE;
                    onlinePaymentTableViewCell.delegate = self;
                    
                    PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
                    model.title = STRING_ONLINE_PAYMENT;
                    model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ONLINE);
                    [onlinePaymentTableViewCell updateWithModel:model];
                    
                    return onlinePaymentTableViewCell;
                }
                    
                case 1: {
                    PaymentDescTableViewCell *onlinePaymentDescTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentDescTableViewCell nibName] forIndexPath:indexPath];
                    onlinePaymentDescTableViewCell.descLabel.text = @"پرداخت آنلاین، پردازش سفارش شما را تسریع داده و باعث می شود سفارش شما با اولویت بالاتری ارسال گردد.";
                    return onlinePaymentDescTableViewCell;
                }
            }
        }
            
        case 1: {
            OnlinePaymentVariationTableViewCell *onlinePaymentVariationCell = [tableView dequeueReusableCellWithIdentifier:[OnlinePaymentVariationTableViewCell nibName] forIndexPath:indexPath];
            onlinePaymentVariationCell.tag = indexPath.row;
            onlinePaymentVariationCell.delegate = self;
            
            OnlinePaymentVariationTableViewCellModel *model = [_onlinePaymentVariations objectAtIndex:indexPath.row];
            model.isSelected = (_indexForOnlineMethodVariation == indexPath.row);
            [onlinePaymentVariationCell updateWithModel:model];
            return onlinePaymentVariationCell;
        }
            
        case 2: {
            switch (_cellIndexPath.row) {
                case 0: {
                    PaymentTypeTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentTypeTableViewCell nibName] forIndexPath:indexPath];
                    payOnDeliveryTableViewCell.tag = PAYMENT_METHOD_ON_DELIVERY;
                    payOnDeliveryTableViewCell.delegate = self;
                    
                    PaymentTypeTableViewCellModel *model = [[PaymentTypeTableViewCellModel alloc] init];
                    model.title = STRING_PAY_ON_DELIVERY;
                    model.isSelected = (_selectedPaymentMethod == PAYMENT_METHOD_ON_DELIVERY);
                    [payOnDeliveryTableViewCell updateWithModel:model];
                    
                    return payOnDeliveryTableViewCell;
                }
                    
                case 1: {
                    PaymentDescTableViewCell *payOnDeliveryTableViewCell = [tableView dequeueReusableCellWithIdentifier:[PaymentDescTableViewCell nibName] forIndexPath:indexPath];
                    payOnDeliveryTableViewCell.descLabel.text = @"مبلغ سفارش را به صورت نقدی و با با کارت بانکی به پیک بامیلو پرداخت نمایید.";
                    return payOnDeliveryTableViewCell;
                }
            }
        }
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: return [PlainTableViewHeaderCell cellHeight];
    }
    
    return 0.0f;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0: {
            PlainTableViewHeaderCell *plainTableViewHeaderCell = [self.tableView dequeueReusableHeaderFooterViewWithIdentifier:[PlainTableViewHeaderCell nibName]];
            plainTableViewHeaderCell.title = STRING_PAYMENT_OPTION;
            return plainTableViewHeaderCell;
        }
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 1: return [OnlinePaymentVariationTableViewCell cellHeight];
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

#pragma mark - RadioButtonViewControlDelegate
-(void)didSelectRadioButton:(id)sender {
    if ([sender isKindOfClass:[PaymentTypeTableViewCell class]]) {
        PaymentTypeTableViewCell *radioButtonPaymentTypeTableViewCell = (PaymentTypeTableViewCell *)sender;
        _selectedPaymentMethod = (PaymentMethod)radioButtonPaymentTypeTableViewCell.tag;
        
        switch (_selectedPaymentMethod) {
            case PAYMENT_METHOD_ONLINE:
                [_cellsIndexPaths setObject:[NSMutableArray indexPathArrayOfLength:2 forSection:1] atIndexedSubscript:1];
                [[_cellsIndexPaths objectAtIndex:0] addObject:[NSIndexPath indexPathForRow:1 inSection:0]];
                [[_cellsIndexPaths objectAtIndex:2] removeObjectAtIndex:1];
            break;
                
            case PAYMENT_METHOD_ON_DELIVERY:
                [_cellsIndexPaths setObject:@[] atIndexedSubscript:1];
                [[_cellsIndexPaths objectAtIndex:0] removeObjectAtIndex:1];
                [[_cellsIndexPaths objectAtIndex:2] addObject:[NSIndexPath indexPathForRow:1 inSection:2]];
            break;
        }
        [self.tableView reloadData];
    } else if([sender isKindOfClass:[OnlinePaymentVariationTableViewCell class]]) {
        OnlinePaymentVariationTableViewCell *onlinePaymentVariationTableViewCell = (OnlinePaymentVariationTableViewCell *)sender;
        _indexForOnlineMethodVariation = onlinePaymentVariationTableViewCell.tag;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
    }
}

#pragma mark - CheckoutProgressViewDelegate
-(NSArray *)getButtonsForCheckoutProgressView {
    return @[
        [CheckoutProgressViewButtonModel buttonWith:1 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:2 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_DONE],
        [CheckoutProgressViewButtonModel buttonWith:3 state:CHECKOUT_PROGRESSVIEW_BUTTON_STATE_ACTIVE]
    ];
}

@end
