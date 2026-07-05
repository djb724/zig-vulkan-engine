//! # CategoryPixels
//!
//! SDL offers facilities for pixel management.
//!
//! Largely these facilities deal with pixel _format_: what does this set of
//! bits represent?
//!
//! If you mostly want to think of a pixel as some combination of red, green,
//! blue, and maybe alpha intensities, this is all pretty straightforward, and
//! in many cases, is enough information to build a perfectly fine game.
//!
//! However, the actual definition of a pixel is more complex than that:
//!
//! Pixels are a representation of a color in a particular color space.
//!
//! The first characteristic of a color space is the color type. SDL
//! understands two different color types, RGB and YCbCr, or in SDL also
//! referred to as YUV.
//!
//! RGB colors consist of red, green, and blue channels of color that are added
//! together to represent the colors we see on the screen.
//!
//! https://en.wikipedia.org/wiki/RGB_color_model
//!
//! YCbCr colors represent colors as a Y luma brightness component and red and
//! blue chroma color offsets. This color representation takes advantage of the
//! fact that the human eye is more sensitive to brightness than the color in
//! an image. The Cb and Cr components are often compressed and have lower
//! resolution than the luma component.
//!
//! https://en.wikipedia.org/wiki/YCbCr
//!
//! When the color information in YCbCr is compressed, the Y pixels are left at
//! full resolution and each Cr and Cb pixel represents an average of the color
//! information in a block of Y pixels. The chroma location determines where in
//! that block of pixels the color information is coming from.
//!
//! The color range defines how much of the pixel to use when converting a
//! pixel into a color on the display. When the full color range is used, the
//! entire numeric range of the pixel bits is significant. When narrow color
//! range is used, for historical reasons, the pixel uses only a portion of the
//! numeric range to represent colors.
//!
//! The color primaries and white point are a definition of the colors in the
//! color space relative to the standard XYZ color space.
//!
//! https://en.wikipedia.org/wiki/CIE_1931_color_space
//!
//! The transfer characteristic, or opto-electrical transfer function (OETF),
//! is the way a color is converted from mathematically linear space into a
//! non-linear output signals.
//!
//! https://en.wikipedia.org/wiki/Rec._709#Transfer_characteristics
//!
//! The matrix coefficients are used to convert between YCbCr and RGB colors.

const builtin = @import("builtin");

const SDLError = @import("error.zig").SDLError;

pub const PixelFormatFourCC = packed struct(u32) {
    a: u8,
    b: u8,
    c: u8,
    d: u8,
    pub const yv12: PixelFormatFourCC = @bitCast(@as(u32, 0x32315659));
    pub const iyuv: PixelFormatFourCC = @bitCast(@as(u32, 0x56555949));
    pub const yuy2: PixelFormatFourCC = @bitCast(@as(u32, 0x32595559));
    pub const uyvy: PixelFormatFourCC = @bitCast(@as(u32, 0x59565955));
    pub const yvyu: PixelFormatFourCC = @bitCast(@as(u32, 0x55595659));
    pub const nv12: PixelFormatFourCC = @bitCast(@as(u32, 0x3231564e));
    pub const nv21: PixelFormatFourCC = @bitCast(@as(u32, 0x3132564e));
    pub const p010: PixelFormatFourCC = @bitCast(@as(u32, 0x30313050));
    pub const external_oes: PixelFormatFourCC = @bitCast(@as(u32, 0x2053454f));
    pub const mjpg: PixelFormatFourCC = @bitCast(@as(u32, 0x47504a4d));
};

