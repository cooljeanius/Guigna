#import "GuignaAppDelegate.h"

@implementation GuignaAppDelegate

@synthesize agent, defaultsController;
@synthesize window = _window;
@synthesize sourcesOutline, itemsTable, searchField;
@synthesize tabView, infoText, webView, logText;
@synthesize segmentedControl, commandsPopUp, shellDisclosure, cmdline;
@synthesize statusField, clearButton, moreButton, statsLabel;
@synthesize progressIndicator, tableProgressIndicator;
@synthesize applyButton, stopButton;
@synthesize toolsMenu, markMenu;
@synthesize optionsPanel, optionsProgressIndicator, optionsStatusField;
@synthesize terminal, shell, shellWindow, browser;
@synthesize sourcesController, itemsController;
@synthesize sources, systems, scrapes, repos;
@synthesize items, allPackages, packagesIndex, markedItems;
@synthesize marksCount, selectedSegment, previousSegment;
@synthesize APPDIR;
@synthesize persistentStoreCoordinator = __persistentStoreCoordinator;
@synthesize managedObjectModel = __managedObjectModel;
@synthesize managedObjectContext = __managedObjectContext;


- (void)awakeFromNib {
    GStatusTransformer *statusTransformer = [[GStatusTransformer alloc] init];
    [NSValueTransformer setValueTransformer:statusTransformer forName:@"StatusTransformer"];
    GSourceTransformer *sourceTransformer = [[GSourceTransformer alloc] init];
    [NSValueTransformer setValueTransformer:sourceTransformer forName:@"SourceTransformer"];
    GMarkTransformer *markTransformer = [[GMarkTransformer alloc] init];
    [NSValueTransformer setValueTransformer:markTransformer forName:@"MarkTransformer"];
    
    [sourcesOutline setFloatsGroupRows:NO];
    [infoText setFont:[NSFont fontWithName:@"Andale Mono" size:11.0]];
    [logText setFont: [NSFont fontWithName:@"Andale Mono" size:11.0]];
    
    [itemsTable setDoubleAction:@selector(showMarkMenu:)];
}


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [tableProgressIndicator startAnimation:self];
    NSString *welcomeMsg = @"\n\t\t\t\t\tWelcome to Guigna\n\t\t\tThe GUI of Guigna is Not by Apple  :)\n\n\t[Sync] to update from remote repositories.\n\tRight/double click a package to mark it.\n\t[Apply] to commit the changes to a [Shell].\n\n\tYou can try other commands typing in the yellow prompt.\n\tTip: Command-click to combine sources.\n\tWarning: keep the Guigna shell open.\n\n\n\t\t\t\tTHIS IS ONLY A PROTOTYPE.\n\n\n\t\t\t\tguido.soranzio@gmail.com";
    [self info:welcomeMsg];
    
    agent = [[GuignaAgent alloc] init];
    agent.appDelegate = self;
    
    sources = [[NSMutableArray alloc] init];
    systems = [[NSMutableArray alloc] init];
    scrapes = [[NSMutableArray alloc] init];
    repos = [[NSMutableArray alloc] init];
    items = [[NSMutableArray alloc] init];
    allPackages = [[NSMutableArray alloc] init];
    packagesIndex = [[NSMutableDictionary alloc] init];
    
    system("osascript -e 'tell application \"Terminal\" to close (windows whose custom title contains \"Guigna\")'");
    self.terminal = [SBApplication applicationWithBundleIdentifier:@"com.apple.Terminal"];
    self.shell = [self.terminal doScript:@"echo Welcome to Guigna" in:nil];
    shell.customTitle = @"Guigna";
    
    self.APPDIR = [@"~/Library/Application Support/Guigna" stringByExpandingTildeInPath];
    system([[NSString stringWithFormat: @"mkdir -p '%@'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"touch '%@/output'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"touch '%@/sync'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"mkdir -p '%@/MacPorts'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"mkdir -p '%@/Fink'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"mkdir -p '%@/pkgsrc'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    system([[NSString stringWithFormat: @"mkdir -p '%@/FreeBSD'", self.APPDIR] cStringUsingEncoding:NSUTF8StringEncoding]);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSMutableArray *hiddenSystems = [NSMutableArray array];
    if ([fileManager fileExistsAtPath:@"/opt/local_off"])
        [hiddenSystems addObject:@"MacPorts"];
    if ([fileManager fileExistsAtPath:@"/usr/local_off"])
        [hiddenSystems addObject:@"Homebrew"];
    if ([hiddenSystems count] > 0) {
        NSString *detectedSystems = [hiddenSystems componentsJoinedByString:@" and "];
        if (NSRunCriticalAlertPanel(@"Hidden systems detected.", [NSString stringWithFormat:@"The prefix of %@ is currently hidden by an \"_off\" suffix.", detectedSystems], @"Unhide and relauch.", @"Continue", nil) ==NSAlertDefaultReturn) {
            for (NSString *system in hiddenSystems) {
                if ([system isEqualToString:@"MacPorts"])
                    [self sudo:@"mv /opt/local_off /opt/local" withBaton:@"relaunch"];
                else if ([system isEqualToString:@"Homebrew"])
                    [self sudo:@"mv /usr/local_off /usr/local" withBaton:@"relaunch"];
            }
            exit(1);
            // TODO
        };
    }
    
    if ([fileManager fileExistsAtPath:@"/opt/local/bin/port"]
        || [fileManager fileExistsAtPath:[@"~/Library/Application Support/Guigna/MacPorts/PortIndex" stringByExpandingTildeInPath]]) {
        if ([[defaultsController values] valueForKey:@"MacPortsStatus"] == nil)
            [[defaultsController values] setValue:@YES forKey:@"MacPortsStatus"];
        if ([[[defaultsController values] valueForKey:@"MacPortsStatus"] integerValue] == GOnState) {
            GSystem *macports = [[GMacPorts alloc] initWithAgent:self.agent];
            [systems addObject:macports];
            if (![fileManager fileExistsAtPath:@"/opt/local/bin/port"])
                macports.mode = GOnlineMode;
        }
    }
    
    if ([fileManager fileExistsAtPath:@"/usr/local/bin/brew"]) {
        if ([[defaultsController values] valueForKey:@"HomebrewStatus"] == nil)
            [[defaultsController values] setValue:@YES forKey:@"HomebrewStatus"];
        if ([[[defaultsController values] valueForKey:@"HomebrewStatus"] integerValue] == GOnState) {
            GSystem *homebrew = [[GHomebrew alloc] initWithAgent:self.agent];
            [systems addObject:homebrew];
        }
    }
    
    if ([fileManager fileExistsAtPath:@"/opt/local/bin/pod"]) {
        if ([[defaultsController values] valueForKey:@"CocoaPodsStatus"] == nil)
            [[defaultsController values] setValue:@YES forKey:@"CocoaPodsStatus"];
        if ([[[defaultsController values] valueForKey:@"CocoaPodsStatus"] integerValue] == GOnState) {
            GSystem *cocoapods = [[GCocoaPods alloc] initWithAgent:self.agent];
            [systems addObject:cocoapods];
        }
    }
    
    if ([fileManager fileExistsAtPath:@"/sw/bin/fink"]) {
        if ([[defaultsController values] valueForKey:@"FinkStatus"] == nil
            || [[[defaultsController values] valueForKey:@"FinkStatus"] boolValue] == YES)
            [[defaultsController values] setValue:@YES forKey:@"FinkStatus"];
        if ([[[defaultsController values] valueForKey:@"FinkStatus"] integerValue] == GOnState) {
            GSystem *fink = [[GFink alloc] initWithAgent:self.agent];
            if ( ![fileManager fileExistsAtPath:@"/sw/bin/fink"])
                fink.mode = GOnlineMode;
            [systems addObject:fink];
        }
    }
    
    // TODO: Index user defaults
    if ([fileManager fileExistsAtPath:@"/usr/pkg/sbin/pkg_info"]
        || [fileManager fileExistsAtPath:[@"~/Library/Application Support/Guigna/pkgsrc/INDEX" stringByExpandingTildeInPath]]) {
        if ([[defaultsController values] valueForKey:@"pkgsrcStatus"] == nil)
            [[defaultsController values] setValue:@YES forKey:@"pkgsrcStatus"];
        if ([[[defaultsController values] valueForKey:@"pkgsrcStatus"] integerValue] == GOnState) {
            GSystem *pkgsrc = [[GPkgsrc alloc] initWithAgent:self.agent];
            [systems addObject:pkgsrc];
            if (![fileManager fileExistsAtPath:@"/usr/pkg/sbin/pkg_info"])
                pkgsrc.mode = GOnlineMode;
        }
    }
    
    if ([fileManager fileExistsAtPath:[@"~/Library/Application Support/Guigna/FreeBSD/INDEX" stringByExpandingTildeInPath]]) {
        if ([[defaultsController values] valueForKey:@"FreeBSDStatus"] == nil)
            [[defaultsController values] setValue:@YES forKey:@"FreeBSDStatus"];
        if ([[[defaultsController values] valueForKey:@"FreeBSDStatus"] integerValue] == GOnState) {
            GSystem *freebsd = [[GFreeBSD alloc] initWithAgent:self.agent];
            [systems addObject:freebsd]; freebsd.mode = GOnlineMode;
        }
    }
    
    if ([[defaultsController values] valueForKey:@"ScrapesCount"] == nil)
        [[defaultsController values] setValue:@15 forKey:@"ScrapesCount"];
    
    GSystem *macosx =   [[GMacOSX alloc] initWithAgent:self.agent];
    [systems addObject:macosx];
    
    GRepo *native = [[GNative alloc] initWithAgent:self.agent];
    [repos addObject:native];
    GRepo *rudix = [[GRudix alloc] initWithAgent:self.agent];
    [repos addObject:rudix];
    GRepo *macportsorg = [[GMacPortsOrg alloc] initWithAgent:self.agent];
    [repos addObject:macportsorg];
    
    GScrape *freecode = [[GFreecode alloc] initWithAgent:self.agent];
    GScrape *pkgsrcse = [[GPkgsrcSE alloc] initWithAgent:self.agent];
    GScrape *appshopper = [[GAppShopper alloc] initWithAgent:self.agent];
    GScrape *macupdate = [[GMacUpdate alloc] initWithAgent:self.agent];
    GScrape *versiontracker = [[GVersionTracker alloc] initWithAgent:self.agent];
    GScrape *appshopperios = [[GAppShopperIOS alloc] initWithAgent:self.agent];
    [scrapes addObjectsFromArray:@[freecode, pkgsrcse, appshopper, macupdate, versiontracker, appshopperios]];
    
    GSource *source1 = [[GSource alloc] initWithName:@"SYSTEMS"];
    source1.categories = [NSMutableArray array];
    [source1.categories addObjectsFromArray:systems];
    GSource *source2 = [[GSource alloc] initWithName:@"STATUS"];
    source2.categories = [NSMutableArray array];
    [source2.categories addObjectsFromArray:@[[[GSource alloc] initWithName:@"installed"], [[GSource alloc] initWithName:@"outdated"], [[GSource alloc] initWithName:@"inactive"]]];
    GSource *source3 = [[GSource alloc] initWithName:@"REPOS"];
    source3.categories = [NSMutableArray array];
    [source3.categories addObjectsFromArray:repos];
    GSource *source4 = [[GSource alloc] initWithName:@"SCRAPES"];
    source4.categories = [NSMutableArray array];
    [source4.categories addObjectsFromArray:scrapes];
    [sourcesController setContent:[NSMutableArray arrayWithObjects:source1, [[GSource alloc] initWithName:@""], source2, [[GSource alloc] initWithName:@""], source3, [[GSource alloc] initWithName:@""], source4, nil]];
    [sourcesOutline expandItem:nil expandChildren:YES];
    [sourcesOutline display];
    
    self.browser =  [SBApplication applicationWithBundleIdentifier:@"com.apple.Safari"];
    [self info:welcomeMsg];
    selectedSegment = @"Info";
    [tableProgressIndicator startAnimation:self];
    [self performSelectorInBackground:@selector(reloadAllPackages) withObject:nil];
    [applyButton setEnabled:NO];
    [stopButton setEnabled:NO]; // TODO
}


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}


- (void)windowWillClose:(NSNotification *)notification {
    system("osascript -e 'tell application \"Terminal\" to close (windows whose custom title contains \"Guigna\")'");
}


- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)subview {
    return ![subview isEqualTo:[splitView subviews][0]];
}


