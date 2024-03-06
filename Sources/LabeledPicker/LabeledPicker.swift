import SwiftUI
import UIKit

public struct Column {
    let selected: Binding<Int>
    let size: Int
    let label: (() -> AnyView)?
    let content: (Int) -> AnyView
    let accessibilityColumn: String
    let accessibilityValue: (Int) -> String

    public static func value<Content: View>(_ selected: Binding<Int>, size: Int, accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, content: @escaping (Int) -> Content) -> Column {
        return Column(selected: selected, size: size, label: nil, content: { AnyView(content($0)) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }

    public static func value<Content: View, Label: View>(_ selected: Binding<Int>, size: Int, @ViewBuilder label: @escaping () -> Label, accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, @ViewBuilder content: @escaping (Int) -> Content) -> Column {
        return Column(selected: selected, size: size, label: { AnyView(label()) }, content: { AnyView(content($0)) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
    }

    public static func label<Content: View>(accessibilityColumn: String, accessibilityValue: @escaping (Int) -> String, content: @escaping () -> Content) -> Column {
        return Column(selected: .constant(0), size: 1, label: { AnyView(content()) }, content: { _ in AnyView(EmptyView()) }, accessibilityColumn: accessibilityColumn, accessibilityValue: accessibilityValue)
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
        LabeledPickerWrapper(columns: columns)
    }
}

struct LabeledPickerWrapper: UIViewRepresentable {


    var columns: [Column]

    func makeUIView(context: Context) -> CustomPickerView {
        let picker = CustomPickerView(columns: self.columns.map({ $0.size }),
                                      selected: self.selected,
                                      labels: self.labels,
                                      views: self.views,
                                      accessibilityColumn: { self.columns.safe(at: $0)?.accessibilityColumn ?? "" },
                                      accessibilityValueString: { self.columns.safe(at: $0)?.accessibilityValue($1) ?? "" })
        return picker
    }

    func updateUIView(_ picker: CustomPickerView, context: Context) {
        picker.views = self.views
        picker.columns = self.columns.map({ $0.size })
        for (index, column) in columns.enumerated() {
            picker.select(column: index, row: column.selected.wrappedValue, animated: true)
        }
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
        let oldVal = binding.wrappedValue
        binding.wrappedValue = row
        if binding.wrappedValue != row {
            picker.select(column: column, row: binding.wrappedValue, animated: true)
        }
    }
}
