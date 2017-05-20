//
//  controller.h
//  test1
//
//  Created by 西木 毅 on 11/12/09.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <sqlite3.h>

@interface Controller : NSWindowController
{
    
    IBOutlet id buttonExec;
    IBOutlet id buttonSQLClear;
    IBOutlet id buttonResultClear;
    
    IBOutlet id textSQLField;
    IBOutlet id textResultField;

    IBOutlet id window;

    sqlite3  *contactDB;
    NSString *docPath;
    NSString *databasePath;
    
    NSInteger commandPos;
    NSMutableArray  *commandHistory;
    NSString *currentCode;

    id odialog;
}

- (id)init;
- (void)setDatabasePath:(NSString*)dbpath;
- (NSString*)databasePath;

- (void)awakeFromNib;
- (NSInteger)countString:(NSString*)str;

- (void)dealloc;

- (void)execSQL:(NSString*)sql;

- (IBAction)onOpenSQLFile:(id)sender;
- (IBAction)onSaveResult:(id)sender;
- (IBAction)onPrint:(id)sender;

-(IBAction)onPreviousCommand:(id)sender;
-(IBAction)onForwardCommand:(id)sender;

- (IBAction)onExecButtonClicked:(id)sender;
- (IBAction)onClearSQLButtonClicked:(id)sender;
- (IBAction)onClearResultButtonClicked:(id)sender;

//データベースの読み込み
- (void)DBLoad;

//フォントサイズ
-(IBAction)onTextFontSizePlus:(id)sender;
-(IBAction)onTextFontSizeMinus:(id)sender;

//undo
-(IBAction)onUndo:(id)sender;


@end