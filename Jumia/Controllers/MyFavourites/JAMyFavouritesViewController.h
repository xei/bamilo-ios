//
//  JAMyFavouritesViewController.h
//  Jumia
//
//  Created by Miguel Chaves on 30/Jul/14.
//  Copyright (c) 2014 Rocket Internet. All rights reserved.
//

#import "JABaseViewController.h"
#import "JAPicker.h"

@interface JAMyFavouritesViewController : JABaseViewController
<
UICollectionViewDataSource,
UICollectionViewDelegate,
JAPickerDelegate
>

@property (nonatomic, retain) NSString* A4SViewControllerAlias;

@end
