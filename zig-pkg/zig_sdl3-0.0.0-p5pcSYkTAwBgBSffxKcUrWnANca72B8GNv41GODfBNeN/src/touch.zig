const std = @import("std");

pub const TouchId = u64;
pub const FingerId = u64;
pub const MOUSE_TOUCHID: TouchId = @as(TouchId, @bitCast(@as(i64, -1)));
pub const TouchDeviceType = enum(c_int) {
    invalid = -1,
    direct,
    indirect_absolute,
    indirect_relative,
};
pub const Finger = extern struct {
    id: FingerId,
    x: f32,
    y: f32,
    pressure: f32,
};

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_GetTouchDevices(count: ?*c_int) callconv(.c) ?[*]TouchId;
extern fn SDL_GetTouchDeviceName(touch_id: TouchId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetTouchDeviceType(touch_id: TouchId) callconv(.c) TouchDeviceType;
extern fn SDL_GetTouchFingers(touch_id: TouchId, count: ?*c_int) callconv(.c) ?[*]*Finger;

pub inline fn getTouchDevices(allocator: std.mem.Allocator) ![]TouchId {
    var count: c_int = 0;
    const devices = SDL_GetTouchDevices(&count) orelse return error.SDLError;
    defer SDL_free(devices);
    const result = try allocator.alloc(TouchId, @intCast(count));
    @memcpy(result, devices[0..@intCast(count)]);
    return result;
}
pub inline fn getTouchDeviceName(touch_id: TouchId) ![*:0]const u8 {
    return SDL_GetTouchDeviceName(touch_id) orelse error.SDLError;
}
pub const getTouchDeviceType = SDL_GetTouchDeviceType;
pub inline fn getTouchFingers(allocator: std.mem.Allocator, touch_id: TouchId) ![]Finger {
    var count: c_int = 0;
    const fingers = SDL_GetTouchFingers(touch_id, &count) orelse return error.SDLError;
    defer SDL_free(fingers);
    const result = try allocator.alloc(Finger, @intCast(count));
    for (result, fingers[0..@intCast(count)]) |*finger, source| {
        finger.* = source.*;
    }
    return result;
}
