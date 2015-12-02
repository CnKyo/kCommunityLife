//
//  AddressVC.h
//  YiZanService
//
//  Created by ljg on 15-3-23.
//  Copyright (c) 2015年 zywl. All rights reserved.
//

#import "BaseVC.h"

@interface AddressVC : BaseVC
@property (weak, nonatomic) IBOutlet UITableView *mTableView;
@property (nonatomic,assign) BOOL mIsCommon;

@property (nonatomic,strong) void(^itblock)(SAddress* getone);



@end