- (BOOL)outlineView:(NSOutlineView *)outlineView isGroupItem:(id)item {
    GSource *source = (GSource *)[item representedObject];
    return (source.categories != nil) && ![source isKindOfClass:[GSystem class]];
}

- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item {
    GSource *source = (GSource *)[item representedObject];
    if (![[[item parentNode] representedObject] isKindOfClass:[GSource class]])
        return [outlineView makeViewWithIdentifier:@"HeaderCell" owner:self];
    else {
        if (source.categories == nil && [[[item parentNode] representedObject] isKindOfClass:[GSystem class]])
            return [outlineView makeViewWithIdentifier:@"LeafCell" owner:self];
        else
            return [outlineView makeViewWithIdentifier:@"DataCell" owner:self];
    }
}

- (BOOL)outlineView:(NSOutlineView *)outlineView shouldShowOutlineCellForItem:(id)item {
    return [(GSource *)[item representedObject] isKindOfClass:[GSystem class]];
}


- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename {
    NSMutableString *history = [[self.shell history] mutableCopy];
    [history setString:[history stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    [self log:history]; [self log:@"\n"];
    [stopButton setEnabled:NO];
    if ([history hasSuffix:@"^C"]) { // TODO: || [history hasSuffix:@"Password:"]
        [segmentedControl setSelectedSegment:-1];
        [self updateTabView:nil];
        [self status:@"Shell: Interrupted."];
        return YES;
    }
    else {
        NSInteger sep = [history rangeOfString:@"--->" options:NSBackwardsSearch].location;
        NSInteger sep2 = [history rangeOfString:@"==>" options:NSBackwardsSearch].location;
        if (sep2 != NSNotFound && sep2 > sep)
            sep = sep2;
        sep2 = [history rangeOfString:@"&>/dev/null" options:NSBackwardsSearch].location;
        if (sep2 != NSNotFound && sep2 > sep)
            sep = NSNotFound;
        if (sep == NSNotFound)
            sep = [history rangeOfString:@"\n" options:NSBackwardsSearch].location;
        NSArray *lastLines = [[history substringFromIndex:sep] componentsSeparatedByString:@"\n"];
        if ([lastLines count] > 1) {
            if ([lastLines[1] hasPrefix:@"Error"]) {
                [segmentedControl setSelectedSegment:-1];
                [self updateTabView:nil];
                [self status:@"Shell: Error."];
                return YES;
            }
        }
        [self status:@"Shell: OK."];
    }
    if ([filename isEqualToString:[@"~/Library/Application Support/Guigna/output" stringByExpandingTildeInPath]]) {
        [self status:@"Analyzing shell outputs..."];
        if ([markedItems count] > 0) {
            GMark mark;
            NSString *markName;
            for (GItem *item in markedItems) {
                mark = item.mark;
                markName = @[@"None", @"Install", @"Uninstall", @"Deactivate", @"Upgrade", @"Fetch", @"Clean"][mark];
                // TODO verify command did really complete
                if (mark == GInstallMark) {
                    if ([item.system.name isEqualToString:@"MacPorts"]) {
                        if ([[item.system installedPackagesNamed:item.name] count] > 0) {
                            ((GPackage *)item).variants = ((GPackage *)[item.system installedPackagesNamed:item.name][0]).variants;
                        }
                    }
                    ((GPackage *)item).version = ((GPackage *)[item.system installedPackagesNamed:item.name][0]).version;
                    item.status = GUpToDateStatus;
                    
                } else if (mark == GUninstallMark) {
                    item.status = GAvailableStatus;
                    
                } else if (mark == GDeactivateMark) {
                    item.status = GInactiveStatus;
                    
                } else if (mark == GUpgradeMark) {
                    ((GPackage *)item).version = ((GPackage *)[item.system installedPackagesNamed:item.name][0]).version;
                    item.status = GUpToDateStatus;
                }
                [self log:[NSString stringWithFormat:@"===> %@ %@ %@: DONE\n", markName, item.system.name, item.name]];
                item.mark = GNoneMark;
                [itemsTable display];
            }
            // update status of currently displayed items
            for (GPackage *package in items) {
                GPackage *indexedPackage = (GPackage *)packagesIndex[[package key]];
                GMark mark = indexedPackage.mark;
                if (package.mark != GNoneMark && mark == GNoneMark) {
                    if (!(package.mark == GFetchMark || package.mark == GCleanMark)) {
                        package.status = indexedPackage.status;
                        package.version = indexedPackage.version;
                    }
                    package.mark = GNoneMark;
                }
                if (mark != GNoneMark)
                    package.mark = mark;
            }
            [itemsTable display];
        }
        [self status:@"Shell: OK."];
        
    } else if ([filename isEqualToString:[@"~/Library/Application Support/Guigna/sync" stringByExpandingTildeInPath]]) {
        [self performSelectorInBackground:@selector(reloadAllPackages) withObject:nil];
    }
    
    return YES;
}


-(void)reloadAllPackages {
    @autoreleasepool {
        [itemsController setFilterPredicate:nil];
        [itemsController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[itemsController arrangedObjects] count])]];
        [itemsController setSortDescriptors:nil];
        NSMutableDictionary *newIndex = [NSMutableDictionary dictionary];
        NSInteger updated = 0, new = 0;
        GPackage *previousPackage;
        GPackage *package;
        for (GSystem *system in systems) {
            NSString *systemName = system.name;
            [self status:[@"Indexing " stringByAppendingFormat:@"%@...", systemName]];
            [itemsController addObjects:[system list]];
            [itemsTable display];
            if ([packagesIndex count] > 0) {
                if ([systemName isEqualToString:@"Mac OS X"]
                    || [systemName isEqualToString:@"FreeBSD"]) // don't compare previous index
                    continue;
                for (package in system.items) {
                    previousPackage = (GPackage *)packagesIndex[[package key]];
                    // TODO: keep mark
                    if (previousPackage == nil) {
                        package.status = GNewStatus;
                        new += 1;
                    } else if ( ![previousPackage.version isEqualToString:package.version]) {
                        package.status = GUpdatedStatus;
                        updated += 1;
                    }
                }
            }
            [newIndex addEntriesFromDictionary:system.packagesIndex];
        }
        
        if ([packagesIndex count] > 0) {
            NSString *name;
            NSArray *currentUpdated = [[[sourcesController content][2] categories] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH 'updated'"]];
            if ([currentUpdated count] > 0 && updated == 0) {
                [[[sourcesController content][2] mutableArrayValueForKey:@"categories"] removeObject:currentUpdated[0]];
            }
            if (updated > 0) {
                name = [NSString stringWithFormat:@"updated (%ld)", updated];
                if ([currentUpdated count] == 0) {
                    GSource *updatedSource = [[GSource alloc] initWithName:name];
                    [[[sourcesController content][2] mutableArrayValueForKey:@"categories"] addObject:updatedSource];
                } else
                    ((GSource *)currentUpdated[0]).name = name;
            }
            NSArray *currentNew = [[[sourcesController content][2] categories] filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name BEGINSWITH 'new'"]];
            if ([currentNew count] > 0 && new == 0) {
                [[[sourcesController content][2] mutableArrayValueForKey:@"categories"] removeObject:currentNew[0]];
            }
            if (new > 0) {
                name = [NSString stringWithFormat:@"new (%ld)", new];
                if ([currentNew count] == 0) {
                    GSource *newSource = [[GSource alloc] initWithName:name];
                    [[[sourcesController content][2] mutableArrayValueForKey:@"categories"] addObject:newSource];
                } else
                    ((GSource *)currentNew[0]).name = name;
            }
            [allPackages removeAllObjects];
            [packagesIndex removeAllObjects];
            
        } else {
            for (GSystem *system in [[sourcesController content][0] categories]) {
                [self status:@"Indexing categories..."];
                system.categories = [NSMutableArray array];
                NSMutableArray *cats = [system mutableArrayValueForKey:@"categories"];
                for (NSString *category in [system categoriesList]) {
                    [cats addObject:[[GSource alloc] initWithName:category]];
                }
            }
            [sourcesOutline reloadData];
            [sourcesOutline display];
        }
        
        [packagesIndex setDictionary:newIndex];
        [allPackages addObjectsFromArray:items];
        [itemsController setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"status" ascending:NO]]];
        [tableProgressIndicator stopAnimation:self];
        [markedItems removeAllObjects];
        self.marksCount = 0;
        [applyButton setEnabled:NO];
        // TODO: remember marked items
        //        marksCount = [markedItems count];
        //        if (marksCount > 0)
        //            [applyButton setEnabled:YES];
        [self status:@"OK."];
    }
}


