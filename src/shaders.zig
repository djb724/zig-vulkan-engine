const std = @import("std");

const vk = @import("vk.zig");
const Device = vk.DeviceProxy;

const max_shader_size = 1024 * 1024;

pub fn loadShader(
    io: std.Io,
    device: Device,
    shader_name: []const u8,
) !vk.ShaderModule {
    var arena: std.heap.ArenaAllocator = .init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const exe_dir = try std.process.executableDirPathAlloc(io, allocator); // ./zig-out/bin/
    const zout_dir = std.fs.path.dirname(exe_dir) orelse return error.InvalidExecutablePath; // ./zig-out/
    const project_dir = std.fs.path.dirname(zout_dir) orelse return error.InvalidExecutablePath;

    const shader_path = try std.fs.path.join(allocator, &[_][]const u8{
        project_dir,
        "spv",
        shader_name,
    });

    const raw_contents = try std.Io.Dir.cwd().readFileAlloc(
        io,
        shader_path,
        allocator,
        .limited(max_shader_size),
    );
    if (raw_contents.len % @sizeOf(u32) != 0) return error.InvalidShaderCode;

    const shader_bytes = try allocator.alignedAlloc(
        u8,
        .of(u32),
        raw_contents.len,
    );
    @memcpy(shader_bytes, raw_contents);

    const shader_code = std.mem.bytesAsSlice(u32, shader_bytes);

    const shader_module = try device.createShaderModule(&vk.ShaderModuleCreateInfo{
        .code_size = shader_bytes.len,
        .p_code = shader_code.ptr,
    }, null);
    errdefer device.destroyShaderModule(shader_module, null);

    return shader_module;
}
