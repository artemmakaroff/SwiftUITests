//
//  ProfileMenuCell.swift
//
//
//  Created by Artem Makarov on 09.08.2024.
//

import PreviewSnapshots
import SwiftUI
import Resources

/// Соответствует компонентам List/Profile/Master в Figma
public struct ProfileMenuCell: View {

    // MARK: - Constants

    private enum Constants {
        static let disabledColor = Colors.gray60.color
    }

    // MARK: - Private Properties

    private let item: ProfileMenuCellItem
    private let onAction: () -> Void

    private var titleColor: Color {
        item.isDisabled ? Constants.disabledColor : Colors.gray80.color
    }

    private var subtitleColor: Color {
        item.isDisabled ? Constants.disabledColor : Colors.gray70.color
    }

    private var iconColor: Color {
        item.isDisabled ? Constants.disabledColor : Colors.primary80.color
    }

    // MARK: - Init

    public init(item: ProfileMenuCellItem, onAction: @escaping () -> Void) {
        self.item = item
        self.onAction = onAction
    }

    // MARK: - Body

    public var body: some View {
        Button(action: { onAction() }) {
            VStack(spacing: 0) {
                contentView()
                    .padding(.vertical, 16)
                    .contentShape(Rectangle())
                Divider()
                    .frame(height: 1.0)
                    .foregroundColor(Colors.grayBlue20.color)
            }
            .padding(.horizontal, 16)
        }
        .buttonStyle(
            ProfileMenuCellStyle()
        )
        .disabled(item.isDisabled)
    }

}

private extension ProfileMenuCell {

    func contentView() -> some View {
        HStack(spacing: 12) {
            icon()
            VStack(spacing: 0) {
                titleText()
                if let subtitle = item.subtitle {
                    subtitleText(with: subtitle)
                }
            }
            Spacer()
            if !item.isDisabled && item.hasChevron {
                Assets.UIComponents.chevronRight.image
                    .resizable()
                    .foregroundColor(iconColor)
                    .frame(width: 20.0, height: 20.0)
            }
        }
    }

    func icon() -> some View {
        item.icon
            .resizable()
            .renderingMode(.template)
            .foregroundColor(iconColor)
            .frame(width: 20.0, height: 20.0)
    }

    func titleText() -> some View {
        HStack {
            Text(item.title)
                .fontWithLineHeight(FontFamily.Formular.regular.font(size: 14), lineHeight: 20)
                .foregroundColor(titleColor)
            Spacer()
        }
    }

    func subtitleText(with subtitle: String) -> some View {
        HStack {
            Text(subtitle)
                .fontWithLineHeight(FontFamily.Formular.regular.font(size: 12), lineHeight: 16)
                .foregroundColor(subtitleColor)
            Spacer()
        }
    }

}

// MARK: - PreviewProvider

struct ProfileMenuCell_Previews: PreviewProvider {

    enum Preset: String, CaseIterable {
        case withLargeTitileAndSubtitle
        case disabled
        case `default`
    }

    static var previews: some View {
        ScrollView {
            snapshots.previews
        }
    }

    static var snapshots: PreviewSnapshots<Preset> {
        return PreviewSnapshots(
            states: Preset.allCases,
            name: \.rawValue
        ) { preset in
            Group {
                switch preset {
                case .withLargeTitileAndSubtitle:
                    ProfileMenuCell(item:
                            .init(
                                icon: Assets.Authorization.calendar.image,
                                title: "Расскажите о своей дате рождения",
                                subtitle: "Картофель необходимо в сыром виде очистить от кожуры, тщательно вымыть и натереть на мелкой терке. Для измельчения картофеля можно также воспользоваться блендером или перекрутить его через мясорубку.",
                                isDisabled: false
                            ), onAction: {}
                    )
                case .disabled:
                    ProfileMenuCell(item: .init(icon: Assets.Authorization.mail.image, title: "E-mail", subtitle: "Добавить почту", isDisabled: true), onAction: {})
                case .`default`:
                    ProfileMenuCell(item: .init(icon: Assets.Authorization.mail.image, title: "E-mail", subtitle: "Добавить почту", isDisabled: false), onAction: {})
                }
            }
            .frame(width: UIScreen.main.bounds.width - 32)
            .padding()
        }
    }

}
