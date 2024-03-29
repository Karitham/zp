const std = @import("std");
const term = @import("ansi-term");
const utils = @import("../utils.zig");
const mod = @import("../module.zig");

pub const module = mod.Module{ .name = "go", .print = print };

fn print(writer: anytype, ctx: *mod.Context) anyerror!void {
    var cwd = try std.fs.cwd().openIterableDir(".", .{});
    defer cwd.close();

    if (!try utils.containsAnyGlob(ctx.alloc, cwd, &.{ "go.mod", "*.go" })) return;

    const go_style = term.Style{
        .foreground = term.Color.Blue,
        .font_style = term.FontStyle.bold,
    };

    if (try getGoVersion(ctx.alloc)) |v| {
        defer ctx.alloc.free(v);
        try mod.updateStyle(writer, go_style, ctx.last_style);
        ctx.last_style = go_style;
        try writer.print(" 🐹 {s}", .{v});
    }
}

/// Returns the version of go if in path.
/// Caller owns returned memory.
fn getGoVersion(alloc: std.mem.Allocator) !?[]const u8 {
    var proc = std.ChildProcess.init(&.{ "go", "version" }, alloc);

    proc.stdout_behavior = .Pipe;

    try proc.spawn();
    if (proc.stdout) |stdout| {
        var big_buf: [512]u8 = undefined;
        if (try stdout.reader().readUntilDelimiterOrEof(&big_buf, '\n')) |buf| {
            _ = proc.wait() catch return null;

            const start_ind = std.mem.indexOf(u8, buf[0..], "go1.");
            const ind = std.mem.indexOfPos(u8, buf[0..], start_ind.?, " ");
            if (ind) |i| return try alloc.dupe(u8, buf[start_ind.?..i]);

            return try alloc.dupe(u8, buf[start_ind.?..]);
        }
    }

    _ = try proc.kill();
    return null;
}

test "get go version" {
    const v = try getGoVersion(std.testing.allocator);
    try std.testing.expect(v != null);
    defer std.testing.allocator.free(v.?);
}
