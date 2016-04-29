//
//  JAStepByStepTabViewController.h
//  Jumia
//
//  Created by Jose Mota on 28/04/16.
//  Copyright © 2016 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAStepByStepModel.h"

@interface JAStepByStepTabViewController : JABaseViewController

@property (nonatomic, strong) JAStepByStepModel *stepByStepModel;
@property (nonatomic) NSInteger indexInit;
@property (nonatomic) BOOL stackIsEmpty;

- (void)goToViewController:(UIViewController *)viewController;
- (void)sendBack;

@end
