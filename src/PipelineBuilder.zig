const std = @import("std");
const Allocator = std.mem.Allocator;
const vk = @import("vk.zig");
const Device = vk.DeviceProxy;

const PipelineBuilder = @This();

const default_viewports = [_]vk.Viewport{
    .{
        .x = 0.0,
        .y = 0.0,
        .width = 1.0,
        .height = 1.0,
        .min_depth = 0.0,
        .max_depth = 1.0,
    },
};
const default_scissors = [_]vk.Rect2D{
    .{
        .offset = .{
            .x = 0,
            .y = 0,
        },
        .extent = .{
            .width = 1,
            .height = 1,
        },
    },
};

const default_color_blend_attachments = [_]vk.PipelineColorBlendAttachmentState{
    .{
        .alpha_blend_op = .add,
        .blend_enable = .false,
        .color_blend_op = .add,
        .color_write_mask = .{
            .r_bit = true,
            .g_bit = true,
            .b_bit = true,
            .a_bit = true,
        },
        .src_alpha_blend_factor = .one,
        .src_color_blend_factor = .one,
        .dst_alpha_blend_factor = .zero,
        .dst_color_blend_factor = .zero,
    },
};

fn shaderStageForModule(shader_module: vk.ShaderModule, stage: vk.ShaderStageFlags) vk.PipelineShaderStageCreateInfo {
    return .{
        .p_name = "main",
        .module = shader_module,
        .stage = stage,
        .p_specialization_info = null,
    };
}

allocator: Allocator,
io: std.Io,
device: Device,
p_next: ?*const anyopaque = null,
flags: vk.PipelineCreateFlags = .{},
vertex_shader: ?vk.PipelineShaderStageCreateInfo = null,
tessellation_control_shader: ?vk.PipelineShaderStageCreateInfo = null,
tessellation_evaluation_shader: ?vk.PipelineShaderStageCreateInfo = null,
geometry_shader: ?vk.PipelineShaderStageCreateInfo = null,
fragment_shader: ?vk.PipelineShaderStageCreateInfo = null,
task_shader: ?vk.PipelineShaderStageCreateInfo = null,
mesh_shader: ?vk.PipelineShaderStageCreateInfo = null,
vertex_binding_descriptions: []const vk.VertexInputBindingDescription = &.{},
vertex_attribute_descriptions: []const vk.VertexInputAttributeDescription = &.{},
input_assembly_state: vk.PipelineInputAssemblyStateCreateInfo = .{
    .topology = .triangle_list,
    .primitive_restart_enable = .false,
},
rasterization_state: vk.PipelineRasterizationStateCreateInfo = .{
    .depth_bias_enable = .false,
    .depth_bias_clamp = 0.0,
    .depth_bias_constant_factor = 0.0,
    .depth_bias_slope_factor = 0.0,
    .depth_clamp_enable = .false,
    .front_face = .clockwise,
    .line_width = 1.0,
    .polygon_mode = .fill,
    .rasterizer_discard_enable = .false,
    .cull_mode = .{ .back_bit = true },
},
tessellation_state: ?vk.PipelineTessellationStateCreateInfo = null,
viewports: []const vk.Viewport = &default_viewports,
scissors: []const vk.Rect2D = &default_scissors,
multisample_state: vk.PipelineMultisampleStateCreateInfo = .{
    .alpha_to_coverage_enable = .false,
    .alpha_to_one_enable = .false,
    .min_sample_shading = 1.0,
    .p_sample_mask = null,
    .rasterization_samples = .{ .@"1_bit" = true },
    .sample_shading_enable = .false,
},
depth_stencil_state: ?vk.PipelineDepthStencilStateCreateInfo = null,
color_blend_attachments: []const vk.PipelineColorBlendAttachmentState = &default_color_blend_attachments,
color_blend_state: vk.PipelineColorBlendStateCreateInfo = .{
    .attachment_count = 0,
    .p_attachments = null,
    .blend_constants = .{
        0.0,
        0.0,
        0.0,
        0.0,
    },
    .logic_op = .copy,
    .logic_op_enable = .false,
},
dynamic_states: []const vk.DynamicState = &.{},
dynamic_state: vk.PipelineDynamicStateCreateInfo = .{
    .dynamic_state_count = 0,
    .p_dynamic_states = null,
},
layout: vk.PipelineLayout = .null_handle,
render_pass: vk.RenderPass = .null_handle,
subpass: u32 = 0,
base_pipeline_handle: vk.Pipeline = .null_handle,
base_pipeline_index: i32 = -1,
pipeline_cache: vk.PipelineCache = .null_handle,

