const std = @import("std");
const Allocator = std.mem.Allocator;
const vk = @import("vk.zig");
const Device = vk.DeviceProxy;

allocator: Allocator,
device: Device,
vertex_input_state: vk.PipelineVertexInputStateCreateInfo = .{
    .p_vertex_attribute_descriptions
},

const PipelineBuilder = @This();

pub fn init(allocator: Allocator, device: Device) PipelineBuilder {
    return .{
        .allocator = allocator,
        .device = device,
    };
}

pub fn build(self: PipelineBuilder) !vk.Pipeline {
    const pipeline: vk.Pipeline = undefined;

    const pipeline_create_info: vk.GraphicsPipelineCreateInfo = .{
        .p_vertex_input_state = &.{
        },
    };
    const result: vk.Result = self.device.createGraphicsPipelines(null, &.{ pipeline_create_info }, null, &.{ pipeline });
    if (result != .success) {
        return error.vkPipelineCreateFailure;
    }
    errdefer self.device.destroyPipeline(pipeline, null);

    return pipeline;
}

