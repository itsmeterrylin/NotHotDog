#import <Foundation/Foundation.h>

#if __has_attribute(swift_private)
#define AC_SWIFT_PRIVATE __attribute__((swift_private))
#else
#define AC_SWIFT_PRIVATE
#endif

/// The "LoadingView" asset catalog image resource.
static NSString * const ACImageNameLoadingView AC_SWIFT_PRIVATE = @"LoadingView";

/// The "analyzing_with_ai" asset catalog image resource.
static NSString * const ACImageNameAnalyzingWithAi AC_SWIFT_PRIVATE = @"analyzing_with_ai";

/// The "hotdog" asset catalog image resource.
static NSString * const ACImageNameHotdog AC_SWIFT_PRIVATE = @"hotdog";

/// The "not_hotdog" asset catalog image resource.
static NSString * const ACImageNameNotHotdog AC_SWIFT_PRIVATE = @"not_hotdog";

#undef AC_SWIFT_PRIVATE
