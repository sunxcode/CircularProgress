import Cocoa
import CircularProgress

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
	@IBOutlet private var window: NSWindow!
	@IBOutlet private var manualCircularProgress: CircularProgress!
	@IBOutlet private var progressCircularProgress: CircularProgress!

	func applicationWillFinishLaunching(_ notification: Notification) {
		window.isMovableByWindowBackground = true
		window.makeVibrant()
		window.center()
	}

	func applicationDidFinishLaunching(_ notification: Notification) {
		configureManualView()
		configureProgressBasedView()
	}

	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}

	private func configureManualView() {
		manualCircularProgress.onCancelled = {
			self.manualCircularProgress.alphaValue = 0.3
		}

		animateWithRandomColor(
			manualCircularProgress,
			start: { circularProgress in
				circularProgress.alphaValue = 1.0
				circularProgress.resetProgress()
			},
			tick: { circularProgress in
				circularProgress.progress += 0.01
			}
		)
	}

	private func configureProgressBasedView() {
		progressCircularProgress.onCancelled = {
			self.progressCircularProgress.alphaValue = 0.3
		}

		animateWithRandomColor(
			progressCircularProgress,
			start: { circularProgress in
				circularProgress.alphaValue = 1.0
				circularProgress.resetProgress()

				let progress = Progress(totalUnitCount: 50)
				circularProgress.progressInstance = progress
			},
			tick: { circularProgress in
				circularProgress.progressInstance?.completedUnitCount += 1
			}
		)
	}

	private func animateWithRandomColor(
		_ circularProgress: CircularProgress,
		start: @escaping (CircularProgress) -> Void,
		tick: @escaping (CircularProgress) -> Void
	) {
		var startAnimating: (() -> Void)!
		var timer: Timer!

		startAnimating = {
			circularProgress.color = NSColor.uniqueRandomSystemColor()
			start(circularProgress)

			timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
				tick(circularProgress)

				if circularProgress.isFinished || circularProgress.isCancelled {
					timer.invalidate()

					delay(seconds: 1) {
						startAnimating()
					}
				}
			}
		}

		startAnimating()
	}
}
