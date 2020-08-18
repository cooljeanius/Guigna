#import <Foundation/Foundation.h>

#import "GSource.h"

@class GSystem;

typedef enum _GStatus {
    GAvailableStatus = 0,
    GInactiveStatus,
    GUpToDateStatus,
    GOutdatedStatus,
    GUpdatedStatus,
    GNewStatus,
    GBrokenStatus
} GStatus;

typedef enum _GMark {
    GNoneMark = 0,
    GInstallMark= 1,
    GUninstallMark,
    GDeactivateMark,
    GUpgradeMark,
    GFetchMark,
    GCleanMark
} GMark;

@interface GItem : NSObject  <NSCoding>

@property(strong, atomic) NSString *name;
@property(strong, atomic) NSString *version;
@property(weak, atomic) GSource  *source;
@property(readwrite, atomic) GStatus status;
@property(weak, atomic) GSystem *system;
@property(readwrite, atomic) GMark mark;
@property(strong, atomic) NSString *ID;
@property(strong, atomic) NSString *categories;
@property(strong, atomic) NSString *description;
@property(strong, atomic) NSString *homepage;
@property(strong, atomic) NSString *URL;

- (id)initWithName:(NSString *)name
           version:(NSString *)version
            source:(GSource *)source
            status:(GStatus)status;

@end


@interface GStatusTransformer : NSValueTransformer
@end

@interface GSourceTransformer : NSValueTransformer
@end

@interface GMarkTransformer : NSValueTransformer
@end