- (IBAction)syncAction:(id)sender {
    [tableProgressIndicator startAnimation:self];
    [self info:@"[Contents not yet available]"];
    [self updateCmdLine:@""];
    [stopButton setEnabled:YES];
    [self sync:sender];
}


- (void)sync:(id)sender {
    NSMutableArray *privilegedTasks = [NSMutableArray array];
    NSMutableArray *tasks = [NSMutableArray array];
    for (GSystem *system in systems) {
        [self status:[@"Syncing " stringByAppendingFormat:@"%@...", system.name]];
        NSString *selfupdateCmd = [system selfupdateCmd];
        if (selfupdateCmd == nil)
            continue;
        if ([selfupdateCmd hasPrefix:@"sudo"]) {
            [privilegedTasks addObject:selfupdateCmd];
        } else
            [tasks addObject:selfupdateCmd];
    }
    if ([privilegedTasks count] > 0) {
        [self execute:[privilegedTasks componentsJoinedByString:@" ; "] withBaton:@"sync"];
    }
    if ([tasks count] > 0) {
        [segmentedControl setSelectedSegment:-1];
        [self updateTabView:nil];
        for (NSString *task in tasks) {
            [self log:[NSString stringWithFormat: @"===> %@\n", task]];
            [self log:[agent outputForCommand:task]];
        }
        if ([privilegedTasks count] == 0) {
            [self performSelectorInBackground:@selector(reloadAllPackages) withObject:nil];
            [self status:@"OK."];
        }
    }
}


