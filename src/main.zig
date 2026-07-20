const std = @import("std");
const sdl = @import("sdl3");
const vk = @import("vk.zig");
const shaders = @import("shaders.zig");
const PipelineBuilder = @import("PipelineBuilder.zig");
const Instance = vk.InstanceProxy;
const Device = vk.DeviceProxy;

const print = std.debug.print;

pub fn main(init: std.process.Init) !void {
    const allocator = init.gpa;
    const io = init.io;

    try sdl.init(.{
        .audio = true,
        .events = true,
        .gamepad = true,
        .video = true,
    });
    defer sdl.quit();

    try sdl.vulkanLoadLibrary(null);
    defer sdl.vulkanUnloadLibrary();

    const extent: vk.Extent2D = .{
        .width = 1280,
        .height = 720,
    };

    const window = try sdl.createWindow("Game Engine", extent.width, extent.height, .{
        .always_on_top = true,
        .vulkan = true,
    });
    defer sdl.destroyWindow(window);

    const get_instance_proc_addr: vk.PfnGetInstanceProcAddr = @ptrCast(try sdl.vulkanGetVkGetInstanceProcAddr());
    const base_wrapper = vk.BaseWrapper.load(get_instance_proc_addr);

    const sdl_extensions = try sdl.vulkanGetInstanceExtensions();
    const enabled_layers: []const [*:0]const u8 = &.{
        "VK_LAYER_KHRONOS_validation",
    };

    var app_info = vk.ApplicationInfo{
        .s_type = .application_info,
        .p_application_name = "game1",
        .application_version = vk.makeApiVersion(0, 1, 0, 0).toU32(),
        .p_engine_name = "Custom Engine",
        .engine_version = vk.makeApiVersion(0, 1, 0, 0).toU32(),
        .api_version = vk.makeApiVersion(0, 1, 3, 0).toU32(),
    };
    const instance_create_info = vk.InstanceCreateInfo{
        .s_type = .instance_create_info,
        .p_application_info = &app_info,
        .enabled_layer_count = @intCast(enabled_layers.len),
        .pp_enabled_layer_names = enabled_layers.ptr,
        .enabled_extension_count = @intCast(sdl_extensions.len),
        .pp_enabled_extension_names = sdl_extensions.ptr,
    };

    const instance_handle = try base_wrapper.createInstance(&instance_create_info, null);
    var instance_wrapper = vk.InstanceWrapper.load(instance_handle, get_instance_proc_addr);
    const instance: Instance = .init(instance_handle, &instance_wrapper);
    defer instance.destroyInstance(null);

    // create vulkan surface
    const surface: vk.SurfaceKHR = @enumFromInt(@intFromPtr(try sdl.vulkan.createSurface(window, @ptrFromInt(@intFromEnum(instance.handle)), null)));
    defer sdl.vulkan.destroySurface(@ptrFromInt(@intFromEnum(instance.handle)), @ptrFromInt(@intFromEnum(surface)), null);

    const physical_devices = try instance.enumeratePhysicalDevicesAlloc(allocator);
    defer allocator.free(physical_devices);

    const physical_device_info = try allocator.alloc(PhysicalDeviceInfo, physical_devices.len);
    defer allocator.free(physical_device_info);

    const device_required_extensions: []const [*:0]const u8 = &.{
        "VK_KHR_swapchain",
    };

    for (physical_devices, 0..) |pd, i| {
        physical_device_info[i] = try getPhysicalDeviceInfo(instance, pd, allocator, surface, device_required_extensions);
    }
    var selected_pdinfo: ?*const PhysicalDeviceInfo = null;
    var max_score: i32 = std.math.minInt(i32);
    for (physical_device_info) |pdi| {
        if (pdi.score > max_score) {
            max_score = pdi.score;
            selected_pdinfo = &pdi;
        }
    }
    const selected_device = if (selected_pdinfo) |info| info else return error.NoViableDevice;

    const priority: [*]const f32 = &.{1.0};
    var device_queue_info: std.ArrayListUnmanaged(vk.DeviceQueueCreateInfo) = .empty;
    defer device_queue_info.deinit(allocator);
    const queue_families = selected_device.queue_families;
    if (queue_families.graphics == queue_families.presentation) {
        try device_queue_info.append(allocator, .{
            .queue_family_index = queue_families.graphics,
            .queue_count = 1,
            .p_queue_priorities = priority,
        });
    } else {
        try device_queue_info.append(allocator, .{
            .queue_family_index = queue_families.graphics,
            .queue_count = 1,
            .p_queue_priorities = priority,
        });
        try device_queue_info.append(allocator, .{
            .queue_family_index = queue_families.presentation,
            .queue_count = 1,
            .p_queue_priorities = priority,
        });
    }

    const device_handle = try instance.createDevice(selected_device.physical_device, &vk.DeviceCreateInfo{
        .s_type = .device_create_info,
        .p_next = null,
        .flags = .{},
        .enabled_extension_count = @intCast(device_required_extensions.len),
        .pp_enabled_extension_names = device_required_extensions.ptr,
        .enabled_layer_count = 0,
        .pp_enabled_layer_names = null,
        .queue_create_info_count = @intCast(device_queue_info.items.len),
        .p_queue_create_infos = device_queue_info.items.ptr,
        .p_enabled_features = &.{},
    }, null);
    const device_wrapper: vk.DeviceWrapper = .load(device_handle, instance.wrapper.dispatch.vkGetDeviceProcAddr.?);
    const device: Device = .init(device_handle, &device_wrapper);
    defer device.destroyDevice(null);

    const graphics_queue = device.getDeviceQueue(selected_device.queue_families.graphics, 0);
    const present_queue = device.getDeviceQueue(selected_device.queue_families.presentation, 0);

    // print("{} - {}\n", .{selected_device.surface_capabilities.min_image_count, selected_device.surface_capabilities.max_image_count});
    var image_count = selected_device.surface_capabilities.min_image_count + 1;
    if (selected_device.surface_capabilities.max_image_count > 0 and selected_device.surface_capabilities.max_image_count < image_count) {
        image_count = selected_device.surface_capabilities.max_image_count;
    }

    const swapchain_image_usage = (vk.ImageUsageFlags{
        .color_attachment_bit = true,
        .transfer_dst_bit = true,
    }).intersect(selected_device.surface_capabilities.supported_usage_flags);

    // swapchain
    var swapchain_create_info = vk.SwapchainCreateInfoKHR{
        .clipped = .true,
        .present_mode = selected_device.present_mode,
        .image_extent = extent,
        .image_array_layers = 1,
        .image_format = selected_device.surface_format.format,
        .image_color_space = selected_device.surface_format.color_space,
        .composite_alpha = .{ .opaque_bit_khr = true },
        .old_swapchain = .null_handle,
        .pre_transform = selected_device.surface_capabilities.current_transform,
        .image_usage = swapchain_image_usage,
        .surface = surface,
        .min_image_count = image_count,
        .image_sharing_mode = .exclusive,
        .queue_family_index_count = 0,
        .p_queue_family_indices = null,
    };
    if (selected_device.queue_families.graphics != selected_device.queue_families.presentation) {
        swapchain_create_info.image_sharing_mode = .concurrent;
        swapchain_create_info.queue_family_index_count = 2;
        swapchain_create_info.p_queue_family_indices = &.{
            selected_device.queue_families.graphics,
            selected_device.queue_families.presentation,
        };
    }
    const swapchain = try device.createSwapchainKHR(&swapchain_create_info, null);
    defer device.destroySwapchainKHR(swapchain, null);

    const swapchain_images = try device.getSwapchainImagesAllocKHR(swapchain, allocator);
    defer allocator.free(swapchain_images);

    const swapchain_image_views = try allocator.alloc(vk.ImageView, image_count);
    defer allocator.free(swapchain_image_views);
    defer for (swapchain_image_views) |view| {
        device.destroyImageView(view, null);
    };
    for (swapchain_images, 0..) |image, i| {
        swapchain_image_views[i] = try device.createImageView(&vk.ImageViewCreateInfo{
            .view_type = .@"2d",
            .format = selected_device.surface_format.format,
            .components = .{
                .r = .identity,
                .g = .identity,
                .b = .identity,
                .a = .identity,
            },
            .image = image,
            .subresource_range = .{
                .aspect_mask = .{ .color_bit = true },
                .base_mip_level = 0,
                .level_count = 1,
                .base_array_layer = 0,
                .layer_count = 1,
            },
        }, null);
    }

    const command_pool = try device.createCommandPool(&vk.CommandPoolCreateInfo{
        .queue_family_index = selected_device.queue_families.graphics,
        .flags = .{
            .reset_command_buffer_bit = true,
        },
    }, null);
    defer device.destroyCommandPool(command_pool, null);

    const dynamic_states = [_]vk.DynamicState{};
    const viewport = vk.Viewport{
        .x = 0.0,
        .y = 0.0,
        .height = @floatFromInt(extent.height),
        .width = @floatFromInt(extent.width),
        .min_depth = 0.0,
        .max_depth = 1.0,
    };
    const viewports = [_]vk.Viewport{viewport};
    const scissor = vk.Rect2D{
        .extent = extent,
        .offset = .{
            .x = 0,
            .y = 0,
        },
    };
    const scissors = [_]vk.Rect2D{scissor};

    const layout = try device.createPipelineLayout(&vk.PipelineLayoutCreateInfo{
        .push_constant_range_count = 0,
        .p_push_constant_ranges = null,
        .set_layout_count = 0,
        .p_set_layouts = null,
    }, null);
    defer device.destroyPipelineLayout(layout, null);

    const attachment_ref: vk.AttachmentReference = .{
        .layout = .color_attachment_optimal,
        .attachment = 0,
    };
    const dependencies: []const vk.SubpassDependency = &.{};
    const attachments = [_]vk.AttachmentDescription{
        .{
            .format = selected_device.surface_format.format,
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
        .p_attachments = &attachments,
        .subpass_count = @intCast(subpasses.len),
        .p_subpasses = subpasses.ptr,
    }, null);
    defer device.destroyRenderPass(render_pass, null);

    const vert_shader = try shaders.loadShader(io, device, "triangle.vert.spv");
    defer device.destroyShaderModule(vert_shader, null);

    const frag_shader = try shaders.loadShader(io, device, "triangle.frag.spv");
    defer device.destroyShaderModule(frag_shader, null);

    const graphics_pipeline = try PipelineBuilder.init(allocator, io, device)
        .with_vertex_shader(vert_shader)
        .with_fragment_shader(frag_shader)
        .with_viewports(&viewports)
        .with_scissors(&scissors)
        .with_dynamic_states(&dynamic_states)
        .with_layout(layout)
        .with_render_pass(render_pass)
        .with_subpass(0)
        .with_base_pipeline_index(0)
        .build();
    defer device.destroyPipeline(graphics_pipeline, null);

    // frame buffers and command buffers
    const frame_count: u32 = 2;
    var frame_index: u32 = 0;
    const command_buffers = try allocator.alloc(vk.CommandBuffer, frame_count);
    defer allocator.free(command_buffers);

    try device.allocateCommandBuffers(&vk.CommandBufferAllocateInfo{
        .command_pool = command_pool,
        .command_buffer_count = 2,
        .level = .primary,
    }, command_buffers.ptr);

    const frame_buffers = try allocator.alloc(vk.Framebuffer, image_count);
    defer allocator.free(frame_buffers);

    for (frame_buffers, 0..) |*buf, i| {
        buf.* = try device.createFramebuffer(&vk.FramebufferCreateInfo{
            .width = extent.width,
            .height = extent.height,
            .layers = 1,
            .render_pass = render_pass,
            .attachment_count = 1,
            .p_attachments = &.{swapchain_image_views[i]},
        }, null);
    }
    defer for (frame_buffers) |frame_buffer| device.destroyFramebuffer(frame_buffer, null);

    const image_available_semaphores = try allocator.alloc(vk.Semaphore, frame_count);
    defer allocator.free(image_available_semaphores);
    for (image_available_semaphores) |*semaphore| {
        semaphore.* = try device.createSemaphore(&.{}, null);
    }
    defer for (image_available_semaphores) |semaphore| device.destroySemaphore(semaphore, null);

    const render_finished_semaphores = try allocator.alloc(vk.Semaphore, image_count);
    defer allocator.free(render_finished_semaphores);
    for (render_finished_semaphores) |*semaphore| {
        semaphore.* = try device.createSemaphore(&.{}, null);
    }
    defer for (render_finished_semaphores) |semaphore| device.destroySemaphore(semaphore, null);

    const fences = try allocator.alloc(vk.Fence, frame_count);
    defer allocator.free(fences);
    for (fences) |*fence| {
        fence.* = try device.createFence(&vk.FenceCreateInfo{
            .flags = .{ .signaled_bit = true },
        }, null);
    }
    defer for (fences) |fence| device.destroyFence(fence, null);

    // main event loop
    const clock = std.Io.Clock.awake;
    const target_fps: f32 = 120.0;
    const target_frame_ns: i96 = @intFromFloat(1_000_000_000.0 / target_fps);

    var running = true;

    while (running) {
        const frame_start = std.Io.Clock.Timestamp.now(io, clock);
        const frame_deadline = frame_start.addDuration(.{
            .raw = std.Io.Duration.fromNanoseconds(target_frame_ns),
            .clock = clock,
        });

        while (sdl.pollEvent()) |event| {
            switch (event.type) {
                @intFromEnum(sdl.EventType.quit),
                @intFromEnum(sdl.EventType.window_close_requested),
                => running = false,
                else => {},
            }
        }

        frame_index = @mod(frame_index + 1, frame_count);
        const fence = fences[frame_index];
        const image_available_semaphore = image_available_semaphores[frame_index];
        const command_buffer = command_buffers[frame_index];

        _ = try device.waitForFences(&.{fence}, .true, std.math.maxInt(u64));
        try device.resetFences(&.{fence});

        const sii_result = try device.acquireNextImageKHR(
            swapchain,
            std.math.maxInt(u64),
            image_available_semaphore,
            .null_handle,
        );
        const swapchain_image_index = sii_result.image_index;
        const frame_buffer = frame_buffers[swapchain_image_index];
        const render_finished_semaphore = render_finished_semaphores[swapchain_image_index];

        try device.resetCommandBuffer(command_buffer, .{});
        try device.beginCommandBuffer(command_buffer, &vk.CommandBufferBeginInfo{
            .p_inheritance_info = null,
        });

        device.cmdBeginRenderPass(command_buffer, &vk.RenderPassBeginInfo{
            .render_pass = render_pass,
            .framebuffer = frame_buffer,
            .render_area = .{
                .extent = extent,
                .offset = .{
                    .x = 0,
                    .y = 0,
                },
            },
            .clear_value_count = 1,
            .p_clear_values = &[_]vk.ClearValue{
                .{
                    .color = .{ .float_32 = .{ 0.0, 0.0, 0.0, 1.0 } },
                },
            },
        }, .@"inline");

        device.cmdBindPipeline(command_buffer, vk.PipelineBindPoint.graphics, graphics_pipeline);
        // device.cmdSetViewport(command_buffer, 0, []vk.Viewport {
        //     .x = 0.0,
        //     .y = 0.0,
        //     .width = @floatFromInt(extent.width),
        //     .height = @floatFromInt(extent.height),
        //     .min_depth = 0.0,
        //     .max_depth = 0.0,
        // });
        device.cmdDraw(command_buffer, 3, 1, 0, 0);
        device.cmdEndRenderPass(command_buffer);

        try device.endCommandBuffer(command_buffer);

        const wait_stages = [_]vk.PipelineStageFlags{
            .{ .top_of_pipe_bit = true },
        };
        const submit_info = vk.SubmitInfo{
            .wait_semaphore_count = 1,
            .p_wait_semaphores = &.{image_available_semaphore},
            .p_wait_dst_stage_mask = &wait_stages,
            .command_buffer_count = 1,
            .p_command_buffers = &.{command_buffer},
            .signal_semaphore_count = 1,
            .p_signal_semaphores = &.{render_finished_semaphore},
        };
        try device.queueSubmit(graphics_queue, &.{submit_info}, fence);

        // TODO: proper error handling
        _ = try device.queuePresentKHR(present_queue, &vk.PresentInfoKHR{
            .wait_semaphore_count = 1,
            .p_wait_semaphores = &.{render_finished_semaphore},
            .swapchain_count = 1,
            .p_swapchains = &.{swapchain},
            .p_image_indices = &.{swapchain_image_index},
            .p_results = null,
        });

        const frame_end = std.Io.Clock.Timestamp.now(io, clock);
        try frame_deadline.wait(io);

        const delta = frame_start.durationTo(frame_end);
        const delta_ms = @as(f64, @floatFromInt(delta.raw.toNanoseconds())) / @as(f64, @floatFromInt(std.time.ns_per_ms));
        const fps = @as(f64, @floatFromInt(std.time.ns_per_s)) / @as(f64, @floatFromInt(delta.raw.toNanoseconds()));

        std.debug.print("  Game Engine | {d:.1} fps | {d:.2} ms\n\x1b[A", .{ fps, delta_ms });
    }

    try device.deviceWaitIdle();
}

