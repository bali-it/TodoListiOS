//
//  LoginViewModel_Tests.swift
//  MyPortfolio_Tests
//
//  Created by Basel Al Ali on 23.08.23.
//

@testable import MyPortfolio_swift
import XCTest

// Naming Structure: test_UnitOfWork_StateUnderTest_ExpectedBehavior
// Naming Structure: test_[struct_or_class]_[variable_or_function]_[expected_result]
/*
 Two best practices for unit testing:
 Make the variable lazy private lazy var viewModel = LoginViewModel()
 Make the variable optional and set it to nil in tearDownWithError()
 private lazy var viewModel: LoginViewModel! = LoginViewModel()

 override func tearDownWithError() throws {
     super.tearDownWithError()
     viewModel = nil
 }
 The reason for this is an implementation detail of XCTest which is not obvious. For each test method, a new instance of LoginViewModel_Tests will be created right before the first test starts. That applies to all tests, not just the ones in this file. Meaning for each test method in your entire project, you end up having an instance of the class it is contained in in a big list [XCTestCase]. XCTest will then iterate through the list and run each test.
 This has two implications:
 All objects contained within the test class are also instantiated when the class itself is instantiated, unless they are lazy. Lazy defers their initialization to the point of their first use.
 Since the XCTestCase objects are kept in a big array and not removed from the array after being completed, they stay in memory. And so do the objects that they keep within them. This may sometimes lead to unintended side effects. That is, we set them to nil in the tearDown methods so they get deallocated and cannot do any harm.

 */

final class LoginViewModel_Tests: XCTestCase {
    // Given
    private lazy var viewModel: LoginViewModel! = LoginViewModel()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        // Clean up the memory

        viewModel = nil
    }

    func test_LoginViewModel_loginDisabled_WhenEmailAndPasswordNotValid_LoginShouldBeFalse() {
        // When
        viewModel.isEmailValid = false
        viewModel.isPasswordValid = false

        // Then
        XCTAssertFalse(viewModel.loginDisabled)
    }

    func test_LoginViewModel_loginDisabled_WhenEmailIsValidButPasswordNotValid_LoginShouldBeFalse() {
        // When
        viewModel.isEmailValid = false
        viewModel.isPasswordValid = false

        // Then
        XCTAssertFalse(viewModel.loginDisabled)
    }

    func test_LoginViewModel_CheckloginDisabled_WhenEmailPasswordAreValid_LoginShouldBeTrue() {
        // When
        viewModel.isEmailValid = true
        viewModel.isPasswordValid = true

        // Then
        XCTAssert(viewModel.loginDisabled)
    }

    func test_LoginViewModel_CheckloginDisabled_WhenIsEmailRandomAndPasswordIsNotValid_LoginShouldBeFalse_stress() {
        for _ in 0 ..< 5 {
            // Given
            let viewModel = LoginViewModel()

            // When
            viewModel.isEmailValid = Bool.random()
            viewModel.isPasswordValid = false

            // Then
            XCTAssertFalse(viewModel.loginDisabled)
        }
    }

    func test_LoginViewModel_CheckPasswordValidity_WhenPasswordAreValid_PasswordValidityShouldBe_true() {
        // When
        let validPassword = "Test!&§112W!"

        // Then
        XCTAssert(viewModel.checkPasswordValidity(password: validPassword))
    }

    func test_LoginViewModel_CheckPasswordValidity_WhenValidPasswordWithLowerCase_PasswordValidityShouldBe_true() {
        // When
        let validPasswordWithLowerCase = "Test!&§112W!"

        // Then
        XCTAssert(viewModel.checkPasswordValidity(password: validPasswordWithLowerCase))
    }

    func test_LoginViewModel_CheckPasswordValidity_WhenValidPasswordWithAllValidChars_PasswordValidityShouldBe_true() {
        // When
        let allValidChars = #"!"\#\$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~"#

        // Then
        XCTAssert(viewModel.checkPasswordValidity(password: allValidChars))
    }

    func test_LoginViewModel_CheckPasswordValidity_WhenIEnterInvalidPassword_PasswordValidityShouldBe_false() {
        // When
        let allInvalidCharacters = "¡¢£¤¥¦§¨©ª«¬®¯°±²³´µ¶·¸¹º»¼½¾¿ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõö÷øùúûüýþÿ"

        // Then
        XCTAssertFalse(viewModel.checkPasswordValidity(password: "Hallo123€"))
        XCTAssertFalse(viewModel.checkPasswordValidity(password: "HALLOaaa!"))
        XCTAssertFalse(viewModel.checkPasswordValidity(password: "HALLO123a"))
        allInvalidCharacters.forEach { character in
            var invalidInput = "Hallo12"
            invalidInput.append(character)
            XCTAssertFalse(viewModel.checkPasswordValidity(password: invalidInput))
        }
    }

    func test_LoginViewModel_CheckEmailValidity_WhenIEnterValidEmail_EmailValidityShouldBe_True() {
        // Given

        // When
        let validEmails = [
            "test@example.sy",
            "john.doe@gmail.de",
            "jane_smith123@hotmail.com",
            "user1234@yahoo.co.uk",
            "alice.smith@example.org",

            "bob.jones@company.net",
            "emma.johnson@gmail.com",
            "michael.wilson@hotmail.ye",
            "sarah.brown@yahoo.co.uk",
            "david.jackson@example.com",
        ]

        // Then
        validEmails.forEach { vaildEmail in
            let isValid = viewModel.checkEmailValidity(email: vaildEmail)
            print("Email: \(vaildEmail), isValid: \(isValid)")
            XCTAssert(isValid, "Valid Email (\(vaildEmail)) is valid")
        }
    }

    func test_LoginViewModel_CheckEmailValidity_WhenIEnterInvalidEmail_EmailValidityShouldBe_false() {
        // Given

        // When
        let invalidEmails = [
            "invalidemail",
            "user@example",
            "user@.com",
            "@example.com",
            "user@-domain.com",
            "user@domain-.com",
            "user@example..com",
            "user@.example.com",
            "user@example.c",
            "user@example@.com",
            "user@.com@",
            "user@",
            "@example.com",
            "user@",
            "user@.com",
            "user@example.",
        ]

        // Then
        invalidEmails.forEach { invalidEmail in
            let isValid = viewModel.checkEmailValidity(email: invalidEmail)
            print("Email: \(invalidEmail), isValid: \(isValid)")
            XCTAssertFalse(isValid, "Invalid Email (\(invalidEmail)) is valid")
        }
    }
}