- (void)outlineViewSelectionDidChange:(NSOutlineView *)outline {
    [self sourcesSelectionDidChange:outline];
}

- (void)sourcesSelectionDidChange:(id)sender {
    NSMutableArray *selectedSources = [NSMutableArray arrayWithArray:[self.sourcesController selectedObjects]];
    [tableProgressIndicator startAnimation:self];
    NSMutableArray *selectedSystems = [NSMutableArray array];
    for (GSystem *system in systems) {
        if ([selectedSources containsObject:system]) {
            [selectedSystems addObject:system];
            [selectedSources removeObject:system];
        }
    }
    if ([selectedSystems count] == 0)
        [selectedSystems addObjectsFromArray:systems];
    if ([selectedSources count] == 0)
        [selectedSources addObject:[sourcesController content][0]]; // SYSTEMS
    NSString *src;
    NSString *filter = [searchField stringValue];
    [itemsController setFilterPredicate:nil];
    [itemsController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[itemsController arrangedObjects] count])]];
    [itemsController setSortDescriptors:nil];
    [self updateCmdLine:@""];
    BOOL first = YES;
    for (GSource *source in selectedSources) {
        src = source.name;
        if ([src isEqualToString:@"AppShopper"]
            || [src isEqualToString:@"MacUpdate"]
            || [src isEqualToString:@"VersionTracker"]
            || [src isEqualToString:@"AppShopper iOS"]
            || [src isEqualToString:@"Pkgsrc.se"]
            || [src isEqualToString:@"Native Installers"]
            || [src isEqualToString:@"Rudix"]
            || [src isEqualToString:@"MacPorts.org"]
            || [src isEqualToString:@"Freecode"]) {
            [itemsTable display];
            ((GScrape *)source).pageNumber = 1;
            [self updateScrape:(GScrape *)source];
        } else {
            if (first)
                [itemsController addObjects:allPackages];
            for (GSystem *system in selectedSystems) {
                NSArray *packages = @[];
                if ([src isEqualToString:@"installed"]) {
                    if (first) {
                        [self status:@"Verifying installed packages..."];
                        [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(GUpToDateStatus)]];
                        [itemsTable display];
                    }
                    packages = [system installed];
                } else if ([src isEqualToString:@"outdated"]) {
                    if (first) {
                        [self status:@"Verifying outdated packages..."];
                        [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(GOutdatedStatus)]];
                        [itemsTable display];
                    }
                    packages = [system outdated];
                } else if ([src isEqualToString:@"inactive"]) {
                    if (first) {
                        [self status:@"Verifying inactive packages..."];
                        [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(GInactiveStatus)]];
                        [itemsTable display];
                    }
                    packages = [system inactive];
                } else if ([src hasPrefix:@"updated"]) {
                    if (first) {
                        [self status:@"Verifying updated packages..."];
                        [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(GUpdatedStatus)]];
                        [itemsTable display];
                        packages = [[itemsController arrangedObjects] mutableCopy];
                    }
                } else if ([src hasPrefix:@"new "]) {
                    if (first) {
                        [self status:@"Verifying new packages..."];
                        [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"status == %@", @(GNewStatus)]];
                        [itemsTable display];
                        packages = [[itemsController arrangedObjects] mutableCopy];
                    }
                } else if (!([src isEqualToString:@"SYSTEMS"]
                             || [src isEqualToString:@"STATUS"]
                             || [src isEqualToString:@""])) { // a category was selected
                    [itemsController setFilterPredicate:[NSPredicate predicateWithFormat:@"categories CONTAINS[c] %@", src]];
                    packages = [system.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"categories CONTAINS[c] %@", src]];
                } else {
                    [itemsController setFilterPredicate:nil];
                    [itemsTable display];
                    packages = system.items;
                    if (first && [[itemsController selectedObjects] count] == 0) {
                        [segmentedControl setSelectedSegment:2]; // shows System Log
                        [self updateTabView:nil];
                    }
                }
                if (first) {
                    [itemsController setFilterPredicate:nil];
                    [itemsController removeObjectsAtArrangedObjectIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [[itemsController arrangedObjects] count])]];
                    first = NO;
                }
                [itemsController addObjects:packages];
                [itemsTable display];
                for (GPackage *package in packages) {
                    GMark mark = ((GPackage *)packagesIndex[[package key]]).mark;
                    if (mark != GNoneMark)
                        package.mark = mark;
                }
                [itemsTable display];
            }
        }
    }
    [searchField setStringValue:filter];
    [searchField performClick:self];
    [tableProgressIndicator stopAnimation:self];
    if (!([[statusField stringValue] hasPrefix:@"Executing"] || [[statusField stringValue] hasPrefix:@"Loading"]))
        [self status:@"OK."];
}


- (void)tableViewSelectionDidChange:(NSNotification *)table {
    NSArray *selectedItems = [itemsController selectedObjects];
    GItem *item = nil;
    if ([selectedItems count] > 0)
        item = selectedItems[0];
    if (item == nil)
        [self info:@""];
    if ([selectedSegment isEqualToString:@"Log"] && [[cmdline stringValue] isEqualToString:[item.system log:nil]]) {
        [segmentedControl setSelectedSegment:0];
        selectedSegment = @"Info";
    } else if ([selectedSegment isEqualToString:@"Shell"]) {
        [segmentedControl setSelectedSegment:0];
        selectedSegment = @"Info";
    }
    [self updateTabView:item];
}

- (IBAction)switchSegment:(NSSegmentedControl *)sender {
    self.selectedSegment = [sender labelForSegment:[sender selectedSegment]];
    NSArray *selectedItems = [itemsController selectedObjects];
    GItem *item = nil;
    if ([selectedItems count] > 0)
        item = selectedItems[0];
    if ([selectedSegment isEqualToString:@"Shell"]
        || [selectedSegment isEqualToString:@"Info"]
        || [selectedSegment isEqualToString:@"Home"]
        || [selectedSegment isEqualToString:@"Log"]
        || [selectedSegment isEqualToString:@"Contents"]
        || [selectedSegment isEqualToString:@"Makefile"]
        || [selectedSegment isEqualToString:@"Deps"]) {
        [self updateTabView:item];
    }
}


- (IBAction)toggleShell:(NSButton *)button {
    NSArray *selectedItems = [itemsController selectedObjects];
    GItem *item = nil;
    if ([selectedItems count] > 0)
        item = selectedItems[0];
    if ([button state] == NSOnState) {
        previousSegment = [segmentedControl selectedSegment];
        [segmentedControl setSelectedSegment:-1];
        self.selectedSegment = @"Shell";
        [self updateTabView:item];
    } else {
        if (previousSegment != -1) {
            [segmentedControl setSelectedSegment:previousSegment];
            [self updateTabView:item];
        }
    }
}


