##利用runtime为setter方法添加存储到本地功能

近来换了一家离家很近的公司工作，接手了一个老项目，独立进行二次开发。

项目中存在许多用户信息，且时常需要更新存储在本地，方便二次访问。

我的上一任是在每一次对其赋值后，使用userdefaults进行存储，没有封装，没有重写setter，直接在后面写上[NSUserD....]，典型copy党···

> 我感觉我的膝盖中了一箭。

###问题：

#####如何将已成型的类的属性更方便快捷的存储到本地？


###解决方案分析：
    
#####1.重写setter方法，在每一个方法中都存储到本地：




`- (void)setName:(NSString *)name`

`{`

  `  _name = name;`
    
  `  [[NSUserDefaults standardUserDefaults] setObject:name forKey:@"name"];`
    
   ` [[NSUserDefaults standardUserDefaults] synchronize];`
    
`}`
 
       
            工作量大，代码冗余度高。
 
        
#####2.写一个方法对用户数据类进行统一存储到本地操作
        
`- (void)savaUserData`

`{`

 `  [[NSUserDefaults standardUserDefaults] setObject:_name forKey:@"name"];`
 
 `  [[NSUserDefaults standardUserDefaults] setObject:_password forKey:@"password"];`
      
   `......`
     
   `......`

      
   ` [[NSUserDefaults standardUserDefaults] synchronize];`

`}`

       工作量小，但只更改一个属性也需要进行整体存储，效率低。 

#####3. 无视之~~ 
        
  
        这能忍！！？
        
        
#####4.运用运行时直接修改其setter，为其添加存储本地功能

        bingo。
        
        

   
>懒，又追求效率，SO选择了方案4！ 果然懒才是程序猿的第一生产力啊。`

####实践

`既然方案选择好了，Just do it。`


1. 书写通用new_setter方法

      `setter方法的本质是用属性的新值去替换掉旧值。`

      setter方法在C层面是一个带三个参数的函数
        
      `static void new_setter(id self, SEL _cmd, id newValue)`
      
          self是实例本身。
          _cmd是方法对应的SEL
          newValue顾名思义。
      
    1.1 `通过_cmd获得setter方法的名字——setName：`
            
                NSString * setter = NSStringFromSelector(_cmd);
    1.2 `通过setter方法得出成员变量名`
            
        if (setter.length <=0 || ![setter hasPrefix:@"set"] || ![setter hasSuffix:@":"]) {
        return nil;
        }
        //去除set
        NSRange range = NSMakeRange(3, setter.length - 4);
        NSString *getter = [setter substringWithRange:range];
        //小写首字母
        NSString *firstLetter = [[getter substringToIndex:1] lowercaseString];
        getter = [getter stringByReplacingCharactersInRange:NSMakeRange(0, 1)
                                       withString:firstLetter];
    
        //拼接变量名
        NSString * varName = @"_";
        varName = [s stringByAppendingString:getter];
            
    1.3 `遍历成员变量列表，替换成员变量值`
    
    
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
            
            
     1.4 `存储到本地——任意自由发挥阶段`
        
        [[NSUserDefaults standardUserDefaults] setObject:newValue forKey:getterName];
        [[NSUserDefaults standardUserDefaults ]synchronize];
 

2. 替换setter方法

    `在方法列表中找到setter方法，用新的setter方法替换之`
    
        unsigned int count = 0;
        //获得方法列表
        Method * a = class_copyMethodList([Person class], &count);
    
        //遍历方法列表
        for (unsigned int i = 0; i < count; i ++) {
        
            NSString * methodName = NSStringFromSelector(method_getName(a[i]));
        
            //获得setter方法
            if([methodName hasPrefix:@"set"]){
                //更改setert
                method_setImplementation(a[i], (IMP)new_setter);
            
        }
        
    }  
  
####难点
    
    1. setter方法如何通用
        
    2. 在C层面如何替换方法
    
 其实这两个问题都在于我对OC底层不熟悉导致。
 
 OC的方法在底层是以method方法的形式存储在方法列表中，每一个方法实际对应一个IMP。
 `IMP实质就是一个函数指针。`

 SEL则类似方法名称，和实例以及IMP是一一对应关系。
 
 一个实例不能有两个相同的SEL（方法名不能重复），一个SEL对应一个IMP。

 所以我们可以通过SEL得到方法名称，进而找到成员变量名，完成setter方法的通用——`解决难点1`
 
 同理由于method对应一个IMP，只需要将menthod的IMP更改为我们写的函数即可——`解决难点2`
 
 
 








