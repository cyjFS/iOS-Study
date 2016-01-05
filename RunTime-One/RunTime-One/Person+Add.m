//
//  Person+Add.m
//  testS
//
//  Created by apple on 16/1/5.
//  Copyright © 2016年 王琨. All rights reserved.
//

#import "Person+Add.h"
#import <objc/runtime.h>

@implementation Person (Add)




- (void)changeSetter

{
    unsigned int count = 0;
    
    Method * a = class_copyMethodList([Person class], &count);
    
    for (unsigned int i = 0; i < count; i ++) {
        
        NSString * methodName = NSStringFromSelector(method_getName(a[i]));
        
        //获得set方法，更改set
        
        if([methodName hasPrefix:@"set"]){
            
            method_setImplementation(a[i], (IMP)new_setter);
            
        }
        
    }

}



static NSString * getterForSetter(NSString *setter)
{
    if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
    }
    
    NSRange range = NSMakeRange(3, setter.length - 4);
    NSString *key = [setter substringWithRange:range];
    
    NSString *firstLetter = [[key substringToIndex:1] lowercaseString];
    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    return key;
}

static void new_setter(id self, SEL _cmd, id newValue)
{
    //根据SEL获得setter方法名
    NSString * setterName = NSStringFromSelector(_cmd);
    //获得getter方法名
    NSString *getterName = getterForSetter(setterName);
    //异常处理
    if (!getterName) {
        NSString *reason = [NSString stringWithFormat:@"Object %@ does not have setter %@", self, setterName];
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:reason
                                     userInfo:nil];
        return;
    }
    
    unsigned int count ;
    
    //拼接变量名
    NSString * s = @"_";
    s = [s stringByAppendingString:getterName];
    
    //得到变量列表
    Ivar * members = class_copyIvarList([self class], &count);
    
    int index = -1;
    //遍历变量
    for (int i = 0 ; i < count; i++) {
        Ivar var = members[i];
        //获得变量名
        const char *memberName = ivar_getName(var);

        //生成string
        NSString * memberNameStr = [NSString stringWithUTF8String:memberName];
        if ([s isEqualToString:memberNameStr]) {
            index = i;
            break ;
        }
        
    }
    
    //变量存在则赋值
    if (index > -1) {
        Ivar member= members[index];
        object_setIvar(self, member, newValue);
    }
    
    //你可以做所有你想做的事~
    [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:getterName];
    [[NSUserDefaults standardUserDefaults ]synchronize];
    

}



@end