pub const PixelFormatNonFourCC = packed struct(u32) {
    pub const PixelType = enum(u4) {
        unknown,
        index1,
        index4,
        index8,
        packed8,
        packed16,
        packed32,
        array_u8,
        array_u16,
        array_u32,
        array_f16,
        array_f32,
        // at the end for compatibility with sdl2-compat
        index2,
    };
    pub const BitmapOrder = enum(u4) {
        none,
        @"4321",
        @"1234",
    };
    pub const PackedOrder = enum(u4) {
        none,
        xrgb,
        rgbx,
        argb,
        rgba,
        xbgr,
        bgrx,
        abgr,
        bgra,
    };
    pub const ArrayOrder = enum(u4) {
        none,
        rgb,
        rgba,
        argb,
        bgr,
        bgra,
        abgr,
    };
    pub const PackedLayout = enum(u4) {
        none,
        @"332",
        @"4444",
        @"1555",
        @"5551",
        @"565",
        @"8888",
        @"2101010",
        @"1010102",
    };
    pub const PixelFlag = enum(u4) {
        non_four_cc = 1,
        _,
    };

    bytes: u8,
    bits: u8,
    layout: PackedLayout,
    order: packed union {
        bitmap_order: BitmapOrder,
        packed_order: PackedOrder,
        array_order: ArrayOrder,
    },
    @"type": PixelType,
    // specifies that this is non-FourCC
    flag: PixelFlag = .non_four_cc,

    pub const unknown: PixelFormatNonFourCC = @bitCast(@as(u32, 0));
    pub const index1lsb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x11100100));
    pub const index1msb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x11200100));
    pub const index2lsb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1c100200));
    pub const index2msb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1c200200));
    pub const index4lsb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x12100400));
    pub const index4msb: PixelFormatNonFourCC = @bitCast(@as(u32, 0x12200400));
    pub const index8: PixelFormatNonFourCC = @bitCast(@as(u32, 0x13000801));
    pub const rgb332: PixelFormatNonFourCC = @bitCast(@as(u32, 0x14110801));
    pub const xrgb4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15120c02));
    pub const xbgr4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15520c02));
    pub const xrgb1555: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15130f02));
    pub const xbgr1555: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15530f02));
    pub const argb4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15321002));
    pub const rgba4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15421002));
    pub const abgr4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15721002));
    pub const bgra4444: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15821002));
    pub const argb1555: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15331002));
    pub const rgba5551: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15441002));
    pub const abgr1555: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15731002));
    pub const bgra5551: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15841002));
    pub const rgb565: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15151002));
    pub const bgr565: PixelFormatNonFourCC = @bitCast(@as(u32, 0x15551002));
    pub const rgb24: PixelFormatNonFourCC = @bitCast(@as(u32, 0x17101803));
    pub const bgr24: PixelFormatNonFourCC = @bitCast(@as(u32, 0x17401803));
    pub const xrgb8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16161804));
    pub const rgbx8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16261804));
    pub const xbgr8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16561804));
    pub const bgrx8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16661804));
    pub const argb8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16362004));
    pub const rgba8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16462004));
    pub const abgr8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16762004));
    pub const bgra8888: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16862004));
    pub const xrgb2101010: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16172004));
    pub const xbgr2101010: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16572004));
    pub const argb2101010: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16372004));
    pub const abgr2101010: PixelFormatNonFourCC = @bitCast(@as(u32, 0x16772004));
    pub const rgb48: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18103006));
    pub const bgr48: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18403006));
    pub const rgba64: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18204008));
    pub const argb64: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18304008));
    pub const bgra64: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18504008));
    pub const abgr64: PixelFormatNonFourCC = @bitCast(@as(u32, 0x18604008));
    pub const rgb48_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a103006));
    pub const bgr48_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a403006));
    pub const rgba64_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a204008));
    pub const argb64_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a304008));
    pub const bgra64_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a504008));
    pub const abgr64_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1a604008));
    pub const rgb96_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b10600c));
    pub const bgr96_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b40600c));
    pub const rgba128_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b208010));
    pub const argb128_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b308010));
    pub const bgra128_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b508010));
    pub const abgr128_float: PixelFormatNonFourCC = @bitCast(@as(u32, 0x1b608010));

    pub const rgba32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) rgba8888 else abgr8888;
    pub const argb32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) argb8888 else bgra8888;
    pub const bgra32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) bgra8888 else argb8888;
    pub const abgr32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) abgr8888 else rgba8888;
    pub const rgbx32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) rgbx8888 else xbgr8888;
    pub const xrgb32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) xrgb8888 else bgrx8888;
    pub const bgrx32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) bgrx8888 else xrgb8888;
    pub const xbgr32: PixelFormatNonFourCC = if (builtin.target.cpu.arch.endian() == .big) xbgr8888 else rgbx8888;

    pub inline fn isIndexed(self: PixelFormat) bool {
        return self.@"type" == .index1 or self.@"type" == .index2 or self.@"type" == .index4 or self.@"type" == .index8;
    }
    pub inline fn isPacked(self: PixelFormat) bool {
        return self.@"type" == .packed8 or self.@"type" == .packed16 or self.@"type" == .packed32;
    }
    pub inline fn isArray(self: PixelFormat) bool {
        return self.@"type" == .array_u8 or self.@"type" == .array_u16 or self.@"type" == .array_u32 or
            self.@"type" == .array_f16 or self.@"type" == .array_f32;
    }
    pub inline fn is10Bit(self: PixelFormat) bool {
        return self.@"type" == .packed32 and self.layout == .@"2101010";
    }
    pub inline fn isFloat(self: PixelFormat) bool {
        return self.@"type" == .array_f16 or self.@"type" == .array_f32;
    }
    pub inline fn isAlpha(self: PixelFormatNonFourCC) bool {
        if (self.isPacked()) {
            return self.order.packed_order == PackedOrder.argb or self.order.packed_order == PackedOrder.rgba or
                self.order.packed_order == PackedOrder.abgr or self.order.packed_order == PackedOrder.bgra;
        } else if (self.isArray()) {
            return self.order.array_order == ArrayOrder.argb or self.order.array_order == ArrayOrder.rgba or 
                self.order.array_order == ArrayOrder.abgr or self.order.array_order == ArrayOrder.bgra;
        }
        return false;
    }
};

