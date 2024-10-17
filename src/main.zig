const std = @import("std");

fn getOsName() ![]const u8 {
    const os = @import("builtin").os;

    return switch (os.tag) {
        .linux => try getLinuxDistribution(),
        .macos => "macOS",
        .freebsd => "FreeBSD",
        .freestanding => "freestanding",
        .ananas => "ananas",
        .cloudabi => "cloudabi",
        .dragonfly => "dragonfly",
        .fuchsia => "fuchsia",
        .ios => "ios",
        .kfreebsd => "kfreebsd",
        .lv2 => "lv2",
        .netbsd => "netbsd",
        .openbsd => "openbsd",
        .solaris => "solaris",
        .uefi => "uefi",
        .zos => "zos",
        .haiku => "haiku",
        .minix => "minix",
        .rtems => "rtems",
        .nacl => "nacl",
        .aix => "aix",
        .cuda => "cuda",
        .nvcl => "nvcl",
        .amdhsa => "amdhsa",
        .ps4 => "ps4",
        .ps5 => "ps5",
        .elfiamcu => "elfiamcu",
        .tvos => "tvos",
        .watchos => "watchos",
        .driverkit => "driverkit",
        .visionos => "visionos",
        .mesa3d => "mesa3d",
        .contiki => "contiki",
        .amdpal => "amdpal",
        .hermit => "hermit",
        .hurd => "hurd",
        .wasi => "wasi",
        .emscripten => "emscripten",
        .shadermodel => "shadermodel",
        .liteos => "liteos",
        .serenity => "serenity",
        .opencl => "opencl",
        .glsl450 => "glsl450",
        .vulkan => "vulkan",
        .plan9 => "plan9",
        .illumos => "illumos",
        .other => "other",
        else => "Unknown OS",
    };
}

fn getLinuxDistribution() ![]const u8 {
    const file = try std.fs.cwd().openFile("/etc/os-release", .{});

    var buffer: [1024]u8 = undefined;

    const read_bytes = try file.readAll(buffer[0..]);

    var os_release = std.mem.tokenizeAny(u8, buffer[0..read_bytes], "\n");
    while (os_release.next()) |line| {
        if (std.mem.startsWith(u8, line, "ID=")) {
            return line[3..];
        }
    }
    return "Unknown Linux";
}

fn getCPUModelAndArch() ![]const u8 {
    const file = try std.fs.cwd().openFile("/proc/cpuinfo", .{});
    var buffer: [4096]u8 = undefined;
    const read_bytes = try file.readAll(buffer[0..]);

    var lines = std.mem.tokenizeAny(u8, buffer[0..read_bytes], "\n");

    while (lines.next()) |line| {
        if (std.mem.startsWith(u8, line, "model name")) {
            const colon_index = std.mem.indexOf(u8, line, ":") orelse return error.ColonNotFound;

            const model_name = std.mem.trim(u8, line[colon_index + 1 ..], " \t");

            return model_name;
        }
    }
    return error.CpuModelNotFound;
}

fn getArchitecture() ![]const u8 {
    const cpu = @import("builtin").target.cpu;
    return switch (cpu.arch) {
        .arm => "arm",
        .armeb => "armeb",
        .aarch64 => "aarch64",
        .aarch64_be => "aarch64_be",
        .aarch64_32 => "aarch64_32",
        .arc => "arc",
        .avr => "avr",
        .bpfel => "bpfel",
        .bpfeb => "bpfeb",
        .csky => "csky",
        .dxil => "dxil",
        .hexagon => "hexagon",
        .loongarch32 => "loongarch32",
        .loongarch64 => "loongarch64",
        .m68k => "m68k",
        .mips => "mips",
        .mipsel => "mipsel",
        .mips64 => "mips64",
        .mips64el => "mips64el",
        .msp430 => "msp430",
        .powerpc => "powerpc",
        .powerpcle => "powerpcle",
        .powerpc64 => "powerpc64",
        .powerpc64le => "powerpc64le",
        .r600 => "r600",
        .amdgcn => "amdgcn",
        .riscv32 => "riscv32",
        .riscv64 => "riscv64",
        .sparc => "sparc",
        .sparc64 => "sparc64",
        .sparcel => "sparcel",
        .s390x => "s390x",
        .tce => "tce",
        .tcele => "tcele",
        .thumb => "thumb",
        .thumbeb => "thumbeb",
        .x86 => "x86",
        .x86_64 => "x86_64",
        .xcore => "xcore",
        .xtensa => "xtensa",
        .nvptx => "nvptx",
        .nvptx64 => "nvptx64",
        .le32 => "le32",
        .le64 => "le64",
        .amdil => "amdil",
        .amdil64 => "amdil64",
        .hsail => "hsail",
        .hsail64 => "hsail64",
        .spir => "spir",
        .spir64 => "spir64",
        .spirv => "spirv",
        .spirv32 => "spirv32",
        .spirv64 => "spirv64",
        .kalimba => "kalimba",
        .shave => "shave",
        .lanai => "lanai",
        .wasm32 => "wasm32",
        .wasm64 => "wasm64",
        .renderscript32 => "renderscript32",
        .renderscript64 => "renderscript64",
        .ve => "ve",
        .spu_2 => "spu_2",
    };
}

