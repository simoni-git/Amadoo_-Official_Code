//
//  MemoDefaultVerDetailVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class MemoDefaultVerDetailVM {

    // MARK: - Clean Architecture Dependencies
    private let deleteMemoUseCase: DeleteMemoUseCaseProtocol

    /// 클린 아키텍처 Entity
    var memoItem: MemoItem?

    // MARK: - Initializer
    init(
        deleteMemoUseCase: DeleteMemoUseCaseProtocol
    ) {
        self.deleteMemoUseCase = deleteMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 메모 삭제
    func deleteMemoUsingUseCase() -> Result<Void, Error>? {
        guard let memo = memoItem else { return nil }
        return deleteMemoUseCase.executeMemo(memo)
    }
}