- (void)updateTabView:(GItem *)item {
    if ([segmentedControl selectedSegment] == -1) {
        [shellDisclosure setState:NSOnState];
        selectedSegment = @"Shell";
    } else {
        [shellDisclosure setState:NSOffState];
        selectedSegment = [segmentedControl labelForSegment:[segmentedControl selectedSegment]];
    }
    [clearButton setHidden: ![selectedSegment isEqualToString:@"Shell"]];
    [moreButton setHidden: ![item.source isKindOfClass:[GScrape class]]];
    
    if ([selectedSegment isEqualToString:@"Home"] || [selectedSegment isEqualToString:@"Log"]) {
        [tabView selectTabViewItemWithIdentifier:@"web"];
        [webView display];
        NSString *page = nil;
        if (item != nil) {
            if ([selectedSegment isEqualToString:@"Log"]) {
                if ([item.system.name isEqualToString:@"MacPorts"] && item.categories == nil)
                    item = ((GPackage *)packagesIndex[[(GPackage*)item key]]);
                page = [item.source log:item];
            } else {
                if (item.homepage == nil)
                    item.homepage = [item.source home:item];
                page = item.homepage;
            }
        } else {
            page = [cmdline stringValue];
            if (![page hasPrefix:@"http:"]) {
                page = @"https://github.com/gui-dos/Guigna/";
                if ([[sourcesController selectedObjects] count] == 1 ) {
                    if ([[sourcesController selectedObjects][0] isKindOfClass:[GSystem class]]) {
                        page = [(GSystem *)[sourcesController selectedObjects][0] log:nil];
                    }
                    
                }
            }
        }
        [webView setMainFrameURL:page];
        
    } else {
        if (item != nil) {
            NSString *cmd;
            cmd = [item.source.cmd lastPathComponent];
            if ([item.system.name isEqualToString:@"Mac OS X"]) {
                [self updateCmdLine:[cmd stringByAppendingFormat:@" %@", item.ID]];
            }
            else
                [self updateCmdLine:[cmd stringByAppendingFormat:@" %@", item.name]];
        }
        if ([selectedSegment isEqualToString:@"Info"]
            || [selectedSegment isEqualToString:@"Contents"]
            || [selectedSegment isEqualToString:@"Makefile"]
            || [selectedSegment isEqualToString:@"Deps"]) {
            [infoText setDelegate:nil]; // avoid textViewDidChangeSelection notification
            [tabView selectTabViewItemWithIdentifier:@"info"];
            [tabView display];
            if (item != nil) {
                [self info:@""];
                if (![[statusField stringValue] hasPrefix:@"Executing"])
                    [self status:@"Getting info..."];
                if ([selectedSegment isEqualToString:@"Info"]) {
                    [self info:[item.source info:item]];
                } else if ([selectedSegment isEqualToString:@"Contents"]) {
                    [self info:[NSString stringWithFormat:@"[Click on a path to open in Finder]\n%@", [item.source contents:item]]];
                } else if ([selectedSegment isEqualToString:@"Makefile"]) {
                    [self info:[item.source cat:item]];
                } else if ([selectedSegment isEqualToString:@"Deps"]) {
                    [tableProgressIndicator startAnimation:self];
                    [self status:@"Computing dependencies..."];
                    [self info:[NSString stringWithFormat:@"%@ \nDependents:\n%@", [item.source deps:item], [item.source dependents:item]]];
                    [tableProgressIndicator stopAnimation:self];
                }
            }
            [infoText setDelegate:self];
            if (![[statusField stringValue] hasPrefix:@"Executing"])
                [self status:@"OK."];
        } else if ([selectedSegment isEqualToString:@"Shell"]) {
            [tabView selectTabViewItemWithIdentifier:@"log"];
            [tabView display];
        }
    }
}

- (void)updateScrape:(GScrape *)scrape {
    [segmentedControl setSelectedSegment:1];
    selectedSegment = @"Home";
    [tabView display];
    [self status:[@"Scraping " stringByAppendingFormat:@"%@...", scrape.name]];
    NSInteger scrapesCount = [[[defaultsController values] valueForKey:@"ScrapesCount"] integerValue];
    NSInteger pagesToScrape = ceil(scrapesCount / 1.0 / scrape.itemsPerPage);
    for (int i = 0; i < pagesToScrape; i++) {
        [itemsController addObjects:scrape.items];
        [itemsTable display];
        scrape.pageNumber++;
    }
    [itemsController setSelectionIndex:0];
    [itemsTable display];
    [moreButton setHidden:NO];
    [self updateTabView:[itemsController selectedObjects][0]];
    [tableProgressIndicator stopAnimation:self];
    if (![[statusField stringValue] hasPrefix:@"Executing"])
        [self status:@"OK."];
}

- (IBAction)moreScrapes:(id)sender {
    [tableProgressIndicator startAnimation:self];
    GScrape *scrape = [sourcesController selectedObjects][0]; // TODO: multiple scrapes
    scrape.pageNumber +=1;
    [self updateScrape:scrape];
    [itemsController rearrangeObjects];
    [tableProgressIndicator stopAnimation:self];
}


- (void)webView:(WebView *)sender didFinishLoadForFrame:(WebFrame *)frame {
    NSString *cmdlineString = [cmdline stringValue];
    if ([cmdlineString hasPrefix:@"Loading"]) {
        [self updateCmdLine:[cmdlineString substringWithRange:NSMakeRange(8, [cmdlineString length]-11)]];
        if (![[statusField stringValue] hasPrefix:@"Executing"])
            [self status:@"OK."];
    } else
        [self updateCmdLine:[webView mainFrameURL]];
}

- (void)webView:(WebView *)sender didStartProvisionalLoadForFrame:(WebFrame *)frame {
    [self updateCmdLine:[@"Loading " stringByAppendingFormat:@"%@...", [webView mainFrameURL]]];
    if (![[statusField stringValue] hasPrefix:@"Executing"])
        [self status:[@"Loading " stringByAppendingFormat:@"%@...", [webView mainFrameURL]]];
}


- (IBAction)executeCmdLine:(id)sender {
    NSArray *selectedItems = [itemsController selectedObjects];
    GItem *item = nil;
    NSString *input, *output;
    if ([selectedItems count] > 0)
        item = selectedItems[0];
    input = cmdline.stringValue;
    NSMutableArray *tokens = [[input componentsSeparatedByString:@" "] mutableCopy];
    NSString *cmd = tokens[0];
    if ([cmd hasPrefix:@"http:"]) {
        item = nil;
        [self updateTabView:item];
    } else {
        [segmentedControl setSelectedSegment:-1];
        [self updateTabView:item];
        if ([cmd isEqualToString:@"sudo"])
            [self sudo:[input substringFromIndex:5]];
        else {
            for (GSystem *system in systems) {
                if ([system.cmd hasSuffix:cmd]) {
                    cmd = system.cmd;
                    tokens[0] = cmd;
                    break;
                }
            }
            if ( ![cmd hasPrefix:@"/"]) {
                NSString *output = [agent outputForCommand:[NSString stringWithFormat:@"/usr/bin/which %@", cmd]];
                if ([output length] != 0)
                    tokens[0] = [output substringToIndex:[output length]-1];
                else
                    tokens[0] = [NSString stringWithFormat:@"/bin/sh -c %@", cmd];
                // TODO:show stderr
            }
            input = [tokens componentsJoinedByString:@" "];
            [self log:[NSString stringWithFormat:@"===> %@\n", input]];
            [self status:[NSString stringWithFormat:@"Executing '%@'...", input]];
            output = [agent outputForCommand:input];
            [self status:@"OK."];
            [self log:output];
        }
    }
}

- (IBAction)executeCommandsMenu:(id)sender {
    ;
}


