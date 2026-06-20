import AppCore
import DesignSystem
import SwiftUI

public struct AIAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.unioPalette) private var palette
    @State private var conversation = Fixtures.aiConversation
    @State private var draft = ""

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(palette.separator)
                .frame(width: 44, height: 5)
                .padding(.top, 10)
                .padding(.bottom, 14)
            HStack {
                Text("Unio AI")
                    .font(UnioTypography.section)
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .frame(width: 34, height: 34)
                }
                .buttonStyle(.glass)
            }
            .padding(.horizontal)
            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(conversation.messages) { message in
                        AIMessageRow(message: message)
                    }
                }
                .padding()
            }
            GlassSurface(cornerRadius: 24, isInteractive: true) {
                HStack(spacing: 10) {
                    TextField("Спросите о посте, переводе или модерации", text: $draft, axis: .vertical)
                        .lineLimit(1...4)
                    Button {
                        send()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28, weight: .bold))
                    }
                    .buttonStyle(.plain)
                    .disabled(draft.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
            }
            .padding()
        }
        .background(palette.background.ignoresSafeArea())
    }

    private func send() {
        let text = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return }
        conversation.messages.append(AIMessage(role: .user, text: text))
        conversation.messages.append(AIMessage(role: .assistant, text: "Готово. Я подготовлю вариант в стиле Unio: коротко, ясно и без лишнего шума."))
        draft = ""
        UnioHaptics.light()
    }
}

private struct AIMessageRow: View {
    let message: AIMessage
    @Environment(\.unioPalette) private var palette

    var body: some View {
        HStack {
            if message.role == .user { Spacer(minLength: 44) }
            Text(message.text)
                .font(UnioTypography.body)
                .foregroundStyle(message.role == .user ? palette.inverseText : palette.textPrimary)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(message.role == .user ? palette.inverseSurface : palette.surface)
                )
            if message.role == .assistant { Spacer(minLength: 44) }
        }
    }
}
