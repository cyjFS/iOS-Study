###解析[FDFullscreenPopGesture](https://github.com/forkingdog/FDFullscreenPopGesture)

阳神的作品，短小精干~ : )

实现思路来自于iOS7自带的最左侧滑动返回上一个VC的做法，具体如下：

				1. 通过运行时，捕获iOS7自带的滑动返回手势的相关信息——存放位置，手势响应的目标A以及方法M。
				2. 添加右滑手势，并让其响应目标A的方法M。
				3. 禁用自带的滑动返回

从.h文件就可看出阳神并不仅仅只做了这些~

		interface UINavigationController (FDFullscreenPopGesture)
		//自添加手势
		@property (nonatomic, strong, readonly) UIPanGestureRecognizer *fd_fullscreenPopGestureRecognizer;

		//是否允许VC控制navbar的显示标识
		@property (nonatomic, assign) BOOL fd_viewControllerBasedNavigationBarAppearanceEnabled;

		@end

		@interface UIViewController (FDFullscreenPopGesture)

		//左滑返回禁用标识
		@property (nonatomic, assign) BOOL fd_interactivePopDisabled;


		//是否隐藏navbar标识
		@property (nonatomic, assign) BOOL fd_prefersNavigationBarHidden;


		//左滑返回手势有效范围
		@property (nonatomic, assign) CGFloat fd_interactivePopMaxAllowedInitialDistanceToLeftEdge;

		@end


可以看到阳神考虑的很周全，navbar的显示与否，滑动返回的启用与否以及其有效范围。

在VC层面对navbar的控制，阳神采用了方法替换的黑魔法~

直接上添加了注释的版本吧~有兴趣的可以看看~

