pub const BlendMode = enum(u32) {
    none = 0x00000000,
    blend = 0x00000001,
    blend_premultiplied = 0x00000010,
    add = 0x00000002,
    add_premultiplied = 0x00000020,
    mod = 0x00000004,
    mul = 0x00000008,
    invalid = 0x7fffffff,
    _,
};
pub const BlendOperation = enum(c_int) {
    add = 0x1,
    subtract = 0x2,
    rev_subtract = 0x3,
    minimum = 0x4,
    maximum = 0x5,
};
pub const BlendFactor = enum(c_int) {
    zero = 0x1,
    one = 0x2,
    src_color = 0x3,
    one_minus_src_color = 0x4,
    src_alpha = 0x5,
    one_minus_src_alpha = 0x6,
    dst_color = 0x7,
    one_minus_dst_color = 0x8,
    dst_alpha = 0x9,
    one_minus_dst_alpha = 0xa,
};

extern fn SDL_ComposeCustomBlendMode(
    srcColorFactor: BlendFactor,
    dstColorFactor: BlendFactor,
    colorOperation: BlendOperation,
    srcAlphaFactor: BlendFactor,
    dstAlphaFactor: BlendFactor,
    alphaOperation: BlendOperation,
) callconv(.c) BlendMode;

pub const composeCustomBlendMode = SDL_ComposeCustomBlendMode;
