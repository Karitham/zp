const std = @import("std");

pub fn main() anyerror!void {
    var out_buf: [2048]u8 = undefined;
    var fbs = std.io.fixedBufferStream(&out_buf);
    var writer = fbs.writer();

    var buf: [512]u8 = undefined;
    var pwd = try std.os.getcwd(&buf);

    try writer.writeAll("\x1B[1m\x1B[36m.");
    try writer.writeAll(split_path(pwd));
    try writer.writeAll("\x1B[0m");

    if (git_branch(std.fs.cwd())) |branch| {
        try writer.writeAll(" on \x1B[1m\x1B[35m ");
        try writer.writeAll(branch);
        try writer.writeAll("\x1B[0m");
    }
    try writer.writeAll("\x1B[1m\x1B[32m >> \x1B[0m");

    try std.io.getStdOut().writeAll(fbs.getWritten());
}

fn split_path(path: []u8) []const u8 {
    const it = std.mem.lastIndexOf(u8, path, "/");
    if (it) |it1| {
        const it2 = std.mem.lastIndexOf(u8, path[0..it1], "/");
        if (it2) |it3| {
            return path[it3..];
        }
        return path[it1..];
    }
    return path;
}

fn git_branch(d: std.fs.Dir) ?[]u8 {
    const f = d.openFile(".git/HEAD", .{}) catch |err| {
        if (err == std.fs.File.OpenError.FileNotFound) {
            // HACK: We don't want to recurse in root. Haven't found a better way.
            var out_buf: [1]u8 = undefined;
            if (std.mem.eql(u8, d.realpath("../", &out_buf) catch "", "/")) return null;

            var nd = d.openDir("../", .{}) catch return null;
            defer nd.close();
            return git_branch(nd);
        }
        return null;
    };
    defer f.close();

    var buf: [1024]u8 = undefined;
    const size = f.readAll(&buf) catch return null;
    if (std.mem.startsWith(u8, buf[0..size], "ref: refs/heads/")) return buf[16 .. size - 1]; //newline

    return null;
}

test "git branch" {
    const expect = std.testing.expect;

    const branch = git_branch(std.fs.cwd());
    try expect(branch != null);
    try expect(branch.?.len > 2);

    // ensure we don't crash by recursively checking for .git folders
    var root = try std.fs.openDirAbsolute("/dev", .{});
    defer root.close();
    try expect(git_branch(root) == null);
}

test "bench" {
    const time = std.time;

    if (std.os.getenv("BENCH")) |_| {
        const start = time.milliTimestamp();
        var i: usize = 0;
        while (i < 1000) : (i += 1) {
            try main();
        }
        const end = time.milliTimestamp();
        std.debug.print("took {} ms\n", .{end - start});
    }
}
