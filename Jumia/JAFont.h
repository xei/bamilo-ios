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

#endif
