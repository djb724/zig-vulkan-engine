const std = @import("std");
const gamepad = @import("gamepad.zig");
const joystick = @import("joystick.zig");
const keyboard = @import("keyboard.zig");
const mouse = @import("mouse.zig");
const pen = @import("pen.zig");
const touch = @import("touch.zig");
const video = @import("video.zig");

pub const AudioDeviceId = u32;
pub const CameraId = u32;
pub const SensorId = u32;
pub const EventType = enum(c_int) {
    first = 0,
    quit = 0x100,
    terminating,
    low_memory,
    will_enter_background,
    did_enter_background,
    will_enter_foreground,
    did_enter_foreground,
    locale_changed,
    system_theme_changed = 0x109,
    display_orientation = 0x151,
    display_added,
    display_removed,
    display_moved,
    display_desktop_mode_changed,
    display_current_mode_changed,
    display_content_scale_changed,
    display_usable_bounds_changed,
    window_shown = 0x202,
    window_hidden,
    window_exposed,
    window_moved,
    window_resized,
    window_pixel_size_changed,
    window_metal_view_resized,
    window_minimized,
    window_maximized,
    window_restored,
    window_mouse_enter,
    window_mouse_leave,
    window_focus_gained,
    window_focus_lost,
    window_close_requested,
    window_hit_test,
    window_iccprof_changed,
    window_display_changed,
    window_display_scale_changed,
    window_safe_area_changed,
    window_occluded,
    window_enter_fullscreen,
    window_leave_fullscreen,
    window_destroyed,
    window_hdr_state_changed,
    window_settings_changed,
    key_down = 0x300,
    key_up,
    text_editing,
    text_input,
    keymap_changed,
    keyboard_added,
    keyboard_removed,
    text_editing_candidates,
    screen_keyboard_shown,
    screen_keyboard_hidden,
    mouse_motion = 0x400,
    mouse_button_down,
    mouse_button_up,
    mouse_wheel,
    mouse_added,
    mouse_removed,
    joystick_axis_motion = 0x600,
    joystick_ball_motion,
    joystick_hat_motion,
    joystick_button_down,
    joystick_button_up,
    joystick_added,
    joystick_removed,
    joystick_battery_updated,
    joystick_update_complete,
    gamepad_axis_motion = 0x650,
    gamepad_button_down,
    gamepad_button_up,
    gamepad_added,
    gamepad_removed,
    gamepad_remapped,
    gamepad_touchpad_down,
    gamepad_touchpad_motion,
    gamepad_touchpad_up,
    gamepad_sensor_update,
    gamepad_update_complete,
    gamepad_steam_handle_updated,
    gamepad_capsense_touch,
    gamepad_capsense_release,
    finger_down = 0x700,
    finger_up,
    finger_motion,
    finger_canceled,
    pinch_begin = 0x710,
    pinch_update,
    pinch_end,
    clipboard_update = 0x900,
    drop_file = 0x1000,
    drop_text,
    drop_begin,
    drop_complete,
    drop_position,
    audio_device_added = 0x1100,
    audio_device_removed,
    audio_device_format_changed,
    sensor_update = 0x1200,
    pen_proximity_in = 0x1300,
    pen_proximity_out,
    pen_down,
    pen_up,
    pen_button_down,
    pen_button_up,
    pen_motion,
    pen_axis,
    camera_device_added = 0x1400,
    camera_device_removed,
    camera_device_approved,
    camera_device_denied,
    render_targets_reset = 0x2000,
    render_device_reset,
    render_device_lost,
    private0 = 0x4000,
    private1,
    private2,
    private3,
    poll_sentinel = 0x7f00,
    user = 0x8000,
    last = 0xffff,
    enum_padding = 0x7fffffff,
};
pub const DISPLAY_FIRST = EventType.display_orientation;
pub const DISPLAY_LAST = EventType.display_usable_bounds_changed;
pub const WINDOW_FIRST = EventType.window_shown;
pub const WINDOW_LAST = EventType.window_settings_changed;

