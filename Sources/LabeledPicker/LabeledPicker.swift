import SwiftUI
import UIKit

public enum Column {
    case _value(_ selected: Binding<Int>, size: Int, label: (() -> AnyView)? = nil,  content: (Int) -> AnyView)
    case _label(content: () -> AnyView)
    
    public static func value<Content: View>(_ selected: Binding<Int>, size: Int, content: @escaping (Int) -> Content) -> Column {
        return ._value(selected, size: size, content: { AnyView(content($0)) })
    }
    
    public static func value<Content: View, Label: View>(_ selected: Binding<Int>, size: Int, @ViewBuilder label: @escaping () -> Label, @ViewBuilder content: @escaping (Int) -> Content) -> Column {
        return ._value(selected, size: size, label: { AnyView(label()) }, content: { AnyView(content($0)) })
    }
    
    public static func label<Content: View>(content: @escaping () -> Content) -> Column {
        return ._label(content: { AnyView(content()) })
    }
    
    var internalColumn: CustomPickerView.Column {
        switch self {
        case ._value(_, let size, _, _):
            return .value(size: size)
        case ._label(_):
            return .label
        }
    }
    
    var content: (Int) -> AnyView {
        switch self {
        case ._value(_, _, _, let content):
            return content
        case ._label(let content):
            return { _ in content() }
        }
    }
    
    var label: (() -> AnyView)? {
        switch self {
        case ._value(_, _, let label, _):
            return label
        case ._label(let content):
            return content
        }
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
    
    init(columns: [Column]) {
        self.columns = columns
    }
    
    func makeUIView(context: Context) -> CustomPickerView {
        let picker = CustomPickerView(columns: self.columns.map({ $0.internalColumn }),
                                      selected: self.selected,
                                      labels: self.labels,
                                      views: self.views)
        return picker
    }
    
    func updateUIView(_ picker: CustomPickerView, context: Context) {
        picker.views = self.views
        picker.columns = self.columns.map({ $0.internalColumn })
        for (index, column) in columns.enumerated() {
            if case ._value(let selected, _, _, _) = column {
                picker.select(column: index, row: selected.wrappedValue, animated: true)
            }
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
    
    func selected(column: Int, row: Int) {
        if case ._value(let selected, _, _, _)? = self.columns.safe(at: column) {
            selected.wrappedValue = row
        }
    }
}
