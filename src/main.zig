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

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();
    try stdout.print("**********NERD**FETCH****************\n", .{});

    const os_name = try getOsName();
    try stdout.print("Operating System: {s}\n", .{os_name});

    const cpu_model_name = try getCPUModelAndArch();
    try stdout.print("CPU Model : {s}\n", .{cpu_model_name});

    const cpu_architecture = try getArchitecture();
    try stdout.print("CPU Architecture: {s}\n", .{cpu_architecture});
}
