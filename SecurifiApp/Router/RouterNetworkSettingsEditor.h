//
// Created by Matthew Sinclair-Day on 7/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

@class RouterNetworkSettingsEditor;
@class SFIAlmondPlus;

typedef NS_ENUM(unsigned int, RouterNetworkSettingsEditorMode) {
    RouterNetworkSettingsEditorMode_editor, // for when almond is already linked
    RouterNetworkSettingsEditorMode_link,   // for initial linking when called from SFICloudLinkViewController
};

@protocol RouterNetworkSettingsEditorDelegate

- (void)networkSettingsEditorDidLinkAlmond:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings;

- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings;

- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor;

- (void)networkSettingsEditorDidComplete:(RouterNetworkSettingsEditor *)editor;

- (void)networkSettingsEditorDidUnlinkAlmond:(RouterNetworkSettingsEditor *)editor;

@end

@interface RouterNetworkSettingsEditor : UITableViewController

@property(nonatomic) enum RouterNetworkSettingsEditorMode mode;
@property(nonatomic, weak) id <RouterNetworkSettingsEditorDelegate> delegate;
@property(nonatomic, copy) SFIAlmondLocalNetworkSettings *settings;
@property(nonatomic) BOOL enableUnlinkActionButton;
@property(nonatomic) BOOL makeLinkedAlmondCurrentOne;
@property(nonatomic) BOOL fromLoginPage;

@end
