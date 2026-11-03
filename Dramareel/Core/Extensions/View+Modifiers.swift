import SwiftUI

public struct GlassCardModifier: ViewModifier {
    public var cornerRadius: CGFloat = 16
    public var borderColor: Color = DramareelColors.surfaceBorder
    public var borderWidth: CGFloat = 1
    
    public func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(DramareelColors.surfaceCard.opacity(0.85))
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(DramareelColors.surfaceGlass.opacity(0.4))
                            .blur(radius: 8)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .stroke(borderColor.opacity(0.5), lineWidth: borderWidth)
            )
    }
}

public struct GlowModifier: ViewModifier {
    public var color: Color = DramareelColors.primaryPurple
    public var radius: CGFloat = 12
    public var opacity: Double = 0.6
    
    public func body(content: Content) -> some View {
        content
            .shadow(color: color.opacity(opacity), radius: radius, x: 0, y: 0)
    }
}

public extension View {
    func dramareelGlass(cornerRadius: CGFloat = 16, borderColor: Color = DramareelColors.surfaceBorder) -> some View {
        modifier(GlassCardModifier(cornerRadius: cornerRadius, borderColor: borderColor))
    }
    
    func dramareelGlow(color: Color = DramareelColors.neonPink, radius: CGFloat = 10, opacity: Double = 0.45) -> some View {
        modifier(GlowModifier(color: color, radius: radius, opacity: opacity))
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
