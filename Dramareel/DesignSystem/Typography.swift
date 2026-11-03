import SwiftUI

public enum DramareelTypography {
    /// Large display title (Hero & Splash)
    public static func heroTitle(size: CGFloat = 32) -> Font {
        .system(size: size, weight: .black, design: .rounded)
    }
    
    /// Screen & Section titles
    public static func sectionTitle(size: CGFloat = 20) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    /// Drama title
    public static func dramaTitle(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .semibold, design: .default)
    }
    
    /// Body copy
    public static func body(size: CGFloat = 14) -> Font {
        .system(size: size, weight: .regular, design: .default)
    }
    
    /// Strong button label
    public static func button(size: CGFloat = 16) -> Font {
        .system(size: size, weight: .bold, design: .rounded)
    }
    
    /// Small badges & counters
    public static func caption(size: CGFloat = 12) -> Font {
        .system(size: size, weight: .medium, design: .default)
    }
    
    /// Tiny tags (HD, VIP, EP.1)
    public static func tag(size: CGFloat = 10) -> Font {
        .system(size: size, weight: .heavy, design: .rounded)
    }
}
