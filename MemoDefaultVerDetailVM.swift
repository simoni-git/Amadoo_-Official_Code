//
//  MemoDefaultVerDetailVM.swift
//  NewCalendar
//
//  Created by 시모니 on 1/15/25.
//

import UIKit

class MemoDefaultVerDetailVM {

    // MARK: - Clean Architecture Dependencies
    private var deleteMemoUseCase: DeleteMemoUseCaseProtocol?

    /// 클린 아키텍처 Entity
    var memoItem: MemoItem?

    /// 의존성 주입 메서드
    func injectDependencies(
        deleteMemoUseCase: DeleteMemoUseCaseProtocol
    ) {
        self.deleteMemoUseCase = deleteMemoUseCase
    }

    // MARK: - UseCase Methods

    /// UseCase를 통한 메모 삭제
    func deleteMemoUsingUseCase() -> Result<Void, Error>? {
        guard let useCase = deleteMemoUseCase,
              let memo = memoItem else { return nil }
        return useCase.executeMemo(memo)
    }
}
