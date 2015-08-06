//
//  SFIAppDelegate.h
//  Securifi Cloud
//
//  Created by Securifi on 21/11/12.
//  Copyright (c) 2012 Securifi. All rights reserved.
//

#import <UIKit/UIKit.h>

// This is the base class used by all branded apps, including Securifi's Almond. Subclasses override two methods, toolkitConfigurator and crashReporterApiKey
@interface SFIAppDelegate : UIResponder <UIApplicationDelegate>

@property(strong, nonatomic) UIWindow *window;

// Returns a Configurator to be used by the app to configure the toolkit; subclasses override to set up configurations for different branded app.
// By default, returns the configurator needed by the Almond app.
- (SecurifiConfigurator *)toolkitConfigurator;

// Returns the tracking ID to be used by the analytics engine; subclasses override to set up for different branded apps
- (NSString *)analyticsTrackingId;

// To work around build system problems keeping assets for each app separated, we follow a naming convention by
// prefixing certain assets, like splash images, that are loaded in code with this prefix id.
// Example: "Almond" prefix is used to resolve "Almond-splash_image" image assets.
- (NSString *)assetsPrefixId;

@end
