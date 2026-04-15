import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    var windowFrame = self.frame

    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame
      let height = screenFrame.height
      let width: CGFloat = 320 // Mobile-like width
      let x = screenFrame.origin.x + (screenFrame.width - width) / 2
      let y = screenFrame.origin.y
      windowFrame = NSRect(x: x, y: y, width: width, height: height)
    }

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
