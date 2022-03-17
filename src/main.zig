const std = @import("std");

pub fn main() anyerror!void {
    var buf: [512]u8 = undefined;
    const pwd = try std.os.getcwd(buf[0..]);
    var writer = std.io.getStdOut().writer();

    try writer.writeAll("\x1B[1m\x1B[36m.");
    try writer.writeAll(split_path(pwd));
    try writer.writeAll("\x1B[0m");

    if (git_branch(std.fs.cwd())) |branch| {
        try writer.writeAll(" on \x1B[1m\x1B[35m ");
        try writer.writeAll(branch);
        try writer.writeAll("\x1B[0m");
    }
    try writer.writeAll("\x1B[1m\x1B[32m >> \x1B[0m");
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
            var nd = d.openDir("../", .{}) catch return null;
            defer nd.close();
            return git_branch(nd);
        }
        return null;
    };
    defer f.close();

    var buf: [1024]u8 = undefined;
    const size = f.readAll(buf[0..]) catch return null;
    if (std.mem.startsWith(u8, buf[0..size], "ref: refs/heads/")) return buf[16 .. size - 1]; //newline

    return null;
}

test "git branch" {
    var branch = git_branch(std.fs.cwd());
    try std.testing.expect(branch != null);
    try std.testing.expect(branch.?.len > 2);
    // try std.testing.expectEqualSlices(u8, "master", branch.?);
}
