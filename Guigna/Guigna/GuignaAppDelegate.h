#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import <ScriptingBridge/ScriptingBridge.h>
#import "Terminal.h"
#import "Safari.h"

#import "GuignaAgent.h"

#import "GItem.h"
#import "GSource.h"

#import "GMacPorts.h"
#import "GHomebrew.h"
#import "GCocoaPods.h"
#import "GFink.h"
#import "GMacOSX.h"
#import "GPkgsrc.h"
#import "GFreeBSD.h"
#import "GNative.h"
#import "GRudix.h"
#import "GMacPortsOrg.h"
#import "GFreecode.h"
#import "GPkgsrcSE.h"
#import "GAppShopper.h"
#import "GAppShopperIOS.h"
#import "GMacUpdate.h"
#import "GVersionTracker.h"

@interface GuignaAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSOutlineViewDelegate,NSOutlineViewDataSource, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate>

@property (strong, atomic) IBOutlet GuignaAgent *agent;
@property (strong, atomic) IBOutlet NSUserDefaultsController *defaultsController;

@property (strong, atomic) IBOutlet NSWindow *window;
@property (strong, atomic) IBOutlet NSOutlineView *sourcesOutline;
@property (strong, atomic) IBOutlet NSTableView *itemsTable;
@property (strong, atomic) IBOutlet NSSearchField *searchField;
@property (strong, atomic) IBOutlet NSTabView *tabView;
@property (strong, atomic) IBOutlet NSTextView *infoText;
@property (strong, atomic) IBOutlet WebView *webView;
@property (strong, atomic) IBOutlet NSTextView *logText;
@property (strong, atomic) IBOutlet NSSegmentedControl *segmentedControl;
@property (strong, atomic) IBOutlet NSPopUpButton *commandsPopUp;
@property (strong, atomic) IBOutlet NSButton *shellDisclosure;
@property (strong, atomic) IBOutlet NSTextField *cmdline;
@property (strong, atomic) IBOutlet NSTextField *statusField;
@property (strong, atomic) IBOutlet NSButton *clearButton;
@property (strong, atomic) IBOutlet NSTextField *statsLabel;
@property (strong, atomic) IBOutlet NSButton *moreButton;
@property (strong, atomic) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong, atomic) IBOutlet NSProgressIndicator *tableProgressIndicator;
@property (strong, atomic) IBOutlet NSToolbarItem *applyButton;
@property (strong, atomic) IBOutlet NSToolbarItem *stopButton;

@property (strong, atomic) IBOutlet NSMenu *toolsMenu;
@property (strong, atomic) IBOutlet NSMenu *markMenu;
@property (strong, atomic) IBOutlet NSPanel *optionsPanel;
@property (strong, atomic) IBOutlet NSProgressIndicator *optionsProgressIndicator;
@property (strong, atomic) IBOutlet NSTextField *optionsStatusField;

@property (strong, atomic) TerminalApplication *terminal;
@property (strong, atomic) TerminalTab *shell;
@property (strong, atomic) TerminalWindow *shellWindow;
@property (strong, atomic) SafariApplication *browser;

@property (strong, atomic) IBOutlet NSTreeController *sourcesController;
@property (strong, atomic) IBOutlet NSArrayController *itemsController;

@property (strong, atomic) NSMutableArray *sources;
@property (strong, atomic) NSMutableArray *systems;
@property (strong, atomic) NSMutableArray *scrapes;
@property (strong, atomic) NSMutableArray *repos;

@property (strong, atomic) NSMutableArray *items;
@property (strong, atomic) NSMutableArray *allPackages;
@property (strong, atomic) NSMutableDictionary *packagesIndex;
@property (strong, atomic) NSMutableArray *markedItems;

@property (readwrite, atomic) NSInteger marksCount;
@property (strong, atomic) NSString *selectedSegment;
@property (readwrite, atomic) NSInteger previousSegment;
@property (strong, atomic) NSString *APPDIR;


- (void)status:(NSString *)msg;
- (void)info:(NSString *)msg;
- (void)log:(NSString *)text;

- (void)sourcesSelectionDidChange:(id)sender;
- (void)updateTabView:(GItem *)item;
- (void)updateScrape:(GScrape *)scrape;
- (void)updateCmdLine:(NSString *)cmd;
- (void)execute:(NSString *)cmd withBaton:(NSString *)baton;
- (void)execute:(NSString *)cmd;
- (void)executeAsRoot:(NSString *)cmd;
- (void)sudo:(NSString *)cmd withBaton:(NSString *)baton;
- (void)sudo:(NSString *)cmd;

- (void)reloadAllPackages;
- (void)sync:(id)sender;

- (IBAction)marks:(id)sender;
- (IBAction)apply:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)syncAction:(id)sender;
- (IBAction)details:(id)sender;
- (IBAction)web:(id)sender;
- (IBAction)shell:(id)sender;
- (IBAction)toolsAction:(id)sender;
- (IBAction)options:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)executeCommandsMenu:(id)sender;

- (IBAction)switchSegment:(id)sender;
- (IBAction)toggleShell:(id)sender;
- (IBAction)executeCmdLine:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)moreScrapes:(id)sender;
- (IBAction)showMarkMenu:(id)sender;
- (IBAction)mark:(id)sender;
- (IBAction)setOptions:(id)sender;
- (IBAction)tools:(id)sender;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
