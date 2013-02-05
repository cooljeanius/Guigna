#import "GSource.h"

#import "GuignaAgent.h"
#import "GPackage.h"

@interface GSystem : GSource

@property(strong) NSString *prefix;
@property(strong) NSMutableDictionary *packagesIndex;

- (id)initWithAgent:(GuignaAgent *)agent;

- (NSString *)outputFor:(NSString *)format, ...;

- (NSArray *)list;
- (NSArray *)installed;
- (NSArray *)outdated;
- (NSArray *)inactive;

- (NSArray *)availableCommands;
- (NSArray *)categoriesList;

- (NSString *)keyForPackage:(GPackage *)package;
- (NSArray *)installedPackagesNamed:(NSString *)name;
- (NSArray *)dependenciesList:(GPackage *)package;
- (NSString *)variants:(GPackage *)package;

- (NSString *)installCmd:(GPackage *)package;
- (NSString *)uninstallCmd:(GPackage *)package;
- (NSString *)deactivateCmd:(GPackage *)package;
- (NSString *)upgradeCmd:(GPackage *)package;
- (NSString *)fetchCmd:(GPackage *)package;
- (NSString *)cleanCmd:(GPackage *)package;

- (NSString *)selfupdateCmd;

+ (NSString *)setupCmd;
+ (NSString *)removeCmd;

- (NSString *)hideCmd;
- (NSString *)unhideCmd;

@end
