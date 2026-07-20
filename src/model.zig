const std = @import("std");
const vk = @import("vk.zig");
const Allocator = std.mem.Allocator;
const Device = vk.DeviceProxy;

const max_model_size = 128 * 1024 * 1024;
const missing_index = std.math.maxInt(u32);

pub fn loadModel(allocator: Allocator, io: std.Io, path: []const u8) !Model {
    const contents = try std.Io.Dir.cwd().readFileAlloc(
        io,
        path,
        allocator,
        .limited(max_model_size),
    );
    defer allocator.free(contents);

    return parseObj(allocator, contents);
}

pub const Vertex = extern struct {
    position: [3]f32,
    normal: [3]f32,
    uv: [2]f32,

    pub const binding_descriptions = [_]vk.VertexInputBindingDescription{
        .{
            .binding = 0,
            .stride = @sizeOf(Vertex),
            .input_rate = .vertex,
        },
    };

    pub const attribute_descriptions = [_]vk.VertexInputAttributeDescription{
        .{
            .binding = 0,
            .location = 0,
            .format = .r32g32b32_sfloat,
            .offset = @offsetOf(Vertex, "position"),
        },
        .{
            .binding = 0,
            .location = 1,
            .format = .r32g32b32_sfloat,
            .offset = @offsetOf(Vertex, "normal"),
        },
        .{
            .binding = 0,
            .location = 2,
            .format = .r32g32_sfloat,
            .offset = @offsetOf(Vertex, "uv"),
        },
    };
};

pub const Model = struct {
    allocator: Allocator,
    vertices: []Vertex,
    indices: []u32,

    pub fn deinit(self: Model) void {
        self.allocator.free(self.indices);
        self.allocator.free(self.vertices);
    }

    pub fn vertexInputState(_: Model) vk.PipelineVertexInputStateCreateInfo {
        return .{
            .vertex_binding_description_count = Vertex.binding_descriptions.len,
            .p_vertex_binding_descriptions = &Vertex.binding_descriptions,
            .vertex_attribute_description_count = Vertex.attribute_descriptions.len,
            .p_vertex_attribute_descriptions = &Vertex.attribute_descriptions,
        };
    }
};

const ObjVertexKey = struct {
    position: u32,
    texcoord: u32 = missing_index,
    normal: u32 = missing_index,
};

fn parseObj(allocator: Allocator, contents: []const u8) !Model {
    var positions: std.ArrayListUnmanaged([3]f32) = .empty;
    defer positions.deinit(allocator);
    var texcoords: std.ArrayListUnmanaged([2]f32) = .empty;
    defer texcoords.deinit(allocator);
    var normals: std.ArrayListUnmanaged([3]f32) = .empty;
    defer normals.deinit(allocator);

    var vertices: std.ArrayListUnmanaged(Vertex) = .empty;
    errdefer vertices.deinit(allocator);
    var indices: std.ArrayListUnmanaged(u32) = .empty;
    errdefer indices.deinit(allocator);
    var vertex_lookup: std.AutoHashMapUnmanaged(ObjVertexKey, u32) = .empty;
    defer vertex_lookup.deinit(allocator);

    var line_iter = std.mem.splitScalar(u8, contents, '\n');
    while (line_iter.next()) |raw_line| {
        const uncommented = if (std.mem.indexOfScalar(u8, raw_line, '#')) |index|
            raw_line[0..index]
        else
            raw_line;
        const line = std.mem.trim(u8, uncommented, " \t\r");
        if (line.len == 0) continue;

        var tokens = std.mem.tokenizeAny(u8, line, " \t");
        const tag = tokens.next() orelse continue;

        if (std.mem.eql(u8, tag, "v")) {
            try positions.append(allocator, .{
                try nextFloat(&tokens),
                try nextFloat(&tokens),
                try nextFloat(&tokens),
            });
        } else if (std.mem.eql(u8, tag, "vt")) {
            try texcoords.append(allocator, .{
                try nextFloat(&tokens),
                try nextFloat(&tokens),
            });
        } else if (std.mem.eql(u8, tag, "vn")) {
            try normals.append(allocator, .{
                try nextFloat(&tokens),
                try nextFloat(&tokens),
                try nextFloat(&tokens),
            });
        } else if (std.mem.eql(u8, tag, "f")) {
            try appendFace(
                allocator,
                &tokens,
                positions.items,
                texcoords.items,
                normals.items,
                &vertices,
                &indices,
                &vertex_lookup,
            );
        }
    }

    if (vertices.items.len == 0 or indices.items.len == 0) return error.EmptyModel;

    const owned_vertices = try vertices.toOwnedSlice(allocator);
    errdefer allocator.free(owned_vertices);
    const owned_indices = try indices.toOwnedSlice(allocator);

    return .{
        .allocator = allocator,
        .vertices = owned_vertices,
        .indices = owned_indices,
    };
}

