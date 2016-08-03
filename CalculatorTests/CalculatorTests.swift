import XCTest
@testable import Calculator

class CalculatorTests: XCTestCase
{
	//	a. касаемся 7 + будет показано “7 + ...” (с 7, которая все еще на display)
	//	b. 7 + 9 будет показано “7 + ...” (9 на display)
	//	c. 7 + 9 = будет показано “7 + 9 =” (16 на display)
	//	d. 7 + 9 = √ будет показано “√(7 + 9) =” (4 на display)
	//	e. 7 + 9 √ будет показано “7 + √(9) ...” (3 на display)
	//	f. 7 + 9 √ = будет показано “7 + √(9) =“ (10 на display)
	//	g. 7 + 9 = + 6 + 3 = будетпоказано “7 + 9 + 6 + 3 =” (25 на display)
	//	h. 7 + 9 = √ 6 + 3 = будетпоказано “6 + 3 =” (9 на display)
	//	i. 5 + 6 = 7 3 будетпоказано “5 + 6 =” (73 на display)
	//	j. 7 + = будет показано “7 + 7 =” (14 на display)
	//	k. 4 × π = будет показано “4 × π =“ (12.5663706143592 на display)
	//	l. 4 + 5 × 3 = будет показано “4 + 5 × 3 =” (27 на display)
	//	m. 4 + 5 × 3 = будет показано “(4 + 5) × 3 =” если вы предпочитаете(27 на display)

	let calc = CalculatorBrain()

	var desc = ""

	override func setUp()
	{
		super.setUp()

		calc.descriptionChangeHandler = { [unowned self] value in self.desc = value }
	}
    
    func test_a_c_d()
	{
		//a
		calc.setOperand(7)
		calc.performOperation("+")

		XCTAssertEqual(desc, "7+...")
		XCTAssertEqual(calc.result, 7)

		//c
		calc.setOperand(9)
		calc.performOperation("=")

		XCTAssertEqual(desc, "7+9=")
		XCTAssertEqual(calc.result, 16)

		//d
		calc.performOperation("√")

		XCTAssertEqual(desc, "√(7+9)=")
		XCTAssertEqual(calc.result, 4)
    }

	func test_e_f()
	{
		//e
		calc.setOperand(7)
		calc.performOperation("+")
		calc.setOperand(9)
		calc.performOperation("√")

		XCTAssertEqual(desc, "7+√(9)...")
		XCTAssertEqual(calc.result, 3)

		//f
		calc.performOperation("=")
		XCTAssertEqual(desc, "7+√(9)=")
		XCTAssertEqual(calc.result, 10)
	}

	func test_g()
	{
		calc.setOperand(7)
		calc.performOperation("+")
		calc.setOperand(9)
		calc.performOperation("=")
		calc.performOperation("+")
		calc.setOperand(6)
		calc.performOperation("+")
		calc.setOperand(3)
		calc.performOperation("=")

		XCTAssertEqual(desc, "7+9+6+3=")
		XCTAssertEqual(calc.result, 25)
	}

	func test_h()
	{
		calc.setOperand(7)
		calc.performOperation("+")
		calc.setOperand(9)
		calc.performOperation("=")
		calc.performOperation("√")
		calc.setOperand(6)
		calc.performOperation("+")
		calc.setOperand(3)
		calc.performOperation("=")

		XCTAssertEqual(desc, "6+3=")
		XCTAssertEqual(calc.result, 9)
	}

	func test_j()
	{
		calc.setOperand(7)
		calc.performOperation("+")
		calc.performOperation("=")

		XCTAssertEqual(desc, "7+7=")
		XCTAssertEqual(calc.result, 14)
	}

	func test_k()
	{
		calc.setOperand(4)
		calc.performOperation("×")
		calc.performOperation("π")
		calc.performOperation("=")

		XCTAssertEqual(desc, "4×π=")
		XCTAssertEqualWithAccuracy(calc.result, 4 * M_PI, accuracy: 0.00000001)
	}

	func test_l_m()
	{
		calc.setOperand(4)
		calc.performOperation("+")
		calc.setOperand(5)
		calc.performOperation("×")
		calc.setOperand(3)
		calc.performOperation("=")

		XCTAssertEqual(desc, "4+5×3=")
		XCTAssertEqual(calc.result, 27)
	}

	func test_sqrt_pi()
	{
		calc.performOperation("π")
		calc.performOperation("√")

		XCTAssertEqual(desc, "√(π)=")
		XCTAssertEqualWithAccuracy(calc.result, sqrt(M_PI), accuracy: 0.00000001)
	}

	func test_value_plus_sqrt_pi()
	{
		calc.setOperand(2)
		calc.performOperation("+")
		calc.performOperation("π")
		calc.performOperation("√")
		calc.performOperation("=")

		XCTAssertEqual(desc, "2+√(π)=")
		XCTAssertEqualWithAccuracy(calc.result, 2 + sqrt(M_PI), accuracy: 0.00000001)
	}

	func test_pi_plus_value()
	{
		calc.performOperation("π")
		calc.performOperation("+")
		calc.setOperand(2)
		calc.performOperation("=")

		XCTAssertEqual(desc, "π+2=")
		XCTAssertEqualWithAccuracy(calc.result, M_PI + 2, accuracy: 0.00000001)
	}

	func testReset()
	{
		calc.setOperand(7)
		calc.performOperation("+")
		calc.setOperand(9)
		calc.performOperation("=")

		calc.reset()

		XCTAssertEqual(desc, "...")
	}
}
