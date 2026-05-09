import SwiftUI
import FamilyControls

struct ScreenTimeSettingsView: View {
    @Bindable var manager: ScreenTimeManager
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss
    private var t: Tide { .resolve(colorScheme) }

    @State private var showingAddRule = false

    var body: some View {
        VStack(spacing: 0) {
            TopBar(leading: .back) { dismiss() }

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 6) {
                        Eyebrow(text: "SCREEN TIME", color: t.inkMute)
                        TideHeadline(text: "Manage your limits.", color: t.ink)
                        Text("Set time limits for apps and get reminded to choose differently.")
                            .font(.system(size: 14))
                            .foregroundStyle(t.inkSoft)
                            .padding(.top, 2)
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 20)
                    .padding(.bottom, 20)

                    // Rules list
                    if manager.config.rules.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "hourglass")
                                .font(.system(size: 32))
                                .foregroundStyle(t.inkMute)
                            Text("No rules yet")
                                .font(.system(size: 15))
                                .foregroundStyle(t.inkMute)
                            Text("Add a rule to start monitoring app usage.")
                                .font(.system(size: 13))
                                .foregroundStyle(t.inkMute)
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(40)
                    } else {
                        VStack(spacing: 8) {
                            ForEach(manager.config.rules) { rule in
                                NavigationLink {
                                    AppLimitRuleView(
                                        manager: manager,
                                        existingRule: rule
                                    )
                                } label: {
                                    ruleRow(rule)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 16)
                    }

                    // Add rule button
                    Button { showingAddRule = true } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(t.accent)
                            Text("Add Rule")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(t.accent)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(t.accent, style: StrokeStyle(
                                    lineWidth: 1, dash: [6, 4]
                                ))
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 40)
                }
            }
        }
        .background(t.bg.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .sheet(isPresented: $showingAddRule) {
            NavigationStack {
                AppLimitRuleView(manager: manager, existingRule: nil)
            }
        }
    }

    @ViewBuilder
    private func ruleRow(_ rule: AppLimitRule) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(rule.isEnabled ? t.accent.opacity(0.12) : t.surfaceAlt)
                    .frame(width: 40, height: 40)
                Image(systemName: "hourglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(rule.isEnabled ? t.accent : t.inkMute)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(rule.name)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(t.ink)
                Text("\(rule.limitLabel) · \(rule.scheduleSummary)")
                    .font(.system(size: 12))
                    .foregroundStyle(t.inkMute)
                    .lineLimit(1)
            }

            Spacer()

            Circle()
                .fill(rule.isEnabled ? t.ok : t.inkMute.opacity(0.3))
                .frame(width: 8, height: 8)

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(t.inkMute)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(t.surface)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(t.line, lineWidth: 1)
                )
        )
    }
}