fn appendFace(
    allocator: Allocator,
    tokens: anytype,
    positions: []const [3]f32,
    texcoords: []const [2]f32,
    normals: []const [3]f32,
    vertices: *std.ArrayListUnmanaged(Vertex),
    indices: *std.ArrayListUnmanaged(u32),
    vertex_lookup: *std.AutoHashMapUnmanaged(ObjVertexKey, u32),
) !void {
    var first: u32 = undefined;
    var previous: u32 = undefined;
    var vertex_count: usize = 0;

    while (tokens.next()) |token| {
        const index = try appendFaceVertex(
            allocator,
            try parseFaceVertex(token, positions.len, texcoords.len, normals.len),
            positions,
            texcoords,
            normals,
            vertices,
            vertex_lookup,
        );

        switch (vertex_count) {
            0 => first = index,
            1 => previous = index,
            else => {
                try indices.append(allocator, first);
                try indices.append(allocator, previous);
                try indices.append(allocator, index);
                previous = index;
            },
        }

        vertex_count += 1;
    }

    if (vertex_count < 3) return error.InvalidObjFace;
}

fn appendFaceVertex(
    allocator: Allocator,
    key: ObjVertexKey,
    positions: []const [3]f32,
    texcoords: []const [2]f32,
    normals: []const [3]f32,
    vertices: *std.ArrayListUnmanaged(Vertex),
    vertex_lookup: *std.AutoHashMapUnmanaged(ObjVertexKey, u32),
) !u32 {
    const entry = try vertex_lookup.getOrPut(allocator, key);
    if (entry.found_existing) return entry.value_ptr.*;

    if (vertices.items.len > std.math.maxInt(u32)) return error.ModelTooLarge;

    const index: u32 = @intCast(vertices.items.len);
    try vertices.append(allocator, .{
        .position = positions[key.position],
        .normal = if (key.normal == missing_index) .{ 0.0, 0.0, 0.0 } else normals[key.normal],
        .uv = if (key.texcoord == missing_index) .{ 0.0, 0.0 } else texcoords[key.texcoord],
    });
    entry.value_ptr.* = index;

    return index;
}

fn parseFaceVertex(token: []const u8, position_count: usize, texcoord_count: usize, normal_count: usize) !ObjVertexKey {
    var parts = std.mem.splitScalar(u8, token, '/');
    const position_part = parts.next() orelse return error.InvalidObjFaceVertex;
    if (position_part.len == 0) return error.InvalidObjFaceVertex;

    var key = ObjVertexKey{
        .position = try resolveObjIndex(position_part, position_count),
    };

    if (parts.next()) |texcoord_part| {
        if (texcoord_part.len != 0) {
            key.texcoord = try resolveObjIndex(texcoord_part, texcoord_count);
        }
    }
    if (parts.next()) |normal_part| {
        if (normal_part.len != 0) {
            key.normal = try resolveObjIndex(normal_part, normal_count);
        }
    }
    if (parts.next() != null) return error.InvalidObjFaceVertex;

    return key;
}

fn resolveObjIndex(text: []const u8, item_count: usize) !u32 {
    const raw_index = try std.fmt.parseInt(i64, text, 10);
    if (raw_index == 0) return error.InvalidObjIndex;

    const resolved = if (raw_index > 0)
        raw_index - 1
    else
        @as(i64, @intCast(item_count)) + raw_index;

    if (resolved < 0 or resolved >= item_count) return error.ObjIndexOutOfRange;
    return @intCast(resolved);
}

fn nextFloat(tokens: anytype) !f32 {
    const token = tokens.next() orelse return error.InvalidObjFloat;
    return std.fmt.parseFloat(f32, token);
}

test "parse obj triangulates faces and deduplicates vertices" {
    const source =
        \\v 0 0 0
        \\v 1 0 0
        \\v 1 1 0
        \\v 0 1 0
        \\vt 0 0
        \\vt 1 0
        \\vt 1 1
        \\vt 0 1
        \\vn 0 0 1
        \\f 1/1/1 2/2/1 3/3/1 4/4/1
        \\
    ;

    const model = try parseObj(std.testing.allocator, source);
    defer model.deinit();

    try std.testing.expectEqual(@as(usize, 4), model.vertices.len);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2, 0, 2, 3 }, model.indices);
}

test "parse obj supports negative indices and missing attributes" {
    const source =
        \\v 0 0 0
        \\v 1 0 0
        \\v 0 1 0
        \\f -3 -2 -1
        \\
    ;

    const model = try parseObj(std.testing.allocator, source);
    defer model.deinit();

    try std.testing.expectEqual(@as(usize, 3), model.vertices.len);
    try std.testing.expectEqualSlices(u32, &.{ 0, 1, 2 }, model.indices);
    try std.testing.expectEqual([3]f32{ 0.0, 0.0, 0.0 }, model.vertices[0].normal);
    try std.testing.expectEqual([2]f32{ 0.0, 0.0 }, model.vertices[0].uv);
}

test "model exposes vulkan vertex input state" {
    const model = Model{
        .allocator = std.testing.allocator,
        .vertices = &.{},
        .indices = &.{},
    };
    const state = model.vertexInputState();

    try std.testing.expectEqual(@as(u32, 1), state.vertex_binding_description_count);
    try std.testing.expectEqual(@as(u32, 3), state.vertex_attribute_description_count);
    try std.testing.expect(state.p_vertex_binding_descriptions != null);
    try std.testing.expect(state.p_vertex_attribute_descriptions != null);
}
