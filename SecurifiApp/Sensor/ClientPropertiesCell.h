//
//  ClientPropertiesCell.h
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 02/03/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClientPropertiesCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *displayLabel;
@property (weak, nonatomic) IBOutlet UILabel *vsluesLabel;
@property (nonatomic) NSString *indexName;
@end
