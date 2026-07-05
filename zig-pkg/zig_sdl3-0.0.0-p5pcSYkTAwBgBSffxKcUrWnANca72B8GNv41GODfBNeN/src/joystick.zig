const std = @import("std");

const SDL_Joystick = opaque {};
pub const Joystick = *SDL_Joystick;
pub const JoystickId = u32;
pub const PropertiesId = u32;
pub const Guid = extern struct {
    data: [16]u8,
};
pub const JoystickType = enum(c_int) {
    unknown,
    gamepad,
    wheel,
    arcade_stick,
    flight_stick,
    dance_pad,
    guitar,
    drum_kit,
    arcade_pad,
    throttle,
    count,
    _,
};
pub const JoystickConnectionState = enum(c_int) {
    invalid = -1,
    unknown,
    wired,
    wireless,
    _,
};
pub const PowerState = enum(c_int) {
    @"error" = -1,
    unknown,
    on_battery,
    no_battery,
    charging,
    charged,
    _,
};
pub const SensorType = enum(c_int) {
    invalid = -1,
    unknown,
    accel,
    gyro,
    accel_l,
    gyro_l,
    accel_r,
    gyro_r,
    count,
    _,
};
pub const AXIS_MAX: i16 = 32767;
pub const AXIS_MIN: i16 = -32768;
pub const Hat = packed struct(u8) {
    up: bool = false,
    right: bool = false,
    down: bool = false,
    left: bool = false,
    _reserved: u4 = 0,
    pub fn toInt(self: Hat) u8 {
        return @bitCast(self);
    }
    pub const centered: Hat = .{};
    pub const right_up: Hat = .{ .right = true, .up = true };
    pub const right_down: Hat = .{ .right = true, .down = true };
    pub const left_up: Hat = .{ .left = true, .up = true };
    pub const left_down: Hat = .{ .left = true, .down = true };
};
pub const BallDelta = struct {
    dx: c_int,
    dy: c_int,
};
pub const PowerInfo = struct {
    state: PowerState,
    percent: c_int,
};
pub const GuidInfo = struct {
    vendor: u16,
    product: u16,
    version: u16,
    crc16: u16,
};
pub const VirtualJoystickTouchpadDesc = extern struct {
    nfingers: u16,
    padding: [3]u16 = .{ 0, 0, 0 },
};
pub const VirtualJoystickSensorDesc = extern struct {
    @"type": SensorType,
    rate: f32,
};
pub const VirtualJoystickUpdateCallback = *const fn (userdata: ?*anyopaque) callconv(.c) void;
pub const VirtualJoystickSetPlayerIndexCallback = *const fn (userdata: ?*anyopaque, player_index: c_int) callconv(.c) void;
pub const VirtualJoystickRumbleCallback = *const fn (userdata: ?*anyopaque, low_frequency_rumble: u16, high_frequency_rumble: u16) callconv(.c) bool;
pub const VirtualJoystickRumbleTriggersCallback = *const fn (userdata: ?*anyopaque, left_rumble: u16, right_rumble: u16) callconv(.c) bool;
pub const VirtualJoystickSetLedCallback = *const fn (userdata: ?*anyopaque, red: u8, green: u8, blue: u8) callconv(.c) bool;
pub const VirtualJoystickSendEffectCallback = *const fn (userdata: ?*anyopaque, data: ?*const anyopaque, size: c_int) callconv(.c) bool;
pub const VirtualJoystickSetSensorsEnabledCallback = *const fn (userdata: ?*anyopaque, enabled: bool) callconv(.c) bool;
pub const VirtualJoystickCleanupCallback = *const fn (userdata: ?*anyopaque) callconv(.c) void;
pub const VirtualJoystickDesc = extern struct {
    version: u32,
    @"type": u16,
    padding: u16 = 0,
    vendor_id: u16 = 0,
    product_id: u16 = 0,
    naxes: u16 = 0,
    nbuttons: u16 = 0,
    nballs: u16 = 0,
    nhats: u16 = 0,
    ntouchpads: u16 = 0,
    nsensors: u16 = 0,
    padding2: [2]u16 = .{ 0, 0 },
    button_mask: u32 = 0,
    axis_mask: u32 = 0,
    name: ?[*:0]const u8 = null,
    touchpads: ?[*]const VirtualJoystickTouchpadDesc = null,
    sensors: ?[*]const VirtualJoystickSensorDesc = null,
    userdata: ?*anyopaque = null,
    update: ?VirtualJoystickUpdateCallback = null,
    set_player_index: ?VirtualJoystickSetPlayerIndexCallback = null,
    rumble: ?VirtualJoystickRumbleCallback = null,
    rumble_triggers: ?VirtualJoystickRumbleTriggersCallback = null,
    set_led: ?VirtualJoystickSetLedCallback = null,
    send_effect: ?VirtualJoystickSendEffectCallback = null,
    set_sensors_enabled: ?VirtualJoystickSetSensorsEnabledCallback = null,
    cleanup: ?VirtualJoystickCleanupCallback = null,
};

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_LockJoysticks() callconv(.c) void;
extern fn SDL_TryLockJoysticks() callconv(.c) bool;
extern fn SDL_UnlockJoysticks() callconv(.c) void;
extern fn SDL_HasJoystick() callconv(.c) bool;
extern fn SDL_GetJoysticks(count: ?*c_int) callconv(.c) ?[*]JoystickId;
extern fn SDL_GetJoystickNameForID(instance_id: JoystickId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetJoystickPathForID(instance_id: JoystickId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetJoystickPlayerIndexForID(instance_id: JoystickId) callconv(.c) c_int;
extern fn SDL_GetJoystickGUIDForID(instance_id: JoystickId) callconv(.c) Guid;
extern fn SDL_GetJoystickVendorForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetJoystickProductForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetJoystickProductVersionForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetJoystickTypeForID(instance_id: JoystickId) callconv(.c) JoystickType;
extern fn SDL_OpenJoystick(instance_id: JoystickId) callconv(.c) ?Joystick;
extern fn SDL_GetJoystickFromID(instance_id: JoystickId) callconv(.c) ?Joystick;
extern fn SDL_GetJoystickFromPlayerIndex(player_index: c_int) callconv(.c) ?Joystick;
extern fn SDL_AttachVirtualJoystick(desc: *const VirtualJoystickDesc) callconv(.c) JoystickId;
extern fn SDL_DetachVirtualJoystick(instance_id: JoystickId) callconv(.c) bool;
extern fn SDL_IsJoystickVirtual(instance_id: JoystickId) callconv(.c) bool;
extern fn SDL_SetJoystickVirtualAxis(joystick: Joystick, axis: c_int, value: i16) callconv(.c) bool;
extern fn SDL_SetJoystickVirtualBall(joystick: Joystick, ball: c_int, xrel: i16, yrel: i16) callconv(.c) bool;
extern fn SDL_SetJoystickVirtualButton(joystick: Joystick, button: c_int, down: bool) callconv(.c) bool;
extern fn SDL_SetJoystickVirtualHat(joystick: Joystick, hat: c_int, value: Hat) callconv(.c) bool;
extern fn SDL_SetJoystickVirtualTouchpad(joystick: Joystick, touchpad: c_int, finger: c_int, down: bool, x: f32, y: f32, pressure: f32) callconv(.c) bool;
extern fn SDL_SendJoystickVirtualSensorData(joystick: Joystick, @"type": SensorType, sensor_timestamp: u64, data: [*]const f32, num_values: c_int) callconv(.c) bool;
extern fn SDL_GetJoystickProperties(joystick: Joystick) callconv(.c) PropertiesId;
extern fn SDL_GetJoystickName(joystick: Joystick) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetJoystickPath(joystick: Joystick) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetJoystickPlayerIndex(joystick: Joystick) callconv(.c) c_int;
extern fn SDL_SetJoystickPlayerIndex(joystick: Joystick, player_index: c_int) callconv(.c) bool;
extern fn SDL_GetJoystickGUID(joystick: Joystick) callconv(.c) Guid;
extern fn SDL_GetJoystickVendor(joystick: Joystick) callconv(.c) u16;
extern fn SDL_GetJoystickProduct(joystick: Joystick) callconv(.c) u16;
extern fn SDL_GetJoystickProductVersion(joystick: Joystick) callconv(.c) u16;
extern fn SDL_GetJoystickFirmwareVersion(joystick: Joystick) callconv(.c) u16;
extern fn SDL_GetJoystickSerial(joystick: Joystick) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetJoystickType(joystick: Joystick) callconv(.c) JoystickType;
extern fn SDL_GetJoystickGUIDInfo(guid: Guid, vendor: ?*u16, product: ?*u16, version: ?*u16, crc16: ?*u16) callconv(.c) void;
extern fn SDL_JoystickConnected(joystick: Joystick) callconv(.c) bool;
extern fn SDL_GetJoystickID(joystick: Joystick) callconv(.c) JoystickId;
extern fn SDL_GetNumJoystickAxes(joystick: Joystick) callconv(.c) c_int;
extern fn SDL_GetNumJoystickBalls(joystick: Joystick) callconv(.c) c_int;
extern fn SDL_GetNumJoystickHats(joystick: Joystick) callconv(.c) c_int;
extern fn SDL_GetNumJoystickButtons(joystick: Joystick) callconv(.c) c_int;
extern fn SDL_SetJoystickEventsEnabled(enabled: bool) callconv(.c) void;
extern fn SDL_JoystickEventsEnabled() callconv(.c) bool;
extern fn SDL_UpdateJoysticks() callconv(.c) void;
extern fn SDL_GetJoystickAxis(joystick: Joystick, axis: c_int) callconv(.c) i16;
extern fn SDL_GetJoystickAxisInitialState(joystick: Joystick, axis: c_int, state: *i16) callconv(.c) bool;
extern fn SDL_GetJoystickBall(joystick: Joystick, ball: c_int, dx: *c_int, dy: *c_int) callconv(.c) bool;
extern fn SDL_GetJoystickHat(joystick: Joystick, hat: c_int) callconv(.c) Hat;
extern fn SDL_GetJoystickButton(joystick: Joystick, button: c_int) callconv(.c) bool;
extern fn SDL_RumbleJoystick(joystick: Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) callconv(.c) bool;
extern fn SDL_RumbleJoystickTriggers(joystick: Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) callconv(.c) bool;
extern fn SDL_SetJoystickLED(joystick: Joystick, red: u8, green: u8, blue: u8) callconv(.c) bool;
extern fn SDL_SendJoystickEffect(joystick: Joystick, data: ?*const anyopaque, size: c_int) callconv(.c) bool;
extern fn SDL_CloseJoystick(joystick: Joystick) callconv(.c) void;
extern fn SDL_GetJoystickConnectionState(joystick: Joystick) callconv(.c) JoystickConnectionState;
extern fn SDL_GetJoystickPowerInfo(joystick: Joystick, percent: ?*c_int) callconv(.c) PowerState;

pub const lockJoysticks = SDL_LockJoysticks;
pub const tryLockJoysticks = SDL_TryLockJoysticks;
pub const unlockJoysticks = SDL_UnlockJoysticks;
pub const hasJoystick = SDL_HasJoystick;
pub inline fn getJoysticks(allocator: std.mem.Allocator) ![]JoystickId {
    var count: c_int = 0;
    const joysticks = SDL_GetJoysticks(&count) orelse return error.SDLError;
    defer SDL_free(joysticks);
    const result = try allocator.alloc(JoystickId, @intCast(count));
    @memcpy(result, joysticks[0..@intCast(count)]);
    return result;
}
pub inline fn getJoystickNameForId(instance_id: JoystickId) ![*:0]const u8 {
    return SDL_GetJoystickNameForID(instance_id) orelse error.SDLError;
}
pub inline fn getJoystickPathForId(instance_id: JoystickId) ![*:0]const u8 {
    return SDL_GetJoystickPathForID(instance_id) orelse error.SDLError;
}
pub const getJoystickPlayerIndexForId = SDL_GetJoystickPlayerIndexForID;
pub const getJoystickGuidForId = SDL_GetJoystickGUIDForID;
pub const getJoystickVendorForId = SDL_GetJoystickVendorForID;
pub const getJoystickProductForId = SDL_GetJoystickProductForID;
pub const getJoystickProductVersionForId = SDL_GetJoystickProductVersionForID;
pub const getJoystickTypeForId = SDL_GetJoystickTypeForID;
pub inline fn openJoystick(instance_id: JoystickId) !Joystick {
    return SDL_OpenJoystick(instance_id) orelse error.SDLError;
}
pub inline fn getJoystickFromId(instance_id: JoystickId) !Joystick {
    return SDL_GetJoystickFromID(instance_id) orelse error.SDLError;
}
pub inline fn getJoystickFromPlayerIndex(player_index: c_int) !Joystick {
    return SDL_GetJoystickFromPlayerIndex(player_index) orelse error.SDLError;
}
pub inline fn attachVirtualJoystick(desc: *const VirtualJoystickDesc) !JoystickId {
    const id = SDL_AttachVirtualJoystick(desc);
    if (id == 0) return error.SDLError;
    return id;
}
pub inline fn detachVirtualJoystick(instance_id: JoystickId) !void {
    if (!SDL_DetachVirtualJoystick(instance_id)) return error.SDLError;
}
pub const isJoystickVirtual = SDL_IsJoystickVirtual;
pub inline fn setJoystickVirtualAxis(joystick: Joystick, axis: c_int, value: i16) !void {
    if (!SDL_SetJoystickVirtualAxis(joystick, axis, value)) return error.SDLError;
}
pub inline fn setJoystickVirtualBall(joystick: Joystick, ball: c_int, xrel: i16, yrel: i16) !void {
    if (!SDL_SetJoystickVirtualBall(joystick, ball, xrel, yrel)) return error.SDLError;
}
pub inline fn setJoystickVirtualButton(joystick: Joystick, button: c_int, down: bool) !void {
    if (!SDL_SetJoystickVirtualButton(joystick, button, down)) return error.SDLError;
}
pub inline fn setJoystickVirtualHat(joystick: Joystick, hat: c_int, value: Hat) !void {
    if (!SDL_SetJoystickVirtualHat(joystick, hat, value)) return error.SDLError;
}
pub inline fn setJoystickVirtualTouchpad(joystick: Joystick, touchpad: c_int, finger: c_int, down: bool, x: f32, y: f32, pressure: f32) !void {
    if (!SDL_SetJoystickVirtualTouchpad(joystick, touchpad, finger, down, x, y, pressure)) return error.SDLError;
}
pub inline fn sendJoystickVirtualSensorData(joystick: Joystick, @"type": SensorType, sensor_timestamp: u64, data: []const f32) !void {
    if (!SDL_SendJoystickVirtualSensorData(joystick, @"type", sensor_timestamp, data.ptr, @intCast(data.len))) return error.SDLError;
}
pub inline fn getJoystickProperties(joystick: Joystick) !PropertiesId {
    const properties = SDL_GetJoystickProperties(joystick);
    if (properties == 0) return error.SDLError;
    return properties;
}
pub inline fn getJoystickName(joystick: Joystick) ?[*:0]const u8 {
    return SDL_GetJoystickName(joystick);
}
pub inline fn getJoystickPath(joystick: Joystick) ?[*:0]const u8 {
    return SDL_GetJoystickPath(joystick);
}
pub const getJoystickPlayerIndex = SDL_GetJoystickPlayerIndex;
pub inline fn setJoystickPlayerIndex(joystick: Joystick, player_index: c_int) !void {
    if (!SDL_SetJoystickPlayerIndex(joystick, player_index)) return error.SDLError;
}
pub const getJoystickGuid = SDL_GetJoystickGUID;
pub const getJoystickVendor = SDL_GetJoystickVendor;
pub const getJoystickProduct = SDL_GetJoystickProduct;
pub const getJoystickProductVersion = SDL_GetJoystickProductVersion;
pub const getJoystickFirmwareVersion = SDL_GetJoystickFirmwareVersion;
pub inline fn getJoystickSerial(joystick: Joystick) ?[*:0]const u8 {
    return SDL_GetJoystickSerial(joystick);
}
pub const getJoystickType = SDL_GetJoystickType;
pub inline fn getJoystickGuidInfo(guid: Guid) GuidInfo {
    var vendor: u16 = undefined;
    var product: u16 = undefined;
    var version: u16 = undefined;
    var crc16: u16 = undefined;
    SDL_GetJoystickGUIDInfo(guid, &vendor, &product, &version, &crc16);
    return .{ .vendor = vendor, .product = product, .version = version, .crc16 = crc16 };
}
pub const joystickConnected = SDL_JoystickConnected;
pub inline fn getJoystickId(joystick: Joystick) !JoystickId {
    const id = SDL_GetJoystickID(joystick);
    if (id == 0) return error.SDLError;
    return id;
}
pub const getNumJoystickAxes = SDL_GetNumJoystickAxes;
pub const getNumJoystickBalls = SDL_GetNumJoystickBalls;
pub const getNumJoystickHats = SDL_GetNumJoystickHats;
pub const getNumJoystickButtons = SDL_GetNumJoystickButtons;
pub const setJoystickEventsEnabled = SDL_SetJoystickEventsEnabled;
pub const joystickEventsEnabled = SDL_JoystickEventsEnabled;
pub const updateJoysticks = SDL_UpdateJoysticks;
pub const getJoystickAxis = SDL_GetJoystickAxis;
pub inline fn getJoystickAxisInitialState(joystick: Joystick, axis: c_int) ?i16 {
    var state: i16 = undefined;
    if (!SDL_GetJoystickAxisInitialState(joystick, axis, &state)) return null;
    return state;
}
pub inline fn getJoystickBall(joystick: Joystick, ball: c_int) !BallDelta {
    var dx: c_int = undefined;
    var dy: c_int = undefined;
    if (!SDL_GetJoystickBall(joystick, ball, &dx, &dy)) return error.SDLError;
    return .{ .dx = dx, .dy = dy };
}
pub const getJoystickHat = SDL_GetJoystickHat;
pub const getJoystickButton = SDL_GetJoystickButton;
pub inline fn rumbleJoystick(joystick: Joystick, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) !void {
    if (!SDL_RumbleJoystick(joystick, low_frequency_rumble, high_frequency_rumble, duration_ms)) return error.SDLError;
}
pub inline fn rumbleJoystickTriggers(joystick: Joystick, left_rumble: u16, right_rumble: u16, duration_ms: u32) !void {
    if (!SDL_RumbleJoystickTriggers(joystick, left_rumble, right_rumble, duration_ms)) return error.SDLError;
}
pub inline fn setJoystickLed(joystick: Joystick, red: u8, green: u8, blue: u8) !void {
    if (!SDL_SetJoystickLED(joystick, red, green, blue)) return error.SDLError;
}
pub inline fn sendJoystickEffect(joystick: Joystick, data: []const u8) !void {
    if (!SDL_SendJoystickEffect(joystick, data.ptr, @intCast(data.len))) return error.SDLError;
}
pub const closeJoystick = SDL_CloseJoystick;
pub inline fn getJoystickConnectionState(joystick: Joystick) !JoystickConnectionState {
    const state = SDL_GetJoystickConnectionState(joystick);
    if (state == .invalid) return error.SDLError;
    return state;
}
pub inline fn getJoystickPowerInfo(joystick: Joystick) !PowerInfo {
    var percent: c_int = undefined;
    const state = SDL_GetJoystickPowerInfo(joystick, &percent);
    if (state == .@"error") return error.SDLError;
    return .{ .state = state, .percent = percent };
}
