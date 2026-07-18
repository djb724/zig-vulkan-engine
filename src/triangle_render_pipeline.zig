const std = @import("std");
const vk = @import("vk.zig");
const shaders = @import("shaders.zig");
const Device = vk.DeviceProxy;
const Allocator = std.mem.Allocator;

pub const PipelineResources = struct {
    pipeline: vk.Pipeline,
    render_pass: vk.RenderPass,
    layout: vk.PipelineLayout,

    pub fn helloTrianglePipeline(allocator: Allocator, io: std.Io, device: Device, extent: vk.Extent2D, format: vk.Format) !PipelineResources {
        const pipelines = try allocator.alloc(vk.Pipeline, 1);
        defer allocator.free(pipelines);

        const dynamic_states = &[_]vk.DynamicState{};
        const viewport = vk.Viewport{
            .x = 0.0,
            .y = 0.0,
            .height = @floatFromInt(extent.height),
            .width = @floatFromInt(extent.width),
            .min_depth = 0.0,
            .max_depth = 1.0,
        };
        const scissor = vk.Rect2D{
            .extent = extent,
            .offset = .{
                .x = 0.0,
                .y = 0.0,
            },
        };

        const layout = try device.createPipelineLayout(&vk.PipelineLayoutCreateInfo{
            .push_constant_range_count = 0,
            .p_push_constant_ranges = null,
            .set_layout_count = 0,
            .p_set_layouts = null,
        }, null);
        errdefer device.destroyPipelineLayout(layout, null);

        const attachment_ref: vk.AttachmentReference = .{
            .layout = .color_attachment_optimal,
            .attachment = 0,
        };
        const dependencies: []const vk.SubpassDependency = &.{};
        const attachments = &[_]vk.AttachmentDescription{
            .{
                .format = format,
                .samples = .{ .@"1_bit" = true },
                .load_op = .clear,
                .store_op = .store,
                .stencil_load_op = .dont_care,
                .stencil_store_op = .dont_care,
                .initial_layout = .undefined,
                .final_layout = .present_src_khr,
            },
        };
        const subpasses: []const vk.SubpassDescription = &.{
            .{
                .pipeline_bind_point = .graphics,
                .color_attachment_count = 1,
                .p_color_attachments = &.{attachment_ref},
                .p_depth_stencil_attachment = null,
                .input_attachment_count = 0,
                .p_input_attachments = null,
                .preserve_attachment_count = 0,
                .p_preserve_attachments = null,
                .p_resolve_attachments = null,
            },
        };

        const render_pass = try device.createRenderPass(&vk.RenderPassCreateInfo{
            .dependency_count = @intCast(dependencies.len),
            .p_dependencies = dependencies.ptr,
            .attachment_count = @intCast(attachments.len),
            .p_attachments = attachments.ptr,
            .subpass_count = @intCast(subpasses.len),
            .p_subpasses = subpasses.ptr,
        }, null);
        errdefer device.destroyRenderPass(render_pass, null);

        const color_blend_attachments = &[_]vk.PipelineColorBlendAttachmentState{
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

        const vert_shader = try shaders.loadShader(io, device, "triangle.vert.spv");
        defer device.destroyShaderModule(vert_shader, null);

        const frag_shader = try shaders.loadShader(io, device, "triangle.frag.spv");
        defer device.destroyShaderModule(frag_shader, null);

        const vertex_shader_stage: vk.PipelineShaderStageCreateInfo = .{ 
            .p_name = "main",
            .module = vert_shader,
            .p_specialization_info = null,
            .stage = .{ .vertex_bit = true },
        };
        const fragment_shader_stage: vk.PipelineShaderStageCreateInfo = .{
            .p_name = "main",
            .module = frag_shader,
            .stage = .{ .fragment_bit = true },
            .p_specialization_info = null,
        };

        const shader_stages: []const vk.PipelineShaderStageCreateInfo = &.{
            vertex_shader_stage,
            fragment_shader_stage,
        };

        const pipeline_create_info: vk.GraphicsPipelineCreateInfo = .{
            .p_vertex_input_state = &vk.PipelineVertexInputStateCreateInfo{
                .vertex_attribute_description_count = 0,
                .p_vertex_attribute_descriptions = null,
                .vertex_binding_description_count = 0,
                .p_vertex_binding_descriptions = null,
            },
            .p_input_assembly_state = &vk.PipelineInputAssemblyStateCreateInfo{
                .topology = .triangle_list,
                .primitive_restart_enable = .false,
            },
            .p_viewport_state = &vk.PipelineViewportStateCreateInfo{
                .viewport_count = 1,
                .p_viewports = &.{viewport},
                .scissor_count = 1,
                .p_scissors = &.{scissor},
            },
            .p_rasterization_state = &vk.PipelineRasterizationStateCreateInfo{
                .depth_bias_clamp = 0.0,
                .depth_bias_constant_factor = 0.0,
                .depth_bias_enable = .false,
                .depth_bias_slope_factor = 0.0,
                .depth_clamp_enable = .false,
                .front_face = .clockwise,
                .line_width = 1.0,
                .polygon_mode = .fill,
                .rasterizer_discard_enable = .false,
                .cull_mode = .{ .back_bit = true },
            },
            .p_multisample_state = &vk.PipelineMultisampleStateCreateInfo{
                .alpha_to_coverage_enable = .false,
                .alpha_to_one_enable = .false,
                .min_sample_shading = 1.0,
                .p_sample_mask = null,
                .rasterization_samples = .{ .@"1_bit" = true },
                .sample_shading_enable = .false,
            },
            .p_depth_stencil_state = null,
            .p_color_blend_state = &vk.PipelineColorBlendStateCreateInfo{
                .attachment_count = @intCast(color_blend_attachments.len),
                .p_attachments = color_blend_attachments.ptr,
                .blend_constants = .{
                    0.0,
                    0.0,
                    0.0,
                    0.0,
                },
                .logic_op = .copy,
                .logic_op_enable = .false,
            },
            .layout = layout,
            .render_pass = render_pass,
            .subpass = 0,
            .base_pipeline_index = 0,
            .base_pipeline_handle = .null_handle,
            .p_dynamic_state = &vk.PipelineDynamicStateCreateInfo{
                .dynamic_state_count = @intCast(dynamic_states.len),
                .p_dynamic_states = dynamic_states.ptr,
            },
            .p_tessellation_state = null,
            .stage_count = @intCast(shader_stages.len),
            .p_stages = shader_stages.ptr,
        };

        const result = try device.createGraphicsPipelines(.null_handle, &.{pipeline_create_info}, null, pipelines);
        if (result != .success) {
            return error.pipelineCreateFailed;
        }

        return .{
            .pipeline = pipelines[0],
            .render_pass = render_pass,
            .layout = layout,
        };
    }

    pub fn deinit(self: PipelineResources, device: Device) void {
        device.destroyRenderPass(self.render_pass, null);
        device.destroyPipelineLayout(self.layout, null);
        device.destroyPipeline(self.pipeline, null);
    }
};