/// Pixel format.
///
/// SDL's pixel formats have the following naming convention:
///
/// - Names with a list of components and a single bit count, such as RGB24 and
///   ABGR32, define a platform-independent encoding into bytes in the order
///   specified. For example, in RGB24 data, each pixel is encoded in 3 bytes
///   (red, green, blue) in that order, and in ABGR32 data, each pixel is
///   encoded in 4 bytes (alpha, blue, green, red) in that order. Use these
///   names if the property of a format that is important to you is the order
///   of the bytes in memory or on disk.
/// - Names with a bit count per component, such as ARGB8888 and XRGB1555, are
///   "packed" into an appropriately-sized integer in the platform's native
///   endianness. For example, ARGB8888 is a sequence of 32-bit integers; in
///   each integer, the most significant bits are alpha, and the least
///   significant bits are blue. On a little-endian CPU such as x86, the least
///   significant bits of each integer are arranged first in memory, but on a
///   big-endian CPU such as s390x, the most significant bits are arranged
///   first. Use these names if the property of a format that is important to
///   you is the meaning of each bit position within a native-endianness
///   integer.
/// - In indexed formats such as INDEX4LSB, each pixel is represented by
///   encoding an index into the palette into the indicated number of bits,
///   with multiple pixels packed into each byte if appropriate. In LSB
///   formats, the first (leftmost) pixel is stored in the least-significant
///   bits of the byte; in MSB formats, it's stored in the most-significant
///   bits. INDEX8 does not need LSB/MSB variants, because each pixel exactly
///   fills one byte.
///
/// The 32-bit byte-array encodings such as RGBA32 are aliases for the
/// appropriate 8888 encoding for the current platform. For example, RGBA32 is
/// an alias for ABGR8888 on little-endian CPUs like x86, or an alias for
/// RGBA8888 on big-endian CPUs.
pub const PixelFormat = packed union {
    pub const FourCC = PixelFormatFourCC;
    pub const NonFourCC = PixelFormatNonFourCC;

    four_cc: FourCC,
    non_four_cc: NonFourCC,

    pub fn toInt(self: PixelFormat) u32 {
        return @bitCast(self);
    }
    pub inline fn isFourCC(self: PixelFormat) bool {
        const format: u32 = @bitCast(self);
        return (format & 0xF0000000) != 0x10000000;
    }
    pub inline fn bytesPerPixel(self: PixelFormat) u32 {
        if (self.isFourCC()) {
            const four_cc: FourCC = @bitCast(self);
            if ((four_cc == FourCC.yuy2) or
                (four_cc == FourCC.uyvy) or
                (four_cc == FourCC.yvyu) or
                (four_cc == FourCC.p010)) {
                return 2;
            } else {
                return 1;
            }
        } else {
            const non_four_cc: NonFourCC = @bitCast(self);
            return non_four_cc.bytes;
        }
    }
    pub inline fn isIndexed(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.isIndexed(@bitCast(self));
    }
    pub inline fn isPacked(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.isPacked(@bitCast(self));
    }
    pub inline fn isArray(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.isArray(@bitCast(self));
    }
    pub inline fn is10Bit(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.is10Bit(@bitCast(self));
    }
    pub inline fn isFloat(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.isFloat(@bitCast(self));
    }
    pub inline fn isAlpha(self: PixelFormat) bool {
        if (self.isFourCC()) return false;
        return NonFourCC.isAlpha(@bitCast(self));
    }

    pub const unknown: PixelFormat = @bitCast(@as(u32, 0));

    pub const yv12: PixelFormat = .{ .four_cc = FourCC.yv12 };
    pub const iyuv: PixelFormat = .{ .four_cc = FourCC.iyuv };
    pub const yuy2: PixelFormat = .{ .four_cc = FourCC.yuy2 };
    pub const uyvy: PixelFormat = .{ .four_cc = FourCC.uyvy };
    pub const yvyu: PixelFormat = .{ .four_cc = FourCC.yvyu };
    pub const nv12: PixelFormat = .{ .four_cc = FourCC.nv12 };
    pub const nv21: PixelFormat = .{ .four_cc = FourCC.nv21 };
    pub const p010: PixelFormat = .{ .four_cc = FourCC.p010 };
    pub const external_oes: PixelFormat = .{ .four_cc = FourCC.external_oes };
    pub const mjpg: PixelFormat = .{ .four_cc = FourCC.mjpg };

    pub const index1lsb: PixelFormat = .{ .non_four_cc = NonFourCC.index1lsb };
    pub const index1msb: PixelFormat = .{ .non_four_cc = NonFourCC.index1msb };
    pub const index2lsb: PixelFormat = .{ .non_four_cc = NonFourCC.index2lsb };
    pub const index2msb: PixelFormat = .{ .non_four_cc = NonFourCC.index2msb };
    pub const index4lsb: PixelFormat = .{ .non_four_cc = NonFourCC.index4lsb };
    pub const index4msb: PixelFormat = .{ .non_four_cc = NonFourCC.index4msb };
    pub const index8: PixelFormat = .{ .non_four_cc = NonFourCC.index8 };
    pub const rgb332: PixelFormat = .{ .non_four_cc = NonFourCC.rgb332 };
    pub const xrgb4444: PixelFormat = .{ .non_four_cc = NonFourCC.xrgb4444 };
    pub const xbgr4444: PixelFormat = .{ .non_four_cc = NonFourCC.xbgr4444 };
    pub const xrgb1555: PixelFormat = .{ .non_four_cc = NonFourCC.xrgb1555 };
    pub const xbgr1555: PixelFormat = .{ .non_four_cc = NonFourCC.xbgr1555 };
    pub const argb4444: PixelFormat = .{ .non_four_cc = NonFourCC.argb4444 };
    pub const rgba4444: PixelFormat = .{ .non_four_cc = NonFourCC.rgba4444 };
    pub const abgr4444: PixelFormat = .{ .non_four_cc = NonFourCC.abgr4444 };
    pub const bgra4444: PixelFormat = .{ .non_four_cc = NonFourCC.bgra4444 };
    pub const argb1555: PixelFormat = .{ .non_four_cc = NonFourCC.argb1555 };
    pub const rgba5551: PixelFormat = .{ .non_four_cc = NonFourCC.rgba5551 };
    pub const abgr1555: PixelFormat = .{ .non_four_cc = NonFourCC.abgr1555 };
    pub const bgra5551: PixelFormat = .{ .non_four_cc = NonFourCC.bgra5551 };
    pub const rgb565: PixelFormat = .{ .non_four_cc = NonFourCC.rgb565 };
    pub const bgr565: PixelFormat = .{ .non_four_cc = NonFourCC.bgr565 };
    pub const rgb24: PixelFormat = .{ .non_four_cc = NonFourCC.rgb24 };
    pub const bgr24: PixelFormat = .{ .non_four_cc = NonFourCC.bgr24 };
    pub const xrgb8888: PixelFormat = .{ .non_four_cc = NonFourCC.xrgb8888 };
    pub const rgbx8888: PixelFormat = .{ .non_four_cc = NonFourCC.rgbx8888 };
    pub const xbgr8888: PixelFormat = .{ .non_four_cc = NonFourCC.xbgr8888 };
    pub const bgrx8888: PixelFormat = .{ .non_four_cc = NonFourCC.bgrx8888 };
    pub const argb8888: PixelFormat = .{ .non_four_cc = NonFourCC.argb8888 };
    pub const rgba8888: PixelFormat = .{ .non_four_cc = NonFourCC.rgba8888 };
    pub const abgr8888: PixelFormat = .{ .non_four_cc = NonFourCC.abgr8888 };
    pub const bgra8888: PixelFormat = .{ .non_four_cc = NonFourCC.bgra8888 };
    pub const xrgb2101010: PixelFormat = .{ .non_four_cc = NonFourCC.xrgb2101010 };
    pub const xbgr2101010: PixelFormat = .{ .non_four_cc = NonFourCC.xbgr2101010 };
    pub const argb2101010: PixelFormat = .{ .non_four_cc = NonFourCC.argb2101010 };
    pub const abgr2101010: PixelFormat = .{ .non_four_cc = NonFourCC.abgr2101010 };
    pub const rgb48: PixelFormat = .{ .non_four_cc = NonFourCC.rgb48 };
    pub const bgr48: PixelFormat = .{ .non_four_cc = NonFourCC.bgr48 };
    pub const rgba64: PixelFormat = .{ .non_four_cc = NonFourCC.rgba64 };
    pub const argb64: PixelFormat = .{ .non_four_cc = NonFourCC.argb64 };
    pub const bgra64: PixelFormat = .{ .non_four_cc = NonFourCC.bgra64 };
    pub const abgr64: PixelFormat = .{ .non_four_cc = NonFourCC.abgr64 };
    pub const rgb48_float: PixelFormat = .{ .non_four_cc = NonFourCC.rgb48_float };
    pub const bgr48_float: PixelFormat = .{ .non_four_cc = NonFourCC.bgr48_float };
    pub const rgba64_float: PixelFormat = .{ .non_four_cc = NonFourCC.rgba64_float };
    pub const argb64_float: PixelFormat = .{ .non_four_cc = NonFourCC.argb64_float };
    pub const bgra64_float: PixelFormat = .{ .non_four_cc = NonFourCC.bgra64_float };
    pub const abgr64_float: PixelFormat = .{ .non_four_cc = NonFourCC.abgr64_float };
    pub const rgb96_float: PixelFormat = .{ .non_four_cc = NonFourCC.rgb96_float };
    pub const bgr96_float: PixelFormat = .{ .non_four_cc = NonFourCC.bgr96_float };
    pub const rgba128_float: PixelFormat = .{ .non_four_cc = NonFourCC.rgba128_float };
    pub const argb128_float: PixelFormat = .{ .non_four_cc = NonFourCC.argb128_float };
    pub const bgra128_float: PixelFormat = .{ .non_four_cc = NonFourCC.bgra128_float };
    pub const abgr128_float: PixelFormat = .{ .non_four_cc = NonFourCC.abgr128_float };
};