pub fn init(allocator: Allocator, io: std.Io, device: Device) PipelineBuilder {
    return .{
        .allocator = allocator,
        .io = io,
        .device = device,
    };
}

pub fn with_p_next(self: PipelineBuilder, p_next: ?*const anyopaque) PipelineBuilder {
    var builder = self;
    builder.p_next = p_next;
    return builder;
}

pub fn with_flags(self: PipelineBuilder, flags: vk.PipelineCreateFlags) PipelineBuilder {
    var builder = self;
    builder.flags = flags;
    return builder;
}

pub fn with_vertex_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.vertex_shader = shaderStageForModule(shader_module, .{ .vertex_bit = true });
    return builder;
}

pub fn with_tessellation_control_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.tessellation_control_shader = shaderStageForModule(shader_module, .{ .tessellation_control_bit = true });
    return builder;
}

pub fn with_tessellation_evaluation_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.tessellation_evaluation_shader = shaderStageForModule(shader_module, .{ .tessellation_evaluation_bit = true });
    return builder;
}

pub fn with_geometry_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.geometry_shader = shaderStageForModule(shader_module, .{ .geometry_bit = true });
    return builder;
}

pub fn with_fragment_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.fragment_shader = shaderStageForModule(shader_module, .{ .fragment_bit = true });
    return builder;
}

pub fn with_task_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.task_shader = shaderStageForModule(shader_module, .{ .task_bit_ext = true });
    return builder;
}

pub fn with_mesh_shader(self: PipelineBuilder, shader_module: vk.ShaderModule) PipelineBuilder {
    var builder = self;
    builder.mesh_shader = shaderStageForModule(shader_module, .{ .mesh_bit_ext = true });
    return builder;
}

pub fn with_vertex_binding_descriptions(self: PipelineBuilder, vertex_binding_descriptions: []const vk.VertexInputBindingDescription) PipelineBuilder {
    var builder = self;
    builder.vertex_binding_descriptions = vertex_binding_descriptions;
    return builder;
}

pub fn with_vertex_attribute_descriptions(self: PipelineBuilder, vertex_attribute_descriptions: []const vk.VertexInputAttributeDescription) PipelineBuilder {
    var builder = self;
    builder.vertex_attribute_descriptions = vertex_attribute_descriptions;
    return builder;
}

pub fn with_input_assembly_state(self: PipelineBuilder, input_assembly_state: vk.PipelineInputAssemblyStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.input_assembly_state = input_assembly_state;
    return builder;
}

pub fn with_rasterization_state(self: PipelineBuilder, rasterization_state: vk.PipelineRasterizationStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.rasterization_state = rasterization_state;
    return builder;
}

pub fn with_tessellation_state(self: PipelineBuilder, tessellation_state: ?vk.PipelineTessellationStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.tessellation_state = tessellation_state;
    return builder;
}

pub fn with_viewports(self: PipelineBuilder, viewports: []const vk.Viewport) PipelineBuilder {
    var builder = self;
    builder.viewports = viewports;
    return builder;
}

pub fn with_scissors(self: PipelineBuilder, scissors: []const vk.Rect2D) PipelineBuilder {
    var builder = self;
    builder.scissors = scissors;
    return builder;
}

pub fn with_multisample_state(self: PipelineBuilder, multisample_state: vk.PipelineMultisampleStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.multisample_state = multisample_state;
    return builder;
}

pub fn with_depth_stencil_state(self: PipelineBuilder, depth_stencil_state: ?vk.PipelineDepthStencilStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.depth_stencil_state = depth_stencil_state;
    return builder;
}

pub fn with_color_blend_attachments(self: PipelineBuilder, color_blend_attachments: []const vk.PipelineColorBlendAttachmentState) PipelineBuilder {
    self.color_blend_attachments = color_blend_attachments;
    return self;
}

pub fn with_color_blend_state(self: PipelineBuilder, color_blend_state: vk.PipelineColorBlendStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.color_blend_state = color_blend_state;
    return builder;
}

pub fn with_dynamic_states(self: PipelineBuilder, dynamic_states: []const vk.DynamicState) PipelineBuilder {
    var builder = self;
    builder.dynamic_states = dynamic_states;
    return builder;
}

pub fn with_dynamic_state(self: PipelineBuilder, dynamic_state: vk.PipelineDynamicStateCreateInfo) PipelineBuilder {
    var builder = self;
    builder.dynamic_state = dynamic_state;
    return builder;
}

