#if canImport(UIKit)
import UIKit

class CustomPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {
    var views: (Int, Int, UIView?) -> UIView

    var labels: (Int, UIView?) -> UIView?
    var actions: (Int) -> (() -> Void)?

    var selected: (Int, Int, CustomPickerView) -> Void
    var accessibilityColumn: (Int) -> String

    var accessibilityValueString: (Int, Int) -> String

    func select(column: Int, row: Int, animated: Bool = false) {
        let current = self.selectedRow(inComponent: column)
        if current != row {
            self.selectRow(row, inComponent: column, animated: animated)
        }
    }

    var columns: [Int] {
        didSet {
            self.reloadAllComponents()
        }
    }

    init(columns: [Int],
         selected: @escaping (Int, Int, CustomPickerView) -> Void,
         labels: @escaping (Int, UIView?) -> UIView?,
         actions: @escaping (Int) -> (() -> Void)?,
         views: @escaping (Int, Int, UIView?) -> UIView,
         accessibilityColumn: @escaping (Int) -> String,
         accessibilityValueString: @escaping (Int, Int) -> String) {
        self.columns = columns
        self.selected = selected
        self.labels = labels
        self.actions = actions
        self.views = views
        self.accessibilityColumn = accessibilityColumn
        self.accessibilityValueString = accessibilityValueString
        super.init(frame: .zero)
        self.delegate = self
        self.dataSource = self
    }

    /// Allow SwiftUI to control the width by removing the intrinsic width.
    override var intrinsicContentSize: CGSize {
        let base = super.intrinsicContentSize
        return CGSize(width: UIView.noIntrinsicMetric, height: base.height)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        self.columns.count
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard let column = self.columns.safe(at: component) else {
            return 0
        }
        return column
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        self.views(component, row, view)
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        self.accessibilityValueString(component, row)
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selected(component, row, self)
    }

    func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
        self.accessibilityColumn(component)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var labelViews: [Int: UIView] = [:]
    private var labelActions: [Int: () -> Void] = [:]

    override func layoutSubviews() {
        super.layoutSubviews()

        for index in self.columns.indices {
            if let view = self.labels(index, self.labelViews[index]), let reference = self.view(forRow: self.selectedRow(inComponent: index), forComponent: index) {
                if view !== self.labelViews[index] {
                    self.labelViews[index]?.removeFromSuperview()
                    self.labelViews[index] = view
                }

                if self.labelActions[index] == nil, let action = self.actions(index) {
                    self.labelActions[index] = action
                    view.isUserInteractionEnabled = true
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.labelTapped(_:)))
                    tap.cancelsTouchesInView = true
                    view.addGestureRecognizer(tap)
                    view.tag = index
                }

                if view.superview !== self {
                    self.addSubview(view)
                }
                view.frame = self.convert(reference.bounds, from: reference)
            } else {
                self.labelViews[index]?.removeFromSuperview()
                self.labelViews[index] = nil
                self.labelActions[index] = nil
            }
        }
    }

    @objc
    private func labelTapped(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        self.labelActions[view.tag]?()
    }

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for (index, labelView) in self.labelViews {
            if self.labelActions[index] != nil {
                let convertedPoint = labelView.convert(point, from: self)
                if labelView.bounds.contains(convertedPoint) {
                    return labelView
                }
            }
        }
        return super.hitTest(point, with: event)
    }
}
#endif
