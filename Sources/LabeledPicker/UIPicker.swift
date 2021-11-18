//
//  File.swift
//  
//
//  Created by Leo Mehlig on 12.11.21.
//

import UIKit


class CustomPickerView: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
    enum Column {
        case value(size: Int)
        case label
        
        var isLabel: Bool {
            switch self {
            case .value:
                return false
            case .label:
                return true
            }
        }
    }
    var views: (Int, Int, UIView?) -> UIView
    
    var selected: (Int, Int) -> Void
    
    func select(column: Int, row: Int, animated: Bool = false) {
        let current = self.selectedRow(inComponent: column)
        if current != row {
            self.selectRow(row, inComponent: column, animated: animated)
        }
    }
    
    var columns: [Column] {
        didSet {
            self.reloadAllComponents()
        }
    }
        
    init(columns: [Column],
         selected: @escaping (Int, Int) -> Void,
         views: @escaping (Int, Int, UIView?) -> UIView) {
        self.columns = columns
        self.selected = selected
        self.views = views
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
        switch column {
        case .value(let size):
            return size
        case .label:
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let view = self.views(component, row, view)
        return view
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.selected(component, row)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for (index, column) in columns.enumerated() {
            if column.isLabel,
               let view = self.view(forRow: 0, forComponent: index)?.searchSuperviews(for: "UIPickerTableView", maxDepth: 5) as? UIScrollView {
                view.isScrollEnabled = false
            }
        }
    }
}

extension UIView {
    func searchSuperviews(for type: String, maxDepth: Int) -> UIView? {
        guard maxDepth > 0, let superview = self.superview else {
            return nil
        }
        let name = String(describing: Swift.type(of: superview))
        if name == type {
            return superview
        } else {
            return superview.searchSuperviews(for: type, maxDepth: maxDepth - 1)
        }
    }
}
