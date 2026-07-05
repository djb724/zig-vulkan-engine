const SDLError = @import("error.zig").SDLError;

pub const AppResult = enum(c_int) {
    cont = 0,
    success = 1,
    failure = 2,
};
pub const InitFlags = packed struct(u32) {
    _b0: u4 = 0,
    /// implies .events
    audio: bool = false,
    /// implies .events, should be initialized on the main thread
    video: bool = false,
    _b6: u3 = 0,
    /// implies .events
    joystick: bool = false,
    _b10: u2 = 0,
    haptic: bool = false,
    /// implies .joystick
    gamepad: bool = false,
    events: bool = false,
    /// implies .events
    sensor: bool = false,
    /// implies .events
    camera: bool = false,
    _reserved: u15 = 0,
    pub fn toInt(self: InitFlags) u32 {
        return @bitCast(self);
    }
};

pub const AppInitFunc = *const fn (appstate: ?*?*anyopaque, argc: i32, argv: ?[*][*:0]u8) callconv(.c) AppResult;
pub const AppIterateFunc = *const fn (appstate: ?*anyopaque) callconv(.c) AppResult;
// event parameter will be *Event once the events module is defined
pub const AppEventFunc = *const fn (appstate: ?*anyopaque, event: *anyopaque) callconv(.c) AppResult;
pub const AppQuitFunc = *const fn (appstate: ?*anyopaque, result: AppResult) callconv(.c) void;
pub const MainThreadCallback = *const fn (userdata: ?*anyopaque) callconv(.c) void;

extern fn SDL_Init(flags: InitFlags) bool;
extern fn SDL_InitSubSystem(flags: InitFlags) bool;
extern fn SDL_Quit() void;
extern fn SDL_QuitSubSystem(flags: InitFlags) void;
extern fn SDL_WasInit(flags: InitFlags) InitFlags;
extern fn SDL_IsMainThread() bool;
extern fn SDL_RunOnMainThread(callback: MainThreadCallback, userdata: ?*anyopaque, wait_complete: bool) bool;
extern fn SDL_SetAppMetadata(appname: ?[*:0]const u8, appversion: ?[*:0]const u8, appidentifier: ?[*:0]const u8) bool;
extern fn SDL_SetAppMetadataProperty(name: [*:0]const u8, value: ?[*:0]const u8) bool;
extern fn SDL_GetAppMetadataProperty(name: [*:0]const u8) ?[*:0]const u8;

pub inline fn init(flags: InitFlags) !void {
    if (!SDL_Init(flags)) return error.SDLError;
}
pub inline fn initSubSystem(flags: InitFlags) !void {
    if (!SDL_InitSubSystem(flags)) return error.SDLError;
}
pub const quit = SDL_Quit;
pub const quitSubSystem = SDL_QuitSubSystem;
pub const wasInit = SDL_WasInit;
pub const isMainThread = SDL_IsMainThread;
pub inline fn runOnMainThread(callback: MainThreadCallback, userdata: ?*anyopaque, wait_complete: bool) !void {
    if (!SDL_RunOnMainThread(callback, userdata, wait_complete)) return error.SDLError;
}
pub inline fn setAppMetadata(appname: ?[*:0]const u8, appversion: ?[*:0]const u8, appidentifier: ?[*:0]const u8) !void {
    if (!SDL_SetAppMetadata(appname, appversion, appidentifier)) return error.SDLError;
}
