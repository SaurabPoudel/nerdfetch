const std = @import("std");

fn getOsName() ![]const u8 {
    const os = @import("builtin").os;

    return switch (os.tag) {
        .linux => try getLinuxDistribution(),
        .macos => "macOS",
        .windows => "Windows",
        .freebsd => "FreeBSD",
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
