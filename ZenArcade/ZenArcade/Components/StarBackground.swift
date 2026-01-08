import SwiftUI

struct StarBackground: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        Canvas { ctx, size in
            let gradient = Gradient(colors: [
                Color(hex: "0B140F"),
                Color(hex: "0E2217")
            ])
            ctx.fill(Path(CGRect(origin: .zero, size: size)),
                     with: .linearGradient(gradient,
                                            startPoint: .zero,
                                            endPoint: CGPoint(x: 0, y: size.height)))

            for i in 0..<180 {
                let x = CGFloat(i * 37 % Int(size.width))
                let y = CGFloat((i * 91) % Int(size.height)) + offset
                let r = CGFloat((i % 3) + 1)
                ctx.fill(
                    Path(ellipseIn: CGRect(x: x, y: y, width: r, height: r)),
                    with: .color(Color.white.opacity(0.15))
                )
            }
        }
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.linear(duration: 60).repeatForever(autoreverses: false)) {
                offset = 1000
            }
        }
    }
}
