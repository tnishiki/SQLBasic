//
//  AppController.m
//  test1
//
//  Created by 西木 毅 on 11/12/10.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (id)init {
    self = [super init];
    if (self) {
    }

    return self;
}

//NIBファイルのロード
-(void)awakeFromNib{
    //NSLog(@"app/awakeFromNib");
}

//新規DBファイルの作成
-(IBAction)newDocument:(id)sender{
    
    //NSLog(@"Create New DB");

    //新しいコントローラに MainMenu.xib を割当
    //Controller *c=[Controller alloc];
    
    //[NSBundle loadNibNamed:@"MainMenu" owner:c];

}


//開く
-(IBAction)openDocument:(id)sender{

}

//閉じる
-(IBAction)close:(id)sender{
    //今のバージョンはシングルウィンドウなので無効にする
    //NSWindow *f=[[NSApp orderedWindows] objectAtIndex:0];
    //[f close];
}


@end
