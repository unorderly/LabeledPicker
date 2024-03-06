//
//  File.swift
//  
//
//  Created by Leo Mehlig on 12.11.21.
//

import UIKit


class CustomPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource, UIPickerViewAccessibilityDelegate {

    var views: (Int, Int, UIView?) -> UIView
    
    var labels: (Int, UIView?) -> UIView?
    
    
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
         views: @escaping (Int, Int, UIView?) -> UIView,
         accessibilityColumn: @escaping (Int) -> String,
         accessibilityValueString: @escaping (Int, Int) -> String) {
        self.columns = columns
        self.selected = selected
        self.labels = labels
        self.views = views
        self.accessibilityColumn = accessibilityColumn
        self.accessibilityValueString = accessibilityValueString
        super.init(frame: .zero)
        self.delegate = self
        self.dataSource = self
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
        let view = self.views(component, row, view)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return accessibilityValueString(component, row)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selected(component, row, self)
    }
    
    func pickerView(_ pickerView: UIPickerView, accessibilityLabelForComponent component: Int) -> String? {
        return self.accessibilityColumn(component)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private var labelViews: [Int: UIView] = [:]

    override func layoutSubviews() {
        super.layoutSubviews()
        
        for index in columns.indices {
            if let view = self.labels(index, self.labelViews[index]), let reference = self.view(forRow: self.selectedRow(inComponent: index), forComponent: index) {
                if view !== self.labelViews[index] {
                    self.labelViews[index]?.removeFromSuperview()
                    self.labelViews[index] = view
                }
                if view.superview !== self {
                    self.addSubview(view)
                }
                view.frame = self.convert(reference.bounds, from: reference)
            } else {
                self.labelViews[index]?.removeFromSuperview()
                self.labelViews[index] = nil
            }
        }
    }
}
