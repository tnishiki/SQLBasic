//
//  AppController.h
//  test1
//
//  Created by 西木 毅 on 11/12/10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//
#import "Controller.h"

@interface AppController : NSObjectController {

    NSMutableArray *dbManager;

    id odialog;
}


- (id)init;
- (void)awakeFromNib;
- (IBAction)newDocument:(id)sender;
- (IBAction)openDocument:(id)sender;
- (IBAction)close:(id)sender;


@end