fn getUptime() ![]const u8 {
    const allocator = std.heap.page_allocator;
    var buffer: [256]u8 = undefined;
    const uptime_file = try std.fs.openFileAbsolute("/proc/uptime", .{ .mode = .read_only });
    defer uptime_file.close();
    const bytes_read = try uptime_file.readAll(&buffer);
    const uptime_str = std.mem.trim(u8, buffer[0..bytes_read], &std.ascii.whitespace);

    var uptime_parts = std.mem.split(u8, uptime_str, " ");
    const uptime_seconds_str = uptime_parts.next() orelse return error.InvalidUptimeFormat;

    const uptime_seconds = std.fmt.parseFloat(f64, uptime_seconds_str) catch |err| {
        std.debug.print("Failed to parse uptime: {}\n", .{err});
        return allocator.dupe(u8, "Unknown");
    };

    const days = @floor(uptime_seconds / (24 * 60 * 60));
    const hours = @floor(@mod(uptime_seconds, 24 * 60 * 60) / (60 * 60));
    const minutes = @floor(@mod(uptime_seconds, 60 * 60) / 60);

    return std.fmt.allocPrint(allocator, "{d} days, {d} hours, {d} minutes", .{ days, hours, minutes });
}

fn getShell() ![]const u8 {
    const allocator = std.heap.page_allocator;
    if (std.process.getEnvVarOwned(allocator, "SHELL")) |shell| {
        return shell;
    } else |_| {
        return "Unknown";
    }
}

fn getUsername() ![]const u8 {
    const allocator = std.heap.page_allocator;

    if (std.process.getEnvVarOwned(allocator, "USER")) |user| {
        return user;
    } else |_| {
        if (std.process.getEnvVarOwned(allocator, "USERNAME")) |user| {
            return user;
        } else |_| {
            return "Unknown";
        }
    }
}

fn getHostname() ![]const u8 {
    const allocator = std.heap.page_allocator;
    const file = std.fs.openFileAbsolute("/etc/hostname", .{ .mode = .read_only }) catch |err| {
        std.debug.print("Failed to open /etc/hostname: {}\n", .{err});
        return "Unknown";
    };
    defer file.close();

    var buffer: [256]u8 = undefined;
    const bytes_read = try file.readAll(&buffer);
    const hostname = std.mem.trim(u8, buffer[0..bytes_read], &std.ascii.whitespace);
    return try allocator.dupe(u8, hostname);
}

pub fn main() !void {
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    try stdout.print("**********NERD**FETCH****************\n", .{});

    const username = try getUsername();
    defer allocator.free(username);
    const hostname = try getHostname();
    defer allocator.free(hostname);
    try stdout.print("User: {s}@{s}\n", .{ username, hostname });

    const os_name = try getOsName();
    try stdout.print("OS: {s}\n", .{os_name});

    // const uptime = getUptime() catch |err| {
    //     std.debug.print("Error getting uptime: {}\n", .{err});
    //     try allocator.free(try allocator.dupe(u8, "Unknown"));
    //     return;
    // };
    // defer allocator.free(uptime);
    // try stdout.print("Uptime: {s}\n", .{uptime});

    const shell = try getShell();
    defer allocator.free(shell);
    try stdout.print("Shell: {s}\n", .{shell});

    const cpu_model_name = try getCPUModelAndArch();
    try stdout.print("CPU: {s}\n", .{cpu_model_name});

    const cpu_architecture = try getArchitecture();
    try stdout.print("CPU Arch: {s}\n", .{cpu_architecture});

    // const memory_usage = try getMemoryUsage();
    // defer allocator.free(memory_usage);
    // try stdout.print("Memory: {s}\n", .{memory_usage});
    //
    // const local_ip = try getLocalIPAddress();
    // defer allocator.free(local_ip);
    // try stdout.print("Local IP: {s}\n", .{local_ip});
}
