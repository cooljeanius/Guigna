#import "GSystem.h"

@implementation GSystem

@synthesize prefix;
@synthesize packagesIndex;

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    self.status = GOnState;
    self.packagesIndex = [NSMutableDictionary dictionary];
    return self;
}

- (NSString *)outputFor:(NSString *)format, ... {
    va_list args;
    va_start(args, format);
    NSString *command = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return [self.agent outputForCommand:command];
}

- (NSArray *)list {
    return @[];
}

- (NSArray *)installed {
    return @[];
}

- (NSArray *)outdated {
    return @[];
}

- (NSArray *)inactive {
    return @[];
}


- (NSArray *)availableCommands {
    return @[@"clean"];
}


- (NSString *)keyForPackage:(GPackage *)package {
    return [NSString stringWithFormat:@"%@-%@", package.name, self.name];
}

- (NSArray *)installedPackagesNamed:(NSString *)name {
    return [[self installed] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", name]];   
}

- (NSArray *)categoriesList {
    NSMutableSet *cats = [NSMutableSet set];
    for (GItem *item in self.items) {
        [cats addObjectsFromArray:[item.categories componentsSeparatedByString:@" "]];
    }
    return [[cats allObjects] sortedArrayUsingSelector:@selector(compare:)];
}


- (NSArray *)dependenciesList:(GPackage *)package {
    return @[];
}


- (NSString *)variants:(GPackage *)package {
    return nil;
}


- (NSString *)installCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ install %@", self.cmd, package.name];
}

- (NSString *)uninstallCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ uninstall %@", self.cmd, package.name];
}

- (NSString *)deactivateCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ deactivate %@", self.cmd, package.name];
}

- (NSString *)upgradeCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ upgrade %@", self.cmd, package.name];
}

- (NSString *)fetchCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ fetch %@", self.cmd, package.name];
}

- (NSString *)cleanCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"%@ clean %@", self.cmd, package.name];
}


- (NSString *)selfupdateCmd {
    return nil;
}

+ (NSString *)setupCmd {
    return nil;
}

+ (NSString *)removeCmd {
    return nil;
}

- (NSString *)hideCmd {
    return nil;
}

- (NSString *)unhideCmd {
    return nil;
}

@end
