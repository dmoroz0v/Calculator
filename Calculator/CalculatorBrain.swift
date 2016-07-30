import Foundation

class CalculatorBrain
{
	private enum Operation
	{
		case Constant(Double)
		case UnaryOperation((Double) -> Double)
		case BinaryOperation((Double, Double) -> Double)
		case DynamicValue(() -> Double)
		case Equals
	}

	private struct PendingBinaryOperationInfo
	{
		var binaryOperation: (Double, Double) -> Double
		var firstOperand: Double
	}

	private enum HistoryItem
	{
		case Operation(String)
		case Operand(String)
	}

	private var history: Array<HistoryItem> = []

	private(set) var result = 0.0 {
		didSet {
			resultChangeHandler(result)
		}
	}

	private var pending: PendingBinaryOperationInfo!

	private let operations = [
		"π": Operation.Constant(M_PI),
		"e": Operation.Constant(M_E),
		"±": Operation.UnaryOperation({ -$0 }),
		"√": Operation.UnaryOperation(sqrt),
		"cos": Operation.UnaryOperation(cos),
		"×": Operation.BinaryOperation({ $0 * $1 }),
		"÷": Operation.BinaryOperation({ $0 / $1 }),
		"+": Operation.BinaryOperation({ $0 + $1 }),
		"−": Operation.BinaryOperation({ $0 - $1 }),
		"=": Operation.Equals,
		"x²": Operation.UnaryOperation({ $0 * $0 }),
		"rand": Operation.DynamicValue({ return Double(random()%1000) / 1000.0 })
	]

	private let formatter = NSNumberFormatter();

	var description: String {
		var result = ""
		var index = 0
		let formattedValueFromRaw: (String) -> (String) = { [unowned self] value in
			if let doubleValue = Double(value)
			{
				return self.formatter.stringForObjectValue(doubleValue)!
			}
			return value
		}
		while index < history.count
		{
			let historyItem = history[index]
			switch historyItem
			{
			case .Operand(let value):
				result += formattedValueFromRaw(value)
			case .Operation(let operationSymbol):
				let operation = operations[operationSymbol]!
				if case .UnaryOperation(_) = operation
				{
					if case .Operand(let value) = history[index - 1]
					{
						let formattedValue = formattedValueFromRaw(value);
						result = (result as NSString).substringToIndex(result.characters.count - formattedValue.characters.count)
						result += operationSymbol + "(" + formattedValue + ")"
					}
					else
					{
						result = operationSymbol + "(" + result + ")"
					}
				}
				else if case .BinaryOperation(_) = operation
				{
					result += operationSymbol
				}
			}

			index += 1
		}
		
		if result.characters.count == 0 || pending != nil
		{
			return result + "..."
		}
		else
		{
			return result + "="
		}
	}

	var resultChangeHandler: (Double) -> () = {_ in}
	var descriptionChangeHandler: (String) -> () = {_ in}

	var isPartialResult: Bool {
		return pending != nil
	}

	init()
	{
		formatter.maximumFractionDigits = 4
	}

	func setOperand(operand: Double)
	{
		if pending == nil
		{
			self.reset()
		}

		result = operand

		self.addHistoryItem(HistoryItem.Operand(String(result)))
	}

	func performOperation(symbol: String)
	{
		if let operation = operations[symbol]
		{
			switch operation
			{
			case .Constant(let value):
				result = value

			case .DynamicValue(let function):
				result = function()

			case .UnaryOperation(let function):
				if history.count == 0
				{
					self.addHistoryItem(self.historyItemForOperand(result))
				}
				if case .Operation(let operationSymbol)? = history.last
				{
					let operation = operations[operationSymbol]!
					if case .BinaryOperation(_) = operation
					{
						self.addHistoryItem(self.historyItemForOperand(result))
					}
				}

				result = function(result)

				self.addHistoryItem(HistoryItem.Operation(symbol))

			case .BinaryOperation(let function):
				executeBinaryOperation()

				pending = PendingBinaryOperationInfo(binaryOperation: function, firstOperand: result)

				self.addHistoryItem(HistoryItem.Operation(symbol))

			case .Equals:
				executeBinaryOperation()

				self.addHistoryItem(HistoryItem.Operation(symbol))
			}
		}
	}

	func tryRemoveLastOperation() -> Bool
	{
		if pending != nil
		{
			if case .Operation(let operation)? = history.last
			{
				if case .BinaryOperation(_)? = operations[operation]
				{
					pending = nil
					history.removeLast()
					descriptionChangeHandler(description)

					return true
				}
			}
		}

		return false
	}

	func reset()
	{
		result = 0.0
		history = []
		pending = nil
		descriptionChangeHandler(description)
	}

	private func historyItemForOperand(operand: Double) -> HistoryItem
	{
		for (symbol, operation) in operations
		{
			if case .Constant(let value) = operation where value == operand
			{
				return .Operand(symbol);
			}
		}
		return .Operand(String(operand))
	}

	private func addHistoryItem(item: HistoryItem)
	{
		history.append(item)
		descriptionChangeHandler(description)
	}

	private func executeBinaryOperation()
	{
		if pending != nil
		{
			if case .Operation(let operationSymbol) = history.last!
			{
				let operation = operations[operationSymbol]!
				if case .UnaryOperation(_) = operation { } else
				{
					self.addHistoryItem(self.historyItemForOperand(result))
				}
			}

			result = pending.binaryOperation(pending.firstOperand, result)
			pending = nil
		}
	}
}