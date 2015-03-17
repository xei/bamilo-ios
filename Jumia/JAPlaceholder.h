//
//  JAPlaceholder.h
//  Jumia
//
//  Created by epacheco on 17/03/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#ifndef Jumia_JAPlaceholder_h
#define Jumia_JAPlaceholder_h

#define kPlaceholderGridNameKey @"kPlaceholderGridNameKey"
#define kPlaceholderListNameKey @"kPlaceholderListNameKey"
#define kPlaceholderPDVNameKey @"kPlaceholderPDVNameKey"
#define kPlaceholderGalleryNameKey @"kPlaceholderGalleryNameKey"
#define kPlaceholderScrollableNameKey @"kPlaceholderScrollableNameKey"
#define kPlaceholderVariationsNameKey @"kPlaceholderVariationsNameKey"

#define kPlaceholderGridName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderGridNameKey]
#define kPlaceholderListName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderListNameKey]
#define kPlaceholderPDVName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderPDVNameKey]
#define kPlaceholderGalleryName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderGalleryNameKey]
#define kPlaceholderScrollableName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderScrollableNameKey]
#define kPlaceholderVariationsName [[NSUserDefaults standardUserDefaults] objectForKey:kPlaceholderVariationsNameKey]

#endif
