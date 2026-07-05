const std = @import("std");
const mouse = @import("mouse.zig");
const touch = @import("touch.zig");

pub const PenId = u32;
pub const PEN_MOUSEID: mouse.MouseId = @as(mouse.MouseId, @bitCast(@as(i32, -2)));
pub const PEN_TOUCHID: touch.TouchId = @as(touch.TouchId, @bitCast(@as(i64, -2)));
pub const PenInputFlags = packed struct(u32) {
    down: bool = false,
    button_1: bool = false,
    button_2: bool = false,
    button_3: bool = false,
    button_4: bool = false,
    button_5: bool = false,
    _b6: u24 = 0,
    eraser_tip: bool = false,
    in_proximity: bool = false,
    pub fn toInt(self: PenInputFlags) u32 {
        return @bitCast(self);
    }
};
pub const PenAxis = enum(c_int) {
    pressure,
    xtilt,
    ytilt,
    distance,
    rotation,
    slider,
    tangential_pressure,
    count,
};
pub const PenDeviceType = enum(c_int) {
    invalid = -1,
    unknown,
    direct,
    indirect,
};

extern fn SDL_GetPenDeviceType(instance_id: PenId) callconv(.c) PenDeviceType;

pub inline fn getPenDeviceType(instance_id: PenId) !PenDeviceType {
    const device_type = SDL_GetPenDeviceType(instance_id);
    if (device_type == .invalid) return error.SDLError;
    return device_type;
}
