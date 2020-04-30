import Foundation

class VendingMachineProduct {
    public private(set) var name: String
    public private(set) var amount: Int
    public private(set) var price: Double

    init(name: String, price: Double, initialAmount: Int = 0) {
        self.name = name
        self.amount = initialAmount
        self.price = price
    }

    public func change(name: String) {
        self.name = name
    }

    public func change(price: Double) {
        self.price = price
    }

    public func update(amount: Int) {
        self.amount = amount
    }

    public func sell(amount: Int = 1) throws {
        guard amount > 0 else { throw VendingMachineError.forbiddenOperation }
        guard self.amount > 0 , amount > 0 else { throw VendingMachineError.productUnavailable }
        self.amount -= amount
    }
}

//TODO: Definir os erros
enum VendingMachineError: Error {
    case productNotRegistered
    case productUnavailable
    case insufficientFunds
    case failedDelivery
    case insufficientChange
    case forbiddenOperation
}

extension VendingMachineError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .productNotRegistered:
            return "Produto não registrado"
        case .productUnavailable:
            return "Produto indisponível"
        case .insufficientFunds:
            return "Fundos Insuficientes"
        case .insufficientChange:
            return "Troco não disponível"
        case .failedDelivery:
            return "Entrega do Produto Falhou"
        case .forbiddenOperation:
            return "Operação não permitida pelo administrador desta máquina"
        }
    }
}

class VendingMachine {
    private var estoque: [VendingMachineProduct]
    public private(set) var credits : Double
    public private(set) var availableChange : Double
    
    init(products: [VendingMachineProduct]) {
        self.estoque = products
        self.availableChange = 0
        self.credits = 0
    }

    public func insert(credits money: Double) {
        //MARK:receber o dinheiro e salvar em uma variável
        guard money > 0 else {
            return
        }
        self.credits += money
    }

    public func insert(change money: Double) {
        //MARK:receber o dinheiro e salvar em uma variável
        guard money > 0 else {
            return
        }
        self.availableChange += money
    }
    
    private func getProduct(named name: String) throws -> VendingMachineProduct {
        //MARK:achar o produto que o cliente quer
        guard let item = estoque.first(where: {(product) -> Bool in product.name == name}) else { throw VendingMachineError.productNotRegistered }
        return item
    }

    private func makeTransaction(with item: VendingMachineProduct, _ amount: Int = 1) throws {
        //MARK:ver se o dinheiro é o suficiente pro produto
        guard amount > 0 else { throw VendingMachineError.forbiddenOperation }
        let totalPrice = item.price * Double(amount)
        if credits >= totalPrice {
            self.credits -= totalPrice
        } else {
            throw VendingMachineError.insufficientFunds
        }
    }

    private func makeDelivery(with item: VendingMachineProduct, _ amount: Int = 1) throws {
        try item.sell(amount: amount)
    }

    public func buy(_ itemName: String) {
        do {
            let item = try getProduct(named: itemName)
            try makeTransaction(with: item)
            try makeDelivery(with: item)
        } catch {
            print(error.localizedDescription)
        }
    }

    public func returnChange() -> Double {
        var change: Double = Double.zero
        do {
            change = try getTroco()
        } catch {
            print(error.localizedDescription)
        }
        return change
    }
    
    private func getTroco() throws -> Double {
        //MARK: devolver o dinheiro que não foi gasto
        guard self.credits > 0 else {
            return 0.0
        }
        guard self.availableChange >= self.credits else {
            throw VendingMachineError.insufficientFunds
        }
        let remainder = self.credits
        self.credits = 0
        return remainder
    }
}

