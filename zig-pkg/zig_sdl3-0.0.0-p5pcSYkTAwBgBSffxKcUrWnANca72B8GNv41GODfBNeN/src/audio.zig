const std = @import("std");
const builtin = @import("builtin");

const SDL_AudioStream = opaque {};
const SDL_IOStream = opaque {};
pub const AudioStream = *SDL_AudioStream;
pub const IOStream = *SDL_IOStream;
pub const AudioDeviceId = u32;
pub const DEFAULT_PLAYBACK: AudioDeviceId = 0xffffffff;
pub const DEFAULT_RECORDING: AudioDeviceId = 0xfffffffe;
pub const MASK_BITSIZE: c_int = 0xff;
pub const MASK_FLOAT: c_int = 1 << 8;
pub const MASK_BIG_ENDIAN: c_int = 1 << 12;
pub const MASK_SIGNED: c_int = 1 << 15;
pub const PROP_AUDIOSTREAM_AUTO_CLEANUP_BOOLEAN = "SDL.audiostream.auto_cleanup";

pub const AudioFormat = packed struct(u16) {
    bitsize: u8,
    float: u4,
    bigendian: u3,
    signed: bool,

    pub fn toInt(self: AudioFormat) u16 {
        return @intFromEnum(self);
    }
    pub fn isInt(self: AudioFormat) bool {
        return self.float == 0;
    }
    pub fn isFloat(self: AudioFormat) bool {
        return self.float != 0;
    }
    pub fn isBigEndian(self: AudioFormat) bool {
        return self.bigendian != 0;
    }
    pub fn isLittleEndian(self: AudioFormat) bool {
        return self.bigendian == 0;
    }

    pub const unknown: AudioFormat = @bitCast(@as(u16, 0));
    pub const @"u8": AudioFormat = @bitCast(@as(u16, 0x0008));
    pub const s8: AudioFormat = @bitCast(@as(u16, 0x8008));
    pub const s16le: AudioFormat = @bitCast(@as(u16, 0x8010));
    pub const s16be: AudioFormat = @bitCast(@as(u16, 0x9010));
    pub const s32le: AudioFormat = @bitCast(@as(u16, 0x8020));
    pub const s32be: AudioFormat = @bitCast(@as(u16, 0x9020));
    pub const f32le: AudioFormat = @bitCast(@as(u16, 0x8120));
    pub const f32be: AudioFormat = @bitCast(@as(u16, 0x9120));

    pub const s16: AudioFormat = if (builtin.target.cpu.arch.endian() == .little) .s16le else .s16be;
    pub const s32: AudioFormat = if (builtin.target.cpu.arch.endian() == .little) .s32le else .s32be;
    pub const @"f32": AudioFormat = if (builtin.target.cpu.arch.endian() == .little) .f32le else .f32be;
};

pub const AudioSpec = extern struct {
    format: AudioFormat,
    channels: c_int,
    freq: c_int,
    pub fn frameSize(self: AudioSpec) c_int {
        return self.format.byteSize() * self.channels;
    }
};
pub const AudioDeviceFormat = struct {
    spec: AudioSpec,
    sample_frames: c_int,
};
pub const AudioStreamFormat = struct {
    src_spec: AudioSpec,
    dst_spec: AudioSpec,
};
pub const Wav = struct {
    spec: AudioSpec,
    data: []u8,
    pub fn deinit(self: Wav) void {
        SDL_free(self.data.ptr);
    }
};
pub const ConvertedAudio = struct {
    data: []u8,
    pub fn deinit(self: ConvertedAudio) void {
        SDL_free(self.data.ptr);
    }
};
pub const AudioStreamDataCompleteCallback = *const fn (userdata: ?*anyopaque, buf: *const anyopaque, buflen: c_int) callconv(.c) void;
pub const AudioStreamCallback = *const fn (userdata: ?*anyopaque, stream: AudioStream, additional_amount: c_int, total_amount: c_int) callconv(.c) void;
pub const AudioPostmixCallback = *const fn (userdata: ?*anyopaque, spec: *const AudioSpec, buffer: [*]f32, buflen: c_int) callconv(.c) void;