- (void)execute:(NSString *)cmd withBaton:(NSString *)baton {
    // TODO:test
    [self status:[NSString stringWithFormat:@"Executing '%@' in the shell...", cmd]];
    [self log:[NSString stringWithFormat:@"===> %@\n", cmd]];
    NSString *command;
    if ([baton isEqualToString:@"relaunch"])
        command = [NSString stringWithFormat:@"sudo -k ; %@ ; osascript -e 'tell app \"Guigna\"' -e 'quit' -e 'activate' -e 'end' &>/dev/null", cmd];
    else
        command = [NSString stringWithFormat:@"%@ ; osascript -e 'tell app \"Guigna\"' -e 'open POSIX file \"%@/%@\"' -e 'end' &>/dev/null", cmd, self.APPDIR, baton];
    [self shell:self];
    [terminal doScript:command in:self.shell];
}

- (void)executeAsRoot:(NSString *)cmd {
    system([[NSString stringWithFormat: @"osascript -e 'do shell script \"%@\"with administrator privileges'", cmd] cStringUsingEncoding:NSUTF8StringEncoding]);
}

- (void)execute:(NSString *)cmd {
    [self execute:cmd withBaton:@"output"];
}

- (void)sudo:(NSString *)cmd withBaton:(NSString *)baton {
    NSString *command = [NSString stringWithFormat:@"sudo %@", cmd];
    [self execute:command withBaton:baton];
}

- (void)sudo:(NSString *)cmd {
    [self sudo:cmd withBaton:@"output"];
}


- (void)updateCmdLine:(NSString *)cmd {
    [cmdline setStringValue:cmd];
    [cmdline display];
}


- (void)controlTextDidBeginEditing:(NSNotification *)aNotification {
    ;
}

- (void)textViewDidChangeSelection:(NSNotification *)aNotification {
    NSRange selectedRange = [infoText selectedRange];
    NSTextStorage *storage = [infoText textStorage];
    NSString *line = [[storage string] substringWithRange:[[storage string] paragraphRangeForRange: selectedRange]];
    if ([selectedSegment isEqualToString:@"Contents"]) {
        NSString *file = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        // TODO detect types
        if ([file hasSuffix:@".nib"]) {
            // [self log:[self.agent outputForCommand:[NSString stringWithFormat:@"/usr/bin/plutil -convert xml1 -o - %@", file]]];
            [self execute:[NSString stringWithFormat:@"/usr/bin/plutil -convert xml1 -o - %@", file]];
            
        } else {
            [[NSWorkspace sharedWorkspace] openFile:file];
        }
    } else if ([selectedSegment isEqualToString:@"Deps"]) {
        NSString *package = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"TODO select dep: %@", package);
    }
}


- (void)status:(NSString *)msg {
    if ([msg hasSuffix:@"..."]) {
        [progressIndicator startAnimation:self];
        if ([statusField.stringValue hasPrefix:@"Executing"])
            msg = [NSString stringWithFormat:@"%@ %@", statusField.stringValue, msg];
    }
    else
        [progressIndicator stopAnimation:self];
    [statusField setStringValue:msg];
    [statusField display];
}

- (void)optionsStatus:(NSString *)msg {
    if ([msg hasSuffix:@"..."]) {
        [optionsProgressIndicator startAnimation:self];
        if ([optionsStatusField.stringValue hasPrefix:@"Executing"])
            msg = [NSString stringWithFormat:@"%@ %@", optionsStatusField.stringValue, msg];
    }
    else
        [optionsProgressIndicator stopAnimation:self];
    [optionsStatusField setStringValue:msg];
    [optionsStatusField display];
    [self status:msg];
    if ([msg isEqualToString:@"OK."]) {
        [optionsStatusField setStringValue:@""];
        [optionsStatusField display];
    }
    
}


- (void)info:(NSString *)msg {
    infoText.string = msg;
    [infoText scrollRangeToVisible:NSMakeRange(0,0)];
    [infoText display];
}


- (void)log:(NSString *)text {
    NSAttributedString *string = [[NSAttributedString alloc] initWithString:text attributes:
                                  @{NSFontAttributeName: [NSFont fontWithName:@"Andale Mono" size:11.0]}];
    NSTextStorage *storage = [logText textStorage];
    [storage beginEditing];
    [storage appendAttributedString:string];
    [storage endEditing];
    [logText display];
    [logText scrollRangeToVisible:NSMakeRange(logText.string.length, 0)];
}

- (IBAction)clear:(id)sender {
    [logText setString:@""];
}


- (void)menuNeedsUpdate:(NSMenu *)menu {
    NSString *title = [menu title];
    NSMutableArray *selectedItems = [[itemsController selectedObjects] mutableCopy];
    if ([title isEqualToString:@"Mark"]) {
        [selectedItems addObject:[itemsController arrangedObjects][[itemsTable clickedRow]]];
        NSMenuItem *installMenu = [menu itemWithTitle:@"Install"];
        NSArray *currentVariants;
        for (GItem *item in selectedItems) {
            if ([item.system.name isEqualToString:@"MacPorts"]) {
                NSString *markedVariants = ((GPackage *)item).markedVariants;
                if (markedVariants != nil) {
                    currentVariants = [[markedVariants substringFromIndex:1] componentsSeparatedByString:@"+"];
                }
                NSArray *variants = [[[[agent outputForCommand:[NSString stringWithFormat:@"%@ info --variants %@", item.system.cmd, item.name]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] substringFromIndex:10] componentsSeparatedByString:@", "];
                NSMenu *variantsMenu = [[NSMenu alloc] initWithTitle:@"Variants"];
                for (NSString *variant in variants) {
                    [variantsMenu addItemWithTitle:variant action:@selector(mark:) keyEquivalent:@""];
                    for (NSString *markedVariant in currentVariants) {
                        if ([markedVariant isEqualToString:variant]) {
                            [[variantsMenu itemWithTitle:variant] setState:NSOnState];
                        }
                    }
                }
                [installMenu setSubmenu:variantsMenu];
            } else {
                if ([installMenu hasSubmenu]) {
                    [[installMenu submenu] removeAllItems];
                    [installMenu setSubmenu:nil];
                }
            }
        }
    } else if ([title isEqualToString:@"Commands"]) {
        for (int i = 1; i < [commandsPopUp numberOfItems]; i++) {
            [commandsPopUp removeItemAtIndex:1];
        }
        if ([selectedItems count] > 0) {
            // GPackage *package = [selectedItems objectAtIndex:0]; // TODO
            // [commandsPopUp addItemsWithTitles:[package.system availableCommands]];
            [commandsPopUp addItemWithTitle:@"[TODO]"];
        } else {
            [commandsPopUp addItemWithTitle:@"[no package selected]"];
        }
    }
}


- (IBAction)showMarkMenu:(id)sender {
    [NSMenu popUpContextMenu:markMenu withEvent:[NSApp currentEvent] forView:itemsTable];
}


- (IBAction)marks:(id)sender {
    // TODO
    [self showMarkMenu:self];
}


- (IBAction)mark:(id)sender {
    NSMutableArray *selectedItems = [[itemsController selectedObjects] mutableCopy];
    if ([itemsTable clickedRow] != -1)
        [selectedItems addObject:[itemsController arrangedObjects][[itemsTable clickedRow]]];
    NSString *title;
    GMark mark;
    for (GItem *item in selectedItems) {
        title = [sender title];
        if ([title isEqualToString:@"Launch"]) {  // TODO: Download manager
            if (item.URL != nil) {
                [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:item.URL]];
            }
        } else {
            if ([title isEqualToString:@"Install"])
                mark = GInstallMark;
            else if ([title isEqualToString:@"Uninstall"])
                mark = GUninstallMark;
            else if ([title isEqualToString:@"Deactivate"])
                mark = GDeactivateMark;
            else if ([title isEqualToString:@"Upgrade"])
                mark = GUpgradeMark;
            else if ([title isEqualToString:@"Fetch"])
                mark = GFetchMark;
            else if ([title isEqualToString:@"Clean"]) // TODO: clean immediately
                mark = GCleanMark;
            else if ([title isEqualToString:@"Unmark"]) {
                mark = GNoneMark;
                if ([item isKindOfClass:[GPackage class]]) {
                    ((GPackage *)item).markedVariants = nil;
                    ((GPackage *)packagesIndex[[(GPackage *)item key]]).markedVariants = nil;
                }
            } else {
                NSString *markedVariants;
                NSString *currentVariants = ((GPackage *)item).markedVariants;
                if ([sender state] == NSOffState) {
                    if (currentVariants == nil)
                        currentVariants = @"";
                    markedVariants = [NSString stringWithFormat:@"%@+%@", currentVariants, title];
                } else {
                    markedVariants = [currentVariants stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"+%@", title] withString:@""];
                    if ([markedVariants isEqualToString:@""])
                        markedVariants = nil;
                }
                ((GPackage *)item).markedVariants = markedVariants;
                ((GPackage *)packagesIndex[[(GPackage *)item key]]).markedVariants = markedVariants;
                mark = GInstallMark;
            }
            if ([title isEqualToString:@"Unmark"]) {
                if (item.mark != GNoneMark)
                    marksCount--;
            } else {
                if (item.mark == GNoneMark)
                    marksCount++;
            }
            if (marksCount > 0)
                [applyButton setEnabled:YES];
            else
                [applyButton setEnabled:NO];
            item.mark = mark;
            GPackage *package = (GPackage *)packagesIndex[[(GPackage *)item key]];
            package.mark = mark;
            package.version = ((GPackage *)item).version;
            package.variants = ((GPackage *)item).variants;
        }
    }
}


