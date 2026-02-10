import SwiftUI

public struct Column {
    let selected: Binding<Int>
    let size: Int
    let label: (() -> AnyView)?
    let action: (() -> Void)?
    let content: (Int) -> AnyView
    let accessibilityColumn: String
    let accessibilityValue: (Int) -> String

    public static func value(_ selected: Binding<Int>, size: Int, accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, content: @escaping (Int) -> some View) -> Column {
        Column(selected: selected, size: size, label: nil, action: nil, content: { AnyView(content($0)) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }

    public static func value(_ selected: Binding<Int>, size: Int, @ViewBuilder label: @escaping () -> some View, accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, @ViewBuilder content: @escaping (Int) -> some View) -> Column {
        Column(selected: selected, size: size, label: { AnyView(label()) }, action: nil, content: { AnyView(content($0)) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }

    public static func label(accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, content: @escaping () -> some View) -> Column {
        Column(selected: .constant(0), size: 1, label: { AnyView(content()) }, action: nil, content: { _ in AnyView(EmptyView()) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }

    public static func label(accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, action: @escaping () -> Void, content: @escaping () -> some View) -> Column {
        Column(selected: .constant(0), size: 1, label: { AnyView(content()) }, action: action, content: { _ in AnyView(EmptyView()) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }
}

public struct LabeledPicker: View {
    var columns: [Column]

    public init(columns: [Column]) {
        self.columns = columns
    }

    public init(_ columns: Column...) {
        self.columns = columns
    }

    public var body: some View {
        #if canImport(UIKit)
        LabeledPickerWrapper(columns: self.columns)
        #elseif canImport(AppKit)
        LabeledPickerMac(columns: self.columns)
        #else
        EmptyView()
        #endif
    }
}

#if canImport(AppKit)
private struct LabeledPickerMac: View {
    let columns: [Column]

    var body: some View {
        HStack(spacing: 12) {
            ForEach(Array(self.columns.enumerated()), id: \.offset) { _, column in
                LabeledPickerMacColumn(column: column)
            }
        }
    }
}

private struct LabeledPickerMacColumn: View {
    let column: Column

    private var selectedValue: Int {
        min(max(0, self.column.selected.wrappedValue), max(0, self.column.size - 1))
    }

    private var isStaticLabelColumn: Bool {
        self.column.label != nil && self.column.size == 1
    }

    var body: some View {
        Group {
            if self.isStaticLabelColumn {
                self.staticLabel
            } else {
                self.valueColumn
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(self.column.accessibilityColumn))
        .accessibilityValue(Text(self.column.accessibilityValue(self.selectedValue)))
    }

    @ViewBuilder
    private var staticLabel: some View {
        if let label = self.column.label?() {
            if let action = self.column.action {
                Button(action: action) {
                    label
                }
                .buttonStyle(.plain)
            } else {
                label
            }
        }
    }

    private var valueColumn: some View {
        Picker("", selection: self.column.selected) {
            ForEach(0..<self.column.size, id: \.self) { row in
                self.column.content(row)
                    .tag(row)
                    .accessibilityLabel(Text(self.column.accessibilityValue(row)))
            }
        }
        .pickerStyle(.menu)
        .labelsHidden()
        .overlay {
            if let label = self.column.label?() {
                if let action = self.column.action {
                    Button(action: action) {
                        label
                    }
                    .buttonStyle(.plain)
                } else {
                    label
                        .allowsHitTesting(false)
                }
            }
        }
    }
}
#endif

#if canImport(UIKit)
import UIKit

struct LabeledPickerWrapper: UIViewRepresentable {
    var columns: [Column]

    func makeUIView(context: Context) -> CustomPickerView {
        CustomPickerView(columns: self.columns.map(\.size),
                         selected: self.selected,
                         labels: self.labels,
                         actions: { self.columns.safe(at: $0)?.action },
                         views: self.views,
                         accessibilityColumn: { self.columns.safe(at: $0)?.accessibilityColumn ?? "" },
                         accessibilityValueString: { self.columns.safe(at: $0)?.accessibilityValue($1) ?? "" })
    }

    func updateUIView(_ picker: CustomPickerView, context: Context) {
        picker.views = self.views
        picker.columns = self.columns.map(\.size)
        for (index, column) in self.columns.enumerated() {
            picker.select(column: index, row: column.selected.wrappedValue, animated: true)
        }
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: CustomPickerView, context: Context) -> CGSize {
        let proposedWidth = proposal.width ?? uiView.bounds.width
        // Keep the native picker height; widen to the proposed width.
        let height = uiView.intrinsicContentSize.height
        return CGSize(width: proposedWidth, height: height)
    }

    func views(column: Int, row: Int, resusable: UIView?) -> UIView {
        let hosting = resusable as? UIHostingView<AnyView> ?? UIHostingView<AnyView>()
        hosting.set(value: self.columns.safe(at: column)?.content(row) ?? AnyView(EmptyView()))
        return hosting
    }

    func labels(column: Int, resusable: UIView?) -> UIView? {
        guard let label = self.columns.safe(at: column)?.label?() else {
            return nil
        }
        let hosting = resusable as? UIHostingView<AnyView> ?? UIHostingView<AnyView>()
        hosting.set(value: label)
        return hosting
    }

    func selected(column: Int, row: Int, picker: CustomPickerView) {
        guard let binding = self.columns.safe(at: column)?.selected else {
            return
        }
        withAnimation {
            binding.wrappedValue = row
        }
        if binding.wrappedValue != row {
            picker.select(column: column, row: binding.wrappedValue, animated: true)
        }
    }
}
#endif
