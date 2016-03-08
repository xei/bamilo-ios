//
//  JAFont.h
//  Jumia
//
//  Created by Telmo Pinto on 17/03/15.
//  Copyright (c) 2015 Rocket Internet. All rights reserved.
//

#ifndef Jumia_JAFont_h
#define Jumia_JAFont_h

#define kFontRegularNameKey @"kFontRegularNameKey"
#define kFontLightNameKey @"kFontLightNameKey"
#define kFontBoldNameKey @"kFontBoldNameKey"
#define kFontMediumNameKey @"kFontMediumNameKey"

#define kFontRegularName [[NSUserDefaults standardUserDefaults] objectForKey:kFontRegularNameKey]
#define kFontLightName [[NSUserDefaults standardUserDefaults] objectForKey:kFontLightNameKey]
#define kFontBoldName [[NSUserDefaults standardUserDefaults] objectForKey:kFontBoldNameKey]
#define kFontMediumName [[NSUserDefaults standardUserDefaults] objectForKey:kFontMediumNameKey]

#define JADisplay1Font [UIFont fontWithName:kFontRegularName size:30]
#define JADisplay2Font [UIFont fontWithName:kFontRegularName size:20]
#define JADisplay3Font [UIFont fontWithName:kFontRegularName size:16]
#define JATitleFont [UIFont fontWithName:kFontMediumName size:14]
#define JAListFont [UIFont fontWithName:kFontRegularName size:14]
#define JAHEADLINEFont [UIFont fontWithName:kFontBoldName size:12]
#define JABodyFont [UIFont fontWithName:kFontRegularName size:12]
#define JACaptionFont [UIFont fontWithName:kFontRegularName size:10]
#define JABADGEFont [UIFont fontWithName:kFontMediumName size:10]
#define JABUTTONFont [UIFont fontWithName:kFontBoldName size:14]
#define JASystemTitleFont [UIFont fontWithName:kFontRegularName size:17]

#endif
