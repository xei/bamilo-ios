//
//  EmptyViewController.h
//  Bamilo
//
//  Created by Ali Saeedifar on 4/18/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"

@interface EmptyViewController : UIViewController

@property (nonatomic, copy) NSString *recommendationLogic;

- (void)getSuggestions;
- (void)updateTitle:(NSString *)title;
- (void)updateImage:(UIImage *)image;

@end
