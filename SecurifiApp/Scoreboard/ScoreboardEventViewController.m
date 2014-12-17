//
//  ScoreboardEventViewController.m
//  Almond
//
//  Created by Matthew Sinclair-Day on 10/29/14.
//  Copyright (c) 2014 Securifi Ltd. All rights reserved.
//

#import "ScoreboardEventViewController.h"

@implementation ScoreboardEventViewController

- (id<ScoreboardEvent>)tryGetEvent:(NSInteger)row {
    if (row >= self.events.count) {
        return nil;
    }
    return self.events[(NSUInteger) row];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cell_id = @"field";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cell_id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cell_id];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [cell.textLabel.font fontWithSize:12];
    }
    
    id<ScoreboardEvent> event = [self tryGetEvent:indexPath.row];
    cell.textLabel.text = [event label];

    return cell;
}

@end
