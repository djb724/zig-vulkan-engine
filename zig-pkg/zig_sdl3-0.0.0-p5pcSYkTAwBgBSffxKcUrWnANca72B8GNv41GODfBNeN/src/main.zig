const std = @import("std");
const sdl = @import("root.zig");

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    sdl.init(.{
        .audio = true,
        .video = true,
    }) catch {
        std.debug.print("Init failed.\n", .{});
        return;
    };
    defer sdl.quit();

    const target: sdl.InitFlags = .{
        .audio = true,
        .video = true,
        .events = true,
    };
    const inited = sdl.wasInit(.{});
    if (target != inited) {
        std.debug.print("Not all fields initialized: {x} != {x}\n", .{inited.toInt(), target.toInt()});
        return;
    }

    const window = try sdl.createWindow("test window", 800, 600, .{
        .always_on_top = true,
        .vulkan = true,
        .input_focus = true,
    });
    defer sdl.destroyWindow(window);

    const windows = try sdl.getWindows(allocator);
    defer allocator.free(windows);

    for (windows) |w| std.debug.print("{}\n", .{w});

    std.debug.print("Success.\n", .{});
}
