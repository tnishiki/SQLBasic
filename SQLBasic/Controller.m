/*
 コントローラプログラム
 
 このファイルにメインのコードが記載されている。
 */
#import "Controller.h"
#import "SQLWindow.h"

@implementation Controller

/*-----------------------------------------------------------------
 初期化
 -----------------------------------------------------------------*/

-(id)init{
    //スーパクラスの初期化
    self=[super init];
    
    if(self){
        //NSLog(@"controller init");
    }
    

    //デフォルトDBファイルパスの設定
    {
        //ユーザのドキュメントパス群を取得
        NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                NSUserDomainMask,
                                                                YES);
        //書類のパスを取得
        docPath = [dirPaths objectAtIndex:0];
        
        //データベースパスを設定
        databasePath = [[NSString alloc] 
                        initWithString: [docPath stringByAppendingPathComponent:@"sqlbasic.db"]];
    }
    
    //設定ファイル(sqlbasic.xml)
    //設定ファイルはプログラムと同じパスにあるものを見る
    {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *inipath=[[[bundle bundlePath] stringByDeletingLastPathComponent] 
                           stringByAppendingPathComponent:@"sqlbasic.xml"];
        //設定ファイルの存在確認
        if([[NSFileManager defaultManager] fileExistsAtPath:inipath]){
            NSLog(@"file exists %@",inipath);

            //設定ファイルのロード
            NSDictionary *dictionary = [[NSDictionary alloc] initWithContentsOfFile:inipath];
            if (dictionary==nil){
                NSLog(@"fail load");
            }
            else{
                //設定ファイルの読み込みに成功
                NSString *dbpath=[dictionary objectForKey:@"DefaultDBFilePath"];
                //データベースファイルの指定があればそれをdatabsePathに代入
                NSLog(@"dbpath %@",dbpath);
                if([dbpath isEqualToString:@"AppPath"]){
                    databasePath=[[inipath stringByDeletingLastPathComponent]
                                  stringByAppendingPathComponent:@"sqlbasic.db"];
                    NSLog(@"Custom DBFile %@",databasePath);
                }
            }
        }
        else{
            /* テスト用設定ファイルの出力
            NSDictionary *dictionary = [NSDictionary 
                                        dictionaryWithObject:@"AppPath"
                                        forKey:@"DefaultDBFilePath"];
            [dictionary writeToFile:inipath atomically:YES];
            NSLog(@"save %@",inipath);
            */
        }
    }
    
    
    //コマンド履歴
    commandPos=0;
    commandHistory=[NSMutableArray array];
    
    return (self);
}
/*-----------------------------------------------------------------
 NIBファイルのロード
 -----------------------------------------------------------------*/
- (void)awakeFromNib {
    NSLog(@"awakeFromNib");
    
    [textSQLField setFont: [NSFont fontWithName:@"Osaka-Mono" size:14]];
    [textResultField setFont: [NSFont fontWithName:@"Osaka-Mono" size:14]];
    [textResultField insertText:@"SQLBasic for Mac Version 0.04 build 3/5/2012\n"];
    [textResultField insertText:@"Copyright (c) T Nishiki All Rights Reserved\n"];
    [textResultField insertText:@"\n"];

    [self DBLoad];
}
/*-----------------------------------------------------------------
 データベースファイルパスの入出力用
 -----------------------------------------------------------------*/
- (void)setDatabasePath:(NSString*)dbpath{
    databasePath = dbpath;
}
- (NSString*)databasePath{
    return databasePath;
}
/*-----------------------------------------------------------------
 解放
 -----------------------------------------------------------------*/
-(void)dealloc {
}
/*-----------------------------------------------------------------
 新規DBのセレクター
 -----------------------------------------------------------------*/
/*
-(void) sdialogEnd: (NSSavePanel*)savePanel
        returnCode: (int)returncode
        contexInfo: (void*)contexInfo
{
    //OKボタンを押した時
    if (returncode == NSOKButton){
        databasePath=[[savePanel URL] path];
        if([databasePath hasSuffix:@".db"]==NO &&
           [databasePath hasSuffix:@".sqlite"]==NO){
            databasePath=[databasePath stringByAppendingString:@".db"];
        }
        NSLog(@" dbfile:%@",databasePath);
        
        //データベースをロード
        [self DBLoad];
    }
    [savePanel close];
}
 */
