//
//  JACatalogViewController.h
//  Jumia
//
//  Created by Telmo Pinto on 05/08/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAPickerScrollView.h"
#import "RICategory.h"

@interface JACatalogViewController : JABaseViewController <JAPickerScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong)RICategory* category;

@end
