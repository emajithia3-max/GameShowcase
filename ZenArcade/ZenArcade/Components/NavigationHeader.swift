import SwiftUI

struct NavigationHeader: View {
    let title: String
    let onDismiss: (() -> Void)?
    let rightAction: (() -> Void)?

    init(_ title: String,
         onDismiss: (() -> Void)? = nil,
         rightAction: (() -> Void)? = nil) {
        self.title = title
        self.onDismiss = onDismiss
        self.rightAction = rightAction
    }

    var body: some View {
        HStack {
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 18, weight: .semibold))
                }
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            Text(title)
                .font(Theme.Font.rounded(18, .semibold))
                .foregroundStyle(Theme.Colors.textPrimary)

            Spacer()

            if let rightAction {
                Button(action: rightAction) {
                    Image(systemName: "slider.horizontal.3")
                }
            } else {
                Spacer().frame(width: 44)
            }
        }
        .padding(.horizontal, Theme.Spacing.md)
        .padding(.top, Theme.Spacing.sm)
    }
}
