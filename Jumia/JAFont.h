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

#define JADisplay1Font [UIFont fontWithName:kFontRegularName size:23]
#define JADisplay2Font [UIFont fontWithName:kFontRegularName size:19]
#define JAListFont [UIFont fontWithName:kFontBoldName size:16]
#define JAList1Font [UIFont fontWithName:kFontMediumName size:16]
#define JAList2Font [UIFont fontWithName:kFontRegularName size:16]
#define JAButtonFont [UIFont fontWithName:kFontMediumName size:15]
#define JABody1Font [UIFont fontWithName:kFontBoldName size:13]
#define JABody2Font [UIFont fontWithName:kFontMediumName size:13]
#define JABody3Font [UIFont fontWithName:kFontRegularName size:13]
#define JACaptionFont [UIFont fontWithName:kFontRegularName size:11]
#define JACaption2Font [UIFont fontWithName:kFontBoldName size:11]

#endif
