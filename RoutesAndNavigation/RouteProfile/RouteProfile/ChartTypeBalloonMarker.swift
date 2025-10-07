// SPDX-FileCopyrightText: 1995-2025 Magic Lane International B.V. <info@magiclane.com>
// SPDX-License-Identifier: Apache-2.0
//
// Contact Magic Lane at <info@magiclane.com> for SDK licensing options.

import Foundation
import Charts

@objc public class ChartTypeBalloonMarker: MarkerImage
{
    @objc open var color: UIColor?
    @objc open var arrowSize = CGSize(width: 15, height: 11)
    @objc open var font: UIFont?
    @objc open var textColor: UIColor?
    @objc open var insets = UIEdgeInsets()
    @objc open var minimumSize = CGSize()
    @objc open var labelSufix : String = ""
    @objc open var roundCorners : Bool = false
    @objc open var textShadow : Bool = false
    @objc open var drawArrowOnly : Bool = false
    
    fileprivate var label: String?
    fileprivate var _labelSize: CGSize = CGSize()
    fileprivate var _paragraphStyle: NSMutableParagraphStyle?
    fileprivate let _shadow = NSShadow()
    fileprivate var _drawAttributes = [NSAttributedString.Key : Any]()
    
    @objc public init(color: UIColor, font: UIFont, textColor: UIColor, insets: UIEdgeInsets)
    {
        super.init()
        
        self.color = color
        self.font = font
        self.textColor = textColor
        self.insets = insets
        
        _paragraphStyle = NSParagraphStyle.default.mutableCopy() as? NSMutableParagraphStyle
        _paragraphStyle?.alignment = .center
        
        _shadow.shadowBlurRadius = 2
        _shadow.shadowOffset = CGSize(width: 2, height: 2) //  Positive values always extend down and to the right
        _shadow.shadowColor = UIColor.darkGray.withAlphaComponent(0.7)
    }
    
    open override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint
    {
        let size = self.size
        var point = point
        point.x -= size.width / 2.0
        point.y -= size.height
        return super.offsetForDrawing(atPoint: point)
    }
    
    open override func draw(context: CGContext, point: CGPoint)
    {
        guard let label = label else { return }
        
        let offset = self.offsetForDrawing(atPoint: point)
        let size = self.size
        
        var rect = CGRect(
            origin: CGPoint(
                x: point.x + offset.x,
                y: point.y + offset.y),
            size: size)
        rect.origin.x -= size.width / 2.0
        rect.origin.y -= size.height
        
        if let img = self.image
        {
            // Update position
            rect.origin.y -= img.size.height/2.0 + 2.0
        }
        
        context.saveGState()
        
        if let color = color
        {
            if self.roundCorners == true
            {
                context.setFillColor(color.cgColor)
                context.beginPath()
                
                // Draw arrow
                context.move(to: CGPoint(
                    x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width / 2.0,
                    y: rect.origin.y + rect.size.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                
                var roundRect = rect
                roundRect.size.height -= arrowSize.height
                
                // Round rect
                let clipPath: CGPath = UIBezierPath(roundedRect: roundRect, cornerRadius: 6.0).cgPath
                context.addPath(clipPath)
                context.setFillColor(color.cgColor)
                context.closePath()
                context.fillPath()
            }
            else
            {
                context.setFillColor(color.cgColor)
                context.beginPath()
                context.move(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width + arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + rect.size.width / 2.0,
                    y: rect.origin.y + rect.size.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x + (rect.size.width - arrowSize.width) / 2.0,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y + rect.size.height - arrowSize.height))
                context.addLine(to: CGPoint(
                    x: rect.origin.x,
                    y: rect.origin.y))
                context.closePath()
                context.fillPath()
            }
        }
        
        rect.origin.x    += self.insets.left
        rect.origin.y    += self.insets.top
        rect.size.width  -= self.insets.left + self.insets.right
        rect.size.height -= self.insets.top  + self.insets.bottom
        
        UIGraphicsPushContext(context)
        
        if let img = self.image
        {
            let recImg = CGRect(origin: CGPoint( x: point.x + offset.x - img.size.width/2.0,
                                                 y: point.y + offset.y - img.size.height),
                                size: img.size)
            img.draw(in: recImg)
        }
        
        label.draw(in: rect, withAttributes: _drawAttributes)
        
        UIGraphicsPopContext()
        
        context.restoreGState()
    }
    
    open override func refreshContent(entry: ChartDataEntry, highlight: Highlight)
    {
        if(self.drawArrowOnly)
        {
            setLabel("")
            
            return;
        }
        
        var string = String(entry.y)
        
        let valueFormatter = NumberFormatter()
        valueFormatter.minimumFractionDigits = 0
        valueFormatter.maximumFractionDigits = 0
        
        if let value = valueFormatter.string(from: NSNumber(floatLiteral: entry.y))
        {
            string = value
        }
        
        setLabel(string)
    }
    
    @objc open func setLabel(_ newLabel: String)
    {
        label = newLabel
        
        if labelSufix.count > 0
        {
            label = newLabel + " " + labelSufix
        }
        
        _drawAttributes.removeAll()
        _drawAttributes[NSAttributedString.Key.font] = self.font
        _drawAttributes[NSAttributedString.Key.paragraphStyle] = _paragraphStyle
        _drawAttributes[NSAttributedString.Key.foregroundColor] = self.textColor
        
        if textShadow == true
        {
            _drawAttributes[NSAttributedString.Key.shadow] = _shadow
        }
        
        var lsize = CGSize.zero
        
        if newLabel.count > 0
        {
            lsize = label?.size(withAttributes: _drawAttributes) ?? CGSize.zero
        }
        
        _labelSize = lsize
        
        var size = CGSize()
        size.width  = _labelSize.width + self.insets.left + self.insets.right
        size.height = _labelSize.height + self.insets.top + self.insets.bottom
        size.width  = max(minimumSize.width, size.width)
        size.height = max(minimumSize.height, size.height)
        
        self.size = size
    }
}
