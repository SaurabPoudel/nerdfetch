const std = @import("std");

fn getOsName() []const u8 {
    const os = @import("builtin").os;

    switch (os.tag) {
        .linux => return "Linux",
        .macos => return "macOs",
        .windows => return "Windows",
        .freebsd => return "FreeBSD",
        else => return "Unknown OS",
    }
}

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("**********NERD**FETCH****************\n", .{});

    // OS
    const os_name = getOsName();
    try stdout.print("Operating System: {s} \n", .{os_name});
}
