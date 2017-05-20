//
//  SQLWindow.h
//  test1
//
//  Created by 西木 毅 on 11/12/09.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <AppKit/AppKit.h>
#import <Cocoa/Cocoa.h>

#import <sqlite3.h>

@interface SQLWindow : NSWindow {
    sqlite3  *contactDB;
    NSString *databasePath;
}

-(id)init;

@end
