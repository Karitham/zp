const std = @import("std");

pub fn main() anyerror!void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var buf: [512]u8 = undefined;
    const pwd = try std.os.getcwd(buf[0..]);
    var writer = std.io.getStdOut().writer();

    try writer.writeAll("\x1B[1m\x1B[36m./");
    try writer.writeAll(split_path(pwd));
    try writer.writeAll("\x1B[0m");

    if (git_branch(gpa.allocator()) catch null) |branch| {
        try writer.writeAll(" on \x1B[1m\x1B[35m");
        try writer.writeAll(branch);
        try writer.writeAll("\x1B[0m");
    }
    try writer.writeAll("\x1B[1m\x1B[32m >> \x1B[0m");
}

fn split_path(path: []u8) []const u8 {
    var it = std.mem.split(u8, path, "/");
    var last: []const u8 = undefined;
    while (it.next()) |n| {
        last = n;
    }

    return last;
}

fn git_branch(alloc: std.mem.Allocator) !?[]u8 {
    var proc = try std.ChildProcess.init(&.{ "git", "branch", "--show-current" }, alloc);
    defer proc.deinit();

    proc.stdout_behavior = .Pipe;
    proc.stderr_behavior = .Ignore;
    try proc.spawn();

    if (proc.stdout) |stdout| {
        var buf: [512]u8 = undefined;
        const n = try stdout.reader().readUntilDelimiterOrEof(buf[0..], '\n');
        _ = try proc.wait();
        return n;
    }
    _ = try proc.kill();
    return null;
}

test "basic test" {
    var alloc = std.testing.allocator;
    var branch = try git_branch(alloc);
    try std.testing.expect(branch != null);
    try std.testing.expect(branch.?.len > 2);
    // try std.testing.expectEqualSlices(u8, "master", branch.?);
}
