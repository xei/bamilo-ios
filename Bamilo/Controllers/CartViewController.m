//
//  CartViewController.m
//  Bamilo
//
//  Created by Narbeh Mirzaei on 2/12/17.
//  Copyright © 2017 Rocket Internet. All rights reserved.
//

#import "CartViewController.h"
#import "DataManager.h"

@implementation CartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[DataManager sharedInstance] getUserCart:self completion:^(id data, NSError *error) {
        if(error == nil) {
            [self bind:data forRequestId:0];
        }
    }];
    
    if (self.firstLoading) {
        NSMutableDictionary* skusFromTeaserInCart = [[NSMutableDictionary alloc] initWithDictionary:[[NSUserDefaults standardUserDefaults] dictionaryForKey:kSkusFromTeaserInCartKey]];
        NSNumber *timeInMillis =  [NSNumber numberWithInt:(int)([self.startLoadingTime timeIntervalSinceNow]*-1000)];
        [[RITrackingWrapper sharedInstance] trackTimingInMillis:timeInMillis reference:self.screenName label:[NSString stringWithFormat:@"%@", [skusFromTeaserInCart allKeys]]];
        self.firstLoading = NO;
    }
}

#pragma mark - DataServiceProtocol
-(void)bind:(id)data forRequestId:(int)rid {
    RICart *cart = (RICart *)data;
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kUpdateCartNotification object:nil userInfo: @{kUpdateCartNotificationValue: cart}];
    self.cart = cart;
}

@end