pub fn with_layout(self: PipelineBuilder, layout: vk.PipelineLayout) PipelineBuilder {
    var builder = self;
    builder.layout = layout;
    return builder;
}

pub fn with_render_pass(self: PipelineBuilder, render_pass: vk.RenderPass) PipelineBuilder {
    var builder = self;
    builder.render_pass = render_pass;
    return builder;
}

pub fn with_subpass(self: PipelineBuilder, subpass: u32) PipelineBuilder {
    var builder = self;
    builder.subpass = subpass;
    return builder;
}

pub fn with_base_pipeline_handle(self: PipelineBuilder, base_pipeline_handle: vk.Pipeline) PipelineBuilder {
    var builder = self;
    builder.base_pipeline_handle = base_pipeline_handle;
    return builder;
}

pub fn with_base_pipeline_index(self: PipelineBuilder, base_pipeline_index: i32) PipelineBuilder {
    var builder = self;
    builder.base_pipeline_index = base_pipeline_index;
    return builder;
}

pub fn with_pipeline_cache(self: PipelineBuilder, pipeline_cache: vk.PipelineCache) PipelineBuilder {
    var builder = self;
    builder.pipeline_cache = pipeline_cache;
    return builder;
}

pub fn build(self: PipelineBuilder) !vk.Pipeline {
    const pipelines = try self.allocator.alloc(vk.Pipeline, 1);
    defer self.allocator.free(pipelines);

    var shader_stages: [7]vk.PipelineShaderStageCreateInfo = undefined;
    var shader_stage_count: usize = 0;
    if (self.vertex_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.tessellation_control_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.tessellation_evaluation_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.geometry_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.fragment_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.task_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }
    if (self.mesh_shader) |shader_stage| {
        shader_stages[shader_stage_count] = shader_stage;
        shader_stage_count += 1;
    }

    const vertex_input_state: vk.PipelineVertexInputStateCreateInfo = .{
        .vertex_binding_description_count = @intCast(self.vertex_binding_descriptions.len),
        .p_vertex_binding_descriptions = if (self.vertex_binding_descriptions.len == 0) null else self.vertex_binding_descriptions.ptr,
        .vertex_attribute_description_count = @intCast(self.vertex_attribute_descriptions.len),
        .p_vertex_attribute_descriptions = if (self.vertex_attribute_descriptions.len == 0) null else self.vertex_attribute_descriptions.ptr,
    };

    const viewport_state: vk.PipelineViewportStateCreateInfo = .{
        .viewport_count = @intCast(self.viewports.len),
        .p_viewports = if (self.viewports.len == 0) null else self.viewports.ptr,
        .scissor_count = @intCast(self.scissors.len),
        .p_scissors = if (self.scissors.len == 0) null else self.scissors.ptr,
    };

    var color_blend_state = self.color_blend_state;
    color_blend_state.attachment_count = @intCast(self.color_blend_attachments.len);
    color_blend_state.p_attachments = if (self.color_blend_attachments.len == 0) null else self.color_blend_attachments.ptr;

    var dynamic_state = self.dynamic_state;
    dynamic_state.dynamic_state_count = @intCast(self.dynamic_states.len);
    dynamic_state.p_dynamic_states = if (self.dynamic_states.len == 0) null else self.dynamic_states.ptr;

    const pipeline_create_info: vk.GraphicsPipelineCreateInfo = .{
        .p_next = self.p_next,
        .flags = self.flags,
        .stage_count = @intCast(shader_stage_count),
        .p_stages = if (shader_stage_count == 0) null else shader_stages[0..shader_stage_count].ptr,
        .p_vertex_input_state = &vertex_input_state,
        .p_input_assembly_state = &self.input_assembly_state,
        .p_tessellation_state = if (self.tessellation_state) |*state| state else null,
        .p_viewport_state = &viewport_state,
        .p_rasterization_state = &self.rasterization_state,
        .p_multisample_state = &self.multisample_state,
        .p_depth_stencil_state = if (self.depth_stencil_state) |*state| state else null,
        .p_color_blend_state = &color_blend_state,
        .p_dynamic_state = &dynamic_state,
        .layout = self.layout,
        .render_pass = self.render_pass,
        .subpass = self.subpass,
        .base_pipeline_handle = self.base_pipeline_handle,
        .base_pipeline_index = self.base_pipeline_index,
    };
    const result: vk.Result = try self.device.createGraphicsPipelines(self.pipeline_cache, &.{pipeline_create_info}, null, pipelines);
    if (result != .success) {
        return error.vkPipelineCreateFailure;
    }
    errdefer self.device.destroyPipeline(pipelines[0], null);

    return pipelines[0];
}
