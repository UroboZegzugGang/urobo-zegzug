import Foundation

extension CGRect {
    /// Returns a new CGRect that is larger on all sides by a given amount of pixels.
    /// - Parameter amount: The amount of pixels to expand the rect by.
    /// - Returns: A new CGRect with the same center and a larger size.
    func expanded(by amount: CGFloat) -> CGRect {
        // Create a new CGRect with the same center as the original one
        let center = CGPoint(x: self.midX, y: self.midY)
        // Add the amount of pixels to the width and height of the original rect
        let width = self.width + amount * 2
        let height = self.height + amount * 2
        // Make sure the width and height are not negative
        let adjustedWidth = max(width, 0)
        let adjustedHeight = max(height, 0)
        // Create a new CGRect with the adjusted size and the same center
        let newRect = CGRect(x: center.x - adjustedWidth / 2, y: center.y - adjustedHeight / 2, width: adjustedWidth, height: adjustedHeight)
        // Return the new CGRect
        return newRect
    }
}
