const std = @import("std");
const pkgs = @import("deps.zig").pkgs;

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zp", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);
    addLibGit(exe);
    pkgs.addAllTo(exe);
    exe.addPackage(glob);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);
    addLibGit(exe_tests);
    pkgs.addAllTo(exe_tests);
    exe_tests.addPackage(glob);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}

pub fn addLibGit(exe: *std.build.LibExeObjStep) void {
    exe.linkLibC();
    exe.linkSystemLibrary("git2");
}

const glob = std.build.Pkg{
    .name = "glob",
    .source = std.build.FileSource{
        .path = "./lib/mattnite-glob/src/main.zig",
    },
};
