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

// Returns the API key used for configuring the crash reporter; subclasses override to set up for different branded apps
// By default, returns the key needed by the Almond app.
- (NSString *)crashReporterApiKey;

@end