pub const ColorType = enum(u4) {
    unknown,
    rgb,
    ycbcr,
};
pub const ColorRange = enum(u4) {
    unknown,
    limited,
    full,
};
pub const ColorPrimaries = enum(u5) {
    unknown = 0,
    bt709 = 1,
    unspecified = 2,
    bt470m = 4,
    bt470bg = 5,
    bt601 = 6,
    smpte240 = 7,
    generic_film = 8,
    bt2020 = 9,
    xyz = 10,
    smpte431 = 11,
    smpte432 = 12,
    ebu3213 = 22,
    custom = 31
};
pub const TransferCharacteristics = enum(u5) {
    unknown = 0,
    bt709 = 1,
    unspecified = 2,
    gamma22 = 4,
    gamma28 = 5,
    bt601 = 6,
    smpte240 = 7,
    linear = 8,
    log100 = 9,
    log100_sqrt10 = 10,
    iec61966 = 11,
    bt1361 = 12,
    srgb = 13,
    bt2020_10bit = 14,
    bt2020_12bit = 15,
    pq = 16,
    smpte428 = 17,
    hlg = 18,
    custom = 31
};
pub const MatrixCoefficients = enum(u5) {
    identity = 0,
    bt709 = 1,
    unspecified = 2,
    fcc = 4,
    bt470bg = 5,
    bt601 = 6,
    smpte240 = 7,
    ycgco = 8,
    bt2020_ncl = 9,
    bt2020_cl = 10,
    smpte2085 = 11,
    chroma_derived_ncl = 12,
    chroma_derived_cl = 13,
    ictcp = 14,
    custom = 31
};
pub const ChromaLocation = enum(u4) {
    none,
    left,
    center,
    top_left,
};
/// packed struct representing the Colorspace enum contents
pub const Colorspace = packed struct(u32) {
    matrix: MatrixCoefficients,
    transfer: TransferCharacteristics,
    primaries: ColorPrimaries,
    _reserved: u5 = 0,
    chroma: ChromaLocation,
    range: ColorRange,
    @"type": ColorType,

    pub const unknown: Colorspace = @bitCast(@as(u32, 0));
    pub const srgb: Colorspace = .{
        .@"type" = .rgb,
        .range = .full,
        .primaries = .bt709,
        .transfer = .srgb,
        .matrix = .identity,
        .chroma = .none,
    };
    pub const srgb_linear: Colorspace = .{
        .@"type" = .rgb,
        .range = .full,
        .primaries = .bt709,
        .transfer = .linear,
        .matrix = .identity,
        .chroma = .none,
    };
    pub const hdr10: Colorspace = .{
        .@"type" = .rgb,
        .range = .full,
        .primaries = .bt2020,
        .transfer = .pq,
        .matrix = .identity,
        .chroma = .none,
    };
    pub const jpeg: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .full,
        .primaries = .bt709,
        .transfer = .bt601,
        .matrix = .bt601,
        .chroma = .none
    };
    pub const bt601_limited: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .limited,
        .primaries = .bt601,
        .transfer = .bt601,
        .matrix = .bt601,
        .chroma = .left,
    };
    pub const bt601_full: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .full,
        .primaries = .bt601,
        .transfer = .bt601,
        .matrix = .bt601,
        .chroma = .left,
    };
    pub const bt709_limited: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .limited,
        .primaries = .bt709,
        .transfer = .bt709,
        .matrix = .bt709,
        .chroma = .left,
    };
    pub const bt709_full: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .full,
        .primaries = .bt709,
        .transfer = .bt709,
        .matrix = .bt709,
        .chroma = .left,
    };
    pub const bt2020_limited: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .limited,
        .primaries = .bt2020,
        .transfer = .pq,
        .matrix = .bt2020_ncl,
        .chroma = .left,
    };
    pub const bt2020_full: Colorspace = .{
        .@"type" = .ycbcr,
        .range = .full,
        .primaries = .bt2020,
        .transfer = .pq,
        .matrix = .bt2020_ncl,
        .chroma = .left,
    };
    pub const rgb_default = Colorspace.srgb;
    pub const yuv_default = Colorspace.bt601_limited;

    pub inline fn isMatrixBt601(self: Colorspace) bool {
        return self.matrix == .bt601 or self.matrix == .bt470bg;
    }
    pub inline fn isMatrixBt709(self: Colorspace) bool {
        return self.matrix == .bt709;
    }
    pub inline fn isMatrixBt2020Ncl(self: Colorspace) bool {
        return self.matrix == .bt2020_ncl;
    }
    pub inline fn isLimitedRange(self: Colorspace) bool {
        return self.range != .full;
    }
    pub inline fn isFullRange(self: Colorspace) bool {
        return self.range == .full;
    }
};