- (IBAction)apply:(id)sender {
    markedItems = [[allPackages filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"mark != 0"]] mutableCopy];
    marksCount = [markedItems count];
    if (marksCount == 0)
        return;
    [applyButton setEnabled:NO];
    [stopButton setEnabled:YES];
    [segmentedControl setSelectedSegment:-1];
    selectedSegment = @"Shell";
    [self updateTabView:nil];
    NSMutableArray *tasks = [NSMutableArray array];
    NSMutableSet *markedSystems = [NSMutableSet set];
    for (GPackage *item in markedItems) {
        [markedSystems addObject:item.system];
    }
    NSMutableDictionary *systemsDict = [NSMutableDictionary dictionary];
    for (GSystem *system in markedSystems) {
        systemsDict[system.name] = [NSMutableArray array];
    }
    for (GPackage *item in markedItems) {
        [systemsDict[item.system.name] addObject:item];
    }
    NSArray *prefixes = @[@"/opt/local", @"/usr/local", @"/sw"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSMutableArray *detectedPrefixes = [NSMutableArray array];
    for (NSString *prefix in prefixes) {
        if ([fileManager fileExistsAtPath:prefix])
            [detectedPrefixes addObject:prefix];
    }
    for (GSystem *system in systems) {
        if ([detectedPrefixes containsObject:system.prefix])
            [detectedPrefixes removeObject:system.prefix];
    }
    GMark mark;
    NSString *markName;
    for (GSystem *system in markedSystems) {
        NSMutableArray *systemTasks = [NSMutableArray array];
        BOOL hidesOthers = NO;
        for (GPackage *item in [systemsDict[system.name] allObjects]) {
            mark = item.mark;
            markName = @[@"None", @"Install", @"Uninstall", @"Deactivate", @"Upgrade", @"Fetch", @"Clean"][mark];
            if (mark == GInstallMark) {
                NSString *installCmd = [item.system installCmd:item];
                [systemTasks addObject:installCmd];
                hidesOthers = YES;
            } else if (mark == GUninstallMark) {
                [systemTasks addObject:[item.system uninstallCmd:item]];
                
            } else if (mark == GDeactivateMark) {
                [systemTasks addObject:[item.system deactivateCmd:item]];
                
            } else if (mark == GUpgradeMark) {
                NSString *upgradeCmd = [item.system upgradeCmd:item];
                [systemTasks addObject:upgradeCmd];
                hidesOthers = YES;
                
            } else if (mark == GFetchMark) {
                [systemTasks addObject:[item.system fetchCmd:item]];
                
            } else if (mark == GCleanMark) {
                [systemTasks addObject:[item.system cleanCmd:item]];
            }
        }
        if (hidesOthers == YES && ([systems count] > 1 || [detectedPrefixes count] > 0)) {
            for (GSystem *otherSystem in systems) {
                if ([otherSystem isEqual:system])
                    continue;
                if ([otherSystem hideCmd] != nil &&
                    ![[otherSystem hideCmd] isEqualToString:[system hideCmd]] &&
                    [fileManager fileExistsAtPath:otherSystem.prefix])
                    [tasks addObject:[otherSystem hideCmd]]; // TODO: set GOnlineMode
            }
            for (NSString *prefix in detectedPrefixes) {
                [tasks addObject:[NSString stringWithFormat:@"sudo mv %@ %@_off", prefix, prefix]];
            }
        }
        [tasks addObjectsFromArray:systemTasks];
        if (hidesOthers == YES && ([systems count] > 1 || [detectedPrefixes count] > 0)) {
            for (GSystem *otherSystem in systems) {
                if ([otherSystem isEqual:system])
                    continue;
                if ([otherSystem unhideCmd] != nil && [fileManager fileExistsAtPath:otherSystem.prefix])
                    [tasks addObject:[otherSystem unhideCmd]];
            }
            for (NSString *prefix in detectedPrefixes) {
                [tasks addObject:[NSString stringWithFormat:@"sudo mv %@_off %@", prefix, prefix]];
            }
        }
    }
    [self execute:[tasks componentsJoinedByString:@" ; "]];
}

- (IBAction)stop:(id)sender {
    // TODO: get terminal PID
    if (self.agent.processID != -1)
        NSLog(@"Agent PID: %i", self.agent.processID);
    for (NSString *process in shell.processes) {
        NSLog(@"Terminal Process: %@", process);
    }
}


- (IBAction)details:(id)sender {
}

- (IBAction)web:(id)sender {
    NSArray *selectedItems = [itemsController selectedObjects];
    GItem *item = nil;
    if ([selectedItems count] == 0)
        return;
    item = selectedItems[0];
    [browser activate];
    NSString *url = [cmdline stringValue];
    if ([url hasPrefix:@"Loading"]) {
        url = [url substringWithRange:NSMakeRange(8, [url length] - 11)];
        [self updateCmdLine:url];
        if (![[statusField stringValue] hasPrefix:@"Executing"])
            [self status:[NSString stringWithFormat:@"Launched in browser: %@", url]];
    }
    else if (![url hasPrefix:@"http://"]) {
        if (item.homepage != nil)
            url = item.homepage;
        else
            url = [item.system home:item];
    }
    [[[browser windows][0] document] setURL:[NSURL URLWithString:url]];
}


