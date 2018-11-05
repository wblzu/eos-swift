import Foundation
import RxSwift

class BuyRamBytesChain : ChainTransaction {

    struct Args {
        let receiver: String
        let quantity: Int64
    }

    private let _chainApi: ChainApi

    init(chainApi: ChainApi) {
        self._chainApi = chainApi
    }

    func chainApi() -> ChainApi {
        return _chainApi
    }

    func buyRamBytes(args: Args, transactionContext: TransactionContext) -> Single<ChainResponse<TransactionCommitted>> {
        return push(
            expirationDate: Date.defaultTransactionExpiry(),
            actions: buildAbiList(args: args, transactionContext: transactionContext),
            authorizingPrivateKey: transactionContext.authorizingPrivateKey)
    }

    private func buildAbiList(args: Args, transactionContext: TransactionContext) -> [ActionAbi] {

        let buyRamBytesArgs: BuyRamBytesArgs = BuyRamBytesArgs(
            payer: AccountNameWriterValue(name: transactionContext.authorizingAccountName),
            receiver: AccountNameWriterValue(name: args.receiver),
            bytes: 4096)

        return [ActionAbi(
            account: AccountNameWriterValue(name: "eosio"),
            name: AccountNameWriterValue(name: "buyrambytes"),
            authorization: [TransactionAuthorizationAbi(
                actor: AccountNameWriterValue(name: transactionContext.authorizingAccountName),
                permission: AccountNameWriterValue(name: "active"))],
            data: DataWriterValue(hex: BuyRamBytesBody(args: buyRamBytesArgs).toHex())
        )]
    }
}