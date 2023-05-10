import Foundation

extension Array {
    /// Removes and returns a subrange of elements from the array.
    ///
    /// - Parameter bounds: The range of indices of the elements to remove.
    /// - Returns: A new array containing the removed elements in their original order.
    /// - Precondition: The bounds must be valid indices of the array.
    mutating func removeAndReturnSubrange (_ bounds: Range<Int>) -> [Element] {
        // Check if the bounds are valid for the array
        guard bounds.lowerBound >= 0 && bounds.upperBound <= count else {
            // Return an empty array if not
            return []
        }
        // Create an empty array to store the removed elements
        var removed = [Element] ()
        // Loop from the upper bound to the lower bound in reverse order
        for i in bounds.reversed () {
            // Remove the element at the current index and append it to the removed array
            removed.append (remove (at: i))
        }
        // Reverse the removed array to preserve the original order
        removed.reverse ()
        // Return the removed array
        return removed
    }
}
