const std = @import("std");
const keycode_ = @import("keycode.zig");
const rect_ = @import("rect.zig");
const scancode_ = @import("scancode.zig");
const video = @import("video.zig");

pub const KeyboardId = u32;
pub const Keycode = keycode_.Keycode;
pub const Keymod = keycode_.Keymod;
pub const Scancode = scancode_.Scancode;
pub const TextInputType = enum(c_int) {
    text,
    text_name,
    text_email,
    text_username,
    text_password_hidden,
    text_password_visible,
    number,
    number_password_hidden,
    number_password_visible,
};
pub const Capitalization = enum(c_int) {
    none,
    sentences,
    words,
    letters,
};
pub const ScancodeWithMod = struct {
    scancode: Scancode,
    modstate: Keymod,
};
pub const TextInputArea = struct {
    rect: rect_.Rect,
    cursor: c_int,
};
pub const PROP_TEXTINPUT_TYPE_NUMBER = "SDL.textinput.type";
pub const PROP_TEXTINPUT_CAPITALIZATION_NUMBER = "SDL.textinput.capitalization";
pub const PROP_TEXTINPUT_AUTOCORRECT_BOOLEAN = "SDL.textinput.autocorrect";
pub const PROP_TEXTINPUT_MULTILINE_BOOLEAN = "SDL.textinput.multiline";
pub const PROP_TEXTINPUT_TITLE_STRING = "SDL.textinput.title";
pub const PROP_TEXTINPUT_PLACEHOLDER_STRING = "SDL.textinput.placeholder";
pub const PROP_TEXTINPUT_DEFAULT_TEXT_STRING = "SDL.textinput.default_text";
pub const PROP_TEXTINPUT_MAX_LENGTH_NUMBER = "SDL.textinput.max_length";
pub const PROP_TEXTINPUT_ANDROID_INPUTTYPE_NUMBER = "SDL.textinput.android.inputtype";

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_HasKeyboard() callconv(.c) bool;
extern fn SDL_GetKeyboards(count: ?*c_int) callconv(.c) ?[*]KeyboardId;
extern fn SDL_GetKeyboardNameForID(instance_id: KeyboardId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetKeyboardFocus() callconv(.c) ?video.Window;
extern fn SDL_GetKeyboardState(numkeys: ?*c_int) callconv(.c) [*]const bool;
extern fn SDL_ResetKeyboard() callconv(.c) void;
extern fn SDL_GetModState() callconv(.c) Keymod;
extern fn SDL_SetModState(modstate: Keymod) callconv(.c) void;
extern fn SDL_GetKeyFromScancode(scancode: Scancode, modstate: Keymod, key_event: bool) callconv(.c) Keycode;
extern fn SDL_GetScancodeFromKey(key: Keycode, modstate: ?*Keymod) callconv(.c) Scancode;
extern fn SDL_SetScancodeName(scancode: Scancode, name: [*:0]const u8) callconv(.c) bool;
extern fn SDL_GetScancodeName(scancode: Scancode) callconv(.c) [*:0]const u8;
extern fn SDL_GetScancodeFromName(name: [*:0]const u8) callconv(.c) Scancode;
extern fn SDL_GetKeyName(key: Keycode) callconv(.c) [*:0]const u8;
extern fn SDL_GetKeyFromName(name: [*:0]const u8) callconv(.c) Keycode;
extern fn SDL_StartTextInput(window: video.Window) callconv(.c) bool;
extern fn SDL_StartTextInputWithProperties(window: video.Window, props: video.PropertiesId) callconv(.c) bool;
extern fn SDL_TextInputActive(window: video.Window) callconv(.c) bool;
extern fn SDL_StopTextInput(window: video.Window) callconv(.c) bool;
extern fn SDL_ClearComposition(window: video.Window) callconv(.c) bool;
extern fn SDL_SetTextInputArea(window: video.Window, rect: ?*const rect_.Rect, cursor: c_int) callconv(.c) bool;
extern fn SDL_GetTextInputArea(window: video.Window, rect: ?*rect_.Rect, cursor: ?*c_int) callconv(.c) bool;
extern fn SDL_HasScreenKeyboardSupport() callconv(.c) bool;
extern fn SDL_ScreenKeyboardShown(window: video.Window) callconv(.c) bool;

pub const hasKeyboard = SDL_HasKeyboard;
pub inline fn getKeyboards(allocator: std.mem.Allocator) ![]KeyboardId {
    var count: c_int = 0;
    const keyboards = SDL_GetKeyboards(&count) orelse return error.SDLError;
    defer SDL_free(keyboards);
    const result = try allocator.alloc(KeyboardId, @intCast(count));
    @memcpy(result, keyboards[0..@intCast(count)]);
    return result;
}
pub inline fn getKeyboardNameForId(instance_id: KeyboardId) ![*:0]const u8 {
    return SDL_GetKeyboardNameForID(instance_id) orelse error.SDLError;
}
pub const getKeyboardFocus = SDL_GetKeyboardFocus;
pub inline fn getKeyboardState() []const bool {
    var numkeys: c_int = 0;
    const state = SDL_GetKeyboardState(&numkeys);
    return state[0..@intCast(numkeys)];
}
pub const resetKeyboard = SDL_ResetKeyboard;
pub const getModState = SDL_GetModState;
pub const setModState = SDL_SetModState;
pub const getKeyFromScancode = SDL_GetKeyFromScancode;
pub inline fn getScancodeFromKey(key: Keycode) ScancodeWithMod {
    var modstate: Keymod = .{};
    return .{ .scancode = SDL_GetScancodeFromKey(key, &modstate), .modstate = modstate };
}
pub inline fn setScancodeName(scancode: Scancode, name: [:0]const u8) !void {
    if (!SDL_SetScancodeName(scancode, name.ptr)) return error.SDLError;
}
pub const getScancodeName = SDL_GetScancodeName;
pub inline fn getScancodeFromName(name: [:0]const u8) Scancode {
    return SDL_GetScancodeFromName(name.ptr);
}
pub const getKeyName = SDL_GetKeyName;
pub inline fn getKeyFromName(name: [:0]const u8) Keycode {
    return SDL_GetKeyFromName(name.ptr);
}
pub inline fn startTextInput(window: video.Window) !void {
    if (!SDL_StartTextInput(window)) return error.SDLError;
}
pub inline fn startTextInputWithProperties(window: video.Window, props: video.PropertiesId) !void {
    if (!SDL_StartTextInputWithProperties(window, props)) return error.SDLError;
}
pub const textInputActive = SDL_TextInputActive;
pub inline fn stopTextInput(window: video.Window) !void {
    if (!SDL_StopTextInput(window)) return error.SDLError;
}
pub inline fn clearComposition(window: video.Window) !void {
    if (!SDL_ClearComposition(window)) return error.SDLError;
}
pub inline fn setTextInputArea(window: video.Window, area: ?rect_.Rect, cursor: c_int) !void {
    if (!SDL_SetTextInputArea(window, if (area) |*rect| rect else null, cursor)) return error.SDLError;
}
pub inline fn getTextInputArea(window: video.Window) !TextInputArea {
    var area: rect_.Rect = undefined;
    var cursor: c_int = undefined;
    if (!SDL_GetTextInputArea(window, &area, &cursor)) return error.SDLError;
    return .{ .rect = area, .cursor = cursor };
}
pub const hasScreenKeyboardSupport = SDL_HasScreenKeyboardSupport;
pub const screenKeyboardShown = SDL_ScreenKeyboardShown;
