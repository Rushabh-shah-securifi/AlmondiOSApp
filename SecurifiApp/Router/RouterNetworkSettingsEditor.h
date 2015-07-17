//
// Created by Matthew Sinclair-Day on 7/16/15.
// Copyright (c) 2015 Securifi Ltd. All rights reserved.
//

@class RouterNetworkSettingsEditor;

@protocol RouterNetworkSettingsEditorDelegate
- (void)networkSettingsEditorDidChangeSettings:(RouterNetworkSettingsEditor *)editor settings:(SFIAlmondLocalNetworkSettings *)newSettings;
- (void)networkSettingsEditorDidCancel:(RouterNetworkSettingsEditor *)editor;
@end


@interface RouterNetworkSettingsEditor : UITableViewController

@property(nonatomic, weak) id <RouterNetworkSettingsEditorDelegate> delegate;
@property(nonatomic, copy) SFIAlmondLocalNetworkSettings *settings;

@end