extern fn SDL_free(mem: ?*anyopaque) callconv(.c) void;
extern fn SDL_GetNumAudioDrivers() callconv(.c) c_int;
extern fn SDL_GetAudioDriver(index: c_int) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetCurrentAudioDriver() callconv(.c) ?[*:0]const u8;
extern fn SDL_GetAudioPlaybackDevices(count: ?*c_int) callconv(.c) ?[*]AudioDeviceId;
extern fn SDL_GetAudioRecordingDevices(count: ?*c_int) callconv(.c) ?[*]AudioDeviceId;
extern fn SDL_GetAudioDeviceName(devid: AudioDeviceId) callconv(.c) ?[*:0]const u8;
extern fn SDL_GetAudioDeviceFormat(devid: AudioDeviceId, spec: *AudioSpec, sample_frames: ?*c_int) callconv(.c) bool;
extern fn SDL_GetAudioDeviceChannelMap(devid: AudioDeviceId, count: ?*c_int) callconv(.c) ?[*]c_int;
extern fn SDL_OpenAudioDevice(devid: AudioDeviceId, spec: ?*const AudioSpec) callconv(.c) AudioDeviceId;
extern fn SDL_IsAudioDevicePhysical(devid: AudioDeviceId) callconv(.c) bool;
extern fn SDL_IsAudioDevicePlayback(devid: AudioDeviceId) callconv(.c) bool;
extern fn SDL_PauseAudioDevice(devid: AudioDeviceId) callconv(.c) bool;
extern fn SDL_ResumeAudioDevice(devid: AudioDeviceId) callconv(.c) bool;
extern fn SDL_AudioDevicePaused(devid: AudioDeviceId) callconv(.c) bool;
extern fn SDL_GetAudioDeviceGain(devid: AudioDeviceId) callconv(.c) f32;
extern fn SDL_SetAudioDeviceGain(devid: AudioDeviceId, gain: f32) callconv(.c) bool;
extern fn SDL_CloseAudioDevice(devid: AudioDeviceId) callconv(.c) void;
extern fn SDL_BindAudioStreams(devid: AudioDeviceId, streams: [*]const AudioStream, num_streams: c_int) callconv(.c) bool;
extern fn SDL_BindAudioStream(devid: AudioDeviceId, stream: AudioStream) callconv(.c) bool;
extern fn SDL_UnbindAudioStreams(streams: ?[*]const AudioStream, num_streams: c_int) callconv(.c) void;
extern fn SDL_UnbindAudioStream(stream: ?AudioStream) callconv(.c) void;
extern fn SDL_GetAudioStreamDevice(stream: AudioStream) callconv(.c) AudioDeviceId;
extern fn SDL_CreateAudioStream(src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) callconv(.c) ?AudioStream;
extern fn SDL_GetAudioStreamProperties(stream: AudioStream) callconv(.c) u32;
extern fn SDL_GetAudioStreamFormat(stream: AudioStream, src_spec: ?*AudioSpec, dst_spec: ?*AudioSpec) callconv(.c) bool;
extern fn SDL_SetAudioStreamFormat(stream: AudioStream, src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) callconv(.c) bool;
extern fn SDL_GetAudioStreamFrequencyRatio(stream: AudioStream) callconv(.c) f32;
extern fn SDL_SetAudioStreamFrequencyRatio(stream: AudioStream, ratio: f32) callconv(.c) bool;
extern fn SDL_GetAudioStreamGain(stream: AudioStream) callconv(.c) f32;
extern fn SDL_SetAudioStreamGain(stream: AudioStream, gain: f32) callconv(.c) bool;
extern fn SDL_GetAudioStreamInputChannelMap(stream: AudioStream, count: ?*c_int) callconv(.c) ?[*]c_int;
extern fn SDL_GetAudioStreamOutputChannelMap(stream: AudioStream, count: ?*c_int) callconv(.c) ?[*]c_int;
extern fn SDL_SetAudioStreamInputChannelMap(stream: AudioStream, chmap: ?[*]const c_int, count: c_int) callconv(.c) bool;
extern fn SDL_SetAudioStreamOutputChannelMap(stream: AudioStream, chmap: ?[*]const c_int, count: c_int) callconv(.c) bool;
extern fn SDL_PutAudioStreamData(stream: AudioStream, buf: *const anyopaque, len: c_int) callconv(.c) bool;
extern fn SDL_PutAudioStreamDataNoCopy(stream: AudioStream, buf: *const anyopaque, len: c_int, callback: ?AudioStreamDataCompleteCallback, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_PutAudioStreamPlanarData(stream: AudioStream, channel_buffers: [*]const ?*const anyopaque, num_channels: c_int, num_samples: c_int) callconv(.c) bool;
extern fn SDL_GetAudioStreamData(stream: AudioStream, buf: *anyopaque, len: c_int) callconv(.c) c_int;
extern fn SDL_GetAudioStreamAvailable(stream: AudioStream) callconv(.c) c_int;
extern fn SDL_GetAudioStreamQueued(stream: AudioStream) callconv(.c) c_int;
extern fn SDL_FlushAudioStream(stream: AudioStream) callconv(.c) bool;
extern fn SDL_ClearAudioStream(stream: AudioStream) callconv(.c) bool;
extern fn SDL_PauseAudioStreamDevice(stream: AudioStream) callconv(.c) bool;
extern fn SDL_ResumeAudioStreamDevice(stream: AudioStream) callconv(.c) bool;
extern fn SDL_AudioStreamDevicePaused(stream: AudioStream) callconv(.c) bool;
extern fn SDL_LockAudioStream(stream: AudioStream) callconv(.c) bool;
extern fn SDL_UnlockAudioStream(stream: AudioStream) callconv(.c) bool;
extern fn SDL_SetAudioStreamGetCallback(stream: AudioStream, callback: ?AudioStreamCallback, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_SetAudioStreamPutCallback(stream: AudioStream, callback: ?AudioStreamCallback, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_DestroyAudioStream(stream: AudioStream) callconv(.c) void;
extern fn SDL_OpenAudioDeviceStream(devid: AudioDeviceId, spec: ?*const AudioSpec, callback: ?AudioStreamCallback, userdata: ?*anyopaque) callconv(.c) ?AudioStream;
extern fn SDL_SetAudioPostmixCallback(devid: AudioDeviceId, callback: ?AudioPostmixCallback, userdata: ?*anyopaque) callconv(.c) bool;
extern fn SDL_LoadWAV_IO(src: IOStream, closeio: bool, spec: *AudioSpec, audio_buf: *?[*]u8, audio_len: *u32) callconv(.c) bool;
extern fn SDL_LoadWAV(path: [*:0]const u8, spec: *AudioSpec, audio_buf: *?[*]u8, audio_len: *u32) callconv(.c) bool;
extern fn SDL_MixAudio(dst: [*]u8, src: [*]const u8, format: AudioFormat, len: u32, volume: f32) callconv(.c) bool;
extern fn SDL_ConvertAudioSamples(src_spec: *const AudioSpec, src_data: [*]const u8, src_len: c_int, dst_spec: *const AudioSpec, dst_data: *?[*]u8, dst_len: *c_int) callconv(.c) bool;
extern fn SDL_GetAudioFormatName(format: AudioFormat) callconv(.c) [*:0]const u8;
extern fn SDL_GetSilenceValueForFormat(format: AudioFormat) callconv(.c) c_int;

pub const getNumAudioDrivers = SDL_GetNumAudioDrivers;
pub inline fn getAudioDriver(index: c_int) ![*:0]const u8 {
    return SDL_GetAudioDriver(index) orelse error.SDLError;
}
pub const getCurrentAudioDriver = SDL_GetCurrentAudioDriver;
fn copyDeviceIds(allocator: std.mem.Allocator, devices: ?[*]AudioDeviceId, count: c_int) ![]AudioDeviceId {
    const ids = devices orelse return error.SDLError;
    defer SDL_free(ids);
    const result = try allocator.alloc(AudioDeviceId, @intCast(count));
    @memcpy(result, ids[0..@intCast(count)]);
    return result;
}
pub inline fn getAudioPlaybackDevices(allocator: std.mem.Allocator) ![]AudioDeviceId {
    var count: c_int = 0;
    return copyDeviceIds(allocator, SDL_GetAudioPlaybackDevices(&count), count);
}
pub inline fn getAudioRecordingDevices(allocator: std.mem.Allocator) ![]AudioDeviceId {
    var count: c_int = 0;
    return copyDeviceIds(allocator, SDL_GetAudioRecordingDevices(&count), count);
}
pub inline fn getAudioDeviceName(devid: AudioDeviceId) ![*:0]const u8 {
    return SDL_GetAudioDeviceName(devid) orelse error.SDLError;
}
pub inline fn getAudioDeviceFormat(devid: AudioDeviceId) !AudioDeviceFormat {
    var spec: AudioSpec = undefined;
    var sample_frames: c_int = 0;
    if (!SDL_GetAudioDeviceFormat(devid, &spec, &sample_frames)) return error.SDLError;
    return .{ .spec = spec, .sample_frames = sample_frames };
}
fn copyChannelMap(allocator: std.mem.Allocator, map: ?[*]c_int, count: c_int) !?[]c_int {
    const channels = map orelse return null;
    defer SDL_free(channels);
    const result = try allocator.alloc(c_int, @intCast(count));
    @memcpy(result, channels[0..@intCast(count)]);
    return result;
}
pub inline fn getAudioDeviceChannelMap(allocator: std.mem.Allocator, devid: AudioDeviceId) !?[]c_int {
    var count: c_int = 0;
    return copyChannelMap(allocator, SDL_GetAudioDeviceChannelMap(devid, &count), count);
}
pub inline fn openAudioDevice(devid: AudioDeviceId, spec: ?*const AudioSpec) !AudioDeviceId {
    const result = SDL_OpenAudioDevice(devid, spec);
    if (result == 0) return error.SDLError;
    return result;
}
pub const isAudioDevicePhysical = SDL_IsAudioDevicePhysical;
pub const isAudioDevicePlayback = SDL_IsAudioDevicePlayback;
pub inline fn pauseAudioDevice(devid: AudioDeviceId) !void {
    if (!SDL_PauseAudioDevice(devid)) return error.SDLError;
}
pub inline fn resumeAudioDevice(devid: AudioDeviceId) !void {
    if (!SDL_ResumeAudioDevice(devid)) return error.SDLError;
}
pub const audioDevicePaused = SDL_AudioDevicePaused;
pub inline fn getAudioDeviceGain(devid: AudioDeviceId) !f32 {
    const gain = SDL_GetAudioDeviceGain(devid);
    if (gain < 0) return error.SDLError;
    return gain;
}
pub inline fn setAudioDeviceGain(devid: AudioDeviceId, gain: f32) !void {
    if (!SDL_SetAudioDeviceGain(devid, gain)) return error.SDLError;
}
pub const closeAudioDevice = SDL_CloseAudioDevice;
pub inline fn bindAudioStreams(devid: AudioDeviceId, streams: []const AudioStream) !void {
    if (!SDL_BindAudioStreams(devid, streams.ptr, @intCast(streams.len))) return error.SDLError;
}
pub inline fn bindAudioStream(devid: AudioDeviceId, stream: AudioStream) !void {
    if (!SDL_BindAudioStream(devid, stream)) return error.SDLError;
}
pub inline fn unbindAudioStreams(streams: []const AudioStream) void {
    SDL_UnbindAudioStreams(streams.ptr, @intCast(streams.len));
}
pub const unbindAudioStream = SDL_UnbindAudioStream;
pub inline fn getAudioStreamDevice(stream: AudioStream) ?AudioDeviceId {
    const device = SDL_GetAudioStreamDevice(stream);
    return if (device == 0) null else device;
}
pub inline fn createAudioStream(src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) !AudioStream {
    return SDL_CreateAudioStream(src_spec, dst_spec) orelse error.SDLError;
}
pub inline fn getAudioStreamProperties(stream: AudioStream) !u32 {
    const properties = SDL_GetAudioStreamProperties(stream);
    if (properties == 0) return error.SDLError;
    return properties;
}
pub inline fn getAudioStreamFormat(stream: AudioStream) !AudioStreamFormat {
    var src_spec: AudioSpec = undefined;
    var dst_spec: AudioSpec = undefined;
    if (!SDL_GetAudioStreamFormat(stream, &src_spec, &dst_spec)) return error.SDLError;
    return .{ .src_spec = src_spec, .dst_spec = dst_spec };
}
pub inline fn setAudioStreamFormat(stream: AudioStream, src_spec: ?*const AudioSpec, dst_spec: ?*const AudioSpec) !void {
    if (!SDL_SetAudioStreamFormat(stream, src_spec, dst_spec)) return error.SDLError;
}
pub inline fn getAudioStreamFrequencyRatio(stream: AudioStream) !f32 {
    const ratio = SDL_GetAudioStreamFrequencyRatio(stream);
    if (ratio == 0) return error.SDLError;
    return ratio;
}
pub inline fn setAudioStreamFrequencyRatio(stream: AudioStream, ratio: f32) !void {
    if (!SDL_SetAudioStreamFrequencyRatio(stream, ratio)) return error.SDLError;
}
pub inline fn getAudioStreamGain(stream: AudioStream) !f32 {
    const gain = SDL_GetAudioStreamGain(stream);
    if (gain < 0) return error.SDLError;
    return gain;
}
pub inline fn setAudioStreamGain(stream: AudioStream, gain: f32) !void {
    if (!SDL_SetAudioStreamGain(stream, gain)) return error.SDLError;
}
pub inline fn getAudioStreamInputChannelMap(allocator: std.mem.Allocator, stream: AudioStream) !?[]c_int {
    var count: c_int = 0;
    return copyChannelMap(allocator, SDL_GetAudioStreamInputChannelMap(stream, &count), count);
}
pub inline fn getAudioStreamOutputChannelMap(allocator: std.mem.Allocator, stream: AudioStream) !?[]c_int {
    var count: c_int = 0;
    return copyChannelMap(allocator, SDL_GetAudioStreamOutputChannelMap(stream, &count), count);
}
pub inline fn setAudioStreamInputChannelMap(stream: AudioStream, chmap: ?[]const c_int) !void {
    if (chmap) |map| {
        if (!SDL_SetAudioStreamInputChannelMap(stream, map.ptr, @intCast(map.len))) return error.SDLError;
    } else if (!SDL_SetAudioStreamInputChannelMap(stream, null, 0)) return error.SDLError;
}
pub inline fn setAudioStreamOutputChannelMap(stream: AudioStream, chmap: ?[]const c_int) !void {
    if (chmap) |map| {
        if (!SDL_SetAudioStreamOutputChannelMap(stream, map.ptr, @intCast(map.len))) return error.SDLError;
    } else if (!SDL_SetAudioStreamOutputChannelMap(stream, null, 0)) return error.SDLError;
}
pub inline fn putAudioStreamData(stream: AudioStream, data: []const u8) !void {
    if (!SDL_PutAudioStreamData(stream, data.ptr, @intCast(data.len))) return error.SDLError;
}
pub inline fn putAudioStreamDataNoCopy(stream: AudioStream, data: []const u8, callback: ?AudioStreamDataCompleteCallback, userdata: ?*anyopaque) !void {
    if (!SDL_PutAudioStreamDataNoCopy(stream, data.ptr, @intCast(data.len), callback, userdata)) return error.SDLError;
}
pub inline fn putAudioStreamPlanarData(stream: AudioStream, channel_buffers: []const ?*const anyopaque, num_samples: c_int) !void {
    if (!SDL_PutAudioStreamPlanarData(stream, channel_buffers.ptr, @intCast(channel_buffers.len), num_samples)) return error.SDLError;
}
pub inline fn getAudioStreamData(stream: AudioStream, buffer: []u8) !usize {
    const count = SDL_GetAudioStreamData(stream, buffer.ptr, @intCast(buffer.len));
    if (count < 0) return error.SDLError;
    return @intCast(count);
}
pub inline fn getAudioStreamAvailable(stream: AudioStream) !usize {
    const count = SDL_GetAudioStreamAvailable(stream);
    if (count < 0) return error.SDLError;
    return @intCast(count);
}
pub inline fn getAudioStreamQueued(stream: AudioStream) !usize {
    const count = SDL_GetAudioStreamQueued(stream);
    if (count < 0) return error.SDLError;
    return @intCast(count);
}
pub inline fn flushAudioStream(stream: AudioStream) !void {
    if (!SDL_FlushAudioStream(stream)) return error.SDLError;
}
pub inline fn clearAudioStream(stream: AudioStream) !void {
    if (!SDL_ClearAudioStream(stream)) return error.SDLError;
}
pub inline fn pauseAudioStreamDevice(stream: AudioStream) !void {
    if (!SDL_PauseAudioStreamDevice(stream)) return error.SDLError;
}
pub inline fn resumeAudioStreamDevice(stream: AudioStream) !void {
    if (!SDL_ResumeAudioStreamDevice(stream)) return error.SDLError;
}
pub const audioStreamDevicePaused = SDL_AudioStreamDevicePaused;
pub inline fn lockAudioStream(stream: AudioStream) !void {
    if (!SDL_LockAudioStream(stream)) return error.SDLError;
}
pub inline fn unlockAudioStream(stream: AudioStream) !void {
    if (!SDL_UnlockAudioStream(stream)) return error.SDLError;
}
pub inline fn setAudioStreamGetCallback(stream: AudioStream, callback: ?AudioStreamCallback, userdata: ?*anyopaque) !void {
    if (!SDL_SetAudioStreamGetCallback(stream, callback, userdata)) return error.SDLError;
}
pub inline fn setAudioStreamPutCallback(stream: AudioStream, callback: ?AudioStreamCallback, userdata: ?*anyopaque) !void {
    if (!SDL_SetAudioStreamPutCallback(stream, callback, userdata)) return error.SDLError;
}
pub const destroyAudioStream = SDL_DestroyAudioStream;
pub inline fn openAudioDeviceStream(devid: AudioDeviceId, spec: ?*const AudioSpec, callback: ?AudioStreamCallback, userdata: ?*anyopaque) !AudioStream {
    return SDL_OpenAudioDeviceStream(devid, spec, callback, userdata) orelse error.SDLError;
}
pub inline fn setAudioPostmixCallback(devid: AudioDeviceId, callback: ?AudioPostmixCallback, userdata: ?*anyopaque) !void {
    if (!SDL_SetAudioPostmixCallback(devid, callback, userdata)) return error.SDLError;
}
pub inline fn loadWavIo(src: IOStream, closeio: bool) !Wav {
    var spec: AudioSpec = undefined;
    var data: ?[*]u8 = null;
    var len: u32 = 0;
    if (!SDL_LoadWAV_IO(src, closeio, &spec, &data, &len)) return error.SDLError;
    return .{ .spec = spec, .data = data.?[0..len] };
}
pub inline fn loadWav(path: [:0]const u8) !Wav {
    var spec: AudioSpec = undefined;
    var data: ?[*]u8 = null;
    var len: u32 = 0;
    if (!SDL_LoadWAV(path.ptr, &spec, &data, &len)) return error.SDLError;
    return .{ .spec = spec, .data = data.?[0..len] };
}
pub inline fn mixAudio(dst: []u8, src: []const u8, format: AudioFormat, volume: f32) !void {
    if (dst.len < src.len) return error.SDLError;
    if (!SDL_MixAudio(dst.ptr, src.ptr, format, @intCast(src.len), volume)) return error.SDLError;
}
pub inline fn convertAudioSamples(src_spec: *const AudioSpec, src_data: []const u8, dst_spec: *const AudioSpec) !ConvertedAudio {
    var dst_data: ?[*]u8 = null;
    var dst_len: c_int = 0;
    if (!SDL_ConvertAudioSamples(src_spec, src_data.ptr, @intCast(src_data.len), dst_spec, &dst_data, &dst_len)) return error.SDLError;
    return .{ .data = dst_data.?[0..@intCast(dst_len)] };
}
pub const getAudioFormatName = SDL_GetAudioFormatName;
pub const getSilenceValueForFormat = SDL_GetSilenceValueForFormat;
