//
//  VerticalSpace.swift
//  CollorAPI
//
//  Created by Guihal Gwenn on 28/11/2018.
//  Copyright © 2018 oui.sncf. All rights reserved.
//

import Foundation

public typealias VerticalSpace = CGFloat

public extension CGFloat {
    public static var zero: VerticalSpace = 0
    public static var small: VerticalSpace = 5
    public static var medium: VerticalSpace = 10
    public static var big: VerticalSpace = 20
    public static var huge: VerticalSpace = 40
}

public typealias Inset = CGFloat
public extension CGFloat {
    static var sectionDefault: Inset = 15
}
