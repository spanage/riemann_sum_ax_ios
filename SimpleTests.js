var target = UIATarget.localTarget();
var application = target.frontMostApp(); 
var mainWindow = application.mainWindow();

mainWindow.logElementTree();

UIALogger.logStart("UI Test 1 - Valid graph with 1 rect: Rect 1 present");

mainWindow.segmentedControls()[0].buttons()["x squared"].tap();
mainWindow.textFields()["Minimum x value"].tap();
application.keyboard().typeString("-2\n");
mainWindow.textFields()["Maximum x value"].tap();
application.keyboard().typeString("2\n");

var elem = mainWindow.elements()["Rectangle 1"];
if (elem.checkIsValid()) {
	UIALogger.logPass("Rectangle 1 is present.");
} else {
	UIALogger.logFail("Rectangle 1 is NOT present.");
}

UIALogger.logStart("UI Test 2 - Valid graph with 1 rect: Only 1 rect present");

var rectangles = mainWindow.elements().withPredicate("name beginswith 'Rectangle'");
if (rectangles.length == 1) {
	UIALogger.logPass("Only 1 rectangle present.");
} else {
	UIALogger.logFail("Incorrect number rectangles present: " + rectangles.length);
}

mainWindow.logElementTree();