/*-----------------------------------------------------------------
 新規DBの実行
 -----------------------------------------------------------------*/
-(IBAction)onNewSQLFile:(id)sender{
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    //パネルの表示
/*
 [panel beginSheetForDirectory: docPath
                             file: nil
                   modalForWindow: [self window]
                    modalDelegate: self
                   didEndSelector: @selector(sdialogEnd:
                                             returnCode:
                                             contexInfo:)
                      contextInfo: nil];
*/
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
     {
    if(result == NSOKButton){
        //OKボタンを押した時
            databasePath=[[panel URL] path];
            if([databasePath hasSuffix:@".db"]==NO &&
               [databasePath hasSuffix:@".sqlite"]==NO){
                databasePath=[databasePath stringByAppendingString:@".db"];
            }
            NSLog(@" dbfile:%@",databasePath);
            
            //データベースをロード
            [self DBLoad];
        }
     }];
    panel = nil;
}
/*-----------------------------------------------------------------
 開くのセレクター
 -----------------------------------------------------------------*/
/*
-(void) odialogEnd: (NSOpenPanel*)openPanel
        returnCode: (int)returncode
        contexInfo: (void*)contexInfo
{
    //OKボタンを押した時
    if (returncode == NSOKButton){
        databasePath=[[openPanel URL] path];
        NSLog(@" dbfile:%@",databasePath);
        
        //データベースをロード
        [self DBLoad];
    }
    [openPanel close];
}
 */
/*-----------------------------------------------------------------
 開く
 -----------------------------------------------------------------*/
-(IBAction)onOpenSQLFile:(id)sender{
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    //ファイルタイプ
    //NSArray *farray= [[NSArray alloc] initWithObjects:@"db",@"sqlite",nil];
    
    //パネルの表示
    /*
    [panel beginSheetForDirectory: docPath
                             file:nil
                            types:farray
                   modalForWindow: [self window]
                    modalDelegate: self
                   didEndSelector:@selector(odialogEnd:
                                            returnCode:
                                            contexInfo:)
                      contextInfo:nil];
     */
    [panel setAllowedFileTypes: [NSArray arrayWithObjects: @"db",@"sqlite",nil]];
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
     {
         if(result == NSOKButton){
             databasePath = [[panel URL] path];
             [self DBLoad];
         }
     }];
    panel=nil;
}
//ログの保存のセレクター
/*
 -(void) saveLogDialogEnd: (NSSavePanel*)savePanel
        returnCode: (int)returncode
        contexInfo: (void*)contexInfo
{
    //OKボタンを押した時
    if (returncode == NSOKButton){
        NSString *f=[[savePanel URL] path];
        //拡張子を付与
        if([f hasSuffix:@".log"]==NO){
            f=[f stringByAppendingString:@".log"];
        }
        NSError* error;
        [[textResultField string] 
            writeToFile: f
             atomically: YES
               encoding: NSUTF8StringEncoding
                  error :&error];
    }
    [savePanel close];
}
 */
/*-----------------------------------------------------------------
 ログの保存の実行
 -----------------------------------------------------------------*/
-(IBAction)onSaveResult:(id)sender{
    NSSavePanel *panel = [NSSavePanel savePanel];
    
    //パネルの表示
    /*
    [panel beginSheetForDirectory: docPath
                             file: nil
                   modalForWindow: [self window]
                    modalDelegate: self
                   didEndSelector: @selector(saveLogDialogEnd:
                                             returnCode:
                                             contexInfo:)
                      contextInfo: nil];
     */
    [panel beginSheetModalForWindow:[self window] completionHandler:^(NSInteger result)
     {
       if(result == NSOKButton){
           NSString *f=[[panel URL] path];
           //拡張子を付与
           if([f hasSuffix:@".log"]==NO){
               f=[f stringByAppendingString:@".log"];
           }
           NSError* error;
           [[textResultField string]
            writeToFile: f
            atomically: YES
            encoding: NSUTF8StringEncoding
            error :&error];
       }
     }];
    
    panel = nil;
}