const DeviceQueueFamilyIndeces = struct {
    graphics: u32,
    presentation: u32,
};

const PhysicalDeviceInfo = struct {
    physical_device: vk.PhysicalDevice,
    score: i32,
    queue_families: DeviceQueueFamilyIndeces,
    present_mode: vk.PresentModeKHR,
    surface_format: vk.SurfaceFormatKHR,
    surface_capabilities: vk.SurfaceCapabilitiesKHR,
    const Self = @This();
    pub fn isValid(self: Self) bool {
        return self.score > 0;
    }
    pub fn scoreCmp(_: void, lhs: Self, rhs: Self) bool {
        return rhs.score > lhs.score;
    }
};
fn getPhysicalDeviceInfo(
    instance: Instance,
    physical_device: vk.PhysicalDevice,
    allocator: std.mem.Allocator,
    surface: vk.SurfaceKHR,
    required_extensions: []const [*:0]const u8,
) !PhysicalDeviceInfo {
    var device_info: PhysicalDeviceInfo = .{
        .physical_device = physical_device,
        .score = 0,
        .queue_families = .{
            .graphics = undefined,
            .presentation = undefined,
        },
        .present_mode = undefined,
        .surface_format = undefined,
        .surface_capabilities = undefined,
    };
    const properties = instance.getPhysicalDeviceProperties(physical_device);
    switch (properties.device_type) {
        .discrete_gpu => device_info.score += 1000,
        .integrated_gpu => device_info.score += 100,
        else => {
            device_info.score = -1;
            return device_info;
        },
    }

    const supported_extensions = try instance.enumerateDeviceExtensionPropertiesAlloc(physical_device, null, allocator);
    defer allocator.free(supported_extensions);

    for (required_extensions) |req_ext| {
        var match: bool = false;
        for (supported_extensions) |sup_ext| {
            if (str_eq(sup_ext.extension_name, req_ext)) {
                match = true;
                break;
            }
        }
        if (!match) {
            device_info.score = -1;
            return device_info;
        }
    }

    // This might not be necessary at all
    const features = instance.getPhysicalDeviceFeatures(physical_device);
    if (features.geometry_shader == .false) {
        device_info.score = -1;
        return device_info;
    }

    const queue_families = try instance.getPhysicalDeviceQueueFamilyPropertiesAlloc(physical_device, allocator);
    defer allocator.free(queue_families);

    var graphics_family: ?u32 = null;
    var present_family: ?u32 = null;

    for (queue_families, 0..) |family, i| {
        const graphics_support = family.queue_flags.graphics_bit;
        const surface_support = try instance.getPhysicalDeviceSurfaceSupportKHR(physical_device, @intCast(i), surface);
        if (graphics_support and surface_support == .true) {
            graphics_family = @intCast(i);
            present_family = @intCast(i);
            break;
        }

        if (graphics_family == null and graphics_support) {
            graphics_family = @intCast(i);
        }

        if (present_family == null and surface_support == .true) {
            present_family = @intCast(i);
        }
    }
    if (graphics_family == null or present_family == null) {
        device_info.score = -1;
        return device_info;
    }
    device_info.queue_families = .{
        .graphics = graphics_family orelse unreachable,
        .presentation = present_family orelse unreachable,
    };
    if (graphics_family == present_family) {
        device_info.score += 10;
    }

    const present_modes = try instance.getPhysicalDeviceSurfacePresentModesAllocKHR(physical_device, surface, allocator);
    defer allocator.free(present_modes);
    if (present_modes.len == 0) {
        device_info.score = -1;
        return device_info;
    }
    var has_fifo = false;
    for (present_modes) |mode| {
        if (mode == .fifo_khr) {
            has_fifo = true;
        }
    }
    if (!has_fifo) {
        device_info.score = -1;
        return device_info;
    }
    device_info.present_mode = .fifo_khr;

    const surface_formats = try instance.getPhysicalDeviceSurfaceFormatsAllocKHR(physical_device, surface, allocator);
    defer allocator.free(surface_formats);
    if (surface_formats.len == 0) {
        device_info.score = -1;
        return device_info;
    }
    device_info.surface_format = surface_formats[0];

    device_info.surface_capabilities = try instance.getPhysicalDeviceSurfaceCapabilitiesKHR(physical_device, surface);

    return device_info;
}

fn str_eq(supported: [256]u8, required: [*:0]const u8) bool {
    const required_span = std.mem.span(required);
    for (required_span, 0..) |c, i| {
        if (supported[i] != c) {
            return false;
        }
    }
    return true;
}
