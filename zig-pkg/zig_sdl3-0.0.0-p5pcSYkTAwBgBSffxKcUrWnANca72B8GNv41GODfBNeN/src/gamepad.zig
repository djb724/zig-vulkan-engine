const std = @import("std");
const joystick_ = @import("joystick.zig");

const SDL_Gamepad = opaque {};
const SDL_IOStream = opaque {};

pub const Gamepad = *SDL_Gamepad;
pub const Joystick = joystick_.Joystick;
pub const IOStream = *SDL_IOStream;
pub const JoystickId = joystick_.JoystickId;
pub const PropertiesId = u32;
pub const Guid = joystick_.Guid;
pub const GamepadType = enum(c_int) {
    unknown = 0,
    standard,
    xbox360,
    xboxone,
    ps3,
    ps4,
    ps5,
    nintendo_switch_pro,
    nintendo_switch_joycon_left,
    nintendo_switch_joycon_right,
    nintendo_switch_joycon_pair,
    gamecube,
    steam,
    count,
    _,
};
pub const GamepadButton = enum(c_int) {
    invalid = -1,
    south,
    east,
    west,
    north,
    back,
    guide,
    start,
    left_stick,
    right_stick,
    left_shoulder,
    right_shoulder,
    dpad_up,
    dpad_down,
    dpad_left,
    dpad_right,
    misc1,
    right_paddle1,
    left_paddle1,
    right_paddle2,
    left_paddle2,
    touchpad,
    misc2,
    misc3,
    misc4,
    misc5,
    misc6,
    count,
    _,
};
pub const GamepadButtonLabel = enum(c_int) {
    unknown,
    a,
    b,
    x,
    y,
    cross,
    circle,
    square,
    triangle,
    _,
};
pub const GamepadAxis = enum(c_int) {
    invalid = -1,
    leftx,
    lefty,
    rightx,
    righty,
    left_trigger,
    right_trigger,
    count,
    _,
};
pub const GamepadCapSenseType = enum(c_int) {
    invalid = -1,
    left_stick,
    right_stick,
    left_grip,
    right_grip,
    count,
    _,
};
pub const GamepadBindingType = enum(c_int) {
    none = 0,
    button,
    axis,
    hat,
    _,
};
pub const GamepadBindingInputAxis = extern struct {
    axis: c_int,
    axis_min: c_int,
    axis_max: c_int,
};
pub const GamepadBindingInputHat = extern struct {
    hat: c_int,
    hat_mask: c_int,
};
pub const GamepadBindingOutputAxis = extern struct {
    axis: GamepadAxis,
    axis_min: c_int,
    axis_max: c_int,
};
pub const GamepadBindingInput = extern union {
    button: c_int,
    axis: GamepadBindingInputAxis,
    hat: GamepadBindingInputHat,
};
pub const GamepadBindingOutput = extern union {
    button: GamepadButton,
    axis: GamepadBindingOutputAxis,
};
pub const GamepadBinding = extern struct {
    input_type: GamepadBindingType,
    input: GamepadBindingInput,
    output_type: GamepadBindingType,
    output: GamepadBindingOutput,
};
pub const JoystickConnectionState = joystick_.JoystickConnectionState;
pub const PowerState = joystick_.PowerState;
pub const SensorType = joystick_.SensorType;
pub const TouchpadFinger = struct {
    down: bool,
    x: f32,
    y: f32,
    pressure: f32,
};
pub const PowerInfo = struct {
    state: PowerState,
    percent: c_int,
};

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_AddGamepadMapping(mapping: [*:0]const u8) callconv(.c) c_int;
extern fn SDL_AddGamepadMappingsFromIO(src: IOStream, closeio: bool) callconv(.c) c_int;
extern fn SDL_AddGamepadMappingsFromFile(file: [*:0]const u8) callconv(.c) c_int;
extern fn SDL_ReloadGamepadMappings() callconv(.c) bool;
extern fn SDL_GetGamepadMappings(count: ?*c_int) callconv(.c) ?[*][*:0]const u8;
extern fn SDL_GetGamepadMappingForGUID(guid: Guid) callconv(.c) ?[*:0]u8;
extern fn SDL_GetGamepadMapping(gamepad: Gamepad) callconv(.c) ?[*:0]u8;
extern fn SDL_SetGamepadMapping(instance_id: JoystickId, mapping: ?[*:0]const u8) callconv(.c) bool;
extern fn SDL_HasGamepad() callconv(.c) bool;
extern fn SDL_GetGamepads(count: ?*c_int) callconv(.c) ?[*]JoystickId;
extern fn SDL_IsGamepad(instance_id: JoystickId) callconv(.c) bool;
extern fn SDL_GetGamepadNameForID(instance_id: JoystickId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadPathForID(instance_id: JoystickId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadPlayerIndexForID(instance_id: JoystickId) callconv(.c) c_int;
extern fn SDL_GetGamepadGUIDForID(instance_id: JoystickId) callconv(.c) Guid;
extern fn SDL_GetGamepadVendorForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetGamepadProductForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetGamepadProductVersionForID(instance_id: JoystickId) callconv(.c) u16;
extern fn SDL_GetGamepadTypeForID(instance_id: JoystickId) callconv(.c) GamepadType;
extern fn SDL_GetRealGamepadTypeForID(instance_id: JoystickId) callconv(.c) GamepadType;
extern fn SDL_GetGamepadMappingForID(instance_id: JoystickId) callconv(.c) ?[*:0]u8;
extern fn SDL_OpenGamepad(instance_id: JoystickId) callconv(.c) ?Gamepad;
extern fn SDL_GetGamepadFromID(instance_id: JoystickId) callconv(.c) ?Gamepad;
extern fn SDL_GetGamepadFromPlayerIndex(player_index: c_int) callconv(.c) ?Gamepad;
extern fn SDL_GetGamepadProperties(gamepad: Gamepad) callconv(.c) PropertiesId;
extern fn SDL_GetGamepadID(gamepad: Gamepad) callconv(.c) JoystickId;
extern fn SDL_GetGamepadName(gamepad: Gamepad) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadPath(gamepad: Gamepad) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadType(gamepad: Gamepad) callconv(.c) GamepadType;
extern fn SDL_GetRealGamepadType(gamepad: Gamepad) callconv(.c) GamepadType;
extern fn SDL_GetGamepadPlayerIndex(gamepad: Gamepad) callconv(.c) c_int;
extern fn SDL_SetGamepadPlayerIndex(gamepad: Gamepad, player_index: c_int) callconv(.c) bool;
extern fn SDL_GetGamepadVendor(gamepad: Gamepad) callconv(.c) u16;
extern fn SDL_GetGamepadProduct(gamepad: Gamepad) callconv(.c) u16;
extern fn SDL_GetGamepadProductVersion(gamepad: Gamepad) callconv(.c) u16;
extern fn SDL_GetGamepadFirmwareVersion(gamepad: Gamepad) callconv(.c) u16;
extern fn SDL_GetGamepadSerial(gamepad: Gamepad) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadSteamHandle(gamepad: Gamepad) callconv(.c) u64;
extern fn SDL_GetGamepadConnectionState(gamepad: Gamepad) callconv(.c) JoystickConnectionState;
extern fn SDL_GetGamepadPowerInfo(gamepad: Gamepad, percent: ?*c_int) callconv(.c) PowerState;
extern fn SDL_GamepadConnected(gamepad: Gamepad) callconv(.c) bool;
extern fn SDL_GetGamepadJoystick(gamepad: Gamepad) callconv(.c) ?Joystick;
extern fn SDL_SetGamepadEventsEnabled(enabled: bool) callconv(.c) void;
extern fn SDL_GamepadEventsEnabled() callconv(.c) bool;
extern fn SDL_GetGamepadBindings(gamepad: Gamepad, count: ?*c_int) callconv(.c) ?[*]*GamepadBinding;
extern fn SDL_UpdateGamepads() callconv(.c) void;
extern fn SDL_GetGamepadTypeFromString(str: [*:0]const u8) callconv(.c) GamepadType;
extern fn SDL_GetGamepadStringForType(@"type": GamepadType) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadAxisFromString(str: [*:0]const u8) callconv(.c) GamepadAxis;
extern fn SDL_GetGamepadStringForAxis(axis: GamepadAxis) callconv(.c) ?[*:0]const u8;
extern fn SDL_GamepadHasAxis(gamepad: Gamepad, axis: GamepadAxis) callconv(.c) bool;
extern fn SDL_GetGamepadAxis(gamepad: Gamepad, axis: GamepadAxis) callconv(.c) i16;
extern fn SDL_GetGamepadButtonFromString(str: [*:0]const u8) callconv(.c) GamepadButton;
extern fn SDL_GetGamepadStringForButton(button: GamepadButton) callconv(.c) ?[*:0]const u8;
extern fn SDL_GamepadHasButton(gamepad: Gamepad, button: GamepadButton) callconv(.c) bool;
extern fn SDL_GetGamepadButton(gamepad: Gamepad, button: GamepadButton) callconv(.c) bool;
extern fn SDL_GetGamepadButtonLabelForType(@"type": GamepadType, button: GamepadButton) callconv(.c) GamepadButtonLabel;
extern fn SDL_GetGamepadButtonLabel(gamepad: Gamepad, button: GamepadButton) callconv(.c) GamepadButtonLabel;
extern fn SDL_GetNumGamepadTouchpads(gamepad: Gamepad) callconv(.c) c_int;
extern fn SDL_GetNumGamepadTouchpadFingers(gamepad: Gamepad, touchpad: c_int) callconv(.c) c_int;
extern fn SDL_GetGamepadTouchpadFinger(gamepad: Gamepad, touchpad: c_int, finger: c_int, down: *bool, x: *f32, y: *f32, pressure: *f32) callconv(.c) bool;
extern fn SDL_GamepadHasSensor(gamepad: Gamepad, @"type": SensorType) callconv(.c) bool;
extern fn SDL_SetGamepadSensorEnabled(gamepad: Gamepad, @"type": SensorType, enabled: bool) callconv(.c) bool;
extern fn SDL_GamepadSensorEnabled(gamepad: Gamepad, @"type": SensorType) callconv(.c) bool;
extern fn SDL_GetGamepadSensorDataRate(gamepad: Gamepad, @"type": SensorType) callconv(.c) f32;
extern fn SDL_GetGamepadSensorData(gamepad: Gamepad, @"type": SensorType, data: [*]f32, num_values: c_int) callconv(.c) bool;
extern fn SDL_GamepadHasCapSense(gamepad: Gamepad, @"type": GamepadCapSenseType) callconv(.c) bool;
extern fn SDL_GetGamepadCapSense(gamepad: Gamepad, @"type": GamepadCapSenseType) callconv(.c) bool;
extern fn SDL_RumbleGamepad(gamepad: Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) callconv(.c) bool;
extern fn SDL_RumbleGamepadTriggers(gamepad: Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) callconv(.c) bool;
extern fn SDL_SetGamepadLED(gamepad: Gamepad, red: u8, green: u8, blue: u8) callconv(.c) bool;
extern fn SDL_SendGamepadEffect(gamepad: Gamepad, data: ?*const anyopaque, size: c_int) callconv(.c) bool;
extern fn SDL_CloseGamepad(gamepad: Gamepad) callconv(.c) void;
extern fn SDL_GetGamepadAppleSFSymbolsNameForButton(gamepad: Gamepad, button: GamepadButton) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetGamepadAppleSFSymbolsNameForAxis(gamepad: Gamepad, axis: GamepadAxis) callconv(.c) ?[*:0]const u8;

fn copySdlString(allocator: std.mem.Allocator, string: [*:0]u8) ![:0]u8 {
    defer SDL_free(string);
    return try allocator.dupeSentinel(u8, std.mem.span(string));
}

pub inline fn addGamepadMapping(mapping: [*:0]const u8) !c_int {
    const result = SDL_AddGamepadMapping(mapping);
    if (result < 0) return error.SDLError;
    return result;
}
pub inline fn addGamepadMappingsFromIO(src: IOStream, closeio: bool) !c_int {
    const result = SDL_AddGamepadMappingsFromIO(src, closeio);
    if (result < 0) return error.SDLError;
    return result;
}
pub inline fn addGamepadMappingsFromFile(file: [*:0]const u8) !c_int {
    const result = SDL_AddGamepadMappingsFromFile(file);
    if (result < 0) return error.SDLError;
    return result;
}
pub inline fn reloadGamepadMappings() !void {
    if (!SDL_ReloadGamepadMappings()) return error.SDLError;
}
pub inline fn getGamepadMappings(allocator: std.mem.Allocator) ![][:0]u8 {
    var count: c_int = 0;
    const mappings = SDL_GetGamepadMappings(&count) orelse return error.SDLError;
    defer SDL_free(mappings);
    const result = try allocator.alloc([:0]u8, @intCast(count));
    errdefer allocator.free(result);
    var initialized: usize = 0;
    errdefer for (result[0..initialized]) |mapping| allocator.free(mapping);
    for (result, mappings[0..@intCast(count)]) |*out, mapping| {
        out.* = try allocator.dupeZ(u8, std.mem.span(mapping));
        initialized += 1;
    }
    return result;
}
pub inline fn getGamepadMappingForGuid(guid: Guid, allocator: std.mem.Allocator) ![:0]u8 {
    return copySdlString(allocator, SDL_GetGamepadMappingForGUID(guid) orelse return error.SDLError);
}
pub inline fn getGamepadMapping(gamepad: Gamepad, allocator: std.mem.Allocator) ![:0]u8 {
    return copySdlString(allocator, SDL_GetGamepadMapping(gamepad) orelse return error.SDLError);
}
pub inline fn setGamepadMapping(instance_id: JoystickId, mapping: ?[*:0]const u8) !void {
    if (!SDL_SetGamepadMapping(instance_id, mapping)) return error.SDLError;
}
pub const hasGamepad = SDL_HasGamepad;
pub inline fn getGamepads(allocator: std.mem.Allocator) ![]JoystickId {
    var count: c_int = 0;
    const gamepads = SDL_GetGamepads(&count) orelse return error.SDLError;
    defer SDL_free(gamepads);
    const result = try allocator.alloc(JoystickId, @intCast(count));
    @memcpy(result, gamepads[0..@intCast(count)]);
    return result;
}
pub const isGamepad = SDL_IsGamepad;
pub inline fn getGamepadNameForId(instance_id: JoystickId) ![*:0]const u8 {
    return SDL_GetGamepadNameForID(instance_id) orelse error.SDLError;
}
pub inline fn getGamepadPathForId(instance_id: JoystickId) ![*:0]const u8 {
    return SDL_GetGamepadPathForID(instance_id) orelse error.SDLError;
}
pub const getGamepadPlayerIndexForId = SDL_GetGamepadPlayerIndexForID;
pub const getGamepadGuidForId = SDL_GetGamepadGUIDForID;
pub const getGamepadVendorForId = SDL_GetGamepadVendorForID;
pub const getGamepadProductForId = SDL_GetGamepadProductForID;
pub const getGamepadProductVersionForId = SDL_GetGamepadProductVersionForID;
pub const getGamepadTypeForId = SDL_GetGamepadTypeForID;
pub const getRealGamepadTypeForId = SDL_GetRealGamepadTypeForID;
pub inline fn getGamepadMappingForId(instance_id: JoystickId, allocator: std.mem.Allocator) ![:0]u8 {
    return copySdlString(allocator, SDL_GetGamepadMappingForID(instance_id) orelse return error.SDLError);
}
pub inline fn openGamepad(instance_id: JoystickId) !Gamepad {
    return SDL_OpenGamepad(instance_id) orelse error.SDLError;
}
pub inline fn getGamepadFromId(instance_id: JoystickId) !Gamepad {
    return SDL_GetGamepadFromID(instance_id) orelse error.SDLError;
}
pub inline fn getGamepadFromPlayerIndex(player_index: c_int) !Gamepad {
    return SDL_GetGamepadFromPlayerIndex(player_index) orelse error.SDLError;
}
pub inline fn getGamepadProperties(gamepad: Gamepad) !PropertiesId {
    const properties = SDL_GetGamepadProperties(gamepad);
    if (properties == 0) return error.SDLError;
    return properties;
}
pub inline fn getGamepadId(gamepad: Gamepad) !JoystickId {
    const id = SDL_GetGamepadID(gamepad);
    if (id == 0) return error.SDLError;
    return id;
}
pub inline fn getGamepadName(gamepad: Gamepad) ?[*:0]const u8 {
    return SDL_GetGamepadName(gamepad);
}
pub inline fn getGamepadPath(gamepad: Gamepad) ?[*:0]const u8 {
    return SDL_GetGamepadPath(gamepad);
}
pub const getGamepadType = SDL_GetGamepadType;
pub const getRealGamepadType = SDL_GetRealGamepadType;
pub const getGamepadPlayerIndex = SDL_GetGamepadPlayerIndex;
pub inline fn setGamepadPlayerIndex(gamepad: Gamepad, player_index: c_int) !void {
    if (!SDL_SetGamepadPlayerIndex(gamepad, player_index)) return error.SDLError;
}
pub const getGamepadVendor = SDL_GetGamepadVendor;
pub const getGamepadProduct = SDL_GetGamepadProduct;
pub const getGamepadProductVersion = SDL_GetGamepadProductVersion;
pub const getGamepadFirmwareVersion = SDL_GetGamepadFirmwareVersion;
pub inline fn getGamepadSerial(gamepad: Gamepad) ?[*:0]const u8 {
    return SDL_GetGamepadSerial(gamepad);
}
pub const getGamepadSteamHandle = SDL_GetGamepadSteamHandle;
pub inline fn getGamepadConnectionState(gamepad: Gamepad) !JoystickConnectionState {
    const state = SDL_GetGamepadConnectionState(gamepad);
    if (state == .invalid) return error.SDLError;
    return state;
}
pub inline fn getGamepadPowerInfo(gamepad: Gamepad) PowerInfo {
    var percent: c_int = undefined;
    return .{ .state = SDL_GetGamepadPowerInfo(gamepad, &percent), .percent = percent };
}
pub const gamepadConnected = SDL_GamepadConnected;
pub inline fn getGamepadJoystick(gamepad: Gamepad) !Joystick {
    return SDL_GetGamepadJoystick(gamepad) orelse error.SDLError;
}
pub const setGamepadEventsEnabled = SDL_SetGamepadEventsEnabled;
pub const gamepadEventsEnabled = SDL_GamepadEventsEnabled;
pub inline fn getGamepadBindings(allocator: std.mem.Allocator, gamepad: Gamepad) ![]*GamepadBinding {
    var count: c_int = 0;
    const bindings = SDL_GetGamepadBindings(gamepad, &count) orelse return error.SDLError;
    defer SDL_free(bindings);
    const result = try allocator.alloc(*GamepadBinding, @intCast(count));
    @memcpy(result, bindings[0..@intCast(count)]);
    return result;
}
pub const updateGamepads = SDL_UpdateGamepads;
pub const getGamepadTypeFromString = SDL_GetGamepadTypeFromString;
pub inline fn getGamepadStringForType(@"type": GamepadType) ?[*:0]const u8 {
    return SDL_GetGamepadStringForType(@"type");
}
pub const getGamepadAxisFromString = SDL_GetGamepadAxisFromString;
pub inline fn getGamepadStringForAxis(axis: GamepadAxis) ?[*:0]const u8 {
    return SDL_GetGamepadStringForAxis(axis);
}
pub const gamepadHasAxis = SDL_GamepadHasAxis;
pub const getGamepadAxis = SDL_GetGamepadAxis;
pub const getGamepadButtonFromString = SDL_GetGamepadButtonFromString;
pub inline fn getGamepadStringForButton(button: GamepadButton) ?[*:0]const u8 {
    return SDL_GetGamepadStringForButton(button);
}
pub const gamepadHasButton = SDL_GamepadHasButton;
pub const getGamepadButton = SDL_GetGamepadButton;
pub const getGamepadButtonLabelForType = SDL_GetGamepadButtonLabelForType;
pub const getGamepadButtonLabel = SDL_GetGamepadButtonLabel;
pub const getNumGamepadTouchpads = SDL_GetNumGamepadTouchpads;
pub const getNumGamepadTouchpadFingers = SDL_GetNumGamepadTouchpadFingers;
pub inline fn getGamepadTouchpadFinger(gamepad: Gamepad, touchpad: c_int, finger: c_int) !TouchpadFinger {
    var down: bool = undefined;
    var x: f32 = undefined;
    var y: f32 = undefined;
    var pressure: f32 = undefined;
    if (!SDL_GetGamepadTouchpadFinger(gamepad, touchpad, finger, &down, &x, &y, &pressure)) return error.SDLError;
    return .{ .down = down, .x = x, .y = y, .pressure = pressure };
}
pub const gamepadHasSensor = SDL_GamepadHasSensor;
pub inline fn setGamepadSensorEnabled(gamepad: Gamepad, @"type": SensorType, enabled: bool) !void {
    if (!SDL_SetGamepadSensorEnabled(gamepad, @"type", enabled)) return error.SDLError;
}
pub const gamepadSensorEnabled = SDL_GamepadSensorEnabled;
pub const getGamepadSensorDataRate = SDL_GetGamepadSensorDataRate;
pub inline fn getGamepadSensorData(gamepad: Gamepad, @"type": SensorType, data: []f32) !void {
    if (!SDL_GetGamepadSensorData(gamepad, @"type", data.ptr, @intCast(data.len))) return error.SDLError;
}
pub const gamepadHasCapSense = SDL_GamepadHasCapSense;
pub const getGamepadCapSense = SDL_GetGamepadCapSense;
pub inline fn rumbleGamepad(gamepad: Gamepad, low_frequency_rumble: u16, high_frequency_rumble: u16, duration_ms: u32) !void {
    if (!SDL_RumbleGamepad(gamepad, low_frequency_rumble, high_frequency_rumble, duration_ms)) return error.SDLError;
}
pub inline fn rumbleGamepadTriggers(gamepad: Gamepad, left_rumble: u16, right_rumble: u16, duration_ms: u32) !void {
    if (!SDL_RumbleGamepadTriggers(gamepad, left_rumble, right_rumble, duration_ms)) return error.SDLError;
}
pub inline fn setGamepadLed(gamepad: Gamepad, red: u8, green: u8, blue: u8) !void {
    if (!SDL_SetGamepadLED(gamepad, red, green, blue)) return error.SDLError;
}
pub inline fn sendGamepadEffect(gamepad: Gamepad, data: []const u8) !void {
    if (!SDL_SendGamepadEffect(gamepad, data.ptr, @intCast(data.len))) return error.SDLError;
}
pub const closeGamepad = SDL_CloseGamepad;
pub inline fn getGamepadAppleSfSymbolsNameForButton(gamepad: Gamepad, button: GamepadButton) ?[*:0]const u8 {
    return SDL_GetGamepadAppleSFSymbolsNameForButton(gamepad, button);
}
pub inline fn getGamepadAppleSfSymbolsNameForAxis(gamepad: Gamepad, axis: GamepadAxis) ?[*:0]const u8 {
    return SDL_GetGamepadAppleSFSymbolsNameForAxis(gamepad, axis);
}