pub const CommonEvent = extern struct {
    type: u32,
    reserved: u32,
    timestamp: u64,
};
pub const DisplayEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    display_id: video.DisplayId,
    data1: i32,
    data2: i32,
};
pub const WindowEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    data1: i32,
    data2: i32,
};
pub const KeyboardDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: keyboard.KeyboardId,
};
pub const KeyboardEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: keyboard.KeyboardId,
    scancode: keyboard.Scancode,
    key: keyboard.Keycode,
    mod: keyboard.Keymod,
    raw: u16,
    down: bool,
    repeat: bool,
};
pub const TextEditingEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    text: [*:0]const u8,
    start: i32,
    length: i32,
};
pub const TextEditingCandidatesEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    candidates: ?[*][*:0]const u8,
    num_candidates: i32,
    selected_candidate: i32,
    horizontal: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};
pub const TextInputEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    text: [*:0]const u8,
};
pub const MouseDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: mouse.MouseId,
};
pub const MouseMotionEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: mouse.MouseId,
    state: mouse.MouseButtonFlags,
    x: f32,
    y: f32,
    xrel: f32,
    yrel: f32,
};
pub const MouseButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: mouse.MouseId,
    button: u8,
    down: bool,
    clicks: u8,
    padding: u8,
    x: f32,
    y: f32,
};
pub const MouseWheelEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: mouse.MouseId,
    x: f32,
    y: f32,
    direction: mouse.MouseWheelDirection,
    mouse_x: f32,
    mouse_y: f32,
    integer_x: i32,
    integer_y: i32,
};
pub const JoyAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    axis: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    value: i16,
    padding4: u16,
};
pub const JoyBallEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    ball: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    xrel: i16,
    yrel: i16,
};
pub const JoyHatEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    hat: u8,
    value: u8,
    padding1: u8,
    padding2: u8,
};
pub const JoyButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    button: u8,
    down: bool,
    padding1: u8,
    padding2: u8,
};
pub const JoyDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
};
pub const JoyBatteryEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    state: joystick.PowerState,
    percent: c_int,
};
pub const GamepadAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    axis: u8,
    padding1: u8,
    padding2: u8,
    padding3: u8,
    value: i16,
    padding4: u16,
};
pub const GamepadButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    button: u8,
    down: bool,
    padding1: u8,
    padding2: u8,
};
pub const GamepadDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
};
pub const GamepadTouchpadEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    touchpad: i32,
    finger: i32,
    x: f32,
    y: f32,
    pressure: f32,
};
pub const GamepadSensorEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    sensor: i32,
    data: [3]f32,
    sensor_timestamp: u64,
};
pub const GamepadCapSenseEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: joystick.JoystickId,
    capsense: u8,
    down: bool,
    padding1: u8,
    padding2: u8,
};
pub const AudioDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: AudioDeviceId,
    recording: bool,
    padding1: u8,
    padding2: u8,
    padding3: u8,
};
pub const CameraDeviceEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: CameraId,
};
pub const RenderEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
};
pub const TouchFingerEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    touch_id: touch.TouchId,
    finger_id: touch.FingerId,
    x: f32,
    y: f32,
    dx: f32,
    dy: f32,
    pressure: f32,
    window_id: video.WindowId,
};
pub const PinchFingerEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    scale: f32,
    window_id: video.WindowId,
};
pub const PenProximityEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: pen.PenId,
};
pub const PenMotionEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: pen.PenId,
    pen_state: pen.PenInputFlags,
    x: f32,
    y: f32,
};
pub const PenTouchEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: pen.PenId,
    pen_state: pen.PenInputFlags,
    x: f32,
    y: f32,
    eraser: bool,
    down: bool,
};
pub const PenButtonEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: pen.PenId,
    pen_state: pen.PenInputFlags,
    x: f32,
    y: f32,
    button: u8,
    down: bool,
};
pub const PenAxisEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    which: pen.PenId,
    pen_state: pen.PenInputFlags,
    x: f32,
    y: f32,
    axis: pen.PenAxis,
    value: f32,
};
pub const DropEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    x: f32,
    y: f32,
    source: ?[*:0]const u8,
    data: ?[*:0]const u8,
};
pub const ClipboardEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    owner: bool,
    num_mime_types: i32,
    mime_types: ?[*][*:0]const u8,
};
pub const SensorEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
    which: SensorId,
    data: [6]f32,
    sensor_timestamp: u64,
};
pub const QuitEvent = extern struct {
    type: EventType,
    reserved: u32,
    timestamp: u64,
};
pub const UserEvent = extern struct {
    type: u32,
    reserved: u32,
    timestamp: u64,
    window_id: video.WindowId,
    code: i32,
    data1: ?*anyopaque,
    data2: ?*anyopaque,
};
pub const Event = extern union {
    type: u32,
    common: CommonEvent,
    display: DisplayEvent,
    window: WindowEvent,
    kdevice: KeyboardDeviceEvent,
    key: KeyboardEvent,
    edit: TextEditingEvent,
    edit_candidates: TextEditingCandidatesEvent,
    text: TextInputEvent,
    mdevice: MouseDeviceEvent,
    motion: MouseMotionEvent,
    button: MouseButtonEvent,
    wheel: MouseWheelEvent,
    jdevice: JoyDeviceEvent,
    jaxis: JoyAxisEvent,
    jball: JoyBallEvent,
    jhat: JoyHatEvent,
    jbutton: JoyButtonEvent,
    jbattery: JoyBatteryEvent,
    gdevice: GamepadDeviceEvent,
    gaxis: GamepadAxisEvent,
    gbutton: GamepadButtonEvent,
    gtouchpad: GamepadTouchpadEvent,
    gsensor: GamepadSensorEvent,
    gcapsense: GamepadCapSenseEvent,
    adevice: AudioDeviceEvent,
    cdevice: CameraDeviceEvent,
    sensor: SensorEvent,
    quit: QuitEvent,
    user: UserEvent,
    tfinger: TouchFingerEvent,
    pinch: PinchFingerEvent,
    pproximity: PenProximityEvent,
    ptouch: PenTouchEvent,
    pmotion: PenMotionEvent,
    pbutton: PenButtonEvent,
    paxis: PenAxisEvent,
    render: RenderEvent,
    drop: DropEvent,
    clipboard: ClipboardEvent,
    padding: [128]u8,
};
pub const EventAction = enum(c_int) {
    add,
    peek,
    get,
};
pub const EventFilter = *const fn (userdata: ?*anyopaque, event: *Event) callconv(.c) bool;
pub const EventFilterInfo = struct {
    filter: EventFilter,
    userdata: ?*anyopaque,
};