- (void)layoutAction:(id)sender
{
    
}
/*-----------------------------------------------------------------
 印刷
 -----------------------------------------------------------------*/
- (IBAction)onPrint:(id)sender{
    // set printing properties
    NSPrintInfo *MyPrintInfo = [NSPrintInfo sharedPrintInfo];

    [MyPrintInfo setHorizontalPagination: NSFitPagination];
    [MyPrintInfo setHorizontallyCentered: NO];
    [MyPrintInfo setVerticallyCentered:   NO];
    [MyPrintInfo setLeftMargin:   62.0];
    [MyPrintInfo setRightMargin:  52.0];
    [MyPrintInfo setTopMargin:    52.0];
    [MyPrintInfo setBottomMargin: 70.0];

    // create new view just for printing
    NSTextView *printView = [[NSTextView alloc]initWithFrame: 
                             NSMakeRect(0.0, 0.0, 8.5 * 72, 11.0 * 72)];

    [MyPrintInfo imageablePageBounds];
    
    NSPrintOperation *op;
    
    // copy the textview into the printview
    NSRange textViewRange = NSMakeRange(0, [[textResultField textStorage] length]);
    NSRange printViewRange = NSMakeRange(0, [[printView textStorage] length]);
    
    [printView replaceCharactersInRange: printViewRange 
                                withRTF:[textResultField RTFFromRange: textViewRange]];
    
    op = [NSPrintOperation 
          printOperationWithView: printView
                       printInfo: MyPrintInfo];
    
    //印刷を実行
    NSDocument *doc=[NSDocument alloc];
    [doc runModalPrintOperation: op 
                       delegate: self
                 didRunSelector: @selector(layoutAction:) 
                    contextInfo: nil];
    
}
/*-----------------------------------------------------------------
 実行ボタン
 -----------------------------------------------------------------*/
