#include "flutter_window.h"

#include <optional>
#include <windows.h>

#include "flutter/generated_plugin_registrant.h"
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
	: project_(project) {
}

FlutterWindow::~FlutterWindow() {}

// Function to send media keyboard commands
bool SendMediaKeyCommand(WORD keyCommand) {
	INPUT input[2] = {};

	// Setup keyboard input for key down
	input[0].type = INPUT_KEYBOARD;
	input[0].ki.wVk = keyCommand;
	input[0].ki.dwFlags = 0;

	// Setup keyboard input for key up
	input[1].type = INPUT_KEYBOARD;
	input[1].ki.wVk = keyCommand;
	input[1].ki.dwFlags = KEYEVENTF_KEYUP;

	// Send the key command
	UINT result = SendInput(2, input, sizeof(INPUT));
	return result == 2; // Return true if both inputs were processed
}

// Alternative approach using keybd_event (older API)
bool SendMediaKeyEventLegacy(BYTE keyCommand) {
	// Key down
	keybd_event(keyCommand, 0, 0, 0);
	// Key up
	keybd_event(keyCommand, 0, KEYEVENTF_KEYUP, 0);
	return true;
}

// Function to control media using Windows API
bool ControlMedia(const std::string& command) {
	if (command == "play" || command == "pause") {
		// VK_MEDIA_PLAY_PAUSE (0xB3) is the virtual key code for play/pause
		if (SendMediaKeyCommand(VK_MEDIA_PLAY_PAUSE)) {
			// Alternative approach using mciSendString
			// mciSendString("play", NULL, 0, NULL);  // or "pause" depending on state
			//return "Media play/pause command sent successfully";
			return true;
		}
	}
	else if (command == "next") {
		if (SendMediaKeyCommand(VK_MEDIA_NEXT_TRACK)) {
			return "Next track command sent successfully";
		}
	}
	else if (command == "previous") {
		if (SendMediaKeyCommand(VK_MEDIA_PREV_TRACK)) {
			return "Previous track command sent successfully";
		}
	}
	else if (command == "stop") {
		if (SendMediaKeyCommand(VK_MEDIA_STOP)) {
			return "Stop command sent successfully";
		}
	}

	return false;
}

bool FlutterWindow::OnCreate() {
	if (!Win32Window::OnCreate()) {
		return false;
	}

	RECT frame = GetClientArea();

	// The size here must match the window dimensions to avoid unnecessary surface
	// creation / destruction in the startup path.
	flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
		frame.right - frame.left, frame.bottom - frame.top, project_);
	// Ensure that basic setup of the controller was successful.
	if (!flutter_controller_->engine() || !flutter_controller_->view()) {
		return false;
	}
	RegisterPlugins(flutter_controller_->engine());

	flutter::MethodChannel<> media_control_channel(
		flutter_controller_->engine()->messenger(), "media/control",
		&flutter::StandardMethodCodec::GetInstance());
	media_control_channel.SetMethodCallHandler(
		[](const flutter::MethodCall<>& call,
			std::unique_ptr<flutter::MethodResult<>> result) {
				if (call.method_name() == "play") {
					if (ControlMedia("play"))
					{
						std::string response = "Media play command sent successfully";
						result->Success(response);
					}
					else
					{
						std::string response = "Failed to send media play command";
						result->Error("ERROR", response);
					}
				}
				else if (call.method_name() == "pause") {
					if (ControlMedia("pause"))
					{
						std::string response = "Media pause command sent successfully";
						result->Success(response);
					}
					else
					{
						std::string response = "Failed to send media pause command";
						result->Error("ERROR", response);
					}
				}
				else if (call.method_name() == "next") {
					if (ControlMedia("next"))
					{
						std::string response = "Media next command sent successfully";
						result->Success(response);
					}
					else
					{
						std::string response = "Failed to send media next command";
						result->Error("ERROR", response);
					}
				}
				else if (call.method_name() == "previous") {
					if (ControlMedia("previous"))
					{
						std::string response = "Media previous command sent successfully";
						result->Success(response);
					}
					else
					{
						std::string response = "Failed to send media previous command";
						result->Error("ERROR", response);
					}
				}
				else if (call.method_name() == "stop") {
					if (ControlMedia("stop"))
					{
						std::string response = "Media stop command sent successfully";
						result->Success(response);
					}
					else
					{
						std::string response = "Failed to send media stop command";
						result->Error("ERROR", response);
					}
				}
				else {
					result->NotImplemented();
				}
		});

	SetChildContent(flutter_controller_->view()->GetNativeWindow());

	flutter_controller_->engine()->SetNextFrameCallback([&]() {
		this->Show();
		});

	// Flutter can complete the first frame before the "show window" callback is
	// registered. The following call ensures a frame is pending to ensure the
	// window is shown. It is a no-op if the first frame hasn't completed yet.
	flutter_controller_->ForceRedraw();

	return true;
}

void FlutterWindow::OnDestroy() {
	if (flutter_controller_) {
		flutter_controller_ = nullptr;
	}

	Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
	WPARAM const wparam,
	LPARAM const lparam) noexcept {
	// Give Flutter, including plugins, an opportunity to handle window messages.
	if (flutter_controller_) {
		std::optional<LRESULT> result =
			flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
				lparam);
		if (result) {
			return *result;
		}
	}

	switch (message) {
	case WM_FONTCHANGE:
		flutter_controller_->engine()->ReloadSystemFonts();
		break;
	}

	return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
