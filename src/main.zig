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
        .freebsd => "freebsd",
        .fuchsia => "fuchsia",
        .ios => "ios",
        .kfreebsd => "kfreebsd",
        .linux => "linux",
        .lv2 => "lv2",
        .macos => "macos",
        .netbsd => "netbsd",
        .openbsd => "openbsd",
        .solaris => "solaris",
        .uefi => "uefi",
        .windows => "windows",
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

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("**********NERD**FETCH****************\n", .{});

    const os_name = try getOsName();
    try stdout.print("Operating System: {s}\n", .{os_name});
}
