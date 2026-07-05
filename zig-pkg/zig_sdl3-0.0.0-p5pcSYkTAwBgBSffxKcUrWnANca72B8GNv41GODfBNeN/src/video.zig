const std = @import("std");
const SDLError = @import("error.zig").SDLError;
const pixels = @import("pixels.zig");
const rect_ = @import("rect.zig");

pub const DisplayId = u32;
pub const WindowId = u32;
pub const PropertiesId = u32;
pub const Point = rect_.Point;
pub const Rect = rect_.Rect;
pub const SystemTheme = enum(c_int) {
    unknown,
    light,
    dark,
};
const DisplayModeData = opaque {};
pub const DisplayMode = extern struct {
    display_id: DisplayId,
    format: pixels.PixelFormat,
    w: c_int,
    h: c_int,
    pixel_density: f32,
    refresh_rate: f32,
    refresh_rate_numerator: c_int,
    refresh_rate_denominator: c_int,
    internal: ?*DisplayModeData,
};
pub const DisplayOrientation = enum(c_int) {
    unknown,
    landscape,
    landscape_flipped,
    portrait,
    portrait_flipped,
};
const SDL_Window = opaque {};
/// A handle to an SDL_Window
pub const Window = *SDL_Window;
pub const WindowFlags = packed struct(u64) {
    fullscreen: bool = false,
    opengl: bool = false,
    occluded: bool = false,
    hidden: bool = false,
    borderless: bool = false,
    resizable: bool = false,
    minimized: bool = false,
    maximized: bool = false,
    mouse_grabbed: bool = false,
    input_focus: bool = false,
    mouse_focus: bool = false,
    external: bool = false,
    modal: bool = false,
    high_pixel_density: bool = false,
    mouse_capture: bool = false,
    mouse_relative_mode: bool = false,
    always_on_top: bool = false,
    utility: bool = false,
    tooltip: bool = false,
    popup_menu: bool = false,
    keyboard_grabbed: bool = false,
    fill_document: bool = false,
    _b22: u6 = 0,
    vulkan: bool = false,
    metal: bool = false,
    transparent: bool = false,
    not_focusable: bool = false,
    _reserved: u32 = 0,
    pub fn toInt(self: WindowFlags) u64 {
        return @bitCast(self);
    }
};
pub const WindowPosition = struct {
    pub const UNDEFINED_MASK: u32 = 0x1fff0000;
    pub const CENTERED_MASK: u32 = 0x2fff0000;
    pub fn undefinedDisplay(display_id: DisplayId) c_int {
        return @bitCast(UNDEFINED_MASK | display_id);
    }
    pub fn centeredDisplay(display_id: DisplayId) c_int {
        return @bitCast(CENTERED_MASK | display_id);
    }
    pub const @"undefined": c_int = undefinedDisplay(0);
    pub const centered: c_int = centeredDisplay(0);
    pub fn isUndefined(position: c_int) bool {
        return (@as(u32, @bitCast(position)) & 0xffff0000) == UNDEFINED_MASK;
    }
    pub fn isCentered(position: c_int) bool {
        return (@as(u32, @bitCast(position)) & 0xffff0000) == CENTERED_MASK;
    }
};
pub const FlashOperation = enum(c_int) {
    cancel,
    briefly,
    until_focused,
};
pub const ProgressState = enum(c_int) {
    invalid = -1,
    none,
    indeterminate,
    normal,
    paused,
    @"error",
};
pub const Size = struct {
    w: c_int,
    h: c_int,
};
pub const Position = struct {
    x: c_int,
    y: c_int,
};
pub const BorderSize = struct {
    top: c_int,
    left: c_int,
    bottom: c_int,
    right: c_int,
};
pub const AspectRatio = struct {
    min: f32,
    max: f32,
};

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_GetSystemTheme() callconv(.c) SystemTheme;
extern fn SDL_GetDisplays(count: ?*c_int) callconv(.c) ?[*]DisplayId;
extern fn SDL_GetPrimaryDisplay() callconv(.c) DisplayId;
extern fn SDL_GetDisplayProperties(displayID: DisplayId) callconv(.c) PropertiesId;
extern fn SDL_GetDisplayName(displayID: DisplayId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetDisplayBounds(displayID: DisplayId, rect: *Rect) callconv(.c) bool;
extern fn SDL_GetDisplayUsableBounds(displayID: DisplayId, rect: *Rect) callconv(.c) bool;
extern fn SDL_GetNaturalDisplayOrientation(displayID: DisplayId) callconv(.c) DisplayOrientation;
extern fn SDL_GetCurrentDisplayOrientation(displayID: DisplayId) callconv(.c) DisplayOrientation;
extern fn SDL_GetDisplayContentScale(displayID: DisplayId) callconv(.c) f32;
extern fn SDL_GetFullscreenDisplayModes(displayID: DisplayId, count: ?*c_int) callconv(.c) ?[*]*DisplayMode;
extern fn SDL_GetClosestFullscreenDisplayMode(displayID: DisplayId, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: bool, closest: *DisplayMode) callconv(.c) bool;
extern fn SDL_GetDesktopDisplayMode(displayID: DisplayId) callconv(.c) ?*const DisplayMode;
extern fn SDL_GetCurrentDisplayMode(displayID: DisplayId) callconv(.c) ?*const DisplayMode;
extern fn SDL_GetDisplayForPoint(point: *const Point) callconv(.c) DisplayId;
extern fn SDL_GetDisplayForRect(rect: *const Rect) callconv(.c) DisplayId;
extern fn SDL_GetDisplayForWindow(window: Window) callconv(.c) DisplayId;
extern fn SDL_GetWindowPixelDensity(window: Window) callconv(.c) f32;
extern fn SDL_GetWindowDisplayScale(window: Window) callconv(.c) f32;
extern fn SDL_SetWindowFullscreenMode(window: Window, mode: ?*const DisplayMode) callconv(.c) bool;
extern fn SDL_GetWindowFullscreenMode(window: Window) callconv(.c) ?*const DisplayMode;
extern fn SDL_GetWindowPixelFormat(window: Window) callconv(.c) pixels.PixelFormat;
extern fn SDL_GetWindows(count: ?*c_int) callconv(.c) ?[*]Window;
extern fn SDL_CreateWindow(title: [*:0]const u8, w: c_int, h: c_int, flags: WindowFlags) callconv(.c) ?Window;
extern fn SDL_CreatePopupWindow(parent: Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) callconv(.c) ?Window;
extern fn SDL_GetWindowID(window: Window) callconv(.c) WindowId;
extern fn SDL_GetWindowFromID(id: WindowId) callconv(.c) ?Window;
extern fn SDL_GetWindowParent(window: Window) callconv(.c) ?Window;
extern fn SDL_GetWindowProperties(window: Window) callconv(.c) PropertiesId;
extern fn SDL_GetWindowFlags(window: Window) callconv(.c) WindowFlags;
extern fn SDL_SetWindowTitle(window: Window, title: [*:0]const u8) callconv(.c) bool;
extern fn SDL_GetWindowTitle(window: Window) callconv(.c) [*:0]const u8;
extern fn SDL_SetWindowPosition(window: Window, x: c_int, y: c_int) callconv(.c) bool;
extern fn SDL_GetWindowPosition(window: Window, x: ?*c_int, y: ?*c_int) callconv(.c) bool;
extern fn SDL_SetWindowSize(window: Window, w: c_int, h: c_int) callconv(.c) bool;
extern fn SDL_GetWindowSize(window: Window, w: ?*c_int, h: ?*c_int) callconv(.c) bool;
extern fn SDL_GetWindowSafeArea(window: Window, rect: *Rect) callconv(.c) bool;
extern fn SDL_SetWindowAspectRatio(window: Window, min_aspect: f32, max_aspect: f32) callconv(.c) bool;
extern fn SDL_GetWindowAspectRatio(window: Window, min_aspect: ?*f32, max_aspect: ?*f32) callconv(.c) bool;
extern fn SDL_GetWindowBordersSize(window: Window, top: ?*c_int, left: ?*c_int, bottom: ?*c_int, right: ?*c_int) callconv(.c) bool;
extern fn SDL_GetWindowSizeInPixels(window: Window, w: ?*c_int, h: ?*c_int) callconv(.c) bool;
extern fn SDL_SetWindowMinimumSize(window: Window, min_w: c_int, min_h: c_int) callconv(.c) bool;
extern fn SDL_GetWindowMinimumSize(window: Window, w: ?*c_int, h: ?*c_int) callconv(.c) bool;
extern fn SDL_SetWindowMaximumSize(window: Window, max_w: c_int, max_h: c_int) callconv(.c) bool;
extern fn SDL_GetWindowMaximumSize(window: Window, w: ?*c_int, h: ?*c_int) callconv(.c) bool;
extern fn SDL_SetWindowBordered(window: Window, bordered: bool) callconv(.c) bool;
extern fn SDL_SetWindowResizable(window: Window, resizable: bool) callconv(.c) bool;
extern fn SDL_SetWindowAlwaysOnTop(window: Window, on_top: bool) callconv(.c) bool;
extern fn SDL_SetWindowFillDocument(window: Window, fill: bool) callconv(.c) bool;
extern fn SDL_ShowWindow(window: Window) callconv(.c) bool;
extern fn SDL_HideWindow(window: Window) callconv(.c) bool;
extern fn SDL_RaiseWindow(window: Window) callconv(.c) bool;
extern fn SDL_MaximizeWindow(window: Window) callconv(.c) bool;
extern fn SDL_MinimizeWindow(window: Window) callconv(.c) bool;
extern fn SDL_RestoreWindow(window: Window) callconv(.c) bool;
extern fn SDL_SetWindowFullscreen(window: Window, fullscreen: bool) callconv(.c) bool;
extern fn SDL_SyncWindow(window: Window) callconv(.c) bool;
extern fn SDL_SetWindowKeyboardGrab(window: Window, grabbed: bool) callconv(.c) bool;
extern fn SDL_SetWindowMouseGrab(window: Window, grabbed: bool) callconv(.c) bool;
extern fn SDL_GetWindowKeyboardGrab(window: Window) callconv(.c) bool;
extern fn SDL_GetWindowMouseGrab(window: Window) callconv(.c) bool;
extern fn SDL_GetGrabbedWindow() callconv(.c) ?Window;
extern fn SDL_SetWindowMouseRect(window: Window, rect: ?*const Rect) callconv(.c) bool;
extern fn SDL_GetWindowMouseRect(window: Window) callconv(.c) ?*const Rect;
extern fn SDL_SetWindowOpacity(window: Window, opacity: f32) callconv(.c) bool;
extern fn SDL_GetWindowOpacity(window: Window) callconv(.c) f32;
extern fn SDL_SetWindowParent(window: Window, parent: ?Window) callconv(.c) bool;
extern fn SDL_SetWindowModal(window: Window, modal: bool) callconv(.c) bool;
extern fn SDL_SetWindowFocusable(window: Window, focusable: bool) callconv(.c) bool;
extern fn SDL_ShowWindowSystemMenu(window: Window, x: c_int, y: c_int) callconv(.c) bool;
extern fn SDL_FlashWindow(window: Window, operation: FlashOperation) callconv(.c) bool;
extern fn SDL_SetWindowProgressState(window: Window, state: ProgressState) callconv(.c) bool;
extern fn SDL_GetWindowProgressState(window: Window) callconv(.c) ProgressState;
extern fn SDL_SetWindowProgressValue(window: Window, value: f32) callconv(.c) bool;
extern fn SDL_GetWindowProgressValue(window: Window) callconv(.c) f32;
extern fn SDL_DestroyWindow(window: Window) callconv(.c) void;

pub const getSystemTheme = SDL_GetSystemTheme;
pub inline fn getDisplays(allocator: std.mem.Allocator) ![]DisplayId {
    var count: c_int = 0;
    const displays = SDL_GetDisplays(&count) orelse return error.SDLError;
    defer SDL_free(@ptrCast(displays));
    const slice = try allocator.alloc(DisplayId, @intCast(count));
    errdefer allocator.free(slice);
    @memcpy(slice, displays);
    return slice;
}
pub inline fn getPrimaryDisplay() !DisplayId {
    const display_id = SDL_GetPrimaryDisplay();
    if (display_id == 0) return error.SDLError;
    return display_id;
}
pub inline fn getDisplayProperties(display_id: DisplayId) !PropertiesId {
    const properties = SDL_GetDisplayProperties(display_id);
    if (properties == 0) return error.SDLError;
    return properties;
}
pub inline fn getDisplayName(display_id: DisplayId) ![*:0]const u8 {
    return SDL_GetDisplayName(display_id) orelse error.SDLError;
}
pub inline fn getDisplayBounds(display_id: DisplayId) !Rect {
    var rect: Rect = undefined;
    if (!SDL_GetDisplayBounds(display_id, &rect)) return error.SDLError;
    return rect;
}
pub inline fn getDisplayUsableBounds(display_id: DisplayId) !Rect {
    var rect: Rect = undefined;
    if (!SDL_GetDisplayUsableBounds(display_id, &rect)) return error.SDLError;
    return rect;
}
pub const getNaturalDisplayOrientation = SDL_GetNaturalDisplayOrientation;
pub const getCurrentDisplayOrientation = SDL_GetCurrentDisplayOrientation;
pub inline fn getDisplayContentScale(display_id: DisplayId) !f32 {
    const scale = SDL_GetDisplayContentScale(display_id);
    if (scale == 0.0) return error.SDLError;
    return scale;
}
pub inline fn getFullscreenDisplayModes(display_id: DisplayId, allocator: std.mem.Allocator) ![]*DisplayMode {
    var count: c_int = 0;
    const modes = SDL_GetFullscreenDisplayModes(display_id, &count) orelse return error.SDLError;
    errdefer SDL_free(@ptrCast(modes));
    const slice = try allocator.alloc(*DisplayMode, @intCast(count));
    errdefer allocator.free(slice);
    @memcpy(slice, modes);
    return slice;
}
pub inline fn getClosestFullscreenDisplayMode(display_id: DisplayId, w: c_int, h: c_int, refresh_rate: f32, include_high_density_modes: bool) !DisplayMode {
    var closest: DisplayMode = undefined;
    if (!SDL_GetClosestFullscreenDisplayMode(display_id, w, h, refresh_rate, include_high_density_modes, &closest)) return error.SDLError;
    return closest;
}
pub inline fn getDesktopDisplayMode(display_id: DisplayId) !*const DisplayMode {
    return SDL_GetDesktopDisplayMode(display_id) orelse error.SDLError;
}
pub inline fn getCurrentDisplayMode(display_id: DisplayId) !*const DisplayMode {
    return SDL_GetCurrentDisplayMode(display_id) orelse error.SDLError;
}
pub inline fn getDisplayForPoint(point: Point) !DisplayId {
    const display_id = SDL_GetDisplayForPoint(&point);
    if (display_id == 0) return error.SDLError;
    return display_id;
}
pub inline fn getDisplayForRect(rect: Rect) !DisplayId {
    const display_id = SDL_GetDisplayForRect(&rect);
    if (display_id == 0) return error.SDLError;
    return display_id;
}
pub inline fn getDisplayForWindow(window: Window) !DisplayId {
    const display_id = SDL_GetDisplayForWindow(window);
    if (display_id == 0) return error.SDLError;
    return display_id;
}
pub inline fn getWindowPixelDensity(window: Window) !f32 {
    const density = SDL_GetWindowPixelDensity(window);
    if (density == 0.0) return error.SDLError;
    return density;
}
pub inline fn getWindowDisplayScale(window: Window) !f32 {
    const scale = SDL_GetWindowDisplayScale(window);
    if (scale == 0.0) return error.SDLError;
    return scale;
}
pub inline fn setWindowFullscreenMode(window: Window, mode: ?*const DisplayMode) !void {
    if (!SDL_SetWindowFullscreenMode(window, mode)) return error.SDLError;
}
pub const getWindowFullscreenMode = SDL_GetWindowFullscreenMode;
pub const getWindowPixelFormat = SDL_GetWindowPixelFormat;
pub inline fn getWindows(allocator: std.mem.Allocator) ![]Window {
    var count: c_int = 0;
    const windows = SDL_GetWindows(&count) orelse return error.SDLError;
    defer SDL_free(@ptrCast(windows));
    const slice = try allocator.alloc(Window, @intCast(count));
    errdefer allocator.free(slice);
    @memcpy(slice, windows);
    return slice;
}
pub inline fn createWindow(title: [*:0]const u8, w: c_int, h: c_int, flags: WindowFlags) !Window {
    return SDL_CreateWindow(title, w, h, flags) orelse error.SDLError;
}
pub inline fn createPopupWindow(parent: Window, offset_x: c_int, offset_y: c_int, w: c_int, h: c_int, flags: WindowFlags) !Window {
    return SDL_CreatePopupWindow(parent, offset_x, offset_y, w, h, flags) orelse error.SDLError;
}
pub inline fn getWindowId(window: Window) !WindowId {
    const id = SDL_GetWindowID(window);
    if (id == 0) return error.SDLError;
    return id;
}
pub inline fn getWindowFromId(id: WindowId) !Window {
    return SDL_GetWindowFromID(id) orelse error.SDLError;
}
pub const getWindowParent = SDL_GetWindowParent;
pub inline fn getWindowProperties(window: Window) !PropertiesId {
    const properties = SDL_GetWindowProperties(window);
    if (properties == 0) return error.SDLError;
    return properties;
}
pub const getWindowFlags = SDL_GetWindowFlags;
pub inline fn setWindowTitle(window: Window, title: [*:0]const u8) !void {
    if (!SDL_SetWindowTitle(window, title)) return error.SDLError;
}
pub const getWindowTitle = SDL_GetWindowTitle;
pub inline fn setWindowPosition(window: Window, x: c_int, y: c_int) !void {
    if (!SDL_SetWindowPosition(window, x, y)) return error.SDLError;
}
pub inline fn getWindowPosition(window: Window) !Position {
    var x: c_int = undefined;
    var y: c_int = undefined;
    if (!SDL_GetWindowPosition(window, &x, &y)) return error.SDLError;
    return .{ .x = x, .y = y };
}
pub inline fn setWindowSize(window: Window, w: c_int, h: c_int) !void {
    if (!SDL_SetWindowSize(window, w, h)) return error.SDLError;
}
pub inline fn getWindowSize(window: Window) !Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (!SDL_GetWindowSize(window, &w, &h)) return error.SDLError;
    return .{ .w = w, .h = h };
}
pub inline fn getWindowSafeArea(window: Window) !Rect {
    var rect: Rect = undefined;
    if (!SDL_GetWindowSafeArea(window, &rect)) return error.SDLError;
    return rect;
}
pub inline fn setWindowAspectRatio(window: Window, min_aspect: f32, max_aspect: f32) !void {
    if (!SDL_SetWindowAspectRatio(window, min_aspect, max_aspect)) return error.SDLError;
}
pub inline fn getWindowAspectRatio(window: Window) !AspectRatio {
    var min_aspect: f32 = undefined;
    var max_aspect: f32 = undefined;
    if (!SDL_GetWindowAspectRatio(window, &min_aspect, &max_aspect)) return error.SDLError;
    return .{ .min = min_aspect, .max = max_aspect };
}
pub inline fn getWindowBordersSize(window: Window) !BorderSize {
    var top: c_int = undefined;
    var left: c_int = undefined;
    var bottom: c_int = undefined;
    var right: c_int = undefined;
    if (!SDL_GetWindowBordersSize(window, &top, &left, &bottom, &right)) return error.SDLError;
    return .{ .top = top, .left = left, .bottom = bottom, .right = right };
}
pub inline fn getWindowSizeInPixels(window: Window) !Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (!SDL_GetWindowSizeInPixels(window, &w, &h)) return error.SDLError;
    return .{ .w = w, .h = h };
}
pub inline fn setWindowMinimumSize(window: Window, min_w: c_int, min_h: c_int) !void {
    if (!SDL_SetWindowMinimumSize(window, min_w, min_h)) return error.SDLError;
}
pub inline fn getWindowMinimumSize(window: Window) !Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (!SDL_GetWindowMinimumSize(window, &w, &h)) return error.SDLError;
    return .{ .w = w, .h = h };
}
pub inline fn setWindowMaximumSize(window: Window, max_w: c_int, max_h: c_int) !void {
    if (!SDL_SetWindowMaximumSize(window, max_w, max_h)) return error.SDLError;
}
pub inline fn getWindowMaximumSize(window: Window) !Size {
    var w: c_int = undefined;
    var h: c_int = undefined;
    if (!SDL_GetWindowMaximumSize(window, &w, &h)) return error.SDLError;
    return .{ .w = w, .h = h };
}
pub inline fn setWindowBordered(window: Window, bordered: bool) !void {
    if (!SDL_SetWindowBordered(window, bordered)) return error.SDLError;
}
pub inline fn setWindowResizable(window: Window, resizable: bool) !void {
    if (!SDL_SetWindowResizable(window, resizable)) return error.SDLError;
}
pub inline fn setWindowAlwaysOnTop(window: Window, on_top: bool) !void {
    if (!SDL_SetWindowAlwaysOnTop(window, on_top)) return error.SDLError;
}
pub inline fn setWindowFillDocument(window: Window, fill: bool) !void {
    if (!SDL_SetWindowFillDocument(window, fill)) return error.SDLError;
}
pub inline fn showWindow(window: Window) !void {
    if (!SDL_ShowWindow(window)) return error.SDLError;
}
pub inline fn hideWindow(window: Window) !void {
    if (!SDL_HideWindow(window)) return error.SDLError;
}
pub inline fn raiseWindow(window: Window) !void {
    if (!SDL_RaiseWindow(window)) return error.SDLError;
}
pub inline fn maximizeWindow(window: Window) !void {
    if (!SDL_MaximizeWindow(window)) return error.SDLError;
}
pub inline fn minimizeWindow(window: Window) !void {
    if (!SDL_MinimizeWindow(window)) return error.SDLError;
}
pub inline fn restoreWindow(window: Window) !void {
    if (!SDL_RestoreWindow(window)) return error.SDLError;
}
pub inline fn setWindowFullscreen(window: Window, fullscreen: bool) !void {
    if (!SDL_SetWindowFullscreen(window, fullscreen)) return error.SDLError;
}
pub inline fn syncWindow(window: Window) !void {
    if (!SDL_SyncWindow(window)) return error.SDLError;
}
pub inline fn setWindowKeyboardGrab(window: Window, grabbed: bool) !void {
    if (!SDL_SetWindowKeyboardGrab(window, grabbed)) return error.SDLError;
}
pub inline fn setWindowMouseGrab(window: Window, grabbed: bool) !void {
    if (!SDL_SetWindowMouseGrab(window, grabbed)) return error.SDLError;
}
pub const getWindowKeyboardGrab = SDL_GetWindowKeyboardGrab;
pub const getWindowMouseGrab = SDL_GetWindowMouseGrab;
pub const getGrabbedWindow = SDL_GetGrabbedWindow;
pub inline fn setWindowMouseRect(window: Window, rect: ?*const Rect) !void {
    if (!SDL_SetWindowMouseRect(window, rect)) return error.SDLError;
}
pub const getWindowMouseRect = SDL_GetWindowMouseRect;
pub inline fn setWindowOpacity(window: Window, opacity: f32) !void {
    if (!SDL_SetWindowOpacity(window, opacity)) return error.SDLError;
}
pub inline fn getWindowOpacity(window: Window) !f32 {
    const opacity = SDL_GetWindowOpacity(window);
    if (opacity < 0.0) return error.SDLError;
    return opacity;
}
pub inline fn setWindowParent(window: Window, parent: ?Window) !void {
    if (!SDL_SetWindowParent(window, parent)) return error.SDLError;
}
pub inline fn setWindowModal(window: Window, modal: bool) !void {
    if (!SDL_SetWindowModal(window, modal)) return error.SDLError;
}
pub inline fn setWindowFocusable(window: Window, focusable: bool) !void {
    if (!SDL_SetWindowFocusable(window, focusable)) return error.SDLError;
}
pub inline fn showWindowSystemMenu(window: Window, x: c_int, y: c_int) !void {
    if (!SDL_ShowWindowSystemMenu(window, x, y)) return error.SDLError;
}
pub inline fn flashWindow(window: Window, operation: FlashOperation) !void {
    if (!SDL_FlashWindow(window, operation)) return error.SDLError;
}
pub inline fn setWindowProgressState(window: Window, state: ProgressState) !void {
    if (!SDL_SetWindowProgressState(window, state)) return error.SDLError;
}
pub inline fn getWindowProgressState(window: Window) !ProgressState {
    const state = SDL_GetWindowProgressState(window);
    if (state == .invalid) return error.SDLError;
    return state;
}
pub inline fn setWindowProgressValue(window: Window, value: f32) !void {
    if (!SDL_SetWindowProgressValue(window, value)) return error.SDLError;
}
pub inline fn getWindowProgressValue(window: Window) !f32 {
    const value = SDL_GetWindowProgressValue(window);
    if (value < 0.0) return error.SDLError;
    return value;
}
pub const destroyWindow = SDL_DestroyWindow;

test "video ABI values" {
    try std.testing.expectEqual(@as(usize, 4), @sizeOf(Point));
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(Rect));
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(WindowFlags));
    try std.testing.expectEqual(@as(u64, 0x0000000000000001), (WindowFlags{ .fullscreen = true }).toInt());
    try std.testing.expectEqual(@as(u64, 0x0000000000002000), (WindowFlags{ .high_pixel_density = true }).toInt());
    try std.testing.expectEqual(@as(u64, 0x0000000010000000), (WindowFlags{ .vulkan = true }).toInt());
    try std.testing.expect(WindowPosition.isUndefined(WindowPosition.@"@\"undefined\""));
    try std.testing.expect(WindowPosition.isCentered(WindowPosition.centered));
}
