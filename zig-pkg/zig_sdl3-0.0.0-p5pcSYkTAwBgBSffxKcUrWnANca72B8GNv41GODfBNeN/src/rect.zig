pub const Point = extern struct {
    x: c_int,
    y: c_int,
};
pub const FPoint = extern struct {
    x: f32,
    y: f32,
};
pub const Rect = extern struct {
    x: c_int,
    y: c_int,
    w: c_int,
    h: c_int,
};
pub const FRect = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};
pub const Line = struct {
    x1: c_int,
    y1: c_int,
    x2: c_int,
    y2: c_int,
};
pub const FLine = struct {
    x1: f32,
    y1: f32,
    x2: f32,
    y2: f32,
};

extern fn SDL_HasRectIntersection(a: *const Rect, b: *const Rect) callconv(.c) bool;
extern fn SDL_GetRectIntersection(a: *const Rect, b: *const Rect, result: *Rect) callconv(.c) bool;
extern fn SDL_GetRectUnion(a: *const Rect, b: *const Rect, result: *Rect) callconv(.c) bool;
extern fn SDL_GetRectEnclosingPoints(points: [*]const Point, count: c_int, clip: ?*const Rect, result: *Rect) callconv(.c) bool;
extern fn SDL_GetRectAndLineIntersection(rect: *const Rect, x1: *c_int, y1: *c_int, x2: *c_int, y2: *c_int) callconv(.c) bool;
extern fn SDL_HasRectIntersectionFloat(a: *const FRect, b: *const FRect) callconv(.c) bool;
extern fn SDL_GetRectIntersectionFloat(a: *const FRect, b: *const FRect, result: *FRect) callconv(.c) bool;
extern fn SDL_GetRectUnionFloat(a: *const FRect, b: *const FRect, result: *FRect) callconv(.c) bool;
extern fn SDL_GetRectEnclosingPointsFloat(points: [*]const FPoint, count: c_int, clip: ?*const FRect, result: *FRect) callconv(.c) bool;
extern fn SDL_GetRectAndLineIntersectionFloat(rect: *const FRect, x1: *f32, y1: *f32, x2: *f32, y2: *f32) callconv(.c) bool;

pub inline fn rectToFRect(rect: Rect) FRect {
    return .{
        .x = @floatFromInt(rect.x),
        .y = @floatFromInt(rect.y),
        .w = @floatFromInt(rect.w),
        .h = @floatFromInt(rect.h),
    };
}
pub inline fn pointInRect(point: Point, rect: Rect) bool {
    return point.x >= rect.x and point.x < rect.x + rect.w and point.y >= rect.y and point.y < rect.y + rect.h;
}
pub inline fn rectEmpty(rect: Rect) bool {
    return rect.w <= 0 or rect.h <= 0;
}
pub inline fn rectsEqual(a: Rect, b: Rect) bool {
    return a.x == b.x and a.y == b.y and a.w == b.w and a.h == b.h;
}
pub const hasRectIntersection = SDL_HasRectIntersection;
pub inline fn getRectIntersection(a: Rect, b: Rect) ?Rect {
    var result: Rect = undefined;
    if (!SDL_GetRectIntersection(&a, &b, &result)) return null;
    return result;
}
pub inline fn getRectUnion(a: Rect, b: Rect) !Rect {
    var result: Rect = undefined;
    if (!SDL_GetRectUnion(&a, &b, &result)) return error.SDLError;
    return result;
}
pub inline fn getRectEnclosingPoints(points: []const Point, clip: ?*const Rect) ?Rect {
    var result: Rect = undefined;
    if (!SDL_GetRectEnclosingPoints(points.ptr, @intCast(points.len), clip, &result)) return null;
    return result;
}
pub inline fn getRectAndLineIntersection(rect: Rect, line: Line) ?Line {
    var x1 = line.x1;
    var y1 = line.y1;
    var x2 = line.x2;
    var y2 = line.y2;
    if (!SDL_GetRectAndLineIntersection(&rect, &x1, &y1, &x2, &y2)) return null;
    return .{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2 };
}
pub inline fn pointInRectFloat(point: FPoint, rect: FRect) bool {
    return point.x >= rect.x and point.x <= rect.x + rect.w and point.y >= rect.y and point.y <= rect.y + rect.h;
}
pub inline fn rectEmptyFloat(rect: FRect) bool {
    return rect.w < 0.0 or rect.h < 0.0;
}
pub inline fn rectsEqualEpsilon(a: FRect, b: FRect, epsilon: f32) bool {
    return @abs(a.x - b.x) <= epsilon and @abs(a.y - b.y) <= epsilon and @abs(a.w - b.w) <= epsilon and @abs(a.h - b.h) <= epsilon;
}
pub inline fn rectsEqualFloat(a: FRect, b: FRect) bool {
    return rectsEqualEpsilon(a, b, @import("std").math.floatEps(f32));
}
pub const hasRectIntersectionFloat = SDL_HasRectIntersectionFloat;
pub inline fn getRectIntersectionFloat(a: FRect, b: FRect) ?FRect {
    var result: FRect = undefined;
    if (!SDL_GetRectIntersectionFloat(&a, &b, &result)) return null;
    return result;
}
pub inline fn getRectUnionFloat(a: FRect, b: FRect) !FRect {
    var result: FRect = undefined;
    if (!SDL_GetRectUnionFloat(&a, &b, &result)) return error.SDLError;
    return result;
}
pub inline fn getRectEnclosingPointsFloat(points: []const FPoint, clip: ?*const FRect) ?FRect {
    var result: FRect = undefined;
    if (!SDL_GetRectEnclosingPointsFloat(points.ptr, @intCast(points.len), clip, &result)) return null;
    return result;
}
pub inline fn getRectAndLineIntersectionFloat(rect: FRect, line: FLine) ?FLine {
    var x1 = line.x1;
    var y1 = line.y1;
    var x2 = line.x2;
    var y2 = line.y2;
    if (!SDL_GetRectAndLineIntersectionFloat(&rect, &x1, &y1, &x2, &y2)) return null;
    return .{ .x1 = x1, .y1 = y1, .x2 = x2, .y2 = y2 };
}

test "rect ABI sizes" {
    const std = @import("std");
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(Point));
    try std.testing.expectEqual(@as(usize, 8), @sizeOf(FPoint));
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(Rect));
    try std.testing.expectEqual(@as(usize, 16), @sizeOf(FRect));
}

test "rect inline helpers" {
    const std = @import("std");
    const rect: Rect = .{ .x = 1, .y = 2, .w = 3, .h = 4 };
    try std.testing.expect(pointInRect(.{ .x = 1, .y = 2 }, rect));
    try std.testing.expect(!pointInRect(.{ .x = 4, .y = 2 }, rect));
    try std.testing.expect(!rectEmpty(rect));
    try std.testing.expect(rectEmpty(.{ .x = 0, .y = 0, .w = 0, .h = 1 }));
    try std.testing.expect(rectsEqual(rect, .{ .x = 1, .y = 2, .w = 3, .h = 4 }));
    try std.testing.expect(rectsEqualFloat(rectToFRect(rect), .{ .x = 1, .y = 2, .w = 3, .h = 4 }));
}