-(IBAction)onExecButtonClicked:(id)sender{
    NSString *sql=[[[textSQLField string] copy]
                    stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    //ヒストリーに保存
    [commandHistory addObject:sql];

    while(0<[sql length]){
        //コメント
        if([sql hasPrefix:@"--"]==YES){
            NSRange range=[sql rangeOfString:@"\n"];
            //改行があるか
            if(0<range.length){
                sql=[[[sql copy] substringFromIndex: range.location] stringByTrimmingCharactersInSet: [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else{
                sql=@"";
            }
        }
        else if([sql hasPrefix:@"/*"]==YES){
            NSRange range=[sql rangeOfString:@"*/"];
            if(0<range.length){
                sql=[[[sql copy] substringFromIndex: range.location+2] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else{
                sql=@"";
            }
        }
        else{
            NSRange range=[sql rangeOfString:@";"];
            if(0<range.length){
                NSString *execcode=[sql substringToIndex:range.location];

                //コード実行
                [self execSQL:execcode];

                sql=[[[sql copy] substringFromIndex: range.location+1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            else{
                //コード実行
                [self execSQL:sql];

                sql=@"";                
            }
        }
    }
    commandPos=[commandHistory count];
}
/*-----------------------------------------------------------------
 SQL コードの実行関数
 -----------------------------------------------------------------*/
 - (void)execSQL:(NSString*)sql{
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    //ファイルチェッック
    if([filemgr fileExistsAtPath: databasePath] == YES)
    {
        const char *dbpath = [databasePath UTF8String];

        if ( sqlite3_open(dbpath, &contactDB) == SQLITE_OK){
            char *errMsg;
            NSString *upsql = [[sql copy] uppercaseString];

            //SQLコードをtextResultFieldに出力
            NSRange range = { [[textResultField string] length], 0 };
            [textResultField setSelectedRange: range];
            [textResultField insertText:sql];
            [textResultField insertText:@"\n"];

            //命令別に処理を変える
            if([upsql hasPrefix:@"?"]==YES){
                //
                NSString *arg=[[[sql copy] substringFromIndex:1] 
                               stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

                if(0<[arg length]){
                    //テーブル詳細
                    arg = [arg stringByReplacingOccurrencesOfString:@"%" withString:@""];
                    arg = [arg stringByReplacingOccurrencesOfString:@";" withString:@""];
                    
                    sqlite3_stmt *statement;
                    const char *sql_stmt = [[NSString stringWithFormat:
                                            @"select sql from sqlite_master " \
                                            "where type='table' and " \
                                            "tbl_name='%@'",arg] UTF8String];

                    //SQLの実行
                    if(sqlite3_prepare_v2(contactDB, sql_stmt, -1, &statement , nil)!=SQLITE_OK){
                        NSString *r = [NSString stringWithCString: sqlite3_errmsg(contactDB) encoding:NSUTF8StringEncoding];
                        [textResultField insertText:r];
                        [textResultField insertText:@"\n\n"];
                        
                        sqlite3_close(contactDB);
                        return;
                    }
                    int colcount=sqlite3_column_count(statement);
                    //データ取得
                    while(sqlite3_step(statement) == SQLITE_ROW)
                    {
                        for(int i=0;i<colcount;i++){
                            NSString *message = [[NSString alloc] initWithUTF8String:
                                                 (char *)sqlite3_column_text(statement, i)];
                            
                            [textResultField insertText:message];
                        }
                        [textResultField insertText:@"\n"];
                    }
                    [textResultField insertText:@"OK\n"];
                    sqlite3_close(contactDB);
                }
                else {
                    //全テーブルのリスト
                    sqlite3_stmt *statement;
                    const char *sql_stmt = "select tbl_name from sqlite_master " \
                                            "where type='table' and " \
                                            "(tbl_name<>'CONTACTS' and tbl_name<>'sqlite_sequence')";
                
                    //SQLの実行
                    if(sqlite3_prepare_v2(contactDB, sql_stmt, -1, &statement , nil)!=SQLITE_OK){
                        NSString *r = [NSString stringWithCString: sqlite3_errmsg(contactDB) encoding:NSUTF8StringEncoding];
                        [textResultField insertText:r];
                        [textResultField insertText:@"\n\n"];
                    
                        sqlite3_close(contactDB);
                        return;
                    }
                    //データ取得
                    while(sqlite3_step(statement) == SQLITE_ROW)
                    {
                        NSString *message = [[NSString alloc] initWithUTF8String:
                                             (char *)sqlite3_column_text(statement, 0)];
                        [textResultField insertText:message];
                        [textResultField insertText:@"\n"];
                    }
                    [textResultField insertText:@"OK\n"];
                    sqlite3_close(contactDB);
                }
            }
            else if([upsql hasPrefix:@"SELECT"]==YES){
                //SELECT の時の処理
                sqlite3_stmt *statement;
                const char *sql_stmt = [sql UTF8String];
                
                //SQLエラー
                if(sqlite3_prepare_v2(contactDB, sql_stmt, -1, &statement, nil)!=SQLITE_OK){
                    NSString *r = [NSString stringWithCString: sqlite3_errmsg(contactDB) encoding:NSUTF8StringEncoding];
                    [textResultField insertText:r];
                    [textResultField insertText:@"\n\n"];

                    sqlite3_close(contactDB);
                    return;
                }

                //それぞれのカラムの最長数を求める
                int colcount=sqlite3_column_count(statement);
                NSMutableArray *collen = [NSMutableArray array ]; 
                for(int i=0;i<colcount;i++){
                    NSString *s = [NSString stringWithCString:sqlite3_column_name(statement, i) encoding:NSUTF8StringEncoding];
                    [collen  addObject:[NSNumber numberWithInteger:[s length]]];
                }
                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    for(int i=0;i<colcount;i++){
                        //NSInteger c1 = [[NSString stringWithCString: (char *)sqlite3_column_text(statement, i) encoding:NSUTF8StringEncoding] length];
                        //マルチバイト文字を数える（凄く効率が悪い）
                        NSString *d = [NSString stringWithCString: (char *)sqlite3_column_text(statement, i) encoding: NSUTF8StringEncoding];
                        NSInteger c1 = [self countString:d];
                        NSInteger c2 = [[collen objectAtIndex:i] integerValue];                        
                        if(c2<c1){
                            [collen replaceObjectAtIndex:i withObject: [[NSNumber alloc ] initWithInteger:c1]];
                        }
                    }
                }

                //先頭に戻る
                sqlite3_reset(statement);
                
                //実データの取得
                if(sqlite3_prepare_v2(contactDB, sql_stmt, -1, &statement , nil)!=SQLITE_OK){
                    NSString *r = [NSString stringWithCString: sqlite3_errmsg(contactDB) encoding:NSUTF8StringEncoding];
                    [textResultField insertText:r];
                    [textResultField insertText:@"\n\n"];
                    
                    sqlite3_close(contactDB);
                    return;
                }

                //カラム名の表示
                for(int i=0;i<colcount;i++){
                    NSString* colname = [NSString stringWithCString:sqlite3_column_name(statement, i) encoding:NSUTF8StringEncoding];
                    [textResultField insertText:colname];
                    //インデント
                    NSInteger c1 = [self countString:colname];
                    NSNumber *colwith = [collen objectAtIndex:i];
                    for(int j=0;j<[colwith intValue] - c1;j++){
                        [textResultField insertText:@" "];
                    }
                    [textResultField insertText:@"|"];
                }
                [textResultField insertText:@"\n"];

                //インデント
                for(int i=0;i<colcount;i++){
                    NSNumber *colwith = [collen objectAtIndex:i];
                    for(int j=0;j<[colwith intValue];j++){
                        [textResultField insertText:@"-"];
                    }
                    [textResultField insertText:@"+"];
                }
                [textResultField insertText:@"\n"];

                //データの抽出
                NSMutableString *outStr=[[NSMutableString alloc] init];

                while(sqlite3_step(statement) == SQLITE_ROW)
                {
                    for(int i=0;i<colcount;i++){
                        NSString *message = [[NSString alloc] initWithUTF8String:
                                             (char *)sqlite3_column_text(statement, i)];

                        [outStr appendString:message];

                        //インデント
                        NSInteger c1 = [self countString:message];
                        NSNumber *colwith = [collen objectAtIndex:i];

                        for(int j=0;j<[colwith intValue] - c1;j++){
                            [outStr appendString:@" "];
                        }
                        [outStr appendString:@"|"];
                    }
                    [outStr appendString:@"\n"];
                }
                sqlite3_finalize(statement);
                [outStr appendString:@"OK\n\n"];

                [textResultField insertText:outStr];
            }
            else {
                const char *sql_stmt = [sql UTF8String];

                //INSERT/UPLOAD 等の処理
                if (sqlite3_exec(contactDB, sql_stmt, NULL, NULL, &errMsg)){
                    //Failed creating table
                    NSString *r = [NSString stringWithCString: errMsg encoding:NSUTF8StringEncoding];
                    [textResultField insertText:r];
                    [textResultField insertText:@"\n\n"];
                }
                else{
                    [textResultField insertText:@"OK\n\n"];
                }
            }
            
            sqlite3_close(contactDB);
        }
    }
}
/*-----------------------------------------------------------------
 データベースの読み込み
 -----------------------------------------------------------------*/
- (void)DBLoad {
    BOOL result=FALSE;
    
    NSFileManager *filemgr = [NSFileManager defaultManager];

    NSLog(@"OpenDB:%@",databasePath);
    if([filemgr fileExistsAtPath: databasePath] == NO)
    {
        //DBファイルが存在していないなら作成する
        const char *dbpath = [databasePath UTF8String];
        
        if ( sqlite3_open(dbpath, &contactDB) == SQLITE_OK){
            
            sqlite3_close(contactDB);
            
            result=TRUE;
        }
        else{
            result=FALSE;
        }
    }
    else{
        result=TRUE;
    }
    {
        NSRange a,b;
        [textResultField selectAll:nil];
        a=[textResultField selectedRange];
        b=NSMakeRange(a.length,0);
        [textResultField setSelectedRange:b];
    }
    
    //データベースをロード
    if(result==TRUE){        
        NSString *fn=[[databasePath lastPathComponent] stringByAppendingString: @" に接続しました\n\n"];
        [textResultField insertText: fn];
    }else{
        NSString *fn=[[databasePath lastPathComponent] stringByAppendingString: @" に接続できませんでした\n\n"];
        [textResultField insertText: fn];
    }
}
/*-----------------------------------------------------------------
 前のコマンド
 -----------------------------------------------------------------*/
-(IBAction)onPreviousCommand:(id)sender{
    if(0<commandPos && 0<[commandHistory count]){
        if([commandHistory count]==commandPos){
            //カレントコードなのでバッファにコピー
            currentCode=[[textSQLField string] copy];
        }
        commandPos=commandPos-1;
        [textSQLField setString:[NSString string]];
        [textSQLField insertText:[commandHistory objectAtIndex:commandPos]];
    }
}
/*-----------------------------------------------------------------
 次のコマンド
 -----------------------------------------------------------------*/
-(IBAction)onForwardCommand:(id)sender{
    //
    if(commandPos==[commandHistory count]-1){
        commandPos=commandPos+1;
        [textSQLField setString:[NSString string]];
        [textSQLField insertText:currentCode];
    }
    else if(commandPos<[commandHistory count]-1){
        commandPos=commandPos+1;
        [textSQLField setString:[NSString string]];
        [textSQLField insertText:[commandHistory objectAtIndex:commandPos]];
    }
}
/*-----------------------------------------------------------------
 フォントを大きくする
 -----------------------------------------------------------------*/
-(IBAction)onTextFontSizePlus:(id)sender{
    NSFont *f= [textSQLField font];
    float s=[f pointSize];
    s=s+2;
    if(40<s){
        s=40;
    }
    
    //フォントをセットする
    [textSQLField setFont:[NSFont fontWithName:[f fontName] size:s]];
    [textResultField setFont:[NSFont fontWithName:[f fontName] size:s]];
}
/*-----------------------------------------------------------------
 フォントを小さくする
 -----------------------------------------------------------------*/
-(IBAction)onTextFontSizeMinus:(id)sender{
    NSFont *f= [textSQLField font];
    float s=[f pointSize];
    s=s-2;
    if(s<8){
        s=8;
    }

    //フォントをセットする
    [textSQLField setFont:[NSFont fontWithName:[f fontName] size:s]];
    [textResultField setFont:[NSFont fontWithName:[f fontName] size:s]];
}

//undo
-(IBAction)onUndo:(id)sender{
    //undoの実行
    [[textSQLField undoManager] undo];
}
/*-----------------------------------------------------------------
 SQLクリアボタン
 -----------------------------------------------------------------*/
- (IBAction)onClearSQLButtonClicked:(id)sender {
    //消去
    [textSQLField setString:[NSString string]];
}
/*-----------------------------------------------------------------
 Resultクリアボタン
 -----------------------------------------------------------------*/
- (IBAction)onClearResultButtonClicked:(id)sender {

    NSInteger result = NSRunAlertPanel(@"確認", 
                                       @"実行結果を消去しますか？", 
                                       @"はい", 
                                       @"いいえ", 
                                       @"");

    if(result==NSAlertDefaultReturn){
        //消去
        [textResultField setString:[NSString string]];
    }
}
//文字長を計算する
- (NSInteger)countString:(NSString*)str {
    NSInteger count=0;
    for(int i=0; i<[str length]; i++) {
        NSString *aChar = [str substringWithRange:NSMakeRange(i, 1)];
        const char *c=[aChar UTF8String];
        if (0 < c[0]) {
            count++;
        }
        else {
            count+=2;
        }
    }
    return count;
}

@end

