//
//  FormViewControl.h
//  Bamilo
//
//  Created by Ali saiedifar on 2/13/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FormItemModel.h"
#import "BaseViewController.h"
#import "ButtonTableViewCell.h"
#import "FormTableViewCell.h"

@protocol FormViewControlDelegate<NSObject>
- (void)submitBtnTapped;
- (void)viewNeedsToEndEditing;
@optional - (void)fieldHasBeenUpdatedByNewValidValue:(NSString *)value inFieldName:(NSString *)fieldname;
@end

@interface FormViewControl :NSObject <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, ButtonTableViewCellDelegate, InputTextFieldControlDelegate>

@property (nonatomic, weak) UITableView *tableView;
@property (nonatomic, copy) NSString *formMessage;
@property (nonatomic, copy) NSString *submitTitle;
@property (nonatomic, strong) NSMutableDictionary<NSString *,FormItemModel *> *formItemListModel;
@property (nonatomic, weak) id<FormViewControlDelegate> delegate;

- (void)setupTableView;
- (void)registerForKeyboardNotifications;
- (void)unregisterForKeyboardNotifications;
- (void)updateFieldName:(NSString *)name WithModel:(FormItemModel *)model;
- (void)showErrorMessgaeForField:(NSString *)fieldName errorMsg:(NSString *)string;
- (NSMutableDictionary *)getMutableDictionaryOfForm;
- (Boolean)isFormValid;
@end
