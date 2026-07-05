const builtin = @import("builtin");
const video = @import("video.zig");

const VkInstanceHandle = opaque {};
const VkPhysicalDeviceHandle = opaque {};
const VkSurfaceKhrHandle = opaque {};
pub const VkInstance = *VkInstanceHandle;
pub const VkPhysicalDevice = *VkPhysicalDeviceHandle;
pub const VkSurfaceKhr = if (builtin.target.ptrBitWidth() == 64) *VkSurfaceKhrHandle else u64;
pub const VkAllocationCallbacks = opaque {};
pub const VkGetInstanceProcAddr = *const fn () callconv(.c) void;
pub const InstanceExtensions = []const [*:0]const u8;

extern fn SDL_Vulkan_LoadLibrary(path: ?[*:0]const u8) callconv(.c) bool;
extern fn SDL_Vulkan_GetVkGetInstanceProcAddr() callconv(.c) ?VkGetInstanceProcAddr;
extern fn SDL_Vulkan_UnloadLibrary() callconv(.c) void;
extern fn SDL_Vulkan_GetInstanceExtensions(count: *u32) callconv(.c) ?[*][*:0]const u8;
extern fn SDL_Vulkan_CreateSurface(window: video.Window, instance: VkInstance, allocator: ?*const VkAllocationCallbacks, surface: *VkSurfaceKhr) callconv(.c) bool;
extern fn SDL_Vulkan_DestroySurface(instance: VkInstance, surface: VkSurfaceKhr, allocator: ?*const VkAllocationCallbacks) callconv(.c) void;
extern fn SDL_Vulkan_GetPresentationSupport(instance: VkInstance, physical_device: VkPhysicalDevice, queue_family_index: u32) callconv(.c) bool;

pub fn loadLibrary(path: ?[*:0]const u8) !void {
    if (!SDL_Vulkan_LoadLibrary(path)) return error.SDLError;
}
pub fn getVkGetInstanceProcAddr() !VkGetInstanceProcAddr {
    return SDL_Vulkan_GetVkGetInstanceProcAddr() orelse error.SDLError;
}
pub const unloadLibrary = SDL_Vulkan_UnloadLibrary;
pub fn getInstanceExtensions() !InstanceExtensions {
    var count: u32 = 0;
    const extensions = SDL_Vulkan_GetInstanceExtensions(&count) orelse return error.SDLError;
    return extensions[0..count];
}
pub fn createSurface(window: video.Window, instance: VkInstance, allocator: ?*const VkAllocationCallbacks) !VkSurfaceKhr {
    var surface: VkSurfaceKhr = undefined;
    if (!SDL_Vulkan_CreateSurface(window, instance, allocator, &surface)) return error.SDLError;
    return surface;
}
pub const destroySurface = SDL_Vulkan_DestroySurface;
pub const getPresentationSupport = SDL_Vulkan_GetPresentationSupport;
