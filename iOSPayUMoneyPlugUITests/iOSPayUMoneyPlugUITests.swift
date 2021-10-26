//
//  iOSPayUMoneyPlugUITests.swift
//  iOSPayUMoneyPlugUITests
//
//  Created by macbook pro on 01/03/19.
//  Copyright © 2019 Omni-Bridge. All rights reserved.
//

import XCTest

class iOSPayUMoneyPlugUITests: XCTestCase {
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    // MARK:- Failed cases
    
    /// Used to failed at least one local validation
    func testAlLeastAnyOneValidationFailed(){
        let app = XCUIApplication()
        
        let txtNameField = app.textFields["Rahul P"]
        txtNameField.tap()
        txtNameField.typeText("Rahul")
        
        let txtEMailField = app.textFields["rahul@gmail.com"]
        txtEMailField.tap()
        txtEMailField.typeText("rahulpanzade@gmail.com")
        
        let txtMobileField = app.textFields["8888118516"]
        txtMobileField.tap()
        txtMobileField.typeText("9876543210")
        
        let txtAmtField = app.textFields["198.50"]
        txtAmtField.tap()
        txtAmtField.typeText("0.00")
        
        app.buttons["Pay"].tap()
        XCTAssert(app.buttons["Pay"].isEnabled, "Failed due to at least one local validation left")
    }
    
    // MARK:- Passed cases
    
    /// used to passed all local validation
    func testAllLocalValidationSuccessfull(){
        
        let app = XCUIApplication()
        
        let txtNameField = app.textFields["Rahul P"]
        txtNameField.tap()
        txtNameField.typeText("Rahul Panzade")
        
        let txtEMailField = app.textFields["rahul@gmail.com"]
        txtEMailField.tap()
        txtEMailField.typeText("rahulpanzade@gmail.com")
        
        let txtMobileField = app.textFields["8888118516"]
        txtMobileField.tap()
        txtMobileField.typeText("8888118516")
        
        let txtAmtField = app.textFields["198.50"]
        txtAmtField.tap()
        txtAmtField.typeText("143.00")
        
        app.buttons["Pay"].tap()
        XCTAssert(app.buttons["Pay"].isEnabled,  "local validations successfully done.")
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}
