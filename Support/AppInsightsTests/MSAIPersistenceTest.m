#import <XCTest/XCTest.h>

#define HC_SHORTHAND
#import <OCHamcrestIOS/OCHamcrestIOS.h>

#define MOCKITO_SHORTHAND
#import <OCMockitoIOS/OCMockitoIOS.h>

#import "AppInsights.h"
#import "MSAIEnvelope.h"
#import "MSAIPersistence.h"

typedef void (^MSAIPersistenceTestBlock)(BOOL);

@interface MSAIPersistenceTest : XCTestCase

@end

@implementation MSAIPersistenceTest {
    MSAIPersistence *_sut;
}

- (void)setUp {
  [super setUp];
  [MSAIAppInsights setup];
  [MSAIAppInsights start];
  _sut = [MSAIPersistence sharedInstance];
  _sut.maxFileCount = 20;
}

- (void)tearDown {
  // Put teardown code here. This method is called after the invocation of each test method in the class.
  [super tearDown];
  
  //Delete all bundles to make sure we have a clean dir next time
  NSString *nextPath = [_sut nextPath];
  NSArray *bundle = [_sut bundleAtPath:nextPath];
  while (bundle) {
    [_sut deleteBundleAtPath:nextPath];
    nextPath = [_sut nextPath];
    bundle = [_sut bundleAtPath:nextPath];
  }
}

- (void)testNoBundles {
  XCTAssertNil([_sut nextPath]);
}

- (void)testIfItPersistsRegular {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsSomething {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
}

- (void)testReturnsHighPrioFirst {
  NSString *testHigh = @"Test1";
  NSString *testRegular = @"Test2";
  
  [_sut persistBundle:@[testHigh] ofType:MSAIPersistenceTypeHighPriority withCompletionBlock:nil];
  [_sut persistBundle:@[testRegular] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  
  NSString *nextPath = [_sut nextPath];
  NSString *returned = [[_sut bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testHigh]);
  [_sut deleteBundleAtPath:nextPath];
  nextPath = [_sut nextPath];
  returned = [[_sut bundleAtPath:nextPath] firstObject];
  XCTAssertTrue([returned isEqualToString:testRegular]);
}

- (void)testDeletionWorks {
  MSAIEnvelope *env = mock(MSAIEnvelope.class);
  [_sut persistBundle:@[env] ofType:MSAIPersistenceTypeRegular withCompletionBlock:^(BOOL success){
    XCTAssertTrue(success);
  }];
  
  NSString *nextPath = [_sut nextPath];
  XCTAssertNotNil([_sut bundleAtPath:nextPath]);
 
  [_sut deleteBundleAtPath:nextPath];
  XCTAssertNil([_sut nextPath]);
}

- (void)testNextPathNotEmptyWhenFilePersisted{
  NSString *nextPath = [_sut nextPath];
  XCTAssertNil(nextPath);
  
  [_sut persistBundle:@[@"testBundle"] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  nextPath = [_sut nextPath];
  XCTAssertNotNil(nextPath);
}

- (void)testBundleForPathReturnsCorrectFile{
  
  NSString *bundleItemValue = @"myBundleItemValue";
  [_sut persistBundle:@[bundleItemValue] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  NSString *nextPath = [_sut nextPath];
  NSArray *bundle = [_sut bundleAtPath:nextPath];
  
  XCTAssert([[bundle firstObject] isEqualToString:bundleItemValue]);
}

- (void)testIfIsFreeSpaceAvailableWorks{
  [_sut setMaxFileCount:1];
  XCTAssertTrue([_sut isFreeSpaceAvailable]);
  
  [_sut persistBundle:@[@"testBundle"] ofType:MSAIPersistenceTypeRegular withCompletionBlock:nil];
  XCTAssertFalse([_sut isFreeSpaceAvailable]);
}

@end
