import UIKit

class ViewController: UIViewController
{
	@IBOutlet private weak var subDisplay: UILabel!
	@IBOutlet private weak var display: UILabel!

	private var userIsInTheMiddleOfTyping = false

	private var brain = CalculatorBrain()

	private let formatter = NSNumberFormatter();

	override func viewDidLoad()
	{
		super.viewDidLoad()

		formatter.maximumFractionDigits = 8

		brain.resultChangeHandler = { [unowned self] result in self.displayValue = result }
		brain.descriptionChangeHandler = { [unowned self] description in self.subDisplay.text = description }
	}

	@IBAction private func touchBackspace()
	{
		let result = display.text!
		if !userIsInTheMiddleOfTyping && brain.isPartialResult
		{
			brain.tryRemoveLastOperation()
			displayValue = brain.result
		}
		else if !userIsInTheMiddleOfTyping || (result != "0" && result.characters.count == 1)
		{
			userIsInTheMiddleOfTyping = false
			display.text = "0"
		}
		else if result.characters.count > 1
		{
			display.text = String(result.characters.dropLast())
		}
	}

	@IBAction private func touchDigit(sender: UIButton)
	{
		let digit = sender.currentTitle!
		if userIsInTheMiddleOfTyping
		{
			display.text = display.text! + digit
		}
		else
		{
			display.text = digit
		}
		userIsInTheMiddleOfTyping = true
	}

	@IBAction private func touchDot()
	{
		let newText = display.text! + "."
		if Double(newText) != nil
		{
			display.text = newText
		}
		userIsInTheMiddleOfTyping = true
	}

	@IBAction private func touchReset()
	{
		brain.reset()
		userIsInTheMiddleOfTyping = false
	}

	private var displayValue : Double? {
		get {
			return Double(display.text!)
		}
		set {
			if newValue != nil
			{
				display.text = formatter.stringForObjectValue(newValue!)
			}
			else
			{
				display.text = "0"
			}
		}
	}

	@IBAction private func performOperation(sender: UIButton)
	{
		if displayValue == nil
		{
			return
		}

		if userIsInTheMiddleOfTyping
		{
			brain.setOperand(displayValue!)
			userIsInTheMiddleOfTyping = false
		}

		if let methematicalSymbol = sender.currentTitle
		{
			brain.performOperation(methematicalSymbol)
		}
	}

}

