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

@property(strong) NSString *name;
@property(strong) NSString *version;
@property(weak) GSource  *source;
@property(readwrite) GStatus status;
@property(weak) GSystem *system;
@property(readwrite) GMark mark;
@property(strong) NSString *ID;
@property(strong) NSString *categories;
@property(strong) NSString *description;
@property(strong) NSString *homepage;
@property(strong) NSString *URL;

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

