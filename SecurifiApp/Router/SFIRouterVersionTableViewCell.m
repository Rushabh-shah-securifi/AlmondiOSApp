//
// Created by Matthew Sinclair-Day on 6/8/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

#import "SFIRouterVersionTableViewCell.h"
#import "SFICardView.h"
#import "SFIColors.h"


@interface SFIRouterVersionTableViewCell ()
@property(nonatomic) BOOL layoutCalled;
@end

@implementation SFIRouterVersionTableViewCell

#pragma mark - Layout

- (void)markReuse {
    [super markReuse];
    self.layoutCalled = NO;
}

- (void)setNewAlmondFirmwareVersionAvailable:(BOOL)available {
    _newAlmondFirmwareVersionAvailable = available;

    if (available) {
        self.titleButtonLabel = @"Update Now";
        self.titleButtonTarget = self;
        self.titleButtonSelector = @selector(onUpdateFirmware);
    }
    else {
        self.titleButtonLabel = @"Update Now";
        self.titleButtonTarget = self;
        self.titleButtonSelector = @selector(onUpdateFirmware);
//        self.titleButtonLabel = nil;
//        self.titleButtonTarget = nil;
//        self.titleButtonSelector = nil;
    }
}


- (void)layoutSubviews {
    if (self.layoutCalled) {
        return;
    }
    self.layoutCalled = YES;

    SFICardView *cardView = self.cardView;
    if (cardView.layoutFrozen) {
        return;
    }

    cardView.backgroundColor = [[SFIColors redColor] color];

    self.title = @"Software Version";
    self.summaries = [self summaryInfo];

    [super layoutSubviews];
}

- (NSArray *)summaryInfo {
    const BOOL newVersionAvailable = self.newAlmondFirmwareVersionAvailable;
    NSString *version = self.firmwareVersion;

    if (version) {
        NSString *currentVersion_label = NSLocalizedString(@"router.software-version.Current version", @"Current version");

        if (newVersionAvailable) {
            NSString *updateAvailable_label = NSLocalizedString(@"router.software-version.Update Available", @"Update Available");
            return @[updateAvailable_label, currentVersion_label, version];
        }
        else {
            return @[currentVersion_label, version];
        }
    }
    else {
        return @[NSLocalizedString(@"router.software-version.Not available", @"Version information is not available.")];
    }
}

#pragma mark - Action callbacks

- (void)onUpdateFirmware {

}

@end