//
//  ReviewDetailsViewModel.swift
//
//
//  Created by Artem Makarov on 14.08.2024.
//

import DataLayer
import Services
import SwiftUI
import UIComponents

public final class ReviewDetailsViewModel: ObservableObject {

    // MARK: - Properties

    @Published var review: Review
    @Published var comments: [ReviewComment]
    @Published var apiError: APIError?

    // MARK: - Private Properties

    let reviewService = ReviewsDataService()
    private let updateReviewCompletion: (Review) -> Void

    // MARK: - Init

    public init(
        review: Review,
        updateReviewCompletion: @escaping (Review) -> Void
    ) {
        self.review = review
        self.comments = review.comments
        self.updateReviewCompletion = updateReviewCompletion
    }

    // MARK: - Internal Methods

    func checkReviewRateInProcess(rate: RateReaction) {
        guard !review.isRateProcessed else {
            return
        }
        let preRatableManager = PreRatableManager<Review>()
        review = preRatableManager.preRate(newRate: .init(rate: rate), ratable: review)

        rateReview(rate: rate) {
            if let oldReview = preRatableManager.oldValue {
                self.review = oldReview
                preRatableManager.oldValue = nil
            }
        }
    }

    func checkCommentRateInProcess(for id: String, rate: RateReaction) {
        guard
            let index = comments.firstIndex(where: { $0.id == id }),
            comments[safe: index]?.isRateProcessed == false,
            let comment = comments[safe: index]
        else {
            return
        }

        let preRatableManager = PreRatableManager<ReviewComment>()
        let preRatableComment = preRatableManager.preRate(newRate: .init(rate: rate), ratable: comment)
        comments[safe: index] = preRatableComment

        rateComment(id: id, rate: rate) { [weak self] in
            self?.comments[safe: index] = preRatableManager.oldValue
            preRatableManager.oldValue = nil
        }
    }

}

// MARK: - Private Methods

private extension ReviewDetailsViewModel {

    func rateReview(rate: RateReaction, errorHandler: @escaping () -> Void) {
        let reviewRate = Rate(rate: rate)
        Task {
            do {
                let newReview = try await reviewService.postRateForReview(reviewUuId: review.uuid, rate: reviewRate)
                await MainActor.run {
                    if let newReview {
                        self.review = newReview
                        updateReviewCompletion(review)
                    }
                }
            } catch {
                await MainActor.run {
                    apiError = APIError(from: error)
                    errorHandler()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.apiError = nil
                    }
                }
            }
        }
    }

    func rateComment(id: String, rate: RateReaction, errorHandler: @escaping () -> Void) {
        let commentRate = Rate(rate: rate)
        Task {
            do {
                let newComment = try await reviewService.postRateForComment(commentUuid: id, rate: commentRate)
                await MainActor.run {
                    comments.findAndReplace(newComment)
                    review.comments = comments
                    updateReviewCompletion(review)
                }
            } catch {
                await MainActor.run {
                    apiError = APIError(from: error)
                    errorHandler()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        self.apiError = nil
                    }
                }
            }
        }
    }

}

// MARK: - CommentRate

public extension Rate {
    init(rate: RateReaction) {
        switch rate {
        case .like:
            self = .like
        case .dislike:
            self = .dislike
        case .cancel:
            self = .cancel
        }
    }
}