pub const SDL_Color = extern struct {
    r: u8,
    g: u8,
    b: u8,
    a: u8,
};
pub const SDL_FColor = extern struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};
pub const SDL_Palette = extern struct {
    ncolors: c_int,
    colors: [*]SDL_Color,
    version: u32,
    refcount: c_int,
};
pub const SDL_PixelFormatDetails = extern struct {
    format: u32, // PixelFormat
    bits_per_pixel: u8,
    bytes_per_pixel: u8,
    padding: [2]u8,
    r_mask: u32,
    g_mask: u32,
    b_mask: u32,
    a_mask: u32,
    r_bits: u8,
    g_bits: u8,
    b_bits: u8,
    a_bits: u8,
    r_shift: u8,
    g_shift: u8,
    b_shift: u8,
    a_shift: u8,
};

pub const Color = SDL_Color;
pub const FColor = SDL_FColor;
/// a handle to an SDL_Palette struct
pub const Palette = ?*SDL_Palette;
/// a handle to a constant SDL_PixelFormatDetails struct
pub const PixelFormatDetails = *const SDL_PixelFormatDetails;

pub extern fn SDL_GetPixelFormatName(format: PixelFormat) callconv(.c) [*:0]const u8;
pub extern fn SDL_GetMasksForPixelFormat(format: PixelFormat, bpp: ?*c_int, r_mask: ?*u32, g_mask: ?*u32, b_mask: ?*u32, a_mask: ?*u32) callconv(.c) bool;
pub extern fn SDL_GetPixelFormatForMasks(bpp: c_int, r_mask: u32, g_mask: u32, b_mask: u32, a_mask: u32) callconv(.c) PixelFormat; 
pub extern fn SDL_GetPixelFormatDetails(format: PixelFormat) callconv(.c) SDL_PixelFormatDetails;
pub extern fn SDL_CreatePalette(ncolors: c_int) callconv(.c) ?*SDL_Palette;
pub extern fn SDL_SetPaletteColors(palette: ?*SDL_Palette, colors: [*]const SDL_Color, first_color: c_int, ncolors: c_int) callconv(.c) bool;
pub extern fn SDL_DestroyPalette(palette: ?*SDL_Palette) callconv(.c) void;
pub extern fn SDL_MapRGB(format: SDL_PixelFormatDetails, palette: ?*const SDL_Palette, r: u8, g: u8, b: u8) callconv(.c) u32;
pub extern fn SDL_MapRGBA(format: SDL_PixelFormatDetails, palette: ?*const SDL_Palette, r: u8, g: u8, b: u8, a: u8) callconv(.c) u32;
pub extern fn SDL_GetRGB(pixel_value: u32, format: SDL_PixelFormatDetails, palette: ?*const SDL_Palette, r: ?*u8, g: ?*u8, b: ?*u8) callconv(.c) void;
pub extern fn SDL_GetRGBA(pixel_value: u32, format: SDL_PixelFormatDetails, palette: ?*const SDL_Palette, r: ?*u8, g: ?*u8, b: ?*u8, a: ?*u8) callconv(.c) void;