- (IBAction)shell:(id)sender {
    for (TerminalWindow *window in terminal.windows) {
        if ([window.name rangeOfString:@"Guigna"].location == NSNotFound)
            window.visible = NO;
    }
    [self.terminal activate];
    NSRect frame = tabView.frame;
    frame.size.width += 0;
    frame.size.height -= 3;
    frame.origin.x = _window.frame.origin.x + sourcesOutline.superview.frame.size.width + 1;
    frame.origin.y = _window.frame.origin.y + 22;
    for (TerminalWindow *window in terminal.windows) {
        if ([window.name rangeOfString:@"Guigna"].location != NSNotFound)
            shellWindow = window;
    }
    shellWindow.frame = frame;
    for (TerminalWindow *window in terminal.windows) {
        if ([window.name rangeOfString:@"Guigna"].location == NSNotFound)
            window.frontmost = NO;
    }
}

- (IBAction)options:(id)sender {
    [NSApp beginSheet:optionsPanel modalForWindow:_window modalDelegate:self didEndSelector:@selector(sheetDidEnd:returnCode:contextInfo:) contextInfo:nil];
}

- (void)sheetDidEnd:(NSWindow *)sheet returnCode:(NSInteger)returnCode contextInfo:(void *)contextInfo {
    [optionsPanel orderOut:self];
}

- (IBAction)setOptions:(id)sender {
    [NSApp endSheet:optionsPanel];
}


- (IBAction)preferences:(id)sender {
    // TODO: use defaultsController
    NSString *title = [sender title];
    NSInteger state = [sender state];
    GSource *source = nil;
    GSystem *system = nil;
    NSInteger status = GOffState;
    if (state == NSOnState) {
        [self optionsStatus:[NSString stringWithFormat: @"Adding %@...", title]];
        if ([title isEqualToString:@"Homebrew"] && [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/local/bin/brew"]) {
            system = [[GHomebrew alloc] initWithAgent:self.agent];
        } else if ([title isEqualToString:@"MacPorts"] && [[NSFileManager defaultManager] fileExistsAtPath:@"/opt/local/bin/port"]) {
            system = [[GMacPorts alloc] initWithAgent:self.agent];
        } else if ([title isEqualToString:@"Fink"]) {
            system = [[GFink alloc] initWithAgent:self.agent]; system.mode = GOnlineMode;
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/sw/bin/fink"]) {
                system.mode = GOfflineMode; // TODO: defaults
            }
        } else if ([title isEqualToString:@"pkgsrc"]) {
            system = [[GPkgsrc alloc] initWithAgent:self.agent]; system.mode = GOnlineMode;
            if ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/pkg/sbin/pkg_info"]) {
                system.mode = GOfflineMode;
            }
        } else if ([title isEqualToString:@"FreeBSD"]) {
            system = [[GFreeBSD alloc] initWithAgent:self.agent]; system.mode = GOnlineMode;
        }
        [systems addObject:system];
        [itemsController addObjects:[system list]]; // FIXME: memory peak if a source has not been selected before
        [itemsTable display];
        [allPackages addObjectsFromArray:system.items];
        [packagesIndex addEntriesFromDictionary:system.packagesIndex];
        source = system;
        // duplicate code from reloalAllPackages
        [[[sourcesController content][0] mutableArrayValueForKey:@"categories"] addObject:source];
        source.categories = [NSMutableArray array];
        NSMutableArray *cats = [source mutableArrayValueForKey:@"categories"];
        for (NSString *category in [system categoriesList]) {
            [cats addObject:[[GSource alloc] initWithName:category]];
        }
        [sourcesOutline reloadData];
        [sourcesOutline display];
        
    } else {
        [self optionsStatus:[NSString stringWithFormat: @"Removing %@...", title]];
        NSArray *filtered = [[[sourcesController content][0] categories]filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", title]];
        if ([filtered count] > 0) {
            source = filtered[0];
            status = source.status;
            if (status == GOnState) {
                [itemsController removeObjects:[items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"system.name == %@", title]]];
                [source.items removeAllObjects];
                [[[sourcesController content][0] mutableArrayValueForKey:@"categories"] removeObject:source];
                [systems removeObject:source];
            }
        }
    }
    [self optionsStatus:@"OK."];
}



- (IBAction)toolsAction:(id)sender {
    [NSMenu popUpContextMenu:toolsMenu withEvent:[NSApp currentEvent] forView:itemsTable];
}

- (IBAction)tools:(id)sender {
    NSString *title = [sender title];
    if ([title isEqualToString:@"Install Fink"]) {
        [self execute:[GFink setupCmd] withBaton:@"relaunch"];
        // TODO: activate system
    }
    
    else if ([title isEqualToString:@"Remove Fink"]) {
        [self execute:[GFink removeCmd] withBaton:@"relaunch"];
    }
    
    else if ([title isEqualToString:@"Install Homebrew"]) {
        [self execute:[GHomebrew setupCmd] withBaton:@"relaunch"];
    }
    
    else if ([title isEqualToString:@"Remove Homebrew"]) {
        [self execute:[GHomebrew removeCmd] withBaton:@"relaunch"];
    }
    
    else if ([title isEqualToString:@"Install pkgsrc"]) {
        [self execute:[GPkgsrc setupCmd] withBaton:@"relaunch"];
    }
    
    else if ([title isEqualToString:@"Fetch pkgsrc and INDEX"]) {
        [self execute:@"cd ~/Library/Application\\ Support/Guigna/pkgsrc ; curl -L -O ftp://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/INDEX ; curl -L -O ftp://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc.tar.gz ; sudo tar -xvzf pkgsrc.tar.gz -C /usr"];
    }
    
    else if ([title isEqualToString:@"Remove pkgsrc"]) {
        [self execute:[GPkgsrc removeCmd] withBaton:@"relaunch"];
    }
    
    else if ([title isEqualToString:@"Fetch FreeBSD INDEX"]) {
        [self execute:@"cd ~/Library/Application\\ Support/Guigna/FreeBSD ; curl -L -O ftp://ftp.freebsd.org/pub/FreeBSD/ports/packages/INDEX"];
    }
    
    else if ([title isEqualToString:@"Fetch MacPorts PortIndex"]) {
        [self execute:@"cd ~/Library/Application\\ Support/Guigna/Macports ; /usr/bin/rsync -rtzv rsync://rsync.macports.org/release/tarballs/PortIndex_darwin_11_i386/PortIndex PortIndex"];
        
    } else if ([title isEqualToString:@"Build Gtk-OSX"]) {
        [self execute:@"cd ~/Library/Application\\ Support/Guigna/ ; curl -L -O http://git.gnome.org/browse/gtk-osx/plain/gtk-osx-build-setup.sh ; sh gtk-osx-build-setup.sh ; ~/.local/bin/jhbuild bootstrap ; ~/.local/bin/jhbuild build meta-gtk-osx-bootstrap ; ~/.local/bin/jhbuild build meta-gtk-osx-core ; ~/.local/bin/jhbuild shell"];
    }
}


/**
 Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Guigna" in the user's Library directory. // /Library/Application Support
 */
- (NSURL *)applicationFilesDirectory {
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Guigna"];
}

/**
 Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Guigna" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return __managedObjectModel;
}

/**
 Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([properties[NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Guigna.storedata"];
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __persistentStoreCoordinator = coordinator;
    
    return __persistentStoreCoordinator;
}

/**
 Returns the managed object context for the application (which is already
 bound to the persistent store coordinator for the application.)
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return __managedObjectContext;
}

/**
 Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
 Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {
    
    // Save changes in the application's managed object context before the application terminates.
    
    if (!__managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {
        
        // Customize this code block to include application-specific recovery steps.
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }
        
        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];
        
        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }
    
    return NSTerminateNow;
}

@end
