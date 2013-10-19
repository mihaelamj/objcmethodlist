//
//  CMListViewController.m
//  ClassMethodList
//
//  Created by Mihaela Mihaljević Jakić on 10/19/13.
//  Copyright (c) 2013 Token d.o.o. All rights reserved.
//

#import "CMListViewController.h"
#import <objc/runtime.h>

@interface CMListViewController ()<UITableViewDataSource>
@property(strong, nonatomic) UIButton *listClassMethodsButton;
@property(strong, nonatomic) UIButton *listInstanceMethodsButton;
@property(nonatomic, strong) UITableView *tableView;
@property(strong, nonatomic) NSMutableArray *methodList;
@property(strong, nonatomic) UITextField *classNameField;
@end

@implementation CMListViewController

#define METHOD_CELL_ID @"method_cell"
#define CONTROL_OFFSET 20

#pragma mark - Loading

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //add textField for view
    [self.view addSubview:self.classNameField];
	
    //add buttons to view
    [self.view addSubview:self.listClassMethodsButton];
    [self.view addSubview:self.listInstanceMethodsButton];
    
    //add tableView to view
    [self.view addSubview:self.tableView];
}

#pragma mark - Helpers

- (void)clearTableView
{
    self.methodList = nil;
    [self.tableView reloadData];
}

#pragma  mark - Target actions

- (void)getClassOrInstanceMethods:(BOOL)isClass
{
    const char *ccName = [self.classNameField.text UTF8String];
    int unsigned numMethods;
    id classDefinition = nil;
    
    // inspect class or metaclass
    if (isClass)
        classDefinition = objc_getMetaClass(ccName);
    else
        classDefinition = objc_getClass(ccName);
    
    Method *methods = class_copyMethodList(classDefinition, &numMethods);
    for (int i = 0; i < numMethods; i++) {
        NSString *methodName = NSStringFromSelector(method_getName(methods[i]));
        [self.methodList addObject:methodName];
    }
}

- (void)listClassInstanceMethodsAction:(id)sender
{
    //dismiss keyboard
    [self.view endEditing:YES];
    
    //clear data
    [self clearTableView];
    
    //load appropriate method list into array
    if (sender == self.listClassMethodsButton) {
        NSLog(@"class button clicked");
        [self getClassOrInstanceMethods:YES];
    } else if (sender == self.listInstanceMethodsButton) {
        NSLog(@"instance button clicked");
        [self getClassOrInstanceMethods:NO];
    }
    
    //reload tableView
    [self.tableView reloadData];
}


#pragma mark - Properties

- (NSMutableArray *)methodList
{
    if (!_methodList) {
        _methodList = [[NSMutableArray alloc] init];
    }
    return _methodList;
}

- (UITextField *)classNameField
{
    if (!_classNameField) {
        CGRect tfFrame = CGRectMake(CONTROL_OFFSET, CONTROL_OFFSET, self.view.frame.size.width - CONTROL_OFFSET*2, CONTROL_OFFSET);
        _classNameField = [[UITextField alloc] initWithFrame:tfFrame];
        _classNameField.placeholder = @"Class name";
    }
    return _classNameField;
}

- (UIButton *)listClassMethodsButton
{
    if (!_listClassMethodsButton) {
        //create button with target action
        CGRect methodListButtonFrame = CGRectMake(CONTROL_OFFSET, CONTROL_OFFSET*3, self.view.frame.size.width - CONTROL_OFFSET*2, CONTROL_OFFSET);
        _listClassMethodsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _listClassMethodsButton.frame = methodListButtonFrame;
        _listClassMethodsButton.titleLabel.text = @"Find class methods";
        [_listClassMethodsButton setTitle:@"Find class methods" forState:UIControlStateNormal];
        [_listClassMethodsButton addTarget:self action:@selector(listClassInstanceMethodsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listClassMethodsButton;
}

- (UIButton *)listInstanceMethodsButton
{
    if (!_listInstanceMethodsButton) {
        //create button with target action
        CGRect methodListButtonFrame = CGRectMake(CONTROL_OFFSET, CONTROL_OFFSET*5, self.view.frame.size.width - CONTROL_OFFSET*2, CONTROL_OFFSET);
        _listInstanceMethodsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        _listInstanceMethodsButton.frame = methodListButtonFrame;
        _listInstanceMethodsButton.titleLabel.text = @"Find instance methods";
        [_listInstanceMethodsButton setTitle:@"Find instance methods" forState:UIControlStateNormal];
        [_listInstanceMethodsButton addTarget:self action:@selector(listClassInstanceMethodsAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listInstanceMethodsButton;
}

- (UITableView *)tableView
{
    if (!_tableView) {
        CGRect tableViewFrame = CGRectMake(0.0, CONTROL_OFFSET*7, self.view.frame.size.width, self.view.frame.size.height-CONTROL_OFFSET*2);
        _tableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStylePlain];
        _tableView.dataSource = (id)self;
        _tableView.rowHeight = 44;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:METHOD_CELL_ID];
    }
    return _tableView;
}

#pragma TableView Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.methodList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //get cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:METHOD_CELL_ID];
    
    //set method name as text
    NSString *methodName = [self.methodList objectAtIndex:indexPath.row];
    cell.textLabel.text = methodName;
    return cell;
}


@end
