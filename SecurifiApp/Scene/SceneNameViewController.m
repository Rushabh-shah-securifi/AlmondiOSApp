//
//  SceneNameViewController.m
//  SecurifiApp
//
//  Created by Securifi-Mac2 on 29/02/16.
//  Copyright © 2016 Securifi Ltd. All rights reserved.
//

#import "SceneNameViewController.h"
#import "UIFont+Securifi.h"

@interface SceneNameViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (strong, nonatomic) IBOutlet UITableView *suggestionTable;
@property (weak, nonatomic) IBOutlet UITextField *sceneNameField;
@property(nonatomic)NSArray *nameList;
@property(nonatomic)NSMutableArray *filteredList;
@end

@implementation SceneNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _filteredList = [NSMutableArray new];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"scene_names" ofType:@"txt"];
    NSString *content = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"filecontentes: %@", content);
    self.nameList = @[@"scene",@"modal",@"light scene",@"main scene",@"door scene",@"home scene",@"hall scene",@"awake scene"];
    // Do any additional setup after loading the view.
    [self.sceneNameField addTarget:self
                  action:@selector(editingChanged:)
        forControlEvents:UIControlEventEditingChanged];
    self.sceneNameField.delegate = self;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.filteredList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"cellForRowAtIndexPath");
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuseIdentifier" forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"reuseIdentifier"];
    }
    cell.textLabel.font = [UIFont securifiFont:13];
    cell.textLabel.text = [self.filteredList objectAtIndex:indexPath.row];
    return cell;

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 30;
}
- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"%@", indexPath);
    //NSLog(@"%@", cell.textLabel.text);
    self.sceneNameField.text = [self.filteredList objectAtIndex:indexPath.row];
}


-(void)editingChanged:(id)sender{
    NSLog(@"editingChanged");
    [self.filteredList removeAllObjects];
    UITextField *textfield = sender;
    NSString *newString = textfield.text;
    NSLog(@"new string: %@", newString);
    for(NSString *sceneName in self.nameList){
        if([sceneName containsString:newString]){
            [self.filteredList addObject:sceneName];
        }
    }
    [self.suggestionTable reloadData];
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"textFieldDidEndEditing");
    [textField resignFirstResponder];
}
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    NSLog(@"textFieldShouldEndEditing");
    textField.backgroundColor = [UIColor whiteColor];
    return YES;
}
- (BOOL)textFieldShouldClear:(UITextField *)textField{
    NSLog(@"textFieldShouldClear:");
    return YES;
}
@end
