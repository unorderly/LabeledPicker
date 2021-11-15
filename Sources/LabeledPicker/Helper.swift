//
//  File.swift
//  
//
//  Created by Leo Mehlig on 12.11.21.
//

import Foundation
import SwiftUI

public extension Collection {
    func safe(at index: Index) -> Iterator.Element? {
        guard index >= startIndex, index < endIndex
        else {
            return nil
        }
        return self[index]
    }
}



final class UIHostingView<Content: View>: UIView {
    private var hosting: UIHostingController<Content>?

    func set(value content: Content) {
        if let hosting = self.hosting {
            hosting.rootView = content
        } else {
            let hosting = UIHostingController(rootView: content)
            backgroundColor = .clear
            hosting.view.translatesAutoresizingMaskIntoConstraints = false
            hosting.view.backgroundColor = .clear
            self.addSubview(hosting.view)

            NSLayoutConstraint.activate([
                hosting.view.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
                hosting.view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0),
                hosting.view.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
                hosting.view.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0)
            ])
            self.hosting = hosting
            self.disableSafeArea(view: hosting.view)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.hosting?.view.setNeedsUpdateConstraints()
    }
    
    func disableSafeArea(view: UIView) {
         guard let viewClass = object_getClass(view) else { return }

         let viewSubclassName = String(cString: class_getName(viewClass)).appending("_IgnoreSafeArea")
         if let viewSubclass = NSClassFromString(viewSubclassName) {
             object_setClass(view, viewSubclass)
         }
         else {
             guard let viewClassNameUtf8 = (viewSubclassName as NSString).utf8String else { return }
             guard let viewSubclass = objc_allocateClassPair(viewClass, viewClassNameUtf8, 0) else { return }

             if let method = class_getInstanceMethod(UIView.self, #selector(getter: UIView.safeAreaInsets)) {
                 let safeAreaInsets: @convention(block) (AnyObject) -> UIEdgeInsets = { _ in
                     return .zero
                 }
                 class_addMethod(viewSubclass, #selector(getter: UIView.safeAreaInsets), imp_implementationWithBlock(safeAreaInsets), method_getTypeEncoding(method))
             }

             if let method2 = class_getInstanceMethod(viewClass, NSSelectorFromString("keyboardWillShowWithNotification:")) {
                 let keyboardWillShow: @convention(block) (AnyObject, AnyObject) -> Void = { _, _ in }
                 class_addMethod(viewSubclass, NSSelectorFromString("keyboardWillShowWithNotification:"), imp_implementationWithBlock(keyboardWillShow), method_getTypeEncoding(method2))
             }

             objc_registerClassPair(viewSubclass)
             object_setClass(view, viewSubclass)
         }
     }
}