pub const getPixelFormatName = SDL_GetPixelFormatName;
pub fn getMasksForPixelFormat(format: PixelFormat, bpp: ?*c_int, r_mask: ?*u32, g_mask: ?*u32, b_mask: ?*u32, a_mask: ?*u32) !void {
    if (!SDL_GetMasksForPixelFormat(format, bpp, r_mask, g_mask, b_mask, a_mask)) return error.SDLError;
}
pub const getPixelFormatForMasks = SDL_GetPixelFormatForMasks;
pub fn getPixelFormatDetails(format: PixelFormat) !*const PixelFormatDetails {
    return if (SDL_GetPixelFormatDetails(format)) |details| details else error.SDLError;
}
pub fn createPalette(n_colors: c_int) !Palette {
    return if (SDL_CreatePalette(n_colors)) |palette| palette else error.SDLError;
}
pub fn setPaletteColors(palette: Palette, colors: []const Color, first_color: c_int) !void {
    if (!SDL_SetPaletteColors(palette, colors.ptr, first_color, @intCast(colors.len))) return error.SDLError;
}
pub const destroyPalette = SDL_DestroyPalette;
pub const mapRGB = SDL_MapRGB;
pub const mapRGBA = SDL_MapRGBA;
pub const getRGB = SDL_GetRGB;
pub const getRGBA = SDL_GetRGBA;
