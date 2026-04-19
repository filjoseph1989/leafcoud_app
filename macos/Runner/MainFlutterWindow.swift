import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    // Set a bigger mobile-like size (400x800)
    let width: CGFloat = 400
    let height: CGFloat = 800
    var windowFrame = NSRect(x: 0, y: 0, width: width, height: height)

    if let screen = NSScreen.main {
      let screenFrame = screen.visibleFrame
      let x = screenFrame.origin.x + (screenFrame.width - width) / 2
      let y = screenFrame.origin.y + (screenFrame.height - height) / 2
      windowFrame = NSRect(x: x, y: y, width: width, height: height)
    }

    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
