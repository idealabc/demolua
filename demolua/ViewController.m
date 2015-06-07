//
//  ViewController.m
//  demolua
//
//  Created by zhao xiaohua on 15/6/7.
//  Copyright (c) 2015年 慎道. All rights reserved.
//

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
#import "ViewController.h"

/* 指向Lua解释器的指针 */
lua_State* L;
static int average(lua_State *L)
{
    /* 得到参数个数 */
    int n = lua_gettop(L);
    double sum = 0;
    int i;
    
    /* 循环求参数之和 */
    for (i = 1; i <= n; i++)
    {
        /* 求和 */
        sum += lua_tonumber(L, i);
    }
    /* 压入平均值 */
    lua_pushnumber(L, sum / n);
    /* 压入和 */
    lua_pushnumber(L, sum);
    /* 返回返回值的个数 */
    return 2;
}

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self luabyc];
}
- (void)luabyc{
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"avg" ofType:@"lua"];
    const char *stringAsChar = [imagePath cStringUsingEncoding:[NSString defaultCStringEncoding]];
    
    /* 初始化Lua */
    lua_State *L = luaL_newstate();
    
    /* 载入Lua基本库 */
    luaL_openlibs(L);
    /* 注册函数 */
    lua_register(L, "average", average);
    /* 运行脚本 */
    luaL_dofile(L, stringAsChar);
    /* 清除Lua */
    lua_close(L);

}
- (void)loadlua {
    //参考： http://blog.csdn.net/shun_fzll/article/details/39120965
    //1.创建Lua状态
    lua_State *L = luaL_newstate();
    if (L == NULL)
    {
        return ;
    }
    
    NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"hello" ofType:@"lua"];
    const char *stringAsChar = [imagePath cStringUsingEncoding:[NSString defaultCStringEncoding]];
    //2.加载lua文件
    int bRet = luaL_loadfile(L, stringAsChar);
    if(bRet)
    {
        NSLog(@"load error");
        return ;
    }
    
    //3.运行lua文件
    bRet = lua_pcall(L,0,0,0);
    if(bRet)
    {
        NSLog(@"executre error");
        return ;
    }
    
    //4.读取变量
    lua_getglobal(L,"str");
    NSLog(@"%s", lua_tostring(L,-1));
    
    //5.读取table
    lua_getglobal(L,"tbl");
    lua_getfield(L,-1,"name");
    NSLog(@"%s", lua_tostring(L,-1));
    
    //6.读取函数
    lua_getglobal(L, "add");		// 获取函数，压入栈中
    lua_pushnumber(L, 10);			// 压入第一个参数
    lua_pushnumber(L, 20);			// 压入第二个参数
    int iRet= lua_pcall(L, 2, 1, 0);// 调用函数，调用完成以后，会将返回值压入栈中，2表示参数个数，1表示返回结果个数。
    if (iRet)						// 调用出错
    {
        const char *pErrorMsg = lua_tostring(L, -1);
        NSLog(@"%s", pErrorMsg);
        lua_close(L);
        return ;
    }
    if (lua_isnumber(L, -1))        //取值输出
    {
        double fValue = lua_tonumber(L, -1);
        NSLog(@"%f", fValue);
    }
    
    //至此，栈中的情况是：
    //=================== 栈顶 ===================
    //  索引  类型      值
    //   4   int：      30
    //   3   string：   shun
    //	 2	 table:		tbl
    //   1   string:	I am so cool~
    //=================== 栈底 ===================
    
    //7.关闭state
    lua_close(L);
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
