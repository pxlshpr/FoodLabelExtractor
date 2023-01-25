import Foundation

extension Notification.Name {
    public static var zoomZoomableScrollView: Notification.Name { return .init("zoomZoomableScrollView") }
    public static var zoomableScrollViewDidEndZooming: Notification.Name { return .init("zoomableScrollViewDidEndZooming") }
    public static var zoomableScrollViewDidEndScrollingAnimation: Notification.Name { return .init("zoomableScrollViewDidEndScrollingAnimation") }
    
    public static var scannerDidPresentKeyboard: Notification.Name { return .init("scannerDidPresentKeyboard") }
    public static var scannerDidDismissKeyboard: Notification.Name { return .init("scannerDidDismissKeyboard") }
    public static var scannerDidSetImage: Notification.Name { return .init("scannerDidSetImage") }
}

extension Notification {
    public struct ZoomableScrollViewKeys {
        public static let contentOffset = "contentOffset"
        public static let contentSize = "contentSize"
        public static let zoomBox = "zoomBox"
        public static let imageSize = "imageSize"
    }
}
