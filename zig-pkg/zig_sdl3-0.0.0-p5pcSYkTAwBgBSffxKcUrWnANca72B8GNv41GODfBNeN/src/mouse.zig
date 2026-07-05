const std = @import("std");
const video = @import("video.zig");

const SDL_Cursor = opaque {};
const SDL_Surface = opaque {};
pub const Cursor = *SDL_Cursor;
pub const Surface = *SDL_Surface;
pub const MouseId = u32;
pub const TOUCH_MOUSEID: MouseId = @as(MouseId, @bitCast(@as(i32, -1)));
pub const PEN_MOUSEID: MouseId = @as(MouseId, @bitCast(@as(i32, -2)));
pub const SystemCursor = enum(c_int) {
    default,
    text,
    wait,
    crosshair,
    progress,
    nwse_resize,
    nesw_resize,
    ew_resize,
    ns_resize,
    move,
    not_allowed,
    pointer,
    nw_resize,
    n_resize,
    ne_resize,
    e_resize,
    se_resize,
    s_resize,
    sw_resize,
    w_resize,
    context_menu,
    help,
    cell,
    vertical_text,
    alias,
    copy,
    no_drop,
    grab,
    grabbing,
    col_resize,
    row_resize,
    all_scroll,
    zoom_in,
    zoom_out,
    count,
    _,
};
pub const MouseWheelDirection = enum(c_int) {
    normal,
    flipped,
};
pub const CursorFrameInfo = extern struct {
    surface: Surface,
    duration: u32,
};
pub const MouseButton = enum(u8) {
    left = 1,
    middle = 2,
    right = 3,
    x1 = 4,
    x2 = 5,
    _,
};
pub const MouseButtonFlags = packed struct(u32) {
    left: bool = false,
    middle: bool = false,
    right: bool = false,
    x1: bool = false,
    x2: bool = false,
    _reserved: u27 = 0,
    pub fn toInt(self: MouseButtonFlags) u32 {
        return @bitCast(self);
    }
    pub fn mask(button: MouseButton) MouseButtonFlags {
        return @bitCast(@as(u32, 1) << @intCast(@intFromEnum(button) - 1));
    }
};
pub const MouseState = struct {
    buttons: MouseButtonFlags,
    x: f32,
    y: f32,
};
pub const MouseMotionTransformCallback = *const fn (userdata: ?*anyopaque, timestamp: u64, window: video.Window, mouse_id: MouseId, x: *f32, y: *f32) callconv(.c) void;

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_HasMouse() callconv(.c) bool;
extern fn SDL_GetMice(count: ?*c_int) callconv(.c) ?[*]MouseId;
extern fn SDL_GetMouseNameForID(instance_id: MouseId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetMouseFocus() callconv(.c) ?video.Window;
extern fn SDL_GetMouseState(x: ?*f32, y: ?*f32) callconv(.c) MouseButtonFlags;
extern fn SDL_GetGlobalMouseState(x: ?*f32, y: ?*f32) callconv(.c) MouseButtonFlags;
extern fn SDL_GetRelativeMouseState(x: ?*f32, y: ?*f32) callconv(.c) MouseButtonFlags;
extern fn SDL_WarpMouseInWindow(window: ?video.Window, x: f32, y: f32) callconv(.c) void;
extern fn SDL_WarpMouseGlobal(x: f32, y: f32) callconv(.c) bool;
extern fn SDL_SetRelativeMouseTransform(callback: ?MouseMotionTransformCallback, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_SetWindowRelativeMouseMode(window: video.Window, enabled: bool) callconv(.c) bool;
extern fn SDL_GetWindowRelativeMouseMode(window: video.Window) callconv(.c) bool;
extern fn SDL_CaptureMouse(enabled: bool) callconv(.c) bool;
extern fn SDL_CreateCursor(data: [*]const u8, mask: [*]const u8, w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) callconv(.c) ?Cursor;
extern fn SDL_CreateColorCursor(surface: Surface, hot_x: c_int, hot_y: c_int) callconv(.c) ?Cursor;
extern fn SDL_CreateAnimatedCursor(frames: [*]CursorFrameInfo, frame_count: c_int, hot_x: c_int, hot_y: c_int) callconv(.c) ?Cursor;
extern fn SDL_CreateSystemCursor(id: SystemCursor) callconv(.c) ?Cursor;
extern fn SDL_SetCursor(cursor: ?Cursor) callconv(.c) bool;
extern fn SDL_GetCursor() callconv(.c) ?Cursor;
extern fn SDL_GetDefaultCursor() callconv(.c) ?Cursor;
extern fn SDL_DestroyCursor(cursor: Cursor) callconv(.c) void;
extern fn SDL_ShowCursor() callconv(.c) bool;
extern fn SDL_HideCursor() callconv(.c) bool;
extern fn SDL_CursorVisible() callconv(.c) bool;

pub const hasMouse = SDL_HasMouse;
pub inline fn getMice(allocator: std.mem.Allocator) ![]MouseId {
    var count: c_int = 0;
    const mice = SDL_GetMice(&count) orelse return error.SDLError;
    defer SDL_free(mice);
    const result = try allocator.alloc(MouseId, @intCast(count));
    @memcpy(result, mice[0..@intCast(count)]);
    return result;
}
pub inline fn getMouseNameForId(instance_id: MouseId) ![*:0]const u8 {
    return SDL_GetMouseNameForID(instance_id) orelse error.SDLError;
}
pub const getMouseFocus = SDL_GetMouseFocus;
pub inline fn getMouseState() MouseState {
    var x: f32 = undefined;
    var y: f32 = undefined;
    return .{ .buttons = SDL_GetMouseState(&x, &y), .x = x, .y = y };
}
pub inline fn getGlobalMouseState() MouseState {
    var x: f32 = undefined;
    var y: f32 = undefined;
    return .{ .buttons = SDL_GetGlobalMouseState(&x, &y), .x = x, .y = y };
}
pub inline fn getRelativeMouseState() MouseState {
    var x: f32 = undefined;
    var y: f32 = undefined;
    return .{ .buttons = SDL_GetRelativeMouseState(&x, &y), .x = x, .y = y };
}
pub const warpMouseInWindow = SDL_WarpMouseInWindow;
pub inline fn warpMouseGlobal(x: f32, y: f32) !void {
    if (!SDL_WarpMouseGlobal(x, y)) return error.SDLError;
}
pub inline fn setRelativeMouseTransform(callback: ?MouseMotionTransformCallback, userdata: ?*anyopaque) !void {
    if (!SDL_SetRelativeMouseTransform(callback, userdata)) return error.SDLError;
}
pub inline fn setWindowRelativeMouseMode(window: video.Window, enabled: bool) !void {
    if (!SDL_SetWindowRelativeMouseMode(window, enabled)) return error.SDLError;
}
pub const getWindowRelativeMouseMode = SDL_GetWindowRelativeMouseMode;
pub inline fn captureMouse(enabled: bool) !void {
    if (!SDL_CaptureMouse(enabled)) return error.SDLError;
}
pub inline fn createCursor(data: []const u8, mask: []const u8, w: c_int, h: c_int, hot_x: c_int, hot_y: c_int) !Cursor {
    _ = mask.len;
    _ = data.len;
    return SDL_CreateCursor(data.ptr, mask.ptr, w, h, hot_x, hot_y) orelse error.SDLError;
}
pub inline fn createColorCursor(surface: Surface, hot_x: c_int, hot_y: c_int) !Cursor {
    return SDL_CreateColorCursor(surface, hot_x, hot_y) orelse error.SDLError;
}
pub inline fn createAnimatedCursor(frames: []CursorFrameInfo, hot_x: c_int, hot_y: c_int) !Cursor {
    return SDL_CreateAnimatedCursor(frames.ptr, @intCast(frames.len), hot_x, hot_y) orelse error.SDLError;
}
pub inline fn createSystemCursor(id: SystemCursor) !Cursor {
    return SDL_CreateSystemCursor(id) orelse error.SDLError;
}
pub inline fn setCursor(cursor: ?Cursor) !void {
    if (!SDL_SetCursor(cursor)) return error.SDLError;
}
pub const getCursor = SDL_GetCursor;
pub inline fn getDefaultCursor() !Cursor {
    return SDL_GetDefaultCursor() orelse error.SDLError;
}
pub const destroyCursor = SDL_DestroyCursor;
pub inline fn showCursor() !void {
    if (!SDL_ShowCursor()) return error.SDLError;
}
pub inline fn hideCursor() !void {
    if (!SDL_HideCursor()) return error.SDLError;
}
pub const cursorVisible = SDL_CursorVisible;