extern fn SDL_PumpEvents() callconv(.c) void;
extern fn SDL_PeepEvents(events: ?[*]Event, numevents: c_int, action: EventAction, min_type: u32, max_type: u32) callconv(.c) c_int;
extern fn SDL_HasEvent(type: u32) callconv(.c) bool;
extern fn SDL_HasEvents(min_type: u32, max_type: u32) callconv(.c) bool;
extern fn SDL_FlushEvent(type: u32) callconv(.c) void;
extern fn SDL_FlushEvents(min_type: u32, max_type: u32) callconv(.c) void;
extern fn SDL_PollEvent(event: ?*Event) callconv(.c) bool;
extern fn SDL_WaitEvent(event: ?*Event) callconv(.c) bool;
extern fn SDL_WaitEventTimeout(event: ?*Event, timeout_ms: i32) callconv(.c) bool;
extern fn SDL_PushEvent(event: *Event) callconv(.c) bool;
extern fn SDL_SetEventFilter(filter: ?EventFilter, userdata: ?*anyopaque) callconv(.c) void;
extern fn SDL_GetEventFilter(filter: *?EventFilter, userdata: *?*anyopaque) callconv(.c) bool;
extern fn SDL_AddEventWatch(filter: EventFilter, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_RemoveEventWatch(filter: EventFilter, userdata: ?*anyopaque) callconv(.c) void;
extern fn SDL_FilterEvents(filter: EventFilter, userdata: ?*anyopaque) callconv(.c) void;
extern fn SDL_SetEventEnabled(type: u32, enabled: bool) callconv(.c) void;
extern fn SDL_EventEnabled(type: u32) callconv(.c) bool;
extern fn SDL_RegisterEvents(numevents: c_int) callconv(.c) u32;
extern fn SDL_GetWindowFromEvent(event: *const Event) callconv(.c) ?video.Window;
extern fn SDL_GetEventDescription(event: ?*const Event, buf: ?[*]u8, buflen: c_int) callconv(.c) c_int;

pub const pumpEvents = SDL_PumpEvents;
pub inline fn eventTypeToInt(event_type: EventType) u32 {
    return @intCast(@intFromEnum(event_type));
}
pub inline fn peepEvents(events: []Event, action: EventAction, min_type: u32, max_type: u32) !usize {
    const count = SDL_PeepEvents(events.ptr, @intCast(events.len), action, min_type, max_type);
    if (count < 0) return error.SDLError;
    return @intCast(count);
}
pub inline fn countEvents(action: EventAction, min_type: u32, max_type: u32) !usize {
    const count = SDL_PeepEvents(null, 0, action, min_type, max_type);
    if (count < 0) return error.SDLError;
    return @intCast(count);
}
pub const hasEvent = SDL_HasEvent;
pub const hasEvents = SDL_HasEvents;
pub const flushEvent = SDL_FlushEvent;
pub const flushEvents = SDL_FlushEvents;
pub inline fn pollEvent() ?Event {
    var event: Event = undefined;
    return if (SDL_PollEvent(&event)) event else null;
}
pub inline fn pollEventAvailable() bool {
    return SDL_PollEvent(null);
}
pub inline fn waitEvent() !Event {
    var event: Event = undefined;
    if (!SDL_WaitEvent(&event)) return error.SDLError;
    return event;
}
pub inline fn waitEventTimeout(timeout_ms: i32) ?Event {
    var event: Event = undefined;
    return if (SDL_WaitEventTimeout(&event, timeout_ms)) event else null;
}
pub inline fn pushEvent(event: *Event) !void {
    if (!SDL_PushEvent(event)) return error.SDLError;
}
pub const setEventFilter = SDL_SetEventFilter;
pub inline fn getEventFilter() ?EventFilterInfo {
    var filter: ?EventFilter = null;
    var userdata: ?*anyopaque = null;
    return if (SDL_GetEventFilter(&filter, &userdata)) .{ .filter = filter.?, .userdata = userdata } else null;
}
pub inline fn addEventWatch(filter: EventFilter, userdata: ?*anyopaque) !void {
    if (!SDL_AddEventWatch(filter, userdata)) return error.SDLError;
}
pub const removeEventWatch = SDL_RemoveEventWatch;
pub const filterEvents = SDL_FilterEvents;
pub const setEventEnabled = SDL_SetEventEnabled;
pub const eventEnabled = SDL_EventEnabled;
pub inline fn registerEvents(numevents: c_int) !u32 {
    const first_type = SDL_RegisterEvents(numevents);
    if (first_type == 0) return error.SDLError;
    return first_type;
}
pub const getWindowFromEvent = SDL_GetWindowFromEvent;
pub inline fn getEventDescription(event: ?*const Event, buffer: []u8) usize {
    return @intCast(SDL_GetEventDescription(event, buffer.ptr, @intCast(buffer.len)));
}
pub inline fn countEventDescription(event: ?*const Event) usize {
    return @intCast(SDL_GetEventDescription(event, null, 0));
}
