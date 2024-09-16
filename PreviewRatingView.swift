//
//  PreviewRatingView.swift
//
//
//  Created by Artem Makarov on 23.07.2024.
//

import SwiftUI
import Resources
import PreviewSnapshots

/// Компонент для рейтинга с кол-вом отзывов
/// cоответствует компоненту Master/Rating_2  в Figma
public struct PreviewRatingView: View {

    // MARK: - Constants

    private enum Constants {
        static let size = 16.0
    }

    // MARK: - Private Properties

    private let rating: Double
    private let description: String

    // MARK: - Initialization

    /// - Parameters:
    ///   - rating: рейтинг
    ///   - reviewsCount: кол-во отзывов
    public init(
        rating: Double,
        reviewsCount: Int = 0
    ) {
        self.rating = rating
        self.description = "\(reviewsCount)"
    }

    /// - Parameters:
    ///   - rating: рейтинг
    ///   - descriprion: описание, если рядом с рейтингом нужно добавить текст, например View отзывов
    public init(
        rating: Double,
        description: String
    ) {
        self.rating = rating
        self.description = description
    }

    // MARK: - Body

    public var body: some View {
        HStack(alignment: .center, spacing: 4) {
            ForEach(1..<6) { index in
                let star = Assets.UIComponents.star16.image
                    .resizable()
                    .frame(width: Constants.size, height: Constants.size)

                star.overlay(
                    GeometryReader { ratio in
                        let ratio = Double(index) <= rating ? 1 : max(rating + 1 - Double(index), 0)
                        Rectangle()
                            .frame(width: Constants.size * ratio)
                            .foregroundColor(Colors.primary50.color)
                    }
                        .mask(star)
                )
            }
            Text("\(description)")
                .fontWithLineHeight(FontFamily.Formular.regular.font(size: 12), lineHeight: 16)
                .foregroundColor(Colors.gray60.color)
        }
    }

}

// MARK: - PreviewProvider

struct PreviewRatingView_Previews: PreviewProvider {

    enum Preset: String, CaseIterable {
        case empty
        case oneStar
        case twoStar
        case threeStar
        case fourStar
        case fiveStar
    }

    static var previews: some View {
        VStack {
            snapshots.previews
        }
        .padding()
    }

    static var snapshots: PreviewSnapshots<Preset> {
        return PreviewSnapshots(
            states: Preset.allCases,
            name: \.rawValue
        ) { preset in
            Group {
                switch preset {
                case .empty:
                    PreviewRatingView(rating: 0, reviewsCount: 0)
                case .oneStar:
                    PreviewRatingView(rating: 1, reviewsCount: 1)
                case .twoStar:
                    PreviewRatingView(rating: 2, reviewsCount: 2)
                case .threeStar:
                    PreviewRatingView(rating: 3, reviewsCount: 3)
                case .fourStar:
                    PreviewRatingView(rating: 4, reviewsCount: 4)
                case .fiveStar:
                    PreviewRatingView(rating: 5, reviewsCount: 999)
                }
            }
            .frame(width: 156)
        }
    }

